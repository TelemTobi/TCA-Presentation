//
//  Todos.swift
//  Demo
//
//  Created by Telem Tobi on 11/11/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct Todos {
    
    @ObservableState
    struct State: Equatable {
        var editMode: EditMode = .inactive
        var filter: Filter = .all
        var todos: IdentifiedArrayOf<Todo.State> = []
        var isUndoAvailable: Bool = false
        
        fileprivate var deletedTodos: IdentifiedArrayOf<Todo.State> = []
        
        var filteredTodos: IdentifiedArrayOf<Todo.State> {
            switch filter {
            case .all: todos
            case .active: todos.filter { !$0.isComplete }
            case .completed: todos.filter(\.isComplete)
            }
        }
    }
    
    enum Action: BindableAction, Sendable {
        case todos(IdentifiedActionOf<Todo>)
        case binding(BindingAction<State>)
        case onAddTodoButtonTap
        case onUndoButtonTap
        case delete(IndexSet)
        case move(IndexSet, Int)
        case disableUndo
        case sortCompletedTodos
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAddTodoButtonTap:
                state.todos.insert(Todo.State(id: uuid()), at: 0)
                return .none
                
            case .onUndoButtonTap:
                for todo in state.deletedTodos {
                    state.todos.updateOrInsert(todo, at: .zero)
                }
                state.deletedTodos.removeAll()
                state.isUndoAvailable = false
                return .cancel(id: CancelID.undo)
                
            case let .delete(indexSet):
                let filteredTodos = state.filteredTodos
                
                for index in indexSet {
                    let todo = filteredTodos[index]
                    state.todos.remove(id: todo.id)
                    state.deletedTodos.updateOrAppend(todo)
                }
                
                state.isUndoAvailable = true
                
                return .run { send in
                    try await clock.sleep(for: .seconds(5))
                    await send(.disableUndo)
                }
                .cancellable(id: CancelID.undo, cancelInFlight: true)
                
            case .disableUndo:
                state.isUndoAvailable = false
                return .none
                
            case var .move(source, destination):
                if state.filter == .completed {
                    source = IndexSet(
                        source
                            .map { state.filteredTodos[$0] }
                            .compactMap { state.todos.index(id: $0.id) }
                    )
                    
                    destination = if destination < state.filteredTodos.endIndex {
                        state.todos.index(id: state.filteredTodos[destination].id) ?? destination
                    } else {
                        state.todos.endIndex
                    }
                }
                
                state.todos.move(fromOffsets: source, toOffset: destination)
                
                return .send(.sortCompletedTodos)
                    .debounce(id: DebounceID.sort, for: .seconds(1), scheduler: mainQueue)
                
            case .sortCompletedTodos:
                state.todos.sort { $1.isComplete && !$0.isComplete }
                return .none
                
            case .todos(.element(id: _, action: .binding(\.isComplete))):
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(.sortCompletedTodos, animation: .default)
                }
                .cancellable(id: CancelID.todoCompletion, cancelInFlight: true)
                
            case .todos, .binding:
                return .none
            }
        }
        .forEach(\.todos, action: \.todos) {
            Todo()
        }
    }
}

extension Todos {
    enum Filter: LocalizedStringKey, CaseIterable, Hashable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
    }
    
    enum CancelID {
        case undo
        case todoCompletion
    }
    
    enum DebounceID {
        case sort
    }
}

struct TodosView: View {
    @Bindable var store: StoreOf<Todos>
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Picker("Filter", selection: $store.filter.animation()) {
                    ForEach(Todos.Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List {
                    ForEach(store.scope(state: \.filteredTodos, action: \.todos)) { store in
                        TodoView(store: store)
                    }
                    .onDelete { store.send(.delete($0)) }
                    .onMove { store.send(.move($0, $1)) }
                }
            }
            .navigationTitle("Todos")
            .toolbar(content: toolbarContent)
            .environment(\.editMode, $store.editMode)
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            EditButton()
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            HStack {
                if store.isUndoAvailable {
                    Button(
                        "Undo",
                        systemImage: "arrow.uturn.backward.circle.fill",
                        action: { store.send(.onUndoButtonTap, animation: .default)}
                    )
                }
                
                Button(
                    "Add Todo",
                    systemImage: "plus.circle.fill",
                    action: { store.send(.onAddTodoButtonTap, animation: .default)}
                )
            }
            .animation(.snappy, value: store.isUndoAvailable)
        }
    }
}

#Preview {
    TodosView(
        store: .init(
            initialState: Todos.State(),
            reducer: Todos.init
        )
    )
}

extension IdentifiedArrayOf<Todo.State> {
    static let mock: Self = [
        Todo.State(
            description: "Check Mail",
            id: UUID(),
            isComplete: false
        ),
        Todo.State(
            description: "Buy Milk",
            id: UUID(),
            isComplete: false
        ),
        Todo.State(
            description: "Call Mom",
            id: UUID(),
            isComplete: true
        ),
    ]
}
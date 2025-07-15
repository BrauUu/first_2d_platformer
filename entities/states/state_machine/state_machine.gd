class_name StateMachine extends Node

@export var initial_state : State

var states: Dictionary = {}
var stack: Array = []

func _ready() -> void:
	for child in get_children():
		if child is State:
			var state = child
			states[child.name.to_lower()] = state
			state.changed.connect(_on_state_changed)
			state.pushed.connect(push_state)
			state.popped.connect(pop_state)
			
	if initial_state:
		await get_tree().process_frame
		push_state(initial_state.name)

func push_state(state_name: String, params: Dictionary = {}) -> void:
	_push(state_name, params)

func pop_state() -> void:
	if stack.size() == 0:
		return
		
	var pop_state = stack.pop_back()
	pop_state.exit()
	
	if stack.size() > 0:
		stack.back().resume()

func _push(state_name: String, params: Dictionary = {}) -> void:
	if stack.size() > 0:
		stack.back().pause()
		
	var state: State = states.get(state_name.to_lower())
	
	if not state:
		return
		
	stack.push_back(state)
	state.enter(params)

func _physics_process(delta: float) -> void:
	if stack.size() > 0:
		stack.back().physics_update(delta)
		
func _process(delta: float) -> void:
	if stack.size() > 0:
		stack.back().update(delta)
		
func handle_input(event: InputEvent) -> void:
	if stack.size() > 0 :
		stack.back().handle_input(event)

func _on_state_changed(new_state_name: String, params: Dictionary = {}) -> void:
	while stack.size() > 0:
		stack.back().exit()
		stack.pop_back()
	_push(new_state_name, params)
	
func change_state(new_state_name: String, params: Dictionary = {}) -> void:
	_on_state_changed(new_state_name, params)

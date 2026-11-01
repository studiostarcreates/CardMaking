extends Node
class_name CardDragManager

const SCREEN_HEIGHT: int = 400
const SCREEN_WIDTH: int = 640

# Current state of card
# Dragging is for the short distance before arrow shows up
# Targeting is for when arrow is used
enum State {NONE, DRAGGING, TARGETING}
var state: State = State.NONE

# The distance from the bottom of the screen at which the target arrow shows up
const DRAG_THRESHOLD: float = 160

var card: CardClass

var hand_index: int

# The location where the card was initially at
var card_initial_position: Vector2

# The initial offset of the card before dragging
var card_start_offset: Vector2
var card_start_rotation: float

var valid_target: Node = null

# Arrow showing card's targeting
var arrow: TargetArrow

func _process(_delta: float) -> void:
	if state == State.DRAGGING:
		update_dragging()
	elif state == State.TARGETING:
		update_targeting()

# Called by card
func begin_drag(card: CardClass) -> void:
	
	# If something's already being dragged, ignore it
	if state != State.NONE:
		return
	
	# Set variables
	self.card = card
	state = State.DRAGGING
	card_initial_position = card.get_global_mouse_position()
	hand_index = card.get_index()
	card_start_offset = card.offset_transform_position
	card_start_rotation = card.offset_transform_rotation

# Called by card
func cancel_drag(card: CardClass) -> void:
	if card == self.card:
		if state == State.DRAGGING:
			end_drag_uncommitted()
		elif state == State.TARGETING:
			release_targeting()

func update_dragging() -> void:
	
	var mouse_pos: Vector2 = card.get_global_mouse_position()
	
	# Follow the mouse a while drag is active
	card.offset_transform_position = card_start_offset + (mouse_pos - card_initial_position)
	
	# If the card goes beyond the threshhold, enter target mode
	if mouse_pos.y <= SCREEN_HEIGHT - DRAG_THRESHOLD:
		enter_targeting_mode()

func enter_targeting_mode() -> void:
	state = State.TARGETING
	
	card.reparent(card.get_tree().current_scene, true)
	card.top_level = true 
	
	card.offset_transform_position = Vector2.ZERO
	card.offset_transform_rotation = 0.0
	card.global_position = Vector2(SCREEN_WIDTH / 2 - card.custom_minimum_size.x / 2, SCREEN_HEIGHT - DRAG_THRESHOLD)
	
	arrow = TargetArrow.new(card.card_stats.target_layer, card.global_position + card.custom_minimum_size / 2.0)
	add_child(arrow)

func end_drag_uncommitted() -> void:
	card.offset_transform_position = card_start_offset
	reset()

func update_targeting() -> void:
	if arrow:
		valid_target = arrow.update_arrow()

func release_targeting() -> void:
	
	if arrow:
		arrow.queue_free()
		arrow = null
	
	if valid_target != null:
		card.queue_free()
		
		var target: Node = valid_target.get_parent()
		
		if target is Enemy:
			target.take_damage(card.card_stats.card_value)
		elif target is Ally:
			target.gain_defense(card.card_stats.card_value)
	
	else:
		return_to_hand()
	
	reset()

func return_to_hand() -> void:
	
	card.top_level = false
	card.z_index = 0
	
	var hand_manager := card.get_tree().get_first_node_in_group("hand_manager") as HandManager
	
	card.reparent(hand_manager.hand_container)
	hand_manager.move_card_index(card, hand_index)

func reset() -> void:
	await get_tree().process_frame
	valid_target = null
	state = State.NONE
	card = null
	hand_index = -1

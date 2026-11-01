extends Control
class_name HandManager

const card_width: int = 96
const card_visual_width: int = 80
const card_height: int = 112

const screen_width: int = 640
const screen_height: int = 400

var cards: Array[CardClass]

var height_curve: Curve = load("res://hand/height_curve.tres")
var rotation_curve: Curve = load("res://hand/rotation_curve.tres")

@onready var hand_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	self.child_entered_tree.connect(_on_child_entered_tree)
	hand_container.child_exiting_tree.connect(_on_child_exited_tree)

func _on_child_entered_tree(node: Node) -> void:
	if node is CardClass:
		cards.append(node)
		node.reparent(hand_container)
		reset_cards.call_deferred()

func _on_child_exited_tree(node: Node) -> void:
	if node is CardClass:
		cards.erase(node)
		reset_cards.call_deferred()

func reset_cards() -> void:
	raise_cards()
	space_cards()
	rotate_cards()

const additional_height: int = 6

func raise_cards() -> void:
	
	if cards.size() <= 2:
		for card in cards:
			card.offset_transform_position.y = -additional_height / 2
	
	else:
		var spread_value: float = height_curve.max_domain / float(cards.size() - 1)
		
		for i in range(cards.size()):
			
			var curve_value: float = height_curve.sample(i * spread_value) * additional_height
			cards[i].offset_transform_position.y = -curve_value

const max_hand_size: int = 400

func space_cards() -> void:
	
	var num_overlaps: int = len(cards) - 1
	
	var default_seperation: int = -(card_width - card_visual_width)
	
	var hand_width: int = len(cards) * card_width + num_overlaps * default_seperation
	
	if hand_width > max_hand_size:
		default_seperation = floor(float(max_hand_size - len(cards) * card_width) / num_overlaps)
	
	hand_container.add_theme_constant_override("separation", default_seperation)

const max_rotation_degrees: int = 8

func rotate_cards() -> void:
	
	if cards.size() <= 2:
		for card in cards:
			card.offset_transform_rotation = deg_to_rad(0)
	
	else:
		
		var mid: float = (cards.size() - 1) / 2.0
		
		var mid_low: int = int(floor(mid))
		var mid_high: int = int(ceil(mid))
		
		var spread_value: float = rotation_curve.max_domain / float(cards.size() - 1)
		
		for i in range(cards.size()):
			
			if i == mid_low or i == mid_high:
				cards[i].offset_transform_rotation = deg_to_rad(0)
			
			else:
				cards[i].offset_transform_rotation = deg_to_rad(rotation_curve.sample(spread_value * i) * max_rotation_degrees)

func move_card_index(card: CardClass, new_index: int) -> void:
	
	hand_container.move_child(card, new_index)
	
	cards.clear()
	for node in hand_container.get_children():
		if node is CardClass:
			node.visible = true
			cards.append(node)
			reset_cards.call_deferred()

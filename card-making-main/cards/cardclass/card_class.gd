extends Control
class_name CardClass

var card_stats: CardStats

func _init(new_card_stats: CardStats) -> void:
	card_stats = new_card_stats

var card_frame: TextureRect = TextureRect.new()
var card_art: TextureRect = TextureRect.new()

var card_title: Label = Label.new()
var card_description: RichTextLabel = RichTextLabel.new()

var energy_cost_image: TextureRect = TextureRect.new()
var energy_cost_text: Label = Label.new()

var card_area: Area2D = Area2D.new()
var card_collision: CollisionShape2D = CollisionShape2D.new()
var card_shape: RectangleShape2D = RectangleShape2D.new()

signal card_played(card: CardClass, target: Node)
signal drag_started(card: CardClass)
signal drag_cancelled(card: CardClass)

func add_card_collision() -> void:
	
	add_child(card_area)
	card_area.add_child(card_collision)
	card_collision.shape = card_shape
	
	card_shape.size = Vector2(80, 112)
	card_area.position = card_stats.card_frame.get_size() / 2
	
	card_area.mouse_entered.connect(_on_mouse_entered)
	card_area.mouse_exited.connect(_on_mouse_exited)
	
	card_area.set_collision_layer_value(1, true)

func change_mouse_filters() -> void:
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_description.mouse_filter = Control.MOUSE_FILTER_IGNORE

var hovered: bool = false

func _on_mouse_entered() -> void:
	hovered = true
	scale = Vector2(1.1, 1.1)

func _on_mouse_exited() -> void:
	hovered = false
	scale = Vector2(1, 1)

func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and hovered:
				begin_drag()
			else:
				cancel_drag()

func set_card_size() -> void:
	offset_transform_enabled = true
	custom_minimum_size = card_stats.card_frame.get_size()
	pivot_offset = card_stats.card_frame.get_size() / 2

func create_visuals() -> void:
	
	card_frame.texture = card_stats.card_frame
	card_art.texture = card_stats.card_art
	
	add_child(card_frame)
	add_child(card_art)
	
	card_title.text = card_stats.card_name
	card_description.text = card_stats.card_description
	
	add_child(card_title)
	add_child(card_description)
	
	card_title.position = Vector2(0, 57)
	card_title.size = Vector2(96, 14)
	
	card_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	card_title.add_theme_font_size_override("font_size", 12)
	card_title.add_theme_font_override("font", load("res://cards/resources/custom_font.ttf"))
	
	card_description.position = Vector2(14, 73)
	card_description.size = Vector2(68, 30)
	
	card_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_description.add_theme_font_size_override("normal_font_size", 8)
	card_description.add_theme_font_override("normal_font", load("res://cards/resources/custom_font.ttf"))
	
	energy_cost_image.texture = card_stats.energy_art
	energy_cost_text.text = str(card_stats.energy)
	
	add_child(energy_cost_image)
	add_child(energy_cost_text)
	
	energy_cost_text.size = Vector2(32, 32)
	energy_cost_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	energy_cost_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	energy_cost_text.add_theme_font_override("font", load("res://cards/resources/custom_font.ttf"))
	energy_cost_text.add_theme_font_size_override("font_size", 20)

func _ready() -> void:
	add_card_collision()
	create_visuals()
	set_card_size()
	change_mouse_filters()

func begin_drag() -> void:
	DragManager.begin_drag(self)
 
func cancel_drag() -> void:
	DragManager.cancel_drag(self)

extends Node2D

func _ready() -> void:
	var card: CardClass = CardClass.new(load("uid://pt8dxc512d4w"))
	
	add_child(card)

func _on_button_pressed() -> void:
	var card: CardClass = CardClass.new(load("uid://pt8dxc512d4w"))
	$HandManager.add_child(card)
	
	var card2: CardClass = CardClass.new(load("uid://b6gykm4ts0wt3"))
	$HandManager.add_child(card2)

func _on_button_2_pressed() -> void:
	$HandManager/HBoxContainer.get_children()[0].queue_free()

extends Node2D
class_name TargetArrow

const GREY_COLOR: Color = Color(0.6, 0.6, 0.65)
const RED_COLOR: Color = Color(0.85, 0.15, 0.15)
const ARROW_WIDTH: float = 6.0
const HEAD_SIZE: float = 18.0

# Positions of start and end of arrow
var start: Vector2
var end: Vector2

var target_layer: int = 0

var current_color: Color = GREY_COLOR

func _init(target_layer: int, start_pos: Vector2) -> void:
	self.target_layer = target_layer
	start = start_pos

func _ready() -> void:
	z_index = 100

func _draw() -> void:
	
	end = get_global_mouse_position()
	
	# Calculate length / direction of arrow
	var local_start: Vector2 = to_local(start)
	var local_end: Vector2 = to_local(end)
	var direction: Vector2 = (local_end - local_start).normalized()
	var shaft_end: Vector2 = local_end - direction * HEAD_SIZE
	
	draw_line(local_start, shaft_end, current_color, ARROW_WIDTH, true)
	
	# Make arrow head
	var perpendicular: Vector2 = direction.rotated(PI / 2.0)
	var head_points := PackedVector2Array([
		local_end,
		shaft_end + perpendicular * (HEAD_SIZE * 0.6),
		shaft_end - perpendicular * (HEAD_SIZE * 0.6)
	])
	
	draw_colored_polygon(head_points, current_color)

func find_target_at(point: Vector2) -> Node:
	
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = point
	params.collide_with_areas = true
	params.collide_with_bodies = false
	params.collision_mask = 2 ** (target_layer - 1)
	
	var results: Array[Dictionary] = space_state.intersect_point(params)
	
	if results.is_empty():
		return null
	else:
		return results[0].collider

func update_arrow() -> Node:
	end = get_global_mouse_position()
	
	var found_target: Node = find_target_at(end)
	if found_target:
		current_color = RED_COLOR 
	else:
		current_color = GREY_COLOR
	
	queue_redraw()
	return found_target

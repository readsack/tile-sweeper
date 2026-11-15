extends CharacterBody2D


const SPEED = 300.0
const bounce_strength = 1
var max_drag_distance = 300;
var max_power = 300;
var drag_vector = Vector2.ZERO;
var can_shoot = false
var dragging = false
@export var tiles: Node2D
@export var next_level: PackedScene
@onready var aim_line = $Line2D

func update_aim_line():
	aim_line.clear_points()
	aim_line.add_point(Vector2.ZERO)
	aim_line.add_point(to_local(get_global_mouse_position()))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and can_shoot:
			if global_position.distance_to(get_global_mouse_position()) < 32:
				dragging = true
				print("begin drag")
		elif not event.pressed and dragging:
			print("shot")
			shoot()
	elif event is InputEventMouseMotion:
		if dragging:
			update_aim_line()
			print("dragging")
		drag_vector = global_position - get_global_mouse_position()
		if drag_vector.length() > max_drag_distance:
			drag_vector = drag_vector.normalized() * max_drag_distance
		
func shoot():
	dragging = false
	can_shoot = false
	aim_line.clear_points()
	print("shot")
	velocity = drag_vector.normalized() * (drag_vector.length() / max_drag_distance) * max_power
	drag_vector = Vector2.ZERO


func _ready() -> void:
	#velocity = Vector2(100, 100)
	can_shoot = true

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		$AudioStreamPlayer2D.play()
		velocity = velocity.bounce(collision.get_normal()) * bounce_strength
		var body = collision.get_collider()
		if body.is_in_group("platforms"):
			body.queue_free()
		if body.is_in_group("borders"):
			if tiles.get_child_count() == 0:
				get_tree().change_scene_to_packed(next_level)
			else: 
				get_tree().reload_current_scene()
		

# res://scripts/runner.gd
extends CharacterBody3D

@export var forward_speed: float = 15.0
@export var lane_shift: float = 0.5
@export var lane_change_speed: float = 10.0
@export var max_offset: float = 3.0
@export var jump_velocity: float = 6.32
@export var gravity: float = 20.0
@export var crouch_scale_y: float = 0.5
@export var crouch_speed: float = 10.0
@export var crouch_rotation_speed: float = 10.0
@export var crouch_depth: float = 2.0
@export var slide_back_distance: float = 1.0

var _target_x: float = 0.0
var _is_crouching: bool = false
var _wants_jump: bool = false
var _q_pressed_last_frame: bool = false
var _d_pressed_last_frame: bool = false
var _z_pressed_last_frame: bool = false
var _crouch_blend: float = 0.0  # 0 = debout, 1 = couché à fond

@onready var collision_shape: CollisionShape3D = get_node_or_null("CollisionShape3D")
@onready var anim_player: AnimationPlayer = get_node_or_null("Running2/AnimationPlayer")
@onready var mesh_root: Node3D = get_node_or_null("Running2")

var _original_shape_height: float = 0.0
var _original_shape_position_y: float = 0.0


func _ready() -> void:
	_target_x = position.x

	if collision_shape and collision_shape.shape is CapsuleShape3D:
		_original_shape_height = collision_shape.shape.height
		_original_shape_position_y = collision_shape.position.y

	print("Runner prêt. Position locale : ", position)


func _physics_process(delta: float) -> void:
	var q_now := Input.is_physical_key_pressed(KEY_Q) or Input.is_physical_key_pressed(KEY_A)
	var d_now := Input.is_physical_key_pressed(KEY_D)
	var z_now := Input.is_physical_key_pressed(KEY_Z) or Input.is_physical_key_pressed(KEY_W)

	if q_now and not _q_pressed_last_frame:
		change_lane(-2)
	if d_now and not _d_pressed_last_frame:
		change_lane(2)
	if z_now and not _z_pressed_last_frame:
		jump()

	_q_pressed_last_frame = q_now
	_d_pressed_last_frame = d_now
	_z_pressed_last_frame = z_now

	_is_crouching = Input.is_physical_key_pressed(KEY_S)
	_update_crouch(delta)

	var vel := velocity
	vel.z = -forward_speed

	var new_x := move_toward(position.x, _target_x, lane_change_speed * delta)
	vel.x = (new_x - position.x) / delta if delta > 0.0 else 0.0

	if is_on_floor():
		vel.y = jump_velocity if _wants_jump else 0.0
	else:
		vel.y -= gravity * delta

	_wants_jump = false

	velocity = vel
	move_and_slide()

	_update_animation()


func change_lane(direction: int) -> void:
	_target_x = clamp(_target_x + direction * lane_shift, -max_offset, max_offset)
	print(">>> Changement de voie -> target_x: ", _target_x)


func jump() -> void:
	if is_on_floor() and not _is_crouching:
		_wants_jump = true
		print(">>> Saut demandé")


func _update_crouch(delta: float) -> void:
	if collision_shape and collision_shape.shape is CapsuleShape3D:
		var target_height := _original_shape_height * crouch_scale_y if _is_crouching else _original_shape_height
		var target_pos_y := _original_shape_position_y - (_original_shape_height - target_height) * 0.5 if _is_crouching else _original_shape_position_y

		collision_shape.shape.height = move_toward(collision_shape.shape.height, target_height, crouch_speed * delta)
		collision_shape.position.y = move_toward(collision_shape.position.y, target_pos_y, crouch_speed * delta)

	if mesh_root:
		var target_blend := 1.0 if _is_crouching else 0.0
		_crouch_blend = move_toward(_crouch_blend, target_blend, crouch_rotation_speed * delta)

		mesh_root.rotation.x = deg_to_rad(180.0) * _crouch_blend
		mesh_root.position.y = -crouch_depth * _crouch_blend
		mesh_root.position.z = slide_back_distance * _crouch_blend


func _update_animation() -> void:
	if anim_player == null:
		return
	if not is_on_floor():
		if anim_player.has_animation("jump"):
			anim_player.play("jump")
	elif _is_crouching:
		if anim_player.has_animation("crouch"):
			anim_player.play("crouch")
	else:
		if anim_player.has_animation("mixamo_com"):
			anim_player.play("mixamo_com")

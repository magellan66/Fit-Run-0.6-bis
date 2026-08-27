# res://scripts/camera_follow.gd
extends Camera3D

@export var target_path: NodePath = NodePath("../Runner")
@export var offset: Vector3 = Vector3(0, 3, 3)
@export var follow_speed: float = 5.0
@export var fov_angle: float = 60.0  # Augmentez cette valeur pour voir plus large

var _target: Node3D

func _ready():
	_target = get_node(target_path)
	if _target == null:
		push_error("Camera: Runner non trouvé!")
	
	# Applique le FOV
	fov = fov_angle

func _process(delta: float) -> void:
	if _target == null:
		return

	var desired_position = _target.global_position + offset
	global_position = global_position.lerp(desired_position, follow_speed * delta)
	look_at(_target.global_position, Vector3.UP)

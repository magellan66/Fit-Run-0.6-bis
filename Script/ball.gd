# res://scripts/ball.gd
extends RigidBody3D

@export var forward_speed: float = 15.0    # vitesse constante d'avancée
@export var side_speed: float = 8.0        # vitesse latérale
@export var jump_impulse: float = 6.0

var _is_on_ground: bool = false

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_axis("ui_left", "ui_right")

	# On récupère la vélocité actuelle et on impose X et Z,
	# mais on garde Y intact (géré par la gravité/saut)
	var vel := linear_velocity
	vel.z = -forward_speed          # avance constante vers -Z
	vel.x = input_dir * side_speed  # contrôle latéral direct
	linear_velocity = vel

	if Input.is_action_just_pressed("ui_accept") and _is_on_ground:
		apply_central_impulse(Vector3(0, jump_impulse, 0))
		_is_on_ground = false


func _on_body_entered(_body: Node) -> void:
	_is_on_ground = true

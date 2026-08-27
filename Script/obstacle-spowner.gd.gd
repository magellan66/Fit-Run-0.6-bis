extends Node3D

@export var ronce_scene: PackedScene
@export var pilier_scene: PackedScene

# Colonnes possibles pour le pilier
@export var pilier_column_positions: Array[float] = [-1, 0.0, 1]

# Position fixe pour la ronce (colonne centrale)
@export var ronce_x_position: float = 0.0

@export var band_z_center: float = -995.0
@export var band_z_length: float = 1000.0
@export var spawn_y: float = 0.0

@export var min_spacing: float = 10
@export var max_spacing: float = 20.0

func _ready() -> void:
	spawn_obstacles()

func spawn_obstacles() -> void:
	var z_start = band_z_center - band_z_length / 2.0
	var z_end = band_z_center + band_z_length / 2.0
	var z = z_start
	var count = 0
	
	while z < z_end:
		spawn_random_obstacle_at(z)
		count += 1
		z += randf_range(min_spacing, max_spacing)
	
	print("Nombre d'obstacles spawnés : ", count)

func spawn_random_obstacle_at(z: float) -> void:
	var chosen_scene: PackedScene
	var x: float
	
	# Choix aléatoire du type d'obstacle
	if randi() % 2 == 0:
		chosen_scene = ronce_scene
		x = ronce_x_position  # Toujours au centre
	else:
		chosen_scene = pilier_scene
		x = pilier_column_positions[randi() % pilier_column_positions.size()]  # Aléatoire sur 3 colonnes
	
	if chosen_scene == null:
		push_warning("Une des scènes d'obstacle n'est pas assignée !")
		return
	
	var pos = Vector3(x, spawn_y, z)
	var obstacle_instance = chosen_scene.instantiate()
	obstacle_instance.position = pos
	add_child.call_deferred(obstacle_instance)

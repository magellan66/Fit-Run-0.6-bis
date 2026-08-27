extends Node3D

@export var tree_scene: PackedScene  # Assignez votre scène de cube/arbre dans l'inspecteur

# Paramètres de la bande
@export var band_x_center: float = -2.5
@export var band_x_width: float = 0  # largeur totale en X
@export var band_z_center: float = -245.0
@export var band_z_length: float = 500.0  # longueur totale en Z
@export var spawn_y: float = 0.5  # hauteur où poser le cube (au-dessus de la bande)

@export var min_spacing: float = 5.0
@export var max_spacing: float = 10.0

func _ready() -> void:
	spawn_cubes2()

func spawn_cubes2() -> void:
	var z_start = band_z_center - band_z_length / 2.0
	var z_end = band_z_center + band_z_length / 2.0
	var z = z_start
	var count = 0
	
	while z < z_end:
		var x = band_x_center + randf_range(-band_x_width / 2.0, band_x_width / 2.0)
		var pos = Vector3(x, spawn_y, z)
		spawn_cube2_at(pos)
		count += 1
		z += randf_range(min_spacing, max_spacing)
	
	print("Nombre d'arbres spawnés : ", count)

func spawn_cube2_at(pos: Vector3) -> void:
	if tree_scene == null:
		push_warning("Aucune scène de cube assignée !")
		return
	
	var cube_instance = tree_scene.instantiate()
	cube_instance.position = pos
	add_child.call_deferred(cube_instance)

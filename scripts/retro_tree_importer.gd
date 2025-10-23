@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Object:
	for child in scene.get_children():
		if child is MeshInstance3D:
			var material: StandardMaterial3D = child.get_active_material(0)
			material.albedo_texture = load("res://models/retro_trees/textures/" + scene.name + ".png")
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			child.set_surface_override_material(0, material)

	return scene


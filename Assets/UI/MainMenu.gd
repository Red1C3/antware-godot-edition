extends Control


func load_scene(scene_name):
	get_node("MenuPick").play()
	get_tree().change_scene(scene_name)

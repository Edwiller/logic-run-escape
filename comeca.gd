extends Button


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pressed.connect(iniciar_jogo)


func iniciar_jogo() -> void:
	get_tree().change_scene_to_file("res://sala_principal.tscn")

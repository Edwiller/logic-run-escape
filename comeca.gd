extends Button


func _ready() -> void:
	pressed.connect(iniciar_jogo)


func iniciar_jogo() -> void:
	get_tree().change_scene_to_file("res://sala_principal.tscn")

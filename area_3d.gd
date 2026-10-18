extends Area3D

@export var jogador_1: CharacterBody3D
@export var jogador_2: CharacterBody3D

var encerrando: bool = false


func _ready() -> void:
	if jogador_1 == null or jogador_2 == null:
		push_error("Preencha os dois jogadores na área do fundo.")
		set_physics_process(false)
		return

	monitoring = true


func _physics_process(_delta: float) -> void:
	if encerrando:
		return

	var corpos := get_overlapping_bodies()

	if corpos.has(jogador_1) and corpos.has(jogador_2):
		encerrando = true
		call_deferred("mostrar_final")


func mostrar_final() -> void:
	var erro := get_tree().change_scene_to_file(
		"res://tela_final.tscn"
	)

	if erro != OK:
		push_error("Não foi possível abrir tela_final.tscn.")
		encerrando = false

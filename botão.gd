
extends Node3D

@export var jogador: CharacterBody3D
@export var ponte_saida: Node3D
@export var distancia_interacao: float = 2.5

var ativado: bool = false


func _ready():
	if ponte_saida != null:
		atualizar_ponte(false)

	print("Aproxime-se do botão e pressione E!")


func _process(_delta):
	if ativado or jogador == null or ponte_saida == null:
		return

	var distancia = jogador.global_position.distance_to(global_position)

	if distancia <= distancia_interacao:
		if Input.is_physical_key_pressed(KEY_E):
			ativar_botao()


func ativar_botao():
	ativado = true

	print("BOTÃO ATIVADO!")
	print("A PONTE PARA A SAÍDA APARECEU!")

	atualizar_ponte(true)


func atualizar_ponte(ativa: bool):
	ponte_saida.visible = ativa
	atualizar_colisoes(ponte_saida, ativa)


func atualizar_colisoes(no: Node, ativa: bool):
	if no is CollisionShape3D:
		no.set_deferred("disabled", not ativa)

	for filho in no.get_children():
		atualizar_colisoes(filho, ativa)

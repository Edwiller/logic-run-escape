
extends Node

signal chave_coletada

@export var jogador: CharacterBody3D
@export var chave: Node3D
@export var tabua_falsa: Node3D
@export var distancia_interacao: float = 2.5

var coletada: bool = false


func _ready():
	print("Sistema da chave iniciado!")


func _process(_delta):
	if coletada:
		return

	if jogador == null or chave == null:
		return

	# Verifica a distância até a chave de verdade
	var distancia = jogador.global_position.distance_to(
		chave.global_position
	)

	if distancia <= distancia_interacao:
		if Input.is_physical_key_pressed(KEY_E):
			coletar_chave()


func coletar_chave():
	coletada = true

	print("CHAVE COLETADA!")
	
	# Esconde a chave
	chave.hide()

	# Faz a tábua falsa desaparecer
	if tabua_falsa != null:
		tabua_falsa.hide()
		desativar_colisoes(tabua_falsa)
		print("A TABUA FALSA CAIU!")
	else:
		print("ERRO: Tabua falsa não configurada!")

	chave_coletada.emit()


func desativar_colisoes(no: Node):
	if no is CollisionShape3D:
		no.set_deferred("disabled", true)

	if no is CollisionObject3D:
		no.set_deferred("collision_layer", 0)
		no.set_deferred("collision_mask", 0)

	for filho in no.get_children():
		desativar_colisoes(filho)


extends Node

@export var jogador: CharacterBody3D

@export var alavanca1: Node3D
@export var alavanca2: Node3D
@export var alavanca3: Node3D

@export var tabua1: Node3D
@export var tabua2: Node3D
@export var tabua3: Node3D

@export var colisao1: CollisionShape3D
@export var colisao2: CollisionShape3D
@export var colisao3: CollisionShape3D

@export var distancia_interacao: float = 2.5

var alavancas_ativadas: Array[bool] = [false, false, false]


func _ready():
	# As três tábuas começam escondidas.
	for tabua in [tabua1, tabua2, tabua3]:
		if tabua != null:
			atualizar_tabua(tabua, false)

	print("Encontre as três alavancas para reconstruir a ponte!")


func _process(_delta):
	if jogador == null:
		return

	if Input.is_key_pressed(KEY_E):
		return

	# A ativação ocorre apenas quando E é pressionado.


func _unhandled_key_input(event):
	if not event is InputEventKey:
		return

	if event.keycode != KEY_E or not event.pressed or event.echo:
		return

	if jogador == null:
		return

	var alavancas = [alavanca1, alavanca2, alavanca3]
	var tabuas = [tabua1, tabua2, tabua3]

	for i in range(3):
		if alavancas[i] == null or tabuas[i] == null:
			continue

		if alavancas_ativadas[i]:
			continue

		var distancia = jogador.global_position.distance_to(
			alavancas[i].global_position
		)

		if distancia <= distancia_interacao:
			alavancas_ativadas[i] = true
			atualizar_tabua(tabuas[i], true)

			print("Alavanca ", i + 1, " ativada! Tábua apareceu!")

			if alavancas_ativadas.all(func(ativa): return ativa):
				print("PONTE RECONSTRUÍDA! Atravesse até o botão.")

			break



func atualizar_tabua(tabua: Node3D, ativa: bool):
	tabua.visible = ativa

	var indice = [tabua1, tabua2, tabua3].find(tabua)
	var colisoes = [colisao1, colisao2, colisao3]

	if indice >= 0 and colisoes[indice] != null:
		colisoes[indice].set_deferred("disabled", not ativa)


func atualizar_colisoes(no: Node, ativa: bool):
	if no is CollisionShape3D:
		no.set_deferred("disabled", not ativa)

	for filho in no.get_children():
		atualizar_colisoes(filho, ativa)

	if no is CollisionObject3D:
		no.set_deferred("collision_layer", 1 if ativa else 0)
		no.set_deferred("collision_mask", 1 if ativa else 0)

	for filho in no.get_children():
		atualizar_colisoes(filho, ativa)


extends Node

@export var jogador: CharacterBody3D

@export var alavanca1: Node3D
@export var alavanca2: Node3D
@export var alavanca3: Node3D

@export var ponte: Node3D

@export var distancia_interacao: float = 2.5

var sequencia: Array[int] = [0, 1, 2]
var passo_atual: int = 0
var ponte_liberada: bool = false


func _ready():
	if ponte != null:
		atualizar_objeto(ponte, false)

	print("Ative as alavancas na ordem correta!")



func _unhandled_key_input(event):
	if ponte_liberada:
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo or event.keycode != KEY_E:
		return

	if jogador == null:
		return

	var alavancas = [alavanca1, alavanca2, alavanca3]

	var indice_mais_proximo = -1
	var menor_distancia = distancia_interacao

	for i in range(alavancas.size()):
		if alavancas[i] == null:
			continue

		var distancia = jogador.global_position.distance_to(
			alavancas[i].global_position
		)

		if distancia < menor_distancia:
			menor_distancia = distancia
			indice_mais_proximo = i

	if indice_mais_proximo != -1:
		print("Você acionou a Alavanca ", indice_mais_proximo + 1)
		verificar_alavanca(indice_mais_proximo)



var alavancas_acionadas: Array[bool] = [false, false, false]


func verificar_alavanca(indice: int):
	if alavancas_acionadas[indice]:
		print("Essa alavanca já foi ativada!")
		return

	alavancas_acionadas[indice] = true

	var quantidade = 0

	for ativada in alavancas_acionadas:
		if ativada:
			quantidade += 1

	print("Alavanca ", indice + 1, " ativada! ", quantidade, "/3")

	if quantidade == 3:
		ponte_liberada = true

		print("PONTE RECONSTRUÍDA!")

		if ponte != null:
			atualizar_objeto(ponte, true)


func atualizar_objeto(objeto: Node3D, ativo: bool):
	objeto.visible = ativo
	atualizar_colisoes(objeto, ativo)


func atualizar_colisoes(no: Node, ativo: bool):
	if no is CollisionShape3D:
		no.set_deferred("disabled", not ativo)

	for filho in no.get_children():
		atualizar_colisoes(filho, ativo)

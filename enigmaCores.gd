
extends Node

@export var cristais: Array[Area3D] = []
@export var pedra_inicio: Node3D
@export var porta_caverna: Node3D

@export var distancia_interacao: float = 2.5
@export var intervalo: float = 0.7

@onready var jogador: CharacterBody3D = $"../jogador"

var quantidades_rodadas: Array[int] = [3, 4, 6]
var rodada_atual: int = 0

var sequencia: Array[int] = []
var passo_atual: int = 0

var desafio_iniciado: bool = false
var aguardando_resposta: bool = false
var desafio_concluido: bool = false


func _ready():
	randomize()

	for cristal in cristais:
		if cristal != null:
			cristal.cristal_pressionado.connect(_verificar_cristal)

	print("Aproxime-se da pedra e pressione E para iniciar.")


func _process(_delta):
	if desafio_iniciado or desafio_concluido:
		return

	if pedra_inicio == null:
		return

	var distancia = jogador.global_position.distance_to(
		pedra_inicio.global_position
	)

	if distancia <= distancia_interacao:
		if Input.is_key_pressed(KEY_E):
			desafio_iniciado = true
			iniciar_rodada()


func iniciar_rodada():
	if cristais.size() != 6:
		push_error("Configure os 6 cristais no Inspetor!")
		desafio_iniciado = false
		return

	aguardando_resposta = false
	passo_atual = 0
	sequencia.clear()

	var quantidade = quantidades_rodadas[rodada_atual]

	for i in range(quantidade):
		sequencia.append(randi_range(0, 5))

	print("================================")
	print("RODADA ", rodada_atual + 1, "/3")
	print("Memorize a sequência!")
	print("================================")

	await mostrar_sequencia()


func mostrar_sequencia():
	aguardando_resposta = false

	# Pequena pausa antes da apresentação
	await get_tree().create_timer(1.0).timeout

	for indice in sequencia:
		var cristal = cristais[indice]

		cristal.acender()
		await get_tree().create_timer(intervalo).timeout

		cristal.apagar()
		await get_tree().create_timer(0.3).timeout

	aguardando_resposta = true

	print("Agora repita a sequência!")



func _verificar_cristal(cristal):
	if not aguardando_resposta:
		return

	var indice_pressionado = cristais.find(cristal)
	var indice_correto = sequencia[passo_atual]

	if indice_pressionado == indice_correto:
		passo_atual += 1

		print("Acertou! ", passo_atual, "/", sequencia.size())

		if passo_atual == sequencia.size():
			aguardando_resposta = false

			if rodada_atual < 2:
				rodada_atual += 1

				print("Rodada concluída!")
				print("Próxima rodada começará em breve...")

				await get_tree().create_timer(2.0).timeout
				await iniciar_rodada()
			else:
				_concluir_desafio()

	else:
		print("Sequência incorreta!")
		print("Você perdeu o progresso e voltou à Rodada 1.")

		aguardando_resposta = false
		desafio_iniciado = false

		# Reinicia completamente o progresso
		rodada_atual = 0
		passo_atual = 0
		sequencia.clear()

		print("Volte à pedra e pressione E para tentar novamente.")



func _concluir_desafio():
	aguardando_resposta = false
	desafio_concluido = true

	print("PARABÉNS! Você venceu as 3 rodadas!")

	if porta_caverna != null:
		porta_caverna.hide()
		desativar_colisoes(porta_caverna)

		print("A porta da caverna foi aberta!")
	else:
		push_warning("A porta da caverna não foi configurada!")


func desativar_colisoes(no: Node):
	if no is CollisionShape3D:
		no.set_deferred("disabled", true)

	if no is CollisionObject3D:
		no.set_deferred("collision_layer", 0)
		no.set_deferred("collision_mask", 0)

	for filho in no.get_children():
		desativar_colisoes(filho)

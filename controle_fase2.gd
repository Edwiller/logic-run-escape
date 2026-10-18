extends Node

@export var jogador_1: CharacterBody3D
@export var jogador_2: CharacterBody3D
@export var placa_inicio: Area3D
@export var ponte: StaticBody3D
@export var placas: Array[Area3D] = []

@export var pedra: Node3D
@export var colisoes_pedra: Array[CollisionShape3D] = []

@export var duracao_ponte: float = 10.0
@export var altura_queda: float = -1.0
@export_file("*.tscn") var primeira_fase: String = "res://sala_principal.tscn"

var pedra_aberta: bool = false
var ponte_ativada: bool = false
var tempo_restante: float = 0.0
var estava_na_placa: bool = false

var ativadas: Array[bool] = []
var materiais: Array[StandardMaterial3D] = []

var participou_1: bool = false
var participou_2: bool = false
var concluido: bool = false
var reiniciando: bool = false

var camada_ponte: int
var mascara_ponte: int
var aviso: Label


func _ready() -> void:
	if (
		jogador_1 == null or jogador_2 == null
		or placa_inicio == null or ponte == null
		or pedra == null or placas.size() != 6
		or colisoes_pedra.is_empty()
	):
		push_error("Preencha as referências de EnigmaC.")
		set_physics_process(false)
		return

	var placas_conferidas: Array[Area3D] = []

	for placa in placas:
		if placa == null:
			push_error("Preencha todas as seis placas.")
			set_physics_process(false)
			return

		var malha := placa.get_node_or_null("MeshInstance3D")

		if not malha is MeshInstance3D:
			push_error("Cada placa precisa de um MeshInstance3D.")
			set_physics_process(false)
			return

		if placas_conferidas.has(placa):
			push_error("As seis placas precisam ser diferentes.")
			set_physics_process(false)
			return

		placas_conferidas.append(placa)

	for colisao in colisoes_pedra:
		if colisao == null:
			push_error("Preencha as colisões da pedra.")
			set_physics_process(false)
			return

	jogador_1.controles_invertidos = false
	jogador_2.controles_invertidos = false

	camada_ponte = ponte.collision_layer
	mascara_ponte = ponte.collision_mask
	mostrar_ponte(false)

	placa_inicio.monitoring = true

	for placa in placas:
		placa.monitoring = true
		ativadas.append(false)

		var material := StandardMaterial3D.new()
		material.albedo_color = Color("#5599ff")

		var malha := placa.get_node("MeshInstance3D") as MeshInstance3D
		malha.material_override = material
		materiais.append(material)

	var interface := CanvasLayer.new()
	add_child(interface)

	aviso = Label.new()
	aviso.position = Vector2(20, 20)
	aviso.add_theme_font_size_override("font_size", 24)
	aviso.add_theme_color_override("font_outline_color", Color.BLACK)
	aviso.add_theme_constant_override("outline_size", 6)
	interface.add_child(aviso)

	atualizar_aviso()


func _physics_process(delta: float) -> void:
	if reiniciando:
		return

	# Se qualquer personagem cair, ambos voltam à primeira fase.
	if (
		jogador_1.global_position.y < altura_queda
		or jogador_2.global_position.y < altura_queda
	):
		reiniciando = true
		aviso.text = "Alguém caiu! Voltando à fase das cores..."
		call_deferred("voltar_ao_inicio")
		return

	# Desativa a ponte quando o tempo acaba.
	if tempo_restante > 0.0:
		tempo_restante = maxf(tempo_restante - delta, 0.0)

		if tempo_restante == 0.0:
			mostrar_ponte(false)

	# Detecta a passagem de placa vazia para placa pressionada.
	var corpos := placa_inicio.get_overlapping_bodies()
	var na_placa := corpos.has(jogador_1) or corpos.has(jogador_2)
	var nova_pisada := na_placa and not estava_na_placa

	estava_na_placa = na_placa

	# Permite reativar somente depois de encerrar o prazo.
	if nova_pisada and tempo_restante <= 0.0:
		ativar_ponte()

	if ponte_ativada and not concluido:
		verificar_placas()

	atualizar_aviso()


func ativar_ponte() -> void:
	ponte_ativada = true
	tempo_restante = maxf(duracao_ponte, 0.1)

	# Mantém a troca sem alternar a cada nova ativação.
	jogador_1.controles_invertidos = true
	jogador_2.controles_invertidos = true

	mostrar_ponte(true)


func verificar_placas() -> void:
	for i in range(placas.size()):
		var corpos := placas[i].get_overlapping_bodies()
		var pisou_1 := corpos.has(jogador_1)
		var pisou_2 := corpos.has(jogador_2)

		if pisou_1:
			participou_1 = true

		if pisou_2:
			participou_2 = true

		if not ativadas[i] and (pisou_1 or pisou_2):
			ativadas[i] = true
			materiais[i].albedo_color = Color("#55dd77")

	if (
		ativadas.count(true) == 6
		and participou_1
		and participou_2
	):
		abrir_pedra()


func abrir_pedra() -> void:
	concluido = true

	var animacao := create_tween()
	animacao.tween_property(
		pedra,
		"position:y",
		pedra.position.y + 6.0,
		1.0
	)

	await animacao.finished

	for colisao_pedra in colisoes_pedra:
		colisao_pedra.set_deferred("disabled", true)

	await get_tree().physics_frame
	pedra_aberta = true


func mostrar_ponte(ativa: bool) -> void:
	ponte.visible = ativa
	ponte.collision_layer = camada_ponte if ativa else 0
	ponte.collision_mask = mascara_ponte if ativa else 0


func atualizar_aviso() -> void:
	if not ponte_ativada:
		aviso.text = (
			"Pisem na placa para liberar a ponte por %d segundos."
			% int(duracao_ponte)
		)
		return

	var situacao := "Ponte: %d s" % int(ceil(tempo_restante))

	if tempo_restante <= 0.0:
		situacao = "Ponte desativada. Saiam da placa e pisem novamente."

	if concluido:
		if pedra_aberta:
			aviso.text = situacao + "\nEntrem juntos na caverna!"
		else:
			aviso.text = situacao + "\nA pedra está abrindo."
		return

	aviso.text = (
		situacao
		+ "\nCONTROLES TROCADOS: menino nas setas; menina no WASD."
		+ "\nPlacas ativadas: %d / 6" % ativadas.count(true)
		+ "\nCada personagem deve pisar em pelo menos uma placa."
	)

	if ativadas.count(true) == 6:
		aviso.text += "\nFalta a participação do outro personagem!"


func voltar_ao_inicio() -> void:
	var erro := get_tree().change_scene_to_file(primeira_fase)

	if erro != OK:
		push_error("Não foi possível abrir a primeira fase: %s" % erro)
		aviso.text = "Confira o arquivo em Primeira Fase."

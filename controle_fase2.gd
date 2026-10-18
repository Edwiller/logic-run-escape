extends Node

@export var jogador_1: CharacterBody3D
@export var jogador_2: CharacterBody3D
@export var placa_inicio: Area3D
@export var ponte: StaticBody3D
@export var placas: Array[Area3D] = []

@export var pedra: Node3D
@export var colisoes_pedra: Array[CollisionShape3D] = []

@export var duracao_ponte: float = 40.0
@export var altura_queda: float = -1.0
@export_file("*.tscn") var primeira_fase: String = "res://sala_principal.tscn"

var ponte_ativada: bool = false
var tempo_restante: float = 0.0
var ativadas: Array[bool] = []

var participou_1: bool = false
var participou_2: bool = false
var concluido: bool = false
var reiniciando: bool = false

var camada_ponte: int
var mascara_ponte: int
var materiais: Array[StandardMaterial3D] = []

var aviso: Label


func _ready() -> void:
	if (
		jogador_1 == null or jogador_2 == null
		or placa_inicio == null or ponte == null
		or pedra == null or placas.size() != 6
		or colisoes_pedra.is_empty()
	):
		push_error("Preencha as referências do Controle Fase 2.")
		set_physics_process(false)
		return

	for placa in placas:
		if placa == null or not placa.has_node("MeshInstance3D"):
			push_error("Confira as seis placas e seus MeshInstance3D.")
			set_physics_process(false)
			return

	for colisao in colisoes_pedra:
		if colisao == null:
			push_error("Preencha todas as colisões da pedra.")
			set_physics_process(false)
			return

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

	# A queda de um reinicia a partida para os dois.
	if (
		jogador_1.global_position.y < altura_queda
		or jogador_2.global_position.y < altura_queda
	):
		reiniciando = true
		aviso.text = "Alguém caiu! Voltando à fase das cores..."
		call_deferred("voltar_ao_inicio")
		return

	if not ponte_ativada:
		var corpos := placa_inicio.get_overlapping_bodies()

		if corpos.has(jogador_1) or corpos.has(jogador_2):
			ponte_ativada = true
			tempo_restante = duracao_ponte
			mostrar_ponte(true)

	elif tempo_restante > 0.0:
		tempo_restante = maxf(tempo_restante - delta, 0.0)

		if tempo_restante == 0.0:
			mostrar_ponte(false)

	# As placas do outro lado só contam após ativar a ponte.
	if ponte_ativada and not concluido:
		verificar_placas()

	atualizar_aviso()


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

	# Desativa somente as colisões da pedra.
	for colisao in colisoes_pedra:
		colisao.set_deferred("disabled", true)


func mostrar_ponte(ativa: bool) -> void:
	ponte.visible = ativa
	ponte.collision_layer = camada_ponte if ativa else 0
	ponte.collision_mask = mascara_ponte if ativa else 0


func atualizar_aviso() -> void:
	if not ponte_ativada:
		aviso.text = "Pisem na placa inicial para liberar a ponte por 60 segundos."
		return

	var mensagem_ponte := "Ponte: %d s" % int(ceil(tempo_restante))

	if tempo_restante <= 0.0:
		mensagem_ponte = "O tempo acabou. A ponte desapareceu."

	if concluido:
		aviso.text = mensagem_ponte + "\nAs seis placas foram ativadas! Pedra liberada."
		return

	aviso.text = (
		mensagem_ponte
		+ "\nPlacas ativadas: %d / 6" % ativadas.count(true)
		+ "\nCada personagem precisa pisar em pelo menos uma placa."
	)

	if ativadas.count(true) == 6:
		aviso.text += "\nFalta a participação do outro personagem!"


func voltar_ao_inicio() -> void:
	var erro := get_tree().change_scene_to_file(primeira_fase)

	if erro != OK:
		push_error("Não foi possível abrir a primeira fase: %s" % erro)
		aviso.text = "Confira o arquivo configurado em Primeira Fase."

extends Node3D

@export var jogador_1: CharacterBody3D
@export var jogador_2: CharacterBody3D

@export var deslocamento: Vector3 = Vector3(2.5, 1.0, 1.5)
@export var altura_pulo: float = 0.8
@export var duracao_pulo: float = 1.2
@export var duracao_volta: float = 3.0
@export var suavidade: float = 4.0

var tempo: float = 0.0
var centro: Vector3
var rotacao_inicial: Vector3


func _ready() -> void:
	if jogador_1 == null or jogador_2 == null:
		push_error("Preencha os dois jogadores no Inspetor do boto.")
		set_process(false)
		return

	rotacao_inicial = rotation

	centro = (
		jogador_1.global_position
		+ jogador_2.global_position
	) * 0.5

	global_position = centro + deslocamento


func _process(delta: float) -> void:
	if (
		not is_instance_valid(jogador_1)
		or not is_instance_valid(jogador_2)
	):
		return

	tempo += delta

	# Acompanha o ponto entre os dois personagens.
	var alvo := (
		jogador_1.global_position
		+ jogador_2.global_position
	) * 0.5

	centro = centro.lerp(
		alvo,
		1.0 - exp(-maxf(suavidade, 0.0) * delta)
	)

	# Pula continuamente.
	var fase_pulo := fmod(
		tempo / maxf(duracao_pulo, 0.1),
		1.0
	)

	var salto := sin(fase_pulo * PI) * altura_pulo

	global_position = (
		centro
		+ deslocamento
		+ Vector3.UP * salto
	)

	# Gira 360 graus continuamente.
	var fase_giro := fmod(
		tempo / maxf(duracao_volta, 0.1),
		1.0
	)

	rotation = rotacao_inicial
	rotation.y += fase_giro * TAU

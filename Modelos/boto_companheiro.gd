extends Node3D

@export var altura_pulo: float = 0.8
@export var duracao_pulo: float = 1.5
@export var duracao_volta: float = 5.0

var tempo: float = 0.0
var posicao_inicial: Vector3
var rotacao_inicial: Vector3


func _ready() -> void:
	posicao_inicial = position
	rotacao_inicial = rotation


func _process(delta: float) -> void:
	tempo += delta

	# Pula sem sair do lugar.
	var fase_pulo := fmod(
		tempo / maxf(duracao_pulo, 0.1),
		1.0
	)

	position = posicao_inicial
	position.y += sin(fase_pulo * PI) * altura_pulo

	# Gira 360 graus continuamente.
	var fase_giro := fmod(
		tempo / maxf(duracao_volta, 0.1),
		1.0
	)

	rotation = rotacao_inicial
	rotation.y += fase_giro * TAU

extends Node3D

@export var jogador_1: CharacterBody3D
@export var jogador_2: CharacterBody3D

@export var sensibilidade: float = 0.003
@export var altura_foco: float = 1.0
@export var distancia_minima: float = 4.0
@export var distancia_maxima: float = 10.0

@onready var inclinacao: Node3D = $Inclinacao
@onready var braco: SpringArm3D = $Inclinacao/SpringArm3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# A câmera não deve ser bloqueada pelos personagens.
	if is_instance_valid(jogador_1):
		braco.add_excluded_object(jogador_1.get_rid())

	if is_instance_valid(jogador_2):
		braco.add_excluded_object(jogador_2.get_rid())

	atualizar_enquadramento()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation.y -= event.relative.x * sensibilidade

			inclinacao.rotation.x = clampf(
				inclinacao.rotation.x
				- event.relative.y * sensibilidade,
				deg_to_rad(-60),
				deg_to_rad(15)
			)


func _physics_process(_delta: float) -> void:
	atualizar_enquadramento()


func atualizar_enquadramento() -> void:
	if not is_instance_valid(jogador_1):
		return

	if not is_instance_valid(jogador_2):
		return

	var posicao_1 := jogador_1.global_position
	var posicao_2 := jogador_2.global_position

	# Acompanha o ponto entre os dois personagens.
	global_position = (
		(posicao_1 + posicao_2) * 0.5
		+ Vector3.UP * altura_foco
	)

	# Afasta a câmera quando os personagens se separam.
	var separacao := posicao_1.distance_to(posicao_2)

	braco.spring_length = clampf(
		distancia_minima + separacao * 0.7,
		distancia_minima,
		distancia_maxima
	)

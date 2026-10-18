extends Node3D

const SENSIBILIDADE := 0.003

@onready var jogador: CharacterBody3D = $"../Jogador"
@onready var inclinacao: Node3D = $Inclinacao
@onready var braco: SpringArm3D = $Inclinacao/SpringArm3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Evita que a câmera seja bloqueada pelo próprio jogador.
	braco.add_excluded_object(jogador.get_rid())
	acompanhar_jogador()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation.y -= event.relative.x * SENSIBILIDADE

			inclinacao.rotation.x = clampf(
				inclinacao.rotation.x
				- event.relative.y * SENSIBILIDADE,
				deg_to_rad(-55),
				deg_to_rad(25)
			)


func _physics_process(_delta: float) -> void:
	acompanhar_jogador()


func acompanhar_jogador() -> void:
	global_position = jogador.global_position + Vector3(0, 0.6, 0)


extends CharacterBody3D

@export var velocidade: float = 5.0
@export var velocidade_camera: float = 2.0
@export var forca_pulo: float = 5.0

var controles_invertidos: bool = false

@onready var camera: Camera3D = $Camera3D

var gravidade: float = 9.8


func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y -= gravidade * delta
	# Pular com a barra de espaço
	if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = forca_pulo

	# Escolhe os controles de movimentação
	var direcao: Vector2

	if controles_invertidos:
		# Controles do Jogador 1 (WASD)
		direcao = Input.get_vector(
			"mover_esquerda",
			"mover_direita",
			"mover_frente",
			"mover_tras"
		)
	else:
		# Controles originais do Jogador 2 (setas)
		direcao = Input.get_vector(
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down"
		)

	# Movimentação relativa à direção do personagem
	var movimento = transform.basis * Vector3(
		direcao.x,
		0,
		direcao.y
	)

	velocity.x = movimento.x * velocidade
	velocity.z = movimento.z * velocidade

	# Câmera com teclado numérico no modo normal
	if not controles_invertidos:
		var giro_horizontal = 0.0

		if Input.is_physical_key_pressed(KEY_KP_4):
			giro_horizontal += 1.0

		if Input.is_physical_key_pressed(KEY_KP_6):
			giro_horizontal -= 1.0

		rotate_y(giro_horizontal * velocidade_camera * delta)

		var giro_vertical = 0.0

		if Input.is_physical_key_pressed(KEY_KP_8):
			giro_vertical += 1.0

		if Input.is_physical_key_pressed(KEY_KP_2):
			giro_vertical -= 1.0

		camera.rotation.x = clamp(
			camera.rotation.x + giro_vertical * velocidade_camera * delta,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

	move_and_slide()


func _input(event):
	# O mouse controla o Jogador 2 apenas
	# quando os controles estiverem invertidos.
	if not controles_invertidos:
		return

	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			# Olhar para esquerda e direita
			rotate_y(-event.relative.x * 0.002)

			# Olhar para cima e para baixo
			camera.rotate_x(-event.relative.y * 0.002)

			# Limitar rotação vertical
			camera.rotation.x = clamp(
				camera.rotation.x,
				deg_to_rad(-80),
				deg_to_rad(80)
			)

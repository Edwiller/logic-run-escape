extends CharacterBody3D

@export_enum("Jogador 1", "Jogador 2") var numero_jogador: int = 0

@export var velocidade: float = 4.0
@export var forca_pulo: float = 5.0
@export var velocidade_giro: float = 12.0

@export var animador: AnimationPlayer
@export var referencia_camera: Node3D

# Ajustaremos se o modelo caminhar de costas.
@export var ajuste_frente_graus: float = 0.0

# Permite que as placas troquem os controles.
var controles_invertidos: bool = false

var animacao_parado: StringName = &""
var animacao_andando: StringName = &""
var animacao_pulando: StringName = &""
var animacao_caindo: StringName = &""

@onready var visual: Node3D = $Visual


func _ready() -> void:
	if animador == null:
		push_warning("Arraste o AnimationPlayer para o campo Animador.")
		return

	animacao_parado = encontrar_animacao("Idle")
	animacao_andando = encontrar_animacao("Walk")
	animacao_pulando = encontrar_animacao("Jump")
	animacao_caindo = encontrar_animacao("Jump_Idle")

	# Parada e caminhada devem se repetir.
	for nome in [animacao_parado, animacao_andando]:
		if nome != &"":
			animador.get_animation(nome).loop_mode = Animation.LOOP_LINEAR


func _physics_process(delta: float) -> void:
	var prefixo := obter_prefixo()

	var entrada := Input.get_vector(
		prefixo + "esquerda",
		prefixo + "direita",
		prefixo + "frente",
		prefixo + "tras"
	)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor() and Input.is_action_just_pressed(prefixo + "pular"):
		velocity.y = forca_pulo

	var direcao := Vector3(entrada.x, 0.0, entrada.y)

	# Sem câmera vinculada, usa as direções do mundo.
	if is_instance_valid(referencia_camera):
		var orientacao := Basis(
			Vector3.UP,
			referencia_camera.global_rotation.y
		)
		direcao = orientacao * direcao

	velocity.x = direcao.x * velocidade
	velocity.z = direcao.z * velocidade

	# Gira somente a aparência, sem girar a colisão.
	if direcao.length_squared() > 0.001:
		var angulo := atan2(direcao.x, direcao.z)
		angulo += deg_to_rad(ajuste_frente_graus)

		visual.rotation.y = lerp_angle(
			visual.rotation.y,
			angulo,
			1.0 - exp(-velocidade_giro * delta)
		)

	move_and_slide()
	atualizar_animacao(entrada.length() > 0.01)


func obter_prefixo() -> String:
	var indice := numero_jogador

	if controles_invertidos:
		indice = 1 - indice

	return "p1_" if indice == 0 else "p2_"


func encontrar_animacao(nome_curto: String) -> StringName:
	for nome in animador.get_animation_list():
		var texto := String(nome)

		if texto == nome_curto or texto.ends_with("|" + nome_curto):
			return StringName(nome)

	push_warning("Animação não encontrada: " + nome_curto)
	return &""


func atualizar_animacao(andando: bool) -> void:
	if animador == null:
		return

	var escolhida := animacao_parado

	if not is_on_floor():
		if velocity.y > 0.0:
			escolhida = animacao_pulando
		else:
			escolhida = animacao_caindo
	elif andando:
		escolhida = animacao_andando

	if escolhida == &"":
		return

	# Não reinicia a animação a cada quadro.
	if animador.current_animation != escolhida:
		animador.play(escolhida, 0.15)

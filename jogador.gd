extends CharacterBody3D

const VELOCIDADE = 4.0
const SENSIBILIDADE = 0.002

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * SENSIBILIDADE)
			camera.rotation.x = clamp(
				camera.rotation.x - event.relative.y * SENSIBILIDADE,
				deg_to_rad(-85),
				deg_to_rad(85)
			)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var entrada := Vector2.ZERO

	if Input.is_physical_key_pressed(KEY_W):
		entrada.y -= 1
	if Input.is_physical_key_pressed(KEY_S):
		entrada.y += 1
	if Input.is_physical_key_pressed(KEY_A):
		entrada.x -= 1
	if Input.is_physical_key_pressed(KEY_D):
		entrada.x += 1

	var direcao := (
		transform.basis * Vector3(entrada.x, 0, entrada.y)
	).normalized()

	velocity.x = direcao.x * VELOCIDADE
	velocity.z = direcao.z * VELOCIDADE

	move_and_slide()

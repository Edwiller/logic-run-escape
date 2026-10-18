extends CharacterBody3D

const VELOCIDADE := 4.0

@onready var camera_rig: Node3D = $"../CameraRig"


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

	# Usa apenas a rotação horizontal da câmera.
	var orientacao := Basis(Vector3.UP, camera_rig.global_rotation.y)
	var direcao := orientacao * Vector3(entrada.x, 0, entrada.y)
	direcao = direcao.normalized()

	velocity.x = direcao.x * VELOCIDADE
	velocity.z = direcao.z * VELOCIDADE

	move_and_slide()

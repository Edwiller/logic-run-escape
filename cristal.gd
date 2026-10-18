extends Area3D

signal cristal_pressionado(cristal)

@export var cor_normal: Color = Color.BLUE
@export var cor_ativa: Color = Color.GREEN

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var jogador: CharacterBody3D = $"../jogador"
@onready var jogador2: CharacterBody3D = $"../jogador2"

var material_cristal: StandardMaterial3D
var pressionado_antes: bool = false
var mostrando_luz: bool = false


func _ready() -> void:
	material_cristal = StandardMaterial3D.new()
	material_cristal.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_cristal.albedo_color = cor_normal
	mesh.material_override = material_cristal


func _physics_process(_delta: float) -> void:
	var pressionado := (
		verificar_jogador(jogador)
		or verificar_jogador(jogador2)
	)

	if mostrando_luz:
		# Durante a demonstração, não envia respostas.
		pressionado_antes = pressionado
		return

	material_cristal.albedo_color = (
		cor_ativa if pressionado else cor_normal
	)

	# Envia uma resposta quando alguém pisa.
	# É necessário sair do cristal para ativá-lo novamente.
	var acabou_de_pisar := pressionado and not pressionado_antes
	pressionado_antes = pressionado

	if acabou_de_pisar:
		cristal_pressionado.emit(self)


func verificar_jogador(personagem: CharacterBody3D) -> bool:
	if not is_instance_valid(personagem):
		return false

	var tamanho := Vector3(1.5, 0.3, 1.5)

	if mesh.mesh is BoxMesh:
		tamanho = mesh.mesh.size

	var posicao_local := mesh.to_local(personagem.global_position)

	var dentro_x := absf(posicao_local.x) <= tamanho.x / 2.0
	var dentro_z := absf(posicao_local.z) <= tamanho.z / 2.0
	var dentro_altura := absf(posicao_local.y) <= 2.0

	return dentro_x and dentro_z and dentro_altura


func acender() -> void:
	mostrando_luz = true
	material_cristal.albedo_color = Color.WHITE


func apagar() -> void:
	mostrando_luz = false
	material_cristal.albedo_color = cor_normal

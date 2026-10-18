
extends Area3D

signal cristal_pressionado(cristal)

@export var cor_normal: Color = Color.BLUE
@export var cor_ativa: Color = Color.GREEN

@onready var mesh: MeshInstance3D = $MeshInstance3D

@onready var jogador: CharacterBody3D = $"../jogador"
@onready var jogador2: CharacterBody3D = $"../jogador2"

var material_cristal: StandardMaterial3D

var pressionado_jogador1: bool = false
var pressionado_jogador2: bool = false

var mostrando_luz: bool = false


func _ready():
	material_cristal = StandardMaterial3D.new()
	material_cristal.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_cristal.albedo_color = cor_normal
	mesh.material_override = material_cristal


func _physics_process(_delta):
	if mostrando_luz:
		return

	var jogador1_em_cima = verificar_jogador(jogador)
	var jogador2_em_cima = verificar_jogador(jogador2)

	# O cristal fica ativo se qualquer jogador estiver sobre ele.
	var algum_jogador_em_cima = jogador1_em_cima or jogador2_em_cima

	material_cristal.albedo_color = (
		cor_ativa if algum_jogador_em_cima else cor_normal
	)

	# Jogador 1 acabou de pisar.
	if jogador1_em_cima and not pressionado_jogador1:
		print(name, " ativado pelo Jogador 1!")
		cristal_pressionado.emit(self)

	# Jogador 2 acabou de pisar.
	if jogador2_em_cima and not pressionado_jogador2:
		print(name, " ativado pelo Jogador 2!")
		cristal_pressionado.emit(self)

	pressionado_jogador1 = jogador1_em_cima
	pressionado_jogador2 = jogador2_em_cima


func verificar_jogador(personagem: CharacterBody3D) -> bool:
	var tamanho = Vector3(1.5, 0.3, 1.5)

	if mesh.mesh is BoxMesh:
		tamanho = mesh.mesh.size

	var posicao_local = mesh.to_local(personagem.global_position)

	var dentro_x = abs(posicao_local.x) <= tamanho.x / 2.0
	var dentro_z = abs(posicao_local.z) <= tamanho.z / 2.0
	var dentro_altura = abs(posicao_local.y) <= 2.0

	return dentro_x and dentro_z and dentro_altura


func acender():
	mostrando_luz = true
	material_cristal.albedo_color = Color.WHITE


func apagar():
	mostrando_luz = false
	material_cristal.albedo_color = cor_normal

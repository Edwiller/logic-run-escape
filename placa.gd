
extends Area3D

@export var cor_normal: Color = Color.BLUE
@export var cor_ativa: Color = Color.GREEN
@export var tempo_ponte: float = 20.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var jogador: CharacterBody3D = $"../jogador"
@onready var jogador2: CharacterBody3D = $"../jogador2"
@onready var ponte: StaticBody3D = $"../ponte"

var material_placa: StandardMaterial3D
var placa_ativada: bool = false
var ponte_ativa: bool = false
var tempo_restante: float = 0.0
var aguardando_saida: bool = false


func _ready():
	material_placa = StandardMaterial3D.new()
	material_placa.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_placa.albedo_color = cor_normal
	mesh.material_override = material_placa

	atualizar_ponte(false)


func _physics_process(delta):
	var tamanho = Vector3(1.5, 0.3, 1.5)

	if mesh.mesh is BoxMesh:
		tamanho = mesh.mesh.size

	var posicao_local = mesh.to_local(jogador.global_position)

	var dentro_x = abs(posicao_local.x) <= tamanho.x / 2.0
	var dentro_z = abs(posicao_local.z) <= tamanho.z / 2.0
	var dentro_altura = abs(posicao_local.y) <= 2.0

	var pressionada = dentro_x and dentro_z and dentro_altura

	# Cor da placa
	material_placa.albedo_color = cor_ativa if pressionada else cor_normal

	# Contagem regressiva
	if ponte_ativa:
		tempo_restante -= delta

		if tempo_restante <= 0.0:
			ponte_ativa = false
			atualizar_ponte(false)
			aguardando_saida = true
			print("Tempo esgotado! Ponte desapareceu.")

	# Exige sair da placa para iniciar uma nova tentativa
	if not pressionada:
		aguardando_saida = false

	# Ativa a ponte quando o jogador pisa na placa
	
	if pressionada and not placa_ativada and not ponte_ativa and not aguardando_saida:
		ponte_ativa = true
		tempo_restante = tempo_ponte
		atualizar_ponte(true)


		print("Você tem ", tempo_ponte, " segundos para atravessar!")



func atualizar_ponte(aberta: bool):
	ponte.visible = aberta
	ponte.collision_layer = 1 if aberta else 0
	ponte.collision_mask = 1 if aberta else 0

extends Area3D

@export var cor_normal: Color = Color.ORANGE
@export var cor_ativa: Color = Color.GREEN

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var jogador: CharacterBody3D = $"../jogador"
@onready var jogador2: CharacterBody3D = $"../jogador2"

var material_placa: StandardMaterial3D
var placa_ativada: bool = false

func _ready():
	material_placa = StandardMaterial3D.new()
	material_placa.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_placa.albedo_color = cor_normal
	mesh.material_override = material_placa

func _physics_process(_delta):
	var pressionada = jogador_em_cima(jogador) or jogador_em_cima(jogador2)

	# Atualiza a cor
	material_placa.albedo_color = cor_ativa if pressionada else cor_normal

	# Só executa uma vez quando alguém pisa
	if pressionada and not placa_ativada:
		placa_ativada = true

		jogador.controles_invertidos = false
		jogador2.controles_invertidos = false

		print("CONTROLES RESTAURADOS!")

	# Permite ativar de novo numa próxima tentativa
	if not pressionada:
		placa_ativada = false

func jogador_em_cima(personagem: CharacterBody3D) -> bool:
	var tamanho = Vector3(1.5, 0.3, 1.5)

	if mesh.mesh is BoxMesh:
		tamanho = mesh.mesh.size

	var posicao_local = mesh.to_local(personagem.global_position)

	var dentro_x = abs(posicao_local.x) <= tamanho.x / 2.0
	var dentro_z = abs(posicao_local.z) <= tamanho.z / 2.0
	var dentro_altura = abs(posicao_local.y) <= 2.0

	return dentro_x and dentro_z and dentro_altura

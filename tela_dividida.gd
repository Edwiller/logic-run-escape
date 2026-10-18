
extends CanvasLayer

@onready var jogador: CharacterBody3D = $"../jogador"
@onready var jogador_2: CharacterBody3D = $"../jogador2"

@onready var interface: Control = $Interface
@onready var container: HBoxContainer = $Interface/HBoxContainer

@onready var viewport1: SubViewport = $Interface/HBoxContainer/visao1/SubViewport
@onready var viewport2: SubViewport = $Interface/HBoxContainer/visao2/SubViewport

@onready var camera1: Camera3D = $Interface/HBoxContainer/visao1/SubViewport/Camera3D
@onready var camera2: Camera3D = $Interface/HBoxContainer/visao2/SubViewport/Camera3D


func _ready():
	interface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var mundo = get_viewport().world_3d

	viewport1.world_3d = mundo
	viewport2.world_3d = mundo

	viewport1.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport2.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	camera1.current = true
	camera2.current = true

	print("Tela dividida iniciada!")


func _process(_delta):
	camera1.global_transform = jogador.get_node("Camera3D").global_transform
	camera2.global_transform = jogador_2.get_node("Camera3D").global_transform

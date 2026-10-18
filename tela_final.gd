extends Node3D

@onready var boto: Node3D = $botocomchapeu
@onready var mensagem: Label = $CanvasLayer/MensagemFinal


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Aguarda a interface calcular o tamanho do texto.
	await get_tree().process_frame

	animar_texto()
	animar_boto()


func animar_texto() -> void:
	var tela := get_viewport().get_visible_rect().size

	mensagem.size.x = tela.x
	mensagem.position = Vector2(0, tela.y + 20)

	var animacao := create_tween()
	animacao.tween_property(
		mensagem,
		"position:y",
		40.0,
		4.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func animar_boto() -> void:
	var altura_inicial := boto.position.y

	var animacao := create_tween().set_loops()

	# Sobe e desacelera até o topo do salto.
	animacao.tween_property(
		boto,
		"position:y",
		altura_inicial + 0.7,
		0.7
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Desce até a posição original.
	animacao.tween_property(
		boto,
		"position:y",
		altura_inicial,
		0.7
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	animacao.tween_interval(0.8)

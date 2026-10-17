extends CSGBox3D

const CORES = ["VERMELHO", "AZUL", "VERDE", "AMARELO"]

var sequencia: Array[int] = [0, 1, 2, 3]
var progresso := 0
var resolvido := false
var mensagem := ""

@onready var porta: CSGBox3D = $"../Porta"
@onready var jogador: CharacterBody3D = $"../Jogador"
@export var instrucao: Label3D


func _ready() -> void:
	sequencia.shuffle()
	atualizar_texto()


func atualizar_texto() -> void:
	var pista := ""
	for i in range(sequencia.size()):
		if i > 0:
			pista += " > "
		pista += CORES[sequencia[i]]

	instrucao.text = (
		"REPITA A SEQUENCIA\n"
		+ pista
		+ "\n\n1: VERMELHO | 2: AZUL\n"
		+ "3: VERDE | 4: AMARELO\n"
		+ "\nAproxime-se do painel para digitar\n"
		+ "Acertos: %d / 4\n" % progresso
		+ mensagem
	)


func _unhandled_input(event: InputEvent) -> void:
	if resolvido:
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if global_position.distance_to(jogador.global_position) > 2.0:
		return

	var escolha := -1

	match event.physical_keycode:
		KEY_1:
			escolha = 0
		KEY_2:
			escolha = 1
		KEY_3:
			escolha = 2
		KEY_4:
			escolha = 3

	if escolha == -1:
		return

	if escolha == sequencia[progresso]:
		progresso += 1
		mensagem = "Cor correta!"
	else:
		progresso = 0
		mensagem = "Sequencia incorreta. Comece novamente."

	atualizar_texto()

	if progresso == sequencia.size():
		abrir_porta()


func abrir_porta() -> void:
	resolvido = true
	instrucao.text = "ACESSO LIBERADO!"

	var animacao := create_tween()
	animacao.tween_property(
		porta,
		"position:y",
		porta.position.y + 3.0,
		1.0
	)

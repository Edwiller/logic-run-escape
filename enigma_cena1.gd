extends Node3D

const NOMES = ["VERMELHO", "AZUL", "VERDE", "AMARELO"]
const CORES = ["#ff5555", "#5599ff", "#55dd77", "#ffdd55"]

@export var jogador_1: CharacterBody3D
@export var jogador_2: CharacterBody3D
@export var porta: Node3D
@export var painel: Node3D
@export var texto: RichTextLabel
@export var saida: Area3D

@export var distancia_interacao: float = 2.5
@export var tempo_senha: float = 7.0
@export_file("*.tscn") var proxima_cena: String = "res://fase_02.tscn"

var sequencia: Array[int] = [0, 1, 2, 3]
var progresso: int = 0
var resolvido: bool = false
var porta_aberta: bool = false
var trocando_cena: bool = false
var mensagem: String = ""

var passou_1: bool = false
var passou_2: bool = false

var cronometro: Timer
var ultimo_segundo: int = -1


func _ready() -> void:
	if (
		jogador_1 == null or jogador_2 == null
		or porta == null or painel == null
		or texto == null or saida == null
	):
		push_error("Preencha as referências do enigma no Inspetor.")
		set_physics_process(false)
		set_process_unhandled_input(false)
		return

	cronometro = Timer.new()
	cronometro.wait_time = maxf(tempo_senha, 0.1)
	cronometro.one_shot = true
	add_child(cronometro)
	cronometro.timeout.connect(trocar_senha)

	texto.bbcode_enabled = true
	sequencia.shuffle()
	atualizar_texto()


func palavra_colorida(indice: int) -> String:
	return "[color=%s]%s[/color]" % [
		CORES[indice],
		NOMES[indice]
	]


func atualizar_texto() -> void:
	if resolvido:
		texto.text = "ACESSO LIBERADO!\n" + mensagem
		return

	var pista := ""

	for i in range(sequencia.size()):
		if i > 0:
			pista += " > "

		pista += palavra_colorida(sequencia[i])

	var aviso_tempo := "O tempo começa no primeiro número aceito."

	if not cronometro.is_stopped():
		aviso_tempo = "Tempo restante: %d s" % int(
			ceil(cronometro.time_left)
		)

	texto.text = (
		"REPITA A SEQUÊNCIA\n"
		+ pista
		+ "\n\n1: " + palavra_colorida(0)
		+ " | 2: " + palavra_colorida(1)
		+ "\n3: " + palavra_colorida(2)
		+ " | 4: " + palavra_colorida(3)
		+ "\nOs dois devem estar perto do painel para digitar."
		+ "\n" + aviso_tempo
		+ "\nAcertos: %d / 4" % progresso
		+ "\n" + mensagem
	)


func os_dois_estao_perto() -> bool:
	var distancia_1 := painel.global_position.distance_to(
		jogador_1.global_position
	)
	var distancia_2 := painel.global_position.distance_to(
		jogador_2.global_position
	)

	return (
		distancia_1 <= distancia_interacao
		and distancia_2 <= distancia_interacao
	)


func _unhandled_input(event: InputEvent) -> void:
	if resolvido:
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	var escolha: int = -1

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

	get_viewport().set_input_as_handled()

	if not os_dois_estao_perto():
		mensagem = "Os dois precisam estar perto do painel!"
		atualizar_texto()
		return

	# Só inicia no primeiro número aceito.
	# Digitar ou errar não reinicia o prazo.
	if cronometro.is_stopped():
		cronometro.start()
		ultimo_segundo = -1

	if escolha == sequencia[progresso]:
		progresso += 1
		mensagem = "Cor correta!"
	else:
		progresso = 0
		mensagem = "Senha incorreta. Repita desde o início."

	if progresso == sequencia.size():
		abrir_porta()
	else:
		atualizar_texto()


func trocar_senha() -> void:
	if resolvido:
		return

	var anterior := sequencia.duplicate()

	# A nova ordem precisa ser diferente da anterior.
	while sequencia == anterior:
		sequencia.shuffle()

	progresso = 0
	mensagem = "Tempo esgotado! A senha mudou."

	cronometro.start()
	ultimo_segundo = -1
	atualizar_texto()


func abrir_porta() -> void:
	resolvido = true
	cronometro.stop()

	mensagem = "Aguarde a porta abrir."
	atualizar_texto()

	var animacao := create_tween()
	animacao.tween_property(
		porta,
		"position:y",
		porta.position.y + 3.0,
		1.0
	)

	await animacao.finished

	porta_aberta = true
	mensagem = "Os dois precisam atravessar a porta."
	atualizar_texto()


func _physics_process(_delta: float) -> void:
	# Atualiza o contador somente quando o segundo muda.
	if not resolvido and not cronometro.is_stopped():
		var segundo := int(ceil(cronometro.time_left))

		if segundo != ultimo_segundo:
			ultimo_segundo = segundo
			atualizar_texto()

	if not porta_aberta or trocando_cena:
		return

	var corpos := saida.get_overlapping_bodies()

	# A porta da cena1 está em Z = -5.
	if corpos.has(jogador_1) and jogador_1.global_position.z < -5.1:
		passou_1 = true

	if corpos.has(jogador_2) and jogador_2.global_position.z < -5.1:
		passou_2 = true

	# Quem voltar à sala precisa atravessar novamente.
	if jogador_1.global_position.z >= -5.0:
		passou_1 = false

	if jogador_2.global_position.z >= -5.0:
		passou_2 = false

	if passou_1 and passou_2:
		trocando_cena = true
		call_deferred("ir_para_proxima_cena")


func ir_para_proxima_cena() -> void:
	var erro := get_tree().change_scene_to_file(proxima_cena)

	if erro != OK:
		mensagem = "Não foi possível abrir a próxima fase."
		atualizar_texto()
		push_error("Erro ao abrir a fase: %s" % erro)
		trocando_cena = false

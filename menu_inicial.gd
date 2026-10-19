extends Control

@export_multiline var texto_creditos: String = "O ENIGMA DO BOTO"

@onready var jogar: Button = $BotoesMenu/Jogar
@onready var como_jogar: Button = $BotoesMenu/ComoJogar
@onready var creditos: Button = $BotoesMenu/Creditos
@onready var sair: Button = $BotoesMenu/Sair

var janela_instrucoes: AcceptDialog
var janela_creditos: AcceptDialog


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	jogar.pressed.connect(iniciar_jogo)
	como_jogar.pressed.connect(mostrar_instrucoes)
	creditos.pressed.connect(mostrar_creditos)
	sair.pressed.connect(fechar_jogo)

	criar_janelas()
	jogar.grab_focus()


func criar_janelas() -> void:
	janela_instrucoes = AcceptDialog.new()
	janela_instrucoes.title = "Como jogar"
	janela_instrucoes.dialog_autowrap = true
	janela_instrucoes.ok_button_text = "Voltar"

	janela_instrucoes.dialog_text = (
		"UMA AVENTURA PARA DUAS PESSOAS\n\n"
		+ "Jogador 1: WASD para andar e Espaço para pular.\n"
		+ "Jogador 2: setas para andar e Enter para pular.\n"
		+ "Mouse: movimentar a câmera.\n"
		+ "Esc: liberar o cursor. Clique para capturar novamente.\n\n"
		+ "PRIMEIRA FASE\n"
		+ "Aproximem os dois personagens do painel.\n"
		+ "Repitam a sequência usando as teclas 1, 2, 3 e 4.\n"
		+ "Depois do primeiro número aceito, vocês têm 10 segundos "
		+ "antes de a senha mudar.\n\n"
		+ "SEGUNDA FASE\n"
		+ "Pisem na placa para ativar a ponte temporária.\n"
		+ "Atenção: os controles dos personagens serão trocados!\n"
		+ "Ativem as seis placas, com participação dos dois.\n"
		+ "Depois, cheguem juntos ao fundo da caverna.\n"
		+ "Se alguém cair, os dois voltam à primeira fase."
	)

	add_child(janela_instrucoes)

	janela_creditos = AcceptDialog.new()
	janela_creditos.title = "Créditos"
	janela_creditos.dialog_autowrap = true
	janela_creditos.ok_button_text = "Voltar"
	add_child(janela_creditos)


func iniciar_jogo() -> void:
	jogar.disabled = true

	var erro := get_tree().change_scene_to_file(
		"res://sala_principal.tscn"
	)

	if erro != OK:
		push_error("Não foi possível abrir sala_principal.tscn.")
		jogar.disabled = false


func mostrar_instrucoes() -> void:
	janela_instrucoes.popup_centered(Vector2i(650, 550))


func mostrar_creditos() -> void:
	janela_creditos.dialog_text = texto_creditos
	janela_creditos.popup_centered(Vector2i(550, 350))


func fechar_jogo() -> void:
	get_tree().quit()

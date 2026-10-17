extends Node2D


func _draw() -> void:
	var rosa := Color("#EF91B4")
	var rosa_escuro := Color("#D36C98")

	# Cauda.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-50, 0),
		Vector2(-90, -28),
		Vector2(-80, 0),
		Vector2(-95, 20),
		Vector2(-45, 12)
	]), rosa)

	# Corpo oval.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(2.0, 0.75))
	draw_circle(Vector2.ZERO, 32.0, rosa)
	draw_set_transform(Vector2.ZERO)

	# Focinho comprido.
	draw_colored_polygon(PackedVector2Array([
		Vector2(45, -12),
		Vector2(105, -3),
		Vector2(108, 4),
		Vector2(45, 12)
	]), rosa)

	# Nadadeira dorsal.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-20, -17),
		Vector2(-10, -42),
		Vector2(15, -17)
	]), rosa)

	# Nadadeira lateral.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-5, 5),
		Vector2(15, 36),
		Vector2(25, 8)
	]), rosa_escuro)

	# Olho e brilho.
	draw_circle(Vector2(42, -10), 4.0, Color.BLACK)
	draw_circle(Vector2(43, -11), 1.3, Color.WHITE)

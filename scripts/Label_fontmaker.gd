@tool
extends Label

const height := 8

func _ready():
	#if not Engine.is_editor_hint(): return
	var font := FontFile.new()
	var img := preload("res://font-serif.png")
	var fsize := Vector2i(height, 0)
	font.set_texture_image(0, fsize, 0, img)
	for i in range(32, 32 + 16 * 14):
		var x = i % 16
		@warning_ignore("integer_division")
		var y = (i - 32) / 16
		var width = height
		for j in range(height):
			if img.get_pixel(x*height+j, y * height) == Color(1.0, 0.0, 1.0, 1.0):
				width = j
				break
		font.set_glyph_size(0, fsize, i, Vector2i(width, height))
		font.set_glyph_texture_idx(0, fsize, i, 0)
		font.set_glyph_uv_rect(0, fsize, i, Rect2(height * x, height * y, width, height))
		font.set_glyph_advance(0, height, i, Vector2i(width, 0))
		font.set_glyph_offset(0, fsize, i, Vector2i(0, 0))
		
	font.set_cache_ascent(0, height, 0)
	font.set_cache_descent(0, height, height - 3)
	font.set_cache_scale(0, height, 1)
	font.allow_system_fallback = false
	add_theme_font_size_override("font_size", height)
	add_theme_font_override("font", font)

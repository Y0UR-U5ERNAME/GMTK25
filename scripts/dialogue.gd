extends Node2D
class_name Dialogue

@onready var textn: int = 0
var texts: Array#[String]
var speakers: Array#[String]
@onready var progress := 0.0
@onready var speaker: Label = $Speaker
@onready var dialog: Label = $Dialog

signal finished

func _ready():
	if texts:
		dialog.text = texts[textn]
		speaker.text = speakers[textn]

func _process(delta):
	if textn >= len(texts):
		visible = false
		finished.emit()
		return
	progress += 30 * delta
	dialog.visible_characters = int(progress)
	if progress >= len(dialog.text) and not $Label.max_lines_visible:
		$Label.max_lines_visible = 1
	if Input.is_action_just_pressed("left_click"):
		if progress >= len(dialog.text):
			$Label.max_lines_visible = 0
			textn += 1
			progress = 0
			dialog.visible_characters = 0
			if textn < len(texts):
				dialog.text = texts[textn]
				speaker.text = speakers[textn]
		else:
			progress = len(dialog.text)

func clear():
	textn = 0
	texts.clear()
	speakers.clear()
	progress = 0
	dialog.visible_characters = 0
	dialog.text = ''
	visible = true
	$Label.max_lines_visible = 0

func switch(t, s):
	clear()
	texts = t
	speakers = s
	dialog.text = texts[textn]
	speaker.text = speakers[textn]

extends Control
var button_type = null
signal start_game()
@onready var button_vbox: VBoxContainer = $MarginContainer/MarginContainer/button_vbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Transition.fade_out()
	
	# Setelah layar menjadi hitam, baru ganti scene
	get_tree().change_scene_to_file("res://Scene/main.tscn") # Ganti dengan path scene game Anda
	focus_button()
	$MarginContainer/MarginContainer/button_vbox/Button.grab_focus()

func _on_start_pressed() -> void:
	await Transition.fade_out()
	start_game.emit()
	get_tree().change_scene_to_file("res://Scene/story_board.tscn")

func _on_visibility_changed() -> void:
	if visible:
		focus_button()

func focus_button() -> void:
	if button_vbox:
		var button: Button = button_vbox.get_child(0)
		if button is Button:
			button.grab_focus()
func _on_exit_pressed() -> void:
	get_tree().quit()
	

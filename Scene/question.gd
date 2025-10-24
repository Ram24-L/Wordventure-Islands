extends Control

@export var correct_answer_index : int = 0
@onready var label: Label = $NinePatchRect/MarginContainer/VBoxContainer/Label
@onready var choice_1: Button = $"NinePatchRect/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/Choice 1"
@onready var choice_2: Button = $"NinePatchRect/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/Choice 2"
@onready var choice_3: Button = $"NinePatchRect/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/Choice 3"
@onready var right: AudioStreamPlayer2D = $Right
@onready var False: AudioStreamPlayer2D = $False

signal answer_submitted(is_correct: bool)

var buttons: Array[Button]
var is_answered: bool = false

func _ready():
	buttons = [choice_1, choice_2, choice_3]
	 # Atur posisi awal di luar layar (misalnya, di atas)
	position = Vector2(position.x, -size.y)
	
	animate_in()
func animate_in():
	# Membuat tween baru
	var tween = create_tween()
	
	# Animasi: pindahkan posisi Y ke 0 (tengah layar) dalam waktu 0.5 detik
	tween.tween_property(self, "position:y", 0, 0.3)
	
	# Opsional: tambahkan efek pantulan
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	await tween.finished 
	choice_1.grab_focus() 
	
func _on_choice_1_pressed():
	handle_choice(0)

func _on_choice_2_pressed():
	handle_choice(1)

func _on_choice_3_pressed():
	handle_choice(2)

func handle_choice(chosen_index: int):
	if is_answered:
		return
	is_answered = true
	
	if chosen_index == correct_answer_index:
		label.text = "You got it Right! ✅"
		right.play()
		emit_signal("answer_submitted", true) # Mengirim sinyal jawaban benar
		
	else:
		label.text = "You got it Wrong! ❌"
		False.play()
		emit_signal("answer_submitted", false) # Mengirim sinyal jawaban salah
	
	# Hapus semua tombol yang salah dari scene tree
	for i in range(buttons.size()):
		if i != chosen_index:
			buttons[i].queue_free()
	
	# Pindahkan tombol yang benar ke tengah jika kamu ingin
	# buttons[chosen_index].get_parent().remove_child(buttons[chosen_index])
	# buttons[chosen_index].get_parent().add_child(buttons[chosen_index])
	
	# Tunggu sebentar sebelum menutup kotak pertanyaan
	var timer = get_tree().create_timer(1.5)
	await timer.timeout
	
	# Hapus kotak pertanyaan dari scene
	queue_free()
	emit_signal("Box closed")

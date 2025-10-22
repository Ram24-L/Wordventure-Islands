extends Control

var player1_score: int = 0
var player2_score: int = 0

@onready var header: Label = $PanelContainer/MarginContainer/VBoxContainer/header
@onready var sub_header: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/sub_header
@onready var sub_header2: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer5/sub_header
@onready var true_answer: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/true_answer
@onready var victory_player: AudioStreamPlayer = $VictoryPlayer

@onready var score: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/score
@onready var question_answered: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/question_answered
@onready var true_answer_2: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer5/true_answer_2

@onready var question_answered_2: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer5/question_answered_2

@onready var score_2: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer5/score_2

@onready var main_menu: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/main_menu

@onready var winner_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/MarginContainer/winner_label
@onready var winner_label_2: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer5/MarginContainer/winner_label2
@onready var coin: AudioStreamPlayer2D = $coin
@onready var ost_citampi_story_soundtrack_town_theme: AudioStreamPlayer = $"OstCitampiStorySoundtrack-TownTheme"


var player1_accumulation = {
	"answered_questions": 0,
	"true_answers": 0,
	"score": 0
}

var player2_accumulation = {
	"answered_questions": 0,
	"true_answers": 0,
	"score": 0
}

var player1_labels: Array[Label]
var player2_labels: Array[Label]
var indexglob;
var roll_counter: int = 0 # Menghitung jumlah lemparan dadu
var questions_to_spawn: int = 0 # Jumlah soal yang harus muncul di ronde spesial
var questions_answered_this_turn: int = 0 # Melacak soal yang sudah dijawab
func _ready() -> void:
	player1_labels = [sub_header, question_answered, true_answer, score, winner_label]
	player2_labels = [sub_header2, question_answered_2, true_answer_2, score_2, winner_label_2]
	
	true_answer.text = "True answers : " + str(player1_accumulation["true_answers"])
	score.text = "score : " + str(player1_accumulation["score"])
	question_answered.text = "Questions answered : " + str(player1_accumulation["answered_questions"])
	
	true_answer_2.text = "True answers : " + str(player2_accumulation["true_answers"])
	score_2.text = "score : " + str(player2_accumulation["score"])
	question_answered_2.text = "Questions answered : " + str(player2_accumulation["answered_questions"])
	
	# Sembunyikan semua label, termasuk header
	for label in player1_labels + player2_labels + [header]:
		label.modulate.a = 0.0
	main_menu.modulate.a = 0.0
	# Tentukan pemenang
	if player1_accumulation['score'] > player2_accumulation['score']:
		winner_label.show()
		indexglob = 9
	elif player2_accumulation['score'] > player1_accumulation['score']:
		winner_label_2.show()
		indexglob = 10
	else:
		winner_label.show()
		winner_label_2.show()
		indexglob = 11
	
	# Jalankan animasi
	animate_header()

func animate_header() -> void:
	# Atur visible_characters ke 0 untuk menyembunyikan teks
	header.visible_characters = 0
	
	# Buat tween baru untuk animasi
	var tween_header = create_tween()
	
	# Animasikan transparansi (alpha) dari 0 ke 1
	tween_header.tween_property(header, "modulate", Color(1, 1, 1, 1), 0.5)
	
	# Animasikan properti visible_characters untuk efek ketikan
	tween_header.tween_property(header, "visible_characters", header.text.length(), 1.5).set_ease(Tween.EASE_IN_OUT)
	
	# Tunggu hingga animasi ketikan selesai
	await tween_header.finished
	
	# Setelah header selesai, jalankan animasi label lainnya
	animate_labels()

func animate_labels() -> void:
	var duration: float = 0.5
	var delay: float = 0.1
	var initial_y: int = 1500
	var initial_y_offset: float = 30.0 # Jarak tombol turun ke bawah
	# Daftar label yang akan dianimasikan secara berurutan
	var victory_sound_played = false # <-- TAMBAHKAN INI
	var ordered_labels = [sub_header, sub_header2, question_answered, question_answered_2, true_answer, true_answer_2, score, score_2]
	if player1_accumulation['score'] > player2_accumulation['score']:
		ordered_labels.append(winner_label)
	elif player2_accumulation['score'] > player1_accumulation['score']:
		ordered_labels.append(winner_label_2)
	else:
		ordered_labels.append(winner_label)
		ordered_labels.append(winner_label_2)
	var index = 0
	for label in ordered_labels:
		index+=1
		# Pindahkan posisi awal di luar layar
		var final_y = label.position.y
		label.position.y = initial_y
		
		# Buat tween baru untuk setiap label
		var tween_label = create_tween()
		
		# Animasikan dari bawah ke posisi akhir
		tween_label.tween_property(label, "position:y", final_y, duration).set_ease(Tween.EASE_OUT)
		
		# Animasikan transparansi
		tween_label.tween_property(label, "modulate", Color(1, 1, 1, 1), duration).set_ease(Tween.EASE_OUT)
		
		
		# Tunggu tween selesai sebelum melanjutkan ke label berikutnya
		await tween_label.finished
		if index > 2 and index!= indexglob and index < 9:
			await(2)
			coin.play()
		if (index == 9 or index == 10) and !victory_sound_played:
			victory_player.play()
			victory_sound_played =true
			
			
	# Setelah semua label selesai, animasikan tombol main menu
	print("Animating main menu button...")
	var final_pos_button = main_menu.position
	# Pindahkan posisi awal tombol sedikit ke bawah
	main_menu.position.y += initial_y_offset
	
	var tween_button = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	# Animasikan posisi Y kembali ke posisi semula
	tween_button.tween_property(main_menu, "position", final_pos_button, duration)
	# Animasikan juga transparansinya
	tween_button.tween_property(main_menu, "modulate", Color(1, 1, 1, 1), duration)
	
	await tween_button.finished
	print("Winner screen animation complete.")
	
func _on_main_menu_pressed():
	# Ganti dengan path ke scene main menu Anda
	var main_menu_scene_path = "res://Scene/main_menu.tscn" 
	var error = get_tree().change_scene_to_file(main_menu_scene_path)
	if error != OK:
		print("Error changing scene to main menu!")

extends Node2D

@onready var player1: AnimatedSprite2D = $Player1
@onready var player2: AnimatedSprite2D = $Player2
@onready var tile_map: TileMap = $levelcontainer/TileMap

@onready var dice: Sprite2D = $dice
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var score_label_p1: Label = $Control/NinePatchRect2/p1
@onready var score_label_p2: Label = $Control/NinePatchRect2/p2
@onready var timer: Timer = $Timer
@onready var turn_label: Label = $Control/NinePatchRect3/Label
@onready var ending: CanvasLayer = $Ending
@onready var question_show: AudioStreamPlayer2D = $CanvasLayer/question_show
@onready var ending_sound: AudioStreamPlayer2D = $Ending/ending
@onready var dirt_1: AudioStreamPlayer2D = $dirt1
@onready var dirt_2: AudioStreamPlayer2D = $dirt2
@onready var wood: AudioStreamPlayer2D = $wood
@onready var wood_2: AudioStreamPlayer2D = $wood2
@onready var camera: Camera2D = $Camera2D
@onready var intro_path: Path2D = $IntroPath
@onready var animation_player: AnimationPlayer = $IntroPath/AnimationPlayer
@onready var intro_camera: Camera2D = $"IntroPath/PathFollow2D/Intro camera"
@onready var gameplay_camera_target: Marker2D = $cameratargetpoin
@onready var transition_path: Path2D = $transitionPath
@onready var transition_follow: PathFollow2D = $"transitionPath/Transition Follow"
@onready var score_ui: NinePatchRect = $Control/NinePatchRect2
@onready var turn_ui: NinePatchRect = $Control/NinePatchRect3
@onready var dice_bottom: NinePatchRect = $Control/NinePatchRect

@export var game_path : Array[Node]
@export var question_boxes : Array[PackedScene]
@export var special_tile_indices : Array[int] = [11, 25,3,17] # Contoh: Tile 11 dan 25 adalah spesial
@export var special_tile_bonus: int = 20 # <-- TAMBAHKAN INI
@export var special_tile_penalty: int = 10 # Poin yang akan dikurangi jika salah
var player1_is_finished: bool = false
var player2_is_finished: bool = false
var player1_place: int = 0
var player2_place: int = 0
var player1_turn: bool = true
@export var player1_score: int = 0
@export var player2_score: int = 0
var number_of_tiles : int
var is_moving: bool = false
var is_question_active: bool = false
const OFFSET_X = 13
const OFFSET_Y = 5
var question_acumulation : int # Variabel ini tidak digunakan, bisa dihapus
var current_turn_is_special: bool = false # Flag untuk menandai giliran spesial
# Variabel baru untuk sistem akumulasi poin soal
var player1_step_points: int = 0
var player2_step_points: int = 0
var questions_to_spawn: int = 0 # Jumlah soal yang harus muncul di ronde spesial
var questions_answered_this_turn: int = 0 # Melacak soal yang sudah dijawab
var player1_accumulation = {
	"answered_questions": 0,
	"true_answers": 0,
	"wrong_answers": 0
}

var player2_accumulation = {
	"answered_questions": 0,
	"true_answers": 0,
	"wrong_answers": 0
}
var score_end_pos: Vector2
var dice_end_pos: Vector2
var turn_ui_end_pos: Vector2
var dice_bottom_end_pos: Vector2
func _ready() -> void:
	# Sembunyikan transisi fade-in di awal agar tidak tumpang tindih
	# Anda bisa memainkannya lagi setelah animasi intro selesai jika perlu
	# 1. Simpan posisi akhir UI sebelum diubah
	score_end_pos = score_ui.position
	dice_end_pos = dice.position
	turn_ui_end_pos = turn_ui.position
	dice_bottom_end_pos = dice_bottom.position 
	# 2. Pindahkan UI ke luar layar
	# Score UI (bergerak ke atas)
	score_ui.position.y -= 200 
	# Dice UI (bergerak ke kiri)
	dice.position.x -= 300
	# Turn UI (bergerak ke kanan)
	turn_ui.position.x += 300
	dice_bottom.position.x -= 300
	# Pastikan dadu tidak bisa diklik dari awal
	dice.can_click = false
	$transition.hide() 
	setup_camera_limits()
	if not game_path.is_empty():
		# Atur posisi awal Player seperti sebelumnya
		var starting_position = game_path[0].position
		player1.position = starting_position + Vector2(-18, -5)
		player2.position = starting_position + Vector2(18, 5)

		# Jalankan fungsi untuk setup dan memutar animasi intro
		setup_and_play_intro_animation()
	else:
		# Jika tidak ada path, langsung update UI
		update_ui()

	number_of_tiles = game_path.size() - 1
	print("Number of tiles: ", number_of_tiles)
	
	# Pindahkan update_ui() ke akhir animasi jika perlu
	# Atau panggil di sini jika tidak masalah tampil dari awal
	update_ui()
	
func setup_camera_limits():
	var used_rect = tile_map.get_used_rect()
	var tile_size = tile_map.tile_set.tile_size
	intro_camera.limit_left = tile_map.map_to_local(used_rect.position).x
	intro_camera.limit_top = tile_map.map_to_local(used_rect.position).y
	intro_camera.limit_right = tile_map.map_to_local(used_rect.end).x
	intro_camera.limit_bottom = tile_map.map_to_local(used_rect.end).y
	print("Batas kamera diatur ke: ", intro_camera.limit_left, intro_camera.limit_top, intro_camera.limit_right, intro_camera.limit_bottom)

func setup_and_play_intro_animation() -> void:
	if game_path.is_empty():
		print("Game path is empty, skipping intro.")
		camera.make_current()
		return

	# ... (kode setup IntroPath tetap sama)
	var curve = Curve2D.new()
	var e = 0
	for tile_node in game_path:
		if(e >= 26 and e <=28) or e >= 30:
			e+=1
			continue
		curve.add_point(tile_node.position)
		e+=1
	intro_path.curve = curve
	
	# Jalankan animasi intro
	intro_camera.make_current()
	animation_player.play("intro_pan_zoom")
	
	# 1. Tunggu animasi intro (pan) selesai
	await animation_player.animation_finished
	
	# Hentikan AnimationPlayer agar tidak ada konflik
	animation_player.stop(true)
	await get_tree().process_frame
	
	# --- MULAI TRANSISI KEMBALI YANG MULUS ---

	# 2. Dapatkan posisi & zoom tujuan (tampilan gameplay)
	var target_pos = gameplay_camera_target.global_position
	var target_zoom = Vector2(1, 1) # Asumsi zoom 1x1 untuk lihat seluruh map

	# 3. Buat Tween untuk menganimasikan IntroCamera KEMBALI ke posisi gameplay
	var tween = create_tween()
	tween.set_parallel(true)
	var transition_duration = 1.5 # Durasi transisi kembali (bisa diatur)
	
	# Animasikan posisi IntroCamera
	tween.tween_property(
		intro_camera, "global_position", target_pos, transition_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# Animasikan zoom IntroCamera
	tween.tween_property(
		intro_camera, "zoom", target_zoom, transition_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# 4. Tunggu animasi transisi ini selesai
	await tween.finished
	
	# 5. Lakukan pergantian instan & tak terlihat ke kamera utama
	camera.global_position = target_pos
	camera.zoom = target_zoom
	camera.make_current()
	intro_camera.enabled = false
	animate_ui_in()

func animate_ui_in():
	# Pengaturan tween tetap sama
	var ease_type = Tween.EASE_OUT
	var trans_type = Tween.TRANS_BACK
	var duration = 0.5

	# Animasi 1: Score UI masuk
	var tween_score = create_tween().set_ease(ease_type).set_trans(trans_type)
	tween_score.tween_property(score_ui, "position", score_end_pos, duration)
	await tween_score.finished
	
	# Animasi 2: Turn UI masuk (Sekarang di urutan kedua)
	var tween_turn = create_tween().set_ease(ease_type).set_trans(trans_type)
	tween_turn.tween_property(turn_ui, "position", turn_ui_end_pos, duration)
	await tween_turn.finished

	# Animasi 3: Dice UI dan Latar Belakangnya masuk (Sekarang terakhir)
	var tween_dice = create_tween().set_ease(ease_type).set_trans(trans_type)
	tween_dice.tween_property(dice_bottom, "position", dice_bottom_end_pos, duration)
	tween_dice.tween_property(dice, "position", dice_end_pos, duration)
	await tween_dice.finished
	
	# Dadu baru bisa diklik setelah semua animasi selesai
	dice.can_click = true
	print("UI is ready, game can start!")
	
func update_ui():
	score_label_p1.text =  str(player1_score)
	score_label_p2.text =  str(player2_score)

	

func add_score(player_number: int, points: int):
	if player_number == 1:
		player1_score += points
		player1_accumulation["true_answers"] += 1   # update jawaban benar
	else:
		player2_score += points
		player2_accumulation["true_answers"] += 1   # update jawaban benar
	update_ui()


func _on_dice_dice_has_rolled(roll: int) -> void:
	if is_moving or is_question_active:
		return
	
	is_moving = true
	dice.can_click = false
	
	# DIUBAH: Siapkan variabel untuk menampung jumlah langkah
	var steps_moved: int = 0
	
	# Lakukan pergerakan pemain dan simpan hasilnya
	if player1_turn:
		if not player1_is_finished:
			steps_moved = await move(player1, player1_place, roll)
	else:
		if not player2_is_finished:
			steps_moved = await move(player2, player2_place, roll)

	# PRIORITAS 1: Tile Spesial (tidak berubah)
	if current_turn_is_special:
		print("--- Special Tile Event! ---")
		questions_to_spawn = 1
		questions_answered_this_turn = 0
		spawn_question_box()
		return

	# PRIORITAS 2: Logika Akumulasi (DIUBAH menggunakan steps_moved)
	if player1_turn:
		player1_step_points += steps_moved # Menggunakan langkah, bukan roll
		print("Player 1 moved %d steps. Total step points: %d" % [steps_moved, player1_step_points])
		
		if player1_step_points >= 3:
			questions_to_spawn = floori(player1_step_points / 3.0)
			player1_step_points %= 3
			questions_answered_this_turn = 0
			print("Player 1 gets %d questions. Remaining points: %d" % [questions_to_spawn, player1_step_points])
			spawn_question_box()
		else:
			end_turn()
	else: # Giliran Player 2
		player2_step_points += steps_moved # Menggunakan langkah, bukan roll
		print("Player 2 moved %d steps. Total step points: %d" % [steps_moved, player2_step_points])

		if player2_step_points >= 3:
			questions_to_spawn = floori(player2_step_points / 3.0)
			player2_step_points %= 3
			questions_answered_this_turn = 0
			print("Player 2 gets %d questions. Remaining points: %d" % [questions_to_spawn, player2_step_points])
			spawn_question_box()
		else:
			end_turn()


func move(player: Node2D, player_place: int, roll: int) -> int: # DIUBAH: Mengembalikan integer
	var step_time = 0.25
	var wait_time = 0.25
	var current_place = player_place
	var steps_taken: int = 0 # BARU: Penghitung langkah
	
	for i in range(roll):
		if current_place >= number_of_tiles:
			break # Berhenti jika sudah di ujung papan
		
		current_place += 1
		steps_taken += 1 # BARU: Tambah 1 setiap kali melangkah
		
		var target_position = game_path[current_place].position
		
		if player == player1:
			target_position.x -= OFFSET_X
		else:
			target_position.x += OFFSET_X
		
		var tween = create_tween()
		tween.tween_property(player, "position", target_position, step_time)
		# ... (logika suara Anda tidak berubah) ...
		await tween.finished
		
		var timer_delay = get_tree().create_timer(wait_time)
		await timer_delay.timeout
	
	if player == player1:
		player1_place = current_place
	else:
		player2_place = current_place
		
	is_moving = false
	if current_place in special_tile_indices:
		current_turn_is_special = true
		
	return steps_taken # BARU: Kembalikan jumlah langkah yang diambil


func spawn_question_box():
	if question_boxes.is_empty():
		end_turn()
		return
	
	is_question_active = true
	var question_box_scene = question_boxes.pick_random()
	var question_box = question_box_scene.instantiate()
	question_show.play()
	# Hubungkan sinyal
	if question_box.has_signal("answer_submitted"):
		question_box.answer_submitted.connect(_on_question_box_answer_submitted)
	
	canvas_layer.add_child(question_box)
	if question_box.has_signal("answer_submitted"):
		question_box.answer_submitted.connect(_on_question_box_answer_submitted)
	
	canvas_layer.add_child(question_box)
	

func _on_question_box_answer_submitted(is_correct: bool):
	# Tentukan pemain mana yang baru saja menjawab
	var player_who_answered = 0
	
	# ---- KONDISI YANG SUDAH DIPERBAIKI ----
	if player1_turn and not player1_is_finished: # Jika ini adalah giliran Player 1
		player_who_answered = 1
		player1_accumulation["answered_questions"] += 1
	else: # Jika ini adalah giliran Player 2
		player_who_answered = 2
		player2_accumulation["answered_questions"] += 1
	# ------------------------------------
	
	# Logika skor Anda di bawah ini sudah benar dan tidak perlu diubah
	if current_turn_is_special:
		if is_correct:
			add_score(player_who_answered, special_tile_bonus)
		else:
			if player_who_answered == 1:
				player1_score -= special_tile_penalty
				player1_accumulation["wrong_answers"] += 1
			else:
				player2_score -= special_tile_penalty
				player2_accumulation["wrong_answers"] += 1
	else:
		if is_correct:
			add_score(player_who_answered, 10)
		else:
			if player_who_answered == 1:
				player1_accumulation["wrong_answers"] += 1
			else:
				player2_accumulation["wrong_answers"] += 1
	
	update_ui()
	
	# Logika untuk soal berurutan
	questions_answered_this_turn += 1
	if questions_answered_this_turn < questions_to_spawn:
		spawn_question_box()
	else:
		end_turn()
	



func end_turn():
	print(player1_accumulation)
	print(player2_accumulation)
	is_question_active = false
	current_turn_is_special = false
	
	# --- LOGIKA PENGGANTIAN GILIRAN YANG HILANG ---
	if player1_turn:
		if not player2_is_finished: # Ganti giliran hanya jika player 2 belum selesai
			player1_turn = false
	else: # Ini adalah giliran player 2
		if not player1_is_finished: # Ganti giliran hanya jika player 1 belum selesai
			player1_turn = true
	# ---------------------------------------------

	# Update label giliran SETELAH nilainya diubah
	if player1_turn:
		turn_label.text = "Player 1 Turn"
	else:
		turn_label.text = "Player 2 Turn"
	
	dice.can_click = true
	check_game_end()

func check_game_end():
	if player1_place >= number_of_tiles:
		if not player1_is_finished:
			print("Player 1 has finished the race!")
			player1_is_finished = true
	
	if player2_place >= number_of_tiles:
		if not player2_is_finished:
			print("Player 2 has finished the race!")
			player2_is_finished = true
	
	if player1_is_finished and player2_is_finished:
		print("Game ends! Final Scores - Player 1: ", player1_score, ", Player 2: ", player2_score)
		dice.queue_free()
		ending_sound.play()
		await get_tree().create_timer(3.0).timeout
		show_win_screen()
		
func show_win_screen():
	var win_scene = preload("res://Scene/winner_screeen.tscn")
	var win_screen = win_scene.instantiate()
	# Kirim data skor
	win_screen.player1_score = player1_score
	win_screen.player2_score = player2_score
	# Kirim statistik dictionary
	win_screen.player1_accumulation = player1_accumulation
	win_screen.player2_accumulation = player2_accumulation
	# Misal kamu punya CanvasLayer khusus UI
	ending.add_child(win_screen)

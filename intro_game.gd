extends Control

# Referensi ke node-node di scene
@onready var logo1: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/TextureRect
@onready var logo2: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/TextureRect2
@onready var disclaimer_label: Label = $MarginContainer/VBoxContainer/Label

# Pengaturan durasi agar mudah diubah
const FADE_DURATION = 0.8  # Durasi animasi fade
const TYPING_SPEED = 0.05  # Kecepatan mengetik (detik per karakter)
const FINAL_PAUSE = 1.5    # Jeda setelah teks selesai diketik

func _ready() -> void:
	# Jaring pengaman untuk memastikan semua elemen tidak terlihat di awal
	logo1.modulate.a = 0.0
	logo2.modulate.a = 0.0
	disclaimer_label.modulate.a = 0.0
	disclaimer_label.visible_characters = 0
	
	# Memulai seluruh sekuens animasi
	play_splash_sequence()

func play_splash_sequence() -> void:
	# Jeda singkat di awal
	await get_tree().create_timer(0.5).timeout

	# 1. Tampilkan Logo 1 & 2 secara bersamaan (Fade In)
	var tween_logos_in = create_tween().set_parallel()
	tween_logos_in.tween_property(logo1, "modulate:a", 1.0, FADE_DURATION)
	tween_logos_in.tween_property(logo2, "modulate:a", 1.0, FADE_DURATION)
	await tween_logos_in.finished
	
	# 2. Tampilkan Teks dengan Efek Mengetik
	disclaimer_label.modulate.a = 1.0
	var typing_duration = disclaimer_label.text.length() * TYPING_SPEED
	
	var tween_typing = create_tween()
	tween_typing.tween_property(disclaimer_label, "visible_characters", disclaimer_label.text.length(), typing_duration)
	await tween_typing.finished

	# 3. Jeda sejenak setelah semua muncul
	await get_tree().create_timer(FINAL_PAUSE).timeout

# 4. Sembunyikan SEMUA elemen secara bersamaan (Fade Out)
	var tween_all_out = create_tween().set_parallel()
	tween_all_out.tween_property(logo1, "modulate:a", 0.0, FADE_DURATION)
	tween_all_out.tween_property(logo2, "modulate:a", 0.0, FADE_DURATION)
	tween_all_out.tween_property(disclaimer_label, "modulate:a", 0.0, FADE_DURATION)
	await tween_all_out.finished
	
	await Transition.fade_in()


	print("DEBUG 3: Mencoba mengganti scene SEKARANG...")
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
	print("DEBUG 4: Perintah ganti scene sudah dieksekusi.")

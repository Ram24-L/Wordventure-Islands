extends Control

@onready var label: Label = $Label
@onready var fade_overlay: ColorRect = $FadeOverlay

# Daftar kalimat narasi Anda dalam Bahasa Inggris
var story_lines = [
	"On an island full of wonder...",
	"A challenge was given: to prove who has the greatest vocabulary of all.",
	"Answer the riddles to advance and claim victory.",
	"This is... Wordventure Island!"
]

func _ready():
	# Jalankan sekuens cerita
	play_story_sequence()

func play_story_sequence() -> void:
	# Durasi fade in/out dalam detik
	var fade_duration = 0.5
	# Durasi teks tampil di layar setelah selesai diketik
	var display_duration = 2.5
	# Kecepatan mengetik (detik per karakter)
	var typing_speed = 0.1

	# 1. Mulai dengan layar hitam
	fade_overlay.color.a = 1.0
	label.visible_characters = 0
	
	# 2. Transisi FADE IN dari hitam
	var tween_fade_in = create_tween()
	tween_fade_in.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
	await tween_fade_in.finished
	
	# Jeda singkat setelah fade in
	await get_tree().create_timer(0.5).timeout

	# 3. Loop untuk setiap kalimat dengan efek mengetik
	for line in story_lines:
		label.text = line
		label.visible_characters = 0 # Reset sebelum mengetik
		
		# Tween untuk efek mengetik
		var tween_typing = create_tween()
		var typing_duration = line.length() * typing_speed
		tween_typing.tween_property(label, "visible_characters", line.length(), typing_duration)
		await tween_typing.finished
		
		# Jeda untuk membaca
		await get_tree().create_timer(display_duration).timeout

	# 4. Transisi FADE OUT ke hitam
	Transition.fade_in()

	# 5. Setelah semua narasi selesai, pindah ke scene main menu
	# Ganti dengan path main menu Anda
	get_tree().change_scene_to_file("res://Scene/map.tscn")

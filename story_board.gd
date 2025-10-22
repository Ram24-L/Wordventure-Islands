extends Control

@onready var label: Label = $Label
@onready var fade_overlay: ColorRect = $FadeOverlay

var story_lines = [
	"On an island full of wonder...",
	"A challenge was given: to prove who has the greatest vocabulary of all.",
	"Answer the riddles to advance and claim victory.",
	"This is... Wordventure Island!"
]

# 1. Tambahkan variabel "flag" ini
var is_skipping: bool = false

func _ready():
	play_story_sequence()

# Tambahkan "async" karena kita akan "await"
func play_story_sequence() -> void:
	var fade_duration = 0.5
	var display_duration = 2.5
	var typing_speed = 0.1

	fade_overlay.color.a = 1.0
	label.visible_characters = 0
	
	var tween_fade_in = create_tween()
	tween_fade_in.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
	await tween_fade_in.finished
	# 2. Cek flag setelah setiap "await"
	if is_skipping: return 

	await get_tree().create_timer(0.5).timeout
	if is_skipping: return

	for line in story_lines:
		# 3. Cek flag di awal loop
		if is_skipping: return 
		
		label.text = line
		label.visible_characters = 0
		
		var tween_typing = create_tween()
		var typing_duration = line.length() * typing_speed
		tween_typing.tween_property(label, "visible_characters", line.length(), typing_duration)
		await tween_typing.finished
		if is_skipping: return # Cek lagi
		
		await get_tree().create_timer(display_duration).timeout
		if is_skipping: return # Cek lagi

	# 4. Transisi FADE OUT (Hanya jika tidak di-skip)
	# Pastikan Anda "await" transisi Anda.
	# Saya berasumsi Transition.fade_in() adalah fungsi async
	await Transition.fade_in()
	
	# 5. Cek sekali lagi sebelum pindah scene
	if is_skipping: return
	get_tree().change_scene_to_file("res://Scene/map.tscn")


# 6. Jadikan fungsi ini "async" agar bisa "await"
func _on_button_pressed() -> void:
	# 7. Jika sudah proses skip, jangan lakukan apa-
	print("tombol terklik")
	if is_skipping:
		return
	print("tombol terklik")
	# 8. Set flag agar sekuens utama berhenti
	is_skipping = true
	
	# 9. Jalankan transisi DAN TUNGGU (await) sampai selesai
	Transition.fade_in()
	await Transition.fade_in()

	# 10. Baru pindah scene setelah transisi selesai
	get_tree().change_scene_to_file("res://Scene/map.tscn")
  

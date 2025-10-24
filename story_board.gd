extends Control

@onready var label: Label = $ColorRect/Label
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var label_2: Label = $ColorRect/Label2

var story_lines = [
	"On an island full of wonder...",
	"A challenge was given: to prove who has the greatest vocabulary of all.",
	"Answer the riddles to advance and claim victory.",
	"This is... Wordventure Island!"
]

# 1. Tambahkan variabel "flag" ini
var is_skipping: bool = false

func _ready():
	start_flashing()
	play_story_sequence()
func start_flashing():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(label_2, "modulate:a", 0.0, 1.5)
	tween.tween_property(label_2, "modulate:a", 1.0, 1.5)
func _unhandled_input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("skip")):
			# 7. Jika sudah proses skip, jangan lakukan apa-
		print("tombol terklik")
		if is_skipping:
			return
		print("tombol terklik")
		# 8. Set flag agar sekuens utama berhenti
		is_skipping = true
		

		# 10. Baru pindah scene setelah transisi selesai
		get_tree().change_scene_to_file("res://Scene/map.tscn")
  

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

	await Transition.fade_in()
	
	# 5. Cek sekali lagi sebelum pindah scene
	if is_skipping: return
	get_tree().change_scene_to_file("res://Scene/map.tscn")

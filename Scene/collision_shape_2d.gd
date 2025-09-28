extends Area2D

@onready var animation_player = $"../AnimationPlayer"
@onready var timer = $"../Timer"
@onready var diceroll =  $"../diceroll"# Ganti dengan nama node suara

var can_click = true

# Fungsi untuk menangani input yang tidak ditangani oleh node UI (seperti spasi)
func _unhandled_input(event: InputEvent) -> void:
	# Cek apakah itu tombol spasi dan sedang ditekan
	if event.is_action_just_pressed("ui_accept"): # Menggunakan ui_accept yang biasanya terikat ke spasi atau enter
		if can_click:
			trigger_roll()
			# Jangan lupa set event.is_handled() jika tidak ingin input lain juga memprosesnya
			get_viewport().set_input_as_handled()

# Fungsi yang terpanggil saat Area2D di klik
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Cek apakah itu tombol kiri mouse dan sedang ditekan
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if can_click:
			trigger_roll()
			get_viewport().set_input_as_handled()

# Fungsi pembantu untuk memulai animasi dan suara
func trigger_roll():
	can_click = false
	animation_player.play("roll")
	timer.start()
	diceroll.play()

# Fungsi yang dipanggil oleh Timer setelah selesai
func _on_Timer_timeout():
	can_click = true

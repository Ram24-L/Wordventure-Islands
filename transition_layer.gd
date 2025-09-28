extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# PENTING: Pastikan angka ini SAMA dengan durasi animasi Anda di editor
const FADE_DURATION = 1

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# Fungsi untuk memunculkan scene dari hitam (FADE IN)
func fade_in():
	animation_player.play("fade_from_black")
	# Tunggu selama durasi animasi secara manual
	await get_tree().create_timer(FADE_DURATION).timeout

# Fungsi untuk membuat scene menghilang ke hitam (FADE OUT)
func fade_out():
	animation_player.play("fade_to_black")
	# Tunggu selama durasi animasi secara manual
	await get_tree().create_timer(FADE_DURATION).timeout

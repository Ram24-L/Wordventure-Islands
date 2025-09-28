extends Node

var questions = []
var used_questions = []

func _ready():
	load_questions_from_file("res://questions.json")

func load_questions_from_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parser = JSON.new()
		var error = parser.parse(content)
		if error == OK:
			questions = parser.get_data()
			randomize() # Mengacak urutan soal
			print("Questions loaded successfully!")
		else:
			print("Error parsing JSON: ", parser.get_error_message(), " at line ", parser.get_error_line())
		file.close()
	else:
		print("Failed to open file: ", path)

func get_next_question() -> Dictionary:
	if questions.is_empty():
		# Jika semua soal sudah digunakan, isi ulang dari daftar soal yang sudah digunakan
		questions = used_questions
		used_questions = []
		if questions.is_empty():
			print("No questions available!")
			return {}

	# Ambil soal pertama dari array
	var next_question = questions.pop_front()
	# Pindahkan ke daftar soal yang sudah digunakan
	used_questions.append(next_question)
	
	return next_question

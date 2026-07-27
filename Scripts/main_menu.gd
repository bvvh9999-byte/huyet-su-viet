extends Control

# Đọc file Bảng Hướng dẫn từ trong thư mục UI
var tutorial_scene = preload("res://UI/TutorialScreen.tscn")

func _on_btn_play_pressed():
	print("=> BẮT ĐẦU GAME! ĐANG TẢI LỜI DẪN...")
	get_tree().change_scene_to_file("res://UI/prologue_screen.tscn")

func _on_btn_quit_pressed():
	print("=> THOÁT GAME!")
	get_tree().quit()

func _on_btn_load_pressed():
	# Cố gắng Tải game
	var co_file_save = Global.load_game()
	if co_file_save:
		get_tree().change_scene_to_file("res://Scenes/world.tscn")
	else:
		%BtnLoad.text = "CHƯA CÓ DỮ LIỆU LƯU!"

# ĐÂY LÀ HÀM BẠN VỪA KẾT NỐI XONG NÈ:
func _on_btn_tutorial_pressed():
	if tutorial_scene:
		# Đẻ ra cái bảng hướng dẫn và dán nó đè lên màn hình Menu
		var tut = tutorial_scene.instantiate()
		add_child(tut)

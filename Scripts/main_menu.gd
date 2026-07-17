extends Control

func _on_btn_play_pressed():
	print("=> BẮT ĐẦU GAME! ĐANG TẢI LỜI DẪN...")
	# MỞ MÀN HÌNH LỜI DẪN TRƯỚC!
	get_tree().change_scene_to_file("res://UI/prologue_screen.tscn")

func _on_btn_quit_pressed():
	print("=> THOÁT GAME!")
	get_tree().quit()


func _on_btn_load_pressed():
	# Cố gắng Tải game
	var co_file_save = Global.load_game()
	
	if co_file_save:
		# Nếu tải thành công -> Bỏ qua Lời dẫn, bay thẳng vào Map đang chơi!
		# (Tạm thời cứ cho vào World 1 trước, sau này học cách lưu tọa độ Map sau nhé)
		get_tree().change_scene_to_file("res://Scenes/world.tscn")
	else:
		# Nếu chưa có file save -> Đổi chữ báo lỗi
		%BtnLoad.text = "CHƯA CÓ DỮ LIỆU LƯU!"

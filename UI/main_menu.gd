extends Control

func _on_btn_play_pressed():
	print("=> BẮT ĐẦU GAME! ĐANG TẢI LỜI DẪN...")
	# MỞ MÀN HÌNH LỜI DẪN TRƯỚC!
	get_tree().change_scene_to_file("res://UI/prologue_screen.tscn")

func _on_btn_quit_pressed():
	print("=> THOÁT GAME!")
	get_tree().quit()

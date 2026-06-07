extends Control

func _on_btn_play_pressed():
	print("=> BẮT ĐẦU GAME! ĐANG TẢI WORLD 1...")
	# CHÚ Ý: Sửa lại đường dẫn này cho khớp với file Map 1 của bạn nhé!
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_btn_quit_pressed():
	print("=> THOÁT GAME!")
	get_tree().quit()

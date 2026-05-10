extends CanvasLayer

func _on_button_pressed(): # NÚT HỒI SINH
	# 1. Bơm lại đầy máu cho Player trong "Bộ não"
	Global.player_hp = Global.max_hp
	
	# 2. Tiếp tục thời gian của game
	get_tree().paused = false 
	
	# 3. Tải lại nguyên xi màn hình hiện tại (Reset game)
	get_tree().reload_current_scene() 
	
	# 4. Xóa cái màn hình Game Over này đi
	queue_free()

func _on_button_2_pressed(): # NÚT THOÁT
	get_tree().quit() # Tắt luôn game

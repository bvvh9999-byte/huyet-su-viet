extends CanvasLayer

func _ready():
	# Đoạn code này ÉP toàn bộ màn hình này và TẤT CẢ các nút bên trong
	# bắt buộc phải thức tỉnh, không bao giờ được phép Pause!
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_button_pressed(): # Nhớ xem tên hàm này có giống tên của bạn không nhé
	print("=> NÚT HỒI SINH ĐÃ ĐƯỢC BẤM!") 
	Global.player_hp = Global.max_hp
	get_tree().paused = false 
	get_tree().reload_current_scene() 
	queue_free()

func _on_button_2_pressed(): # Nhớ xem tên hàm này có giống tên của bạn không nhé
	print("=> NÚT THOÁT ĐÃ ĐƯỢC BẤM!")
	get_tree().quit()

extends CanvasLayer

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS

# --- NÚT 1 ĐÃ CÓ MŨI TÊN XANH ---
func _on_button_pressed():
	print("=> ĐÃ CLICK NÚT ĐỒNG Ý!")
	Global.unlocked_song_kiem = true
	get_tree().paused = false 
	queue_free() 

# --- NÚT 2 ĐÃ CÓ MŨI TÊN XANH ---
func _on_button_2_pressed():
	print("=> ĐÃ CLICK NÚT TỪ CHỐI!")
	get_tree().paused = false 
	queue_free()

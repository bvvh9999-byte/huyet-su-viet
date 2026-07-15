extends CanvasLayer

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS # Ép chạy khi game Pause

# KHI CHỌN NÚT 1: TĂNG SÁT THƯƠNG
func _on_button_pressed():
	Global.bonus_damage += 10 # Cộng 10 đam vào hệ thống
	ket_thuc_chon_skill()

# KHI CHỌN NÚT 2: TĂNG MÁU TỐI ĐA
func _on_button_2_pressed():
	Global.max_hp += 50
	Global.player_hp += 50 # Hồi luôn 50 máu đó cho Player
	ket_thuc_chon_skill()

# HÀM DÙNG CHUNG: ĐÓNG MÀN HÌNH VÀ TIẾP TỤC GAME
func ket_thuc_chon_skill():
	get_tree().paused = false # Rã đông thời gian
	queue_free() # Xóa màn hình chọn skill đi

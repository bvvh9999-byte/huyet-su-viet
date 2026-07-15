extends CanvasLayer

@onready var lbl_tien = %LblTien

func _ready():
	cap_nhat_tien()

func cap_nhat_tien():
	lbl_tien.text = "Vàng của bạn: " + str(Global.vang)

# --- NÚT MUA MÁU ---
func _on_btn_mua_mau_pressed():
	if Global.vang >= 20:
		Global.vang -= 20
		Global.kho_vat_pham.append("Bình Máu Nhỏ") # Ném vào túi đồ
		print("=> Đã mua 1 Bình Máu!")
		cap_nhat_tien()
	else:
		print("=> KHÔNG ĐỦ TIỀN!")

# --- NÚT MUA KIẾM ---
func _on_btn_mua_kiem_pressed():
	if Global.vang >= 100:
		Global.vang -= 100
		Global.kho_vu_khi.append("Kiếm Bạc") 
		print("=> Đã mua Kiếm Bạc!")
		cap_nhat_tien()
	else:
		print("=> KHÔNG ĐỦ TIỀN!")

# --- NÚT THOÁT ---
func _on_btn_thoat_pressed():
	get_tree().paused = false # Rã đông game
	queue_free() # Tắt bảng Shop đi

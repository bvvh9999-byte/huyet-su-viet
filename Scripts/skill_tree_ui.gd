extends CanvasLayer

@onready var lbl_diem = %LblDiem
@onready var btn_toc_danh = %BtnTocDanh
@onready var btn_song_kiem = %BtnSongKiem
@onready var btn_hao_khi = %BtnHaoKhi

func _ready():
	cap_nhat_giao_dien()

func cap_nhat_giao_dien():
	lbl_diem.text = "Điểm Kỹ Năng (SP): " + str(Global.diem_ky_nang)
	
	if Global.skill_tang_toc_danh:
		btn_toc_danh.text = "[ĐÃ HỌC] Tăng Tốc Đánh"
		btn_toc_danh.disabled = true 
		
	if Global.skill_song_kiem:
		btn_song_kiem.text = "[ĐÃ HỌC] Song Kiếm Liên Hoàn"
		btn_song_kiem.disabled = true
		
	if Global.skill_hao_khi:
		btn_hao_khi.text = "[ĐÃ HỌC] Hào Khí Đông A"
		btn_hao_khi.disabled = true

func _on_btn_toc_danh_pressed():
	if Global.diem_ky_nang >= 1:
		Global.diem_ky_nang -= 1
		Global.skill_tang_toc_danh = true
		print("=> ĐÃ HỌC: Tăng Tốc Đánh!")
		cap_nhat_giao_dien()

func _on_btn_song_kiem_pressed():
	if not Global.skill_tang_toc_danh:
		print("=> Phải học Tốc Đánh trước!")
		return
		
	if Global.diem_ky_nang >= 2:
		Global.diem_ky_nang -= 2
		Global.skill_song_kiem = true
		cap_nhat_giao_dien()

func _on_btn_hao_khi_pressed():
	if Global.diem_ky_nang >= 3:
		Global.diem_ky_nang -= 3
		Global.skill_hao_khi = true
		cap_nhat_giao_dien()


func _on_btn_thoat_pressed():
	get_tree().paused = false
	queue_free()

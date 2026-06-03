extends CanvasLayer

# ==========================================
# KẾT NỐI VỚI GIAO DIỆN (Dùng % Unique Name)
# ==========================================
@onready var lbl_level = %LblLevel
@onready var lbl_hp = %LblHP
@onready var lbl_damage = %LblDamage
@onready var lbl_speed = %LblSpeed

@onready var btn_weapon = %BtnWeapon
@onready var btn_armor = %BtnArmor
@onready var btn_accessory = %BtnAccessory

@onready var list_vu_khi = %"Vũ Khí"
@onready var list_vat_pham = %"Vật Phẩm"

func _ready():
	# Ép bảng Profile luôn hoạt động ngay cả khi game đang bị Pause
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Load thông số ngay khi vừa mở bảng
	cap_nhat_giao_dien()

# ==========================================
# HÀM LÀM MỚI TOÀN BỘ GIAO DIỆN MÀN HÌNH
# ==========================================
func cap_nhat_giao_dien():
	# 1. Cập nhật cột CHỈ SỐ (Lấy từ Global)
	lbl_level.text = "Cấp độ: " + str(Global.player_level)
	lbl_hp.text = "Sinh lực: " + str(Global.player_hp) + " / " + str(Global.max_hp)
	
	var tong_dam = 10 + Global.bonus_damage
	lbl_damage.text = "Sát thương: " + str(tong_dam)
	lbl_speed.text = "Tốc độ: " + str(Global.toc_do)
	
	# 2. Cập nhật cột TRANG BỊ (Đồ đang mặc trên người)
	btn_weapon.text = "Vũ khí: " + Global.trang_bi_vu_khi
	btn_armor.text = "Giáp: " + Global.trang_bi_ao_giap
	btn_accessory.text = "Phụ kiện: " + Global.trang_bi_day_chuyen
	
	# 3. Làm sạch Kho Đồ cũ trên màn hình
	list_vu_khi.clear()
	list_vat_pham.clear()
	
	# 4. Đổ dữ liệu mới từ "Túi Không Gian" (Global) vào cột KHO ĐỒ
	for vu_khi in Global.kho_vu_khi:
		list_vu_khi.add_item(vu_khi)
		
	for vat_pham in Global.kho_vat_pham:
		list_vat_pham.add_item(vat_pham)


# ==========================================
# SỰ KIỆN CLICK ĐÚP VÀO VŨ KHÍ TRONG KHO
# ==========================================
func _on_vũ_khí_item_activated(index):
	# Lấy tên món vũ khí bạn vừa click đúp
	var ten_vu_khi_moi = Global.kho_vu_khi[index]
	
	# Lột vũ khí đang cầm trên tay cất vào lại kho đồ (nếu có cầm)
	if Global.trang_bi_vu_khi != "Chưa có":
		Global.kho_vu_khi.append(Global.trang_bi_vu_khi)
		
	# Mặc vũ khí mới lên người
	Global.trang_bi_vu_khi = ten_vu_khi_moi
	
	# Xóa vũ khí mới đó khỏi kho (vì đang cầm trên tay rồi)
	Global.kho_vu_khi.remove_at(index)
	
	# TĂNG SÁT THƯƠNG DỰA TRÊN TÊN VŨ KHÍ VỪA MẶC!
	if ten_vu_khi_moi == "Kiếm Gỗ Tầm Sét":
		Global.bonus_damage = 5
	elif ten_vu_khi_moi == "Gươm Rỉ Sét":
		Global.bonus_damage = 15
	elif ten_vu_khi_moi == "Huyết Kiếm": # Quà của NPC
		Global.bonus_damage = 30
		
	# Tải lại toàn bộ giao diện để thấy sự thay đổi ngay lập tức
	cap_nhat_giao_dien()
	
	# Ép giao diện nhả quyền điều khiển bàn phím trả lại cho Player
	get_viewport().gui_release_focus()


# ====================================================
# KHI CLICK ĐÚP VÀO 1 MÓN ĐỒ TRONG TAB VẬT PHẨM
# ====================================================
func _on_vật_phẩm_item_activated(index):
	# 1. Lấy tên vật phẩm bạn vừa click đúp
	var ten_vat_pham = Global.kho_vat_pham[index]
	
	print("\n=> ĐANG CỐ SỬ DỤNG VẬT PHẨM: ", ten_vat_pham)
	
	var da_su_dung_thanh_cong = false
	
	# 2. KIỂM TRA LOẠI VẬT PHẨM VÀ TÁC DỤNG CỦA NÓ
	if ten_vat_pham == "Bình Máu Nhỏ":
		if Global.player_hp < Global.max_hp:
			# Bơm 30 máu
			Global.player_hp += 30
			if Global.player_hp > Global.max_hp:
				Global.player_hp = Global.max_hp # Không cho lố máu tối đa
				
			print("-> Uống máu ngon quá! Đã hồi phục sinh lực.")
			da_su_dung_thanh_cong = true
		else:
			print("-> Máu đang đầy, không cần uống!")
			
	elif ten_vat_pham == "Lá Bùa Hồi Sinh":
		print("-> Lá bùa này chỉ tự động kích hoạt khi bạn chết. Không thể dùng tay!")
	
	# 3. NẾU UỐNG THÀNH CÔNG -> XÓA NÓ KHỎI TÚI ĐỒ VÀ CẬP NHẬT GIAO DIỆN
	if da_su_dung_thanh_cong:
		Global.kho_vat_pham.remove_at(index) # Xóa bình máu đi
		cap_nhat_giao_dien() # Tải lại hình ảnh
	
	# 4. CÂU THẦN CHÚ CHỐNG KẸT NÚT THOÁT (BẮT BUỘC)
	# Dù dùng thành công hay thất bại, cũng phải nhả quyền kiểm soát bàn phím ra!
	get_viewport().gui_release_focus()

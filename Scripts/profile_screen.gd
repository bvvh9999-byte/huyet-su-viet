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
	# Ép bảng Profile luôn hoạt động khi game Pause
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# LỚP BẢO VỆ 1: CẤM TẤT CẢ GIAO DIỆN CƯỚP BÀN PHÍM
	btn_weapon.focus_mode = Control.FOCUS_NONE
	btn_armor.focus_mode = Control.FOCUS_NONE
	btn_accessory.focus_mode = Control.FOCUS_NONE
	list_vu_khi.focus_mode = Control.FOCUS_NONE
	list_vat_pham.focus_mode = Control.FOCUS_NONE
	
	# Lấy TabContainer (Khung chứa Tab) ra và cấm nó cướp phím luôn
	var tab_container = list_vu_khi.get_parent()
	if tab_container and tab_container is TabContainer:
		tab_container.focus_mode = Control.FOCUS_NONE
	
	# Load thông số khi vừa mở bảng
	cap_nhat_giao_dien()

# ==========================================
# HÀM LÀM MỚI TOÀN BỘ GIAO DIỆN MÀN HÌNH
# ==========================================
func cap_nhat_giao_dien():
	# 1. Cập nhật cột CHỈ SỐ
	lbl_level.text = "Cấp độ: " + str(Global.player_level)
	lbl_hp.text = "Sinh lực: " + str(Global.player_hp) + " / " + str(Global.max_hp)
	
	var tong_dam = 10 + Global.bonus_damage
	lbl_damage.text = "Sát thương: " + str(tong_dam)
	lbl_speed.text = "Tốc độ: " + str(Global.toc_do)
	
	# 2. Cập nhật cột TRANG BỊ
	btn_weapon.text = "Vũ khí: " + Global.trang_bi_vu_khi
	btn_armor.text = "Giáp: " + Global.trang_bi_ao_giap
	btn_accessory.text = "Phụ kiện: " + Global.trang_bi_day_chuyen
	
	# 3. Làm sạch Kho Đồ cũ trên màn hình
	list_vu_khi.clear()
	list_vat_pham.clear()
	
	# 4. Đổ dữ liệu mới vào KHO ĐỒ
	for vu_khi in Global.kho_vu_khi:
		list_vu_khi.add_item(vu_khi)
		
	for vat_pham in Global.kho_vat_pham:
		list_vat_pham.add_item(vat_pham)

# ==========================================
# CLICK ĐÚP VÀO VŨ KHÍ TRONG KHO ĐỂ TRANG BỊ
# ==========================================
func _on_vũ_khí_item_activated(index):
	var ten_vu_khi_moi = Global.kho_vu_khi[index]
	
	# Lột vũ khí đang cầm cất vào lại kho đồ 
	if Global.trang_bi_vu_khi != "Chưa có":
		Global.kho_vu_khi.append(Global.trang_bi_vu_khi)
		
	# Mặc vũ khí mới lên người
	Global.trang_bi_vu_khi = ten_vu_khi_moi
	Global.kho_vu_khi.remove_at(index)
	
	# TĂNG SÁT THƯƠNG TÙY ĐỘ HIẾM!
	if ten_vu_khi_moi == "Kiếm Gỗ Tầm Sét": Global.bonus_damage = 5
	elif ten_vu_khi_moi == "Kiếm Bạc": Global.bonus_damage = 20
	elif ten_vu_khi_moi == "Huyết Kiếm": Global.bonus_damage = 25
	elif ten_vu_khi_moi == "Gươm Rỉ Sét": Global.bonus_damage = 15
	elif ten_vu_khi_moi == "Huyết Kiếm Truyền Thuyết": Global.bonus_damage = 30
		
	cap_nhat_giao_dien()
	
	# Nhả phím trả lại cho Player
	get_viewport().gui_release_focus()

# ==========================================
# CLICK ĐÚP VÀO VẬT PHẨM ĐỂ SỬ DỤNG
# ==========================================
func _on_vật_phẩm_item_activated(index):
	var ten_vat_pham = Global.kho_vat_pham[index]
	var da_su_dung_thanh_cong = false
	
	if ten_vat_pham == "Bình Máu Nhỏ":
		if Global.player_hp < Global.max_hp:
			Global.player_hp += 30
			if Global.player_hp > Global.max_hp: Global.player_hp = Global.max_hp
			da_su_dung_thanh_cong = true
			print("=> Đã uống Bình Máu!")
			
	elif ten_vat_pham == "Áo Choàng Thánh":
		Global.max_hp += 100 
		Global.player_hp = Global.max_hp 
		da_su_dung_thanh_cong = true
		print("=> Đã mặc Áo Choàng Thánh!")
	
	if da_su_dung_thanh_cong:
		Global.kho_vat_pham.remove_at(index)
		cap_nhat_giao_dien()
		
	# Nhả phím trả lại cho Player
	get_viewport().gui_release_focus()

# ==========================================
# LỚP BẢO VỆ 2: ÉP BẮT PHÍM ĐỂ TẮT GIAO DIỆN
# ==========================================
func _input(event):
	# Dù Focus đang bị kẹt ở đâu, cứ bấm Tab/I là tắt bảng
	if event.is_action_pressed("open_profile"):
		# Đẩy lệnh tắt bảng về cho Player xử lý
		get_viewport().gui_release_focus()

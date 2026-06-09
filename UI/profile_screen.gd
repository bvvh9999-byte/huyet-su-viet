extends CanvasLayer

# Kết nối giao diện độc nhất (%)
@onready var lbl_level = %LblLevel
@onready var lbl_hp = %LblHP
@onready var lbl_damage = %LblDamage
@onready var lbl_speed = %LblSpeed
@onready var lbl_atk_speed = %LblAtkSpeed

@onready var btn_weapon = %BtnWeapon
@onready var btn_armor = %BtnArmor
@onready var btn_accessory = %BtnAccessory

@onready var list_vu_khi = %"Vũ Khí"
@onready var list_vat_pham = %"Vật Phẩm"

func _ready():
	# 1. Ép bảng luôn chạy khi game Pause
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 2. ĐOẠN CODE "HỦY DIỆT": Ép tất cả các nút và danh sách 
	# KHÔNG ĐƯỢC PHÉP cướp bàn phím của người chơi!
	btn_weapon.focus_mode = Control.FOCUS_NONE
	btn_armor.focus_mode = Control.FOCUS_NONE
	btn_accessory.focus_mode = Control.FOCUS_NONE
	list_vu_khi.focus_mode = Control.FOCUS_NONE
	list_vat_pham.focus_mode = Control.FOCUS_NONE
	
	# Load giao diện lúc mới vào
	cap_nhat_giao_dien()

# ==========================================
# HÀM LÀM MỚI TOÀN BỘ GIAO DIỆN
# ==========================================
func cap_nhat_giao_dien():
	lbl_level.text = "Cấp độ: " + str(Global.player_level)
	lbl_hp.text = "Sinh lực: " + str(Global.player_hp) + " / " + str(Global.max_hp)
	
	var tong_dam = 10 + Global.bonus_damage
	lbl_damage.text = "Sát thương: " + str(tong_dam)
	lbl_speed.text = "Tốc độ: " + str(Global.toc_do)
	# --- CẬP NHẬT TỐC ĐỘ VUNG KIẾM ---
	if Global.skill_tang_toc_danh:
		lbl_atk_speed.text = "Tốc độ chém: Siêu Tốc (0.1s)"
		lbl_atk_speed.modulate = Color(1, 1, 0) # Tô màu vàng cho ngầu
	else:
		lbl_atk_speed.text = "Tốc độ chém: Bình Thường (0.2s)"
		lbl_atk_speed.modulate = Color(1, 1, 1)
	
	btn_weapon.text = "Vũ khí: " + Global.trang_bi_vu_khi
	btn_armor.text = "Giáp: " + Global.trang_bi_ao_giap
	btn_accessory.text = "Phụ kiện: " + Global.trang_bi_day_chuyen
	
	list_vu_khi.clear()
	list_vat_pham.clear()
	
	for vu_khi in Global.kho_vu_khi:
		list_vu_khi.add_item(vu_khi)
		
	for vat_pham in Global.kho_vat_pham:
		list_vat_pham.add_item(vat_pham)

# ==========================================
# SỰ KIỆN CLICK ĐÚP VŨ KHÍ (TRANG BỊ)
# ==========================================
func _on_vũ_khí_item_activated(index):
	var ten_vu_khi_moi = Global.kho_vu_khi[index]
	
	if Global.trang_bi_vu_khi != "Chưa có":
		Global.kho_vu_khi.append(Global.trang_bi_vu_khi)
		
	Global.trang_bi_vu_khi = ten_vu_khi_moi
	Global.kho_vu_khi.remove_at(index)
	
	if ten_vu_khi_moi == "Kiếm Gỗ Tầm Sét":
		Global.bonus_damage = 5
	elif ten_vu_khi_moi == "Gươm Rỉ Sét":
		Global.bonus_damage = 15
	elif ten_vu_khi_moi == "Huyết Kiếm Truyền Thuyết":
		Global.bonus_damage = 30
	elif ten_vu_khi_moi == "Huyết Kiếm":
		Global.bonus_damage = 25
	elif ten_vu_khi_moi == "Kiếm Bạc": # Thêm cây kiếm mua ở Shop
		Global.bonus_damage = 20
		
	cap_nhat_giao_dien()
	get_viewport().gui_release_focus() # Trả phím

# ==========================================
# SỰ KIỆN CLICK ĐÚP VẬT PHẨM (SỬ DỤNG)
# ==========================================
func _on_vật_phẩm_item_activated(index):
	var ten_vat_pham = Global.kho_vat_pham[index]
	var da_su_dung_thanh_cong = false
	
	if ten_vat_pham == "Bình Máu Nhỏ":
		if Global.player_hp < Global.max_hp:
			Global.player_hp += 30
			if Global.player_hp > Global.max_hp:
				Global.player_hp = Global.max_hp
			da_su_dung_thanh_cong = true
			print("=> Đã uống 1 Bình Máu Nhỏ!")
		else:
			print("=> Máu đang đầy!")
			
	elif ten_vat_pham == "Lá Bùa Hồi Sinh":
		print("=> Lá bùa này sẽ tự kích hoạt khi bạn chết!")
		
	elif ten_vat_pham == "Áo Choàng Thánh":
		Global.max_hp += 100 # Tăng hẳn 100 máu tối đa!
		Global.player_hp = Global.max_hp # Hồi đầy máu luôn
		print("=> ĐÃ MẶC ÁO CHOÀNG! Máu tối đa tăng lên ", Global.max_hp)
		da_su_dung_thanh_cong = true
	
	if da_su_dung_thanh_cong:
		Global.kho_vat_pham.remove_at(index)
		cap_nhat_giao_dien()
		
	get_viewport().gui_release_focus() # Trả phím

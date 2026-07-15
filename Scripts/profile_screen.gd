extends CanvasLayer

# ==========================================
# GỌI GIAO DIỆN BẰNG DẤU % (Bất tử, không sợ sai đường dẫn)
# ==========================================
@onready var lbl_level = %LblLevel
@onready var lbl_hp = %LblHP
@onready var lbl_damage = %LblDamage
@onready var lbl_speed = %LblSpeed
# @onready var lbl_atk_speed = %LblAtkSpeed # Bỏ dấu # nếu bạn có làm dòng Tốc đánh

@onready var btn_weapon = %BtnWeapon
@onready var btn_armor = %BtnArmor
@onready var btn_accessory = %BtnAccessory

@onready var list_vu_khi = %"Vũ Khí"
@onready var list_vat_pham = %"Vật Phẩm"

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Ép nhả bàn phím chống kẹt nút
	btn_weapon.focus_mode = Control.FOCUS_NONE
	btn_armor.focus_mode = Control.FOCUS_NONE
	btn_accessory.focus_mode = Control.FOCUS_NONE
	list_vu_khi.focus_mode = Control.FOCUS_NONE
	list_vat_pham.focus_mode = Control.FOCUS_NONE
	
	cap_nhat_giao_dien()

func cap_nhat_giao_dien():
	lbl_level.text = "Cấp độ: " + str(Global.player_level)
	lbl_hp.text = "Sinh lực: " + str(Global.player_hp) + " / " + str(Global.max_hp)
	
	var tong_dam = 10 + Global.bonus_damage
	lbl_damage.text = "Sát thương: " + str(tong_dam)
	lbl_speed.text = "Tốc độ: " + str(Global.toc_do)
	
	# if Global.skill_tang_toc_danh:
	# 	lbl_atk_speed.text = "Tốc độ chém: Siêu Tốc (0.1s)"
	# else:
	# 	lbl_atk_speed.text = "Tốc độ chém: Bình Thường (0.2s)"
	
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
# CLICK ĐÚP VŨ KHÍ (TRANG BỊ)
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
	elif ten_vu_khi_moi == "Kiếm Bạc":
		Global.bonus_damage = 20
		
	cap_nhat_giao_dien()
	get_viewport().gui_release_focus()

# ==========================================
# CLICK ĐÚP VẬT PHẨM (SỬ DỤNG)
# ==========================================
func _on_vật_phẩm_item_activated(index):
	var ten_vat_pham = Global.kho_vat_pham[index]
	var da_su_dung_thanh_cong = false
	
	if ten_vat_pham == "Bình Máu Nhỏ":
		if Global.player_hp < Global.max_hp:
			Global.player_hp += 30
			if Global.player_hp > Global.max_hp: Global.player_hp = Global.max_hp
			da_su_dung_thanh_cong = true
	elif ten_vat_pham == "Áo Choàng Thánh":
		Global.max_hp += 100 
		Global.player_hp = Global.max_hp 
		da_su_dung_thanh_cong = true
	
	if da_su_dung_thanh_cong:
		Global.kho_vat_pham.remove_at(index)
		cap_nhat_giao_dien()
		
	get_viewport().gui_release_focus()

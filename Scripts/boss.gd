extends Node

# ==========================================
# CHỈ SỐ PLAYER CƠ BẢN
# ==========================================
var player_hp = 100
var max_hp = 100
var player_level = 1
var player_exp = 0
var exp_to_next_level = 100
var bonus_damage = 0
var toc_do = 200
var vang = 100 # Tiền mua đồ

# ==========================================
# TRANG BỊ & KHO ĐỒ
# ==========================================
var kho_vu_khi = ["Village Blade"] 
var kho_vat_pham = ["Wooden Buckler"]

var trang_bi_vu_khi = "Chưa có"
var trang_bi_ao_giap = "Chưa có"
var trang_bi_day_chuyen = "Chưa có"

# ==========================================
# HỆ THỐNG KỸ NĂNG (SKILL TREE)
# ==========================================
var diem_ky_nang = 0 
var skill_tang_toc_danh = false
var skill_song_kiem = false
var skill_hao_khi = false

# ==========================================
# SỔ TAY NHIỆM VỤ (QUEST LOG)
# ==========================================
var danh_sach_nhiem_vu = {
	"main_01": {
		"ten": "Khởi Nghĩa",
		"loai": "Nhiệm Vụ Chính",
		"trang_thai": 0, 
		"muc_tieu": 3,
		"da_lam": 0,
		"phan_thuong": "Sword of Me Linh",
		"thoai_nhan_nv": [
			"Ngươi cuối cùng cũng tỉnh lại rồi sao, Hồn Việt?",
			"Lũ giặc ngoại xâm đang dày xéo quê hương ta.",
			"Hãy đi tiêu diệt 3 tên giặc ngoài kia, ta sẽ có thưởng!"
		],
		"thoai_dang_lam": "Chưa xong đâu! Ngươi mới diệt được ", 
		"thoai_tra_nv": "Tuyệt vời! Nhận lấy thanh kiếm này và lên đường!",
		"thoai_ket_thuc": "Lịch sử trông cậy cả vào ngươi..."
	},
	"main_02": {
		"ten": "Hắc Hóa",
		"loai": "Nhiệm Vụ Chính",
		"trang_thai": 0, 
		"muc_tieu": 5, 
		"da_lam": 0,
		"phan_thuong": "Storm Gauntlet",
		"thoai_nhan_nv": [
			"Khu rừng này tà khí quá nặng...",
			"Giúp ta dọn dẹp 5 con quái vật quanh đây nhé!"
		],
		"thoai_dang_lam": "Quái vật vẫn còn, ngươi mới giết được ",
		"thoai_tra_nv": "Làm tốt lắm. Đây là phần thưởng của ngươi!",
		"thoai_ket_thuc": "Hãy cẩn thận với cái Rương Nguyền Rủa..."
	}
}

# ==========================================
# THUẬT TOÁN GACHA - BẢNG ĐỒ RỚT CHUẨN XÁC
# ==========================================
var bang_rot_do = [
	# --- COMMON (50%) ---
	{"ten": "Village Blade", "loai": "vu_khi", "rarity": "Common", "trong_so": 100},
	{"ten": "Bronze-Edge Sword", "loai": "vu_khi", "rarity": "Common", "trong_so": 100},
	{"ten": "Wooden Buckler", "loai": "vat_pham", "rarity": "Common", "trong_so": 100},
	{"ten": "Leather Boots", "loai": "vat_pham", "rarity": "Common", "trong_so": 100},
	
	# --- RARE (30%) ---
	{"ten": "Sword of Me Linh", "loai": "vu_khi", "rarity": "Rare", "trong_so": 30},
	{"ten": "Militia Armour", "loai": "vat_pham", "rarity": "Rare", "trong_so": 30},
	{"ten": "Ring of Swiftness", "loai": "vat_pham", "rarity": "Rare", "trong_so": 30},
	{"ten": "River Spirit Amulet", "loai": "vat_pham", "rarity": "Rare", "trong_so": 30},
	
	# --- EPIC (10%) ---
	{"ten": "Sword of the Trung Sisters", "loai": "vu_khi", "rarity": "Epic", "trong_so": 10},
	{"ten": "Bach Dang Naval Armour", "loai": "vat_pham", "rarity": "Epic", "trong_so": 10},
	{"ten": "Storm Gauntlet", "loai": "vat_pham", "rarity": "Epic", "trong_so": 10},
	
	# --- LEGENDARY SSR (2%) ---
	{"ten": "Blade of Viet Soul", "loai": "vu_khi", "rarity": "SSR", "trong_so": 2},
	{"ten": "Ancestral Guardian Plate", "loai": "vat_pham", "rarity": "SSR", "trong_so": 2},
	{"ten": "Amulet of Eternal Memory", "loai": "vat_pham", "rarity": "SSR", "trong_so": 2}
]

func quay_gacha_ruong():
	var tong_trong_so = 0
	for mon_do in bang_rot_do:
		tong_trong_so += mon_do["trong_so"]
		
	var so_random = randi() % tong_trong_so
	var tich_luy = 0
	
	for mon_do in bang_rot_do:
		tich_luy += mon_do["trong_so"]
		if so_random < tich_luy:
			if mon_do["loai"] == "vu_khi":
				kho_vu_khi.append(mon_do["ten"])
			else:
				kho_vat_pham.append(mon_do["ten"])
			return mon_do # Trả về toàn bộ thông tin món đồ
	return null

# ==========================================
# HỆ THỐNG LƯU TRỮ (SAVE / LOAD)
# ==========================================
var save_path = "user://huyetsuviet_save.save"

func save_game():
	var data_to_save = {
		"hp": player_hp, "max_hp": max_hp, "level": player_level, "exp": player_exp,
		"next_exp": exp_to_next_level, "sp": diem_ky_nang, "bonus_dmg": bonus_damage, "gold": vang,
		"weapon": kho_vu_khi, "item": kho_vat_pham, "eq_weapon": trang_bi_vu_khi,
		"eq_armor": trang_bi_ao_giap, "eq_acc": trang_bi_day_chuyen, "quest": danh_sach_nhiem_vu,
		"s_tocdanh": skill_tang_toc_danh, "s_songkiem": skill_song_kiem, "s_haokhi": skill_hao_khi
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(data_to_save)
	file.close()

func load_game():
	if not FileAccess.file_exists(save_path): return false
	var file = FileAccess.open(save_path, FileAccess.READ)
	var loaded_data = file.get_var()
	file.close()
	
	player_hp = loaded_data["hp"]
	max_hp = loaded_data["max_hp"]
	player_level = loaded_data["level"]
	player_exp = loaded_data["exp"]
	exp_to_next_level = loaded_data["next_exp"]
	diem_ky_nang = loaded_data["sp"]
	bonus_damage = loaded_data["bonus_dmg"]
	vang = loaded_data["gold"]
	kho_vu_khi = loaded_data["weapon"]
	kho_vat_pham = loaded_data["item"]
	trang_bi_vu_khi = loaded_data["eq_weapon"]
	trang_bi_ao_giap = loaded_data["eq_armor"]
	trang_bi_day_chuyen = loaded_data["eq_acc"]
	danh_sach_nhiem_vu = loaded_data["quest"]
	skill_tang_toc_danh = loaded_data["s_tocdanh"]
	skill_song_kiem = loaded_data["s_songkiem"]
	skill_hao_khi = loaded_data["s_haokhi"]
	return true

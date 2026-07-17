extends Node

# ==========================================
# CHỈ SỐ PLAYER
# ==========================================
var player_hp = 100
var max_hp = 100
var player_level = 1
var player_exp = 0
var exp_to_next_level = 100
var bonus_damage = 0
var toc_do = 200
var vang = 100 # Cho sẵn 100 Vàng để test mua đồ
var diem_ky_nang = 0 # Skill Points (SP)
# Trạng thái các kỹ năng: false = Chưa học, true = Đã học
var skill_tang_toc_danh = false
var skill_song_kiem = false
var skill_hao_khi = false

# ==========================================
# TRANG BỊ & KHO ĐỒ
# ==========================================
var kho_vu_khi = ["Kiếm Gỗ Tầm Sét"] 
var kho_vat_pham = ["Bình Máu Nhỏ"]

var trang_bi_vu_khi = "Chưa có"
var trang_bi_ao_giap = "Chưa có"
var trang_bi_day_chuyen = "Chưa có"

# ==========================================
# SỔ TAY NHIỆM VỤ
# ==========================================
# ==========================================
# SỔ TAY NHIỆM VỤ & CỐT TRUYỆN (NÂNG CẤP)
# ==========================================
var danh_sach_nhiem_vu = {
	
	# NHIỆM VỤ Ở WORLD 1
	"main_01": {
		"ten": "Khởi Nghĩa",
		"loai": "Nhiệm Vụ Chính",
		"trang_thai": 0, 
		"muc_tieu": 3,
		"da_lam": 0,
		"phan_thuong": "Song Kiếm",
		
		# DÀN THOẠI TRƯỚC KHI NHẬN NHIỆM VỤ (Nhiều câu liên tiếp)
		"thoai_nhan_nv": [
			"Ngươi cuối cùng cũng tỉnh lại rồi sao, Hồn Việt?",
			"Lũ giặc ngoại xâm đang dày xéo quê hương ta.",
			"Chúng ta không thể ngồi chờ chết được nữa!",
			"Hãy đi tiêu diệt 3 tên giặc ngoài kia, ta sẽ có thưởng cho ngươi!"
		],
		"thoai_dang_lam": "Chưa xong đâu! Ngươi mới diệt được ", # Code sẽ tự ghép số vào
		"thoai_tra_nv": "Tuyệt vời! Nhận lấy Song Kiếm này và tiếp tục lên đường!",
		"thoai_ket_thuc": "Lịch sử trông cậy cả vào ngươi..."
	},

	# NHIỆM VỤ Ở WORLD 2 (Thêm mới)
	"main_02": {
		"ten": "Hắc Hóa",
		"loai": "Nhiệm Vụ Chính",
		"trang_thai": 0, 
		"muc_tieu": 5, # Cần giết 5 con quái
		"da_lam": 0,
		"phan_thuong": "Huyết Kiếm Truyền Thuyết",
		
		"thoai_nhan_nv": [
			"Khu rừng này tà khí quá nặng...",
			"Lũ yêu quái đã bị Bóng Đen Lịch Sử hắc hóa hoàn toàn.",
			"Nếu không ngăn chúng lại, chúng sẽ tràn về làng mất.",
			"Giúp ta dọn dẹp 5 con quái vật quanh đây nhé!"
		],
		"thoai_dang_lam": "Quái vật vẫn còn, ngươi mới giết được ",
		"thoai_tra_nv": "Làm tốt lắm. Bóng tối đã tạm thời lùi bước. Đây là phần thưởng của ngươi!",
		"thoai_ket_thuc": "Hãy cẩn thận với cái Rương Nguyền Rủa ở cuối rừng..."
	}
}

# ==========================================
# THUẬT TOÁN GACHA - TRỌNG SỐ RỚT ĐỒ
# ==========================================
var bang_rot_do = [
	{"ten": "Bình Máu Nhỏ", "loai": "vat_pham", "trong_so": 50}, # 50% ra máu
	{"ten": "Kiếm Gỗ Tầm Sét", "loai": "vu_khi", "trong_so": 30}, # 30% ra đồ rác
	{"ten": "Lá Bùa Hồi Sinh", "loai": "vat_pham", "trong_so": 10}, # 10% đồ hiếm
	{"ten": "Gươm Rỉ Sét", "loai": "vu_khi", "trong_so": 8}, # 8% đồ hiếm
	{"ten": "Huyết Kiếm Truyền Thuyết", "loai": "vu_khi", "trong_so": 2} # 2% ĐỒ SSR!!!
]

func quay_gacha_ruong():
	var tong_trong_so = 0
	
	# B1: Tính tổng số vé
	for mon_do in bang_rot_do:
		tong_trong_so += mon_do["trong_so"]
		
	# B2: Quay một con số ngẫu nhiên từ 0 đến Tổng
	var so_random = randi() % tong_trong_so
	var tich_luy = 0
	
	# B3: Đối chiếu để tìm ra món đồ trúng thưởng
	for mon_do in bang_rot_do:
		tich_luy += mon_do["trong_so"]
		if so_random < tich_luy:
			# TRÚNG RỒI! Nhét ngay vào kho đồ tương ứng
			if mon_do["loai"] == "vu_khi":
				kho_vu_khi.append(mon_do["ten"])
			else:
				kho_vat_pham.append(mon_do["ten"])
				
			return mon_do["ten"] # Trả về tên món đồ để hiện lên màn hình
	
	return "Rương Trống"
	
	# Đường dẫn tạo file save trong ổ đĩa hệ thống (AppData)
var save_path = "user://huyetsuviet_save.save"

# HÀM LƯU GAME (SAVE)
func save_game():
	# Gom toàn bộ dữ liệu quan trọng vào một cuốn sổ (Dictionary)
	var data_to_save = {
		"hp": player_hp,
		"max_hp": max_hp,
		"level": player_level,
		"exp": player_exp,
		"next_exp": exp_to_next_level,
		"sp": diem_ky_nang,
		"bonus_dmg": bonus_damage,
		"gold": vang,
		"weapon": kho_vu_khi,
		"item": kho_vat_pham,
		"eq_weapon": trang_bi_vu_khi,
		"eq_armor": trang_bi_ao_giap,
		"eq_acc": trang_bi_day_chuyen,
		"quest": danh_sach_nhiem_vu,
		
		# Kỹ năng
		"s_tocdanh": skill_tang_toc_danh,
		"s_songkiem": skill_song_kiem,
		"s_haokhi": skill_hao_khi
	}
	
	# Mở ổ cứng ra và ghi đè vào
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(data_to_save)
	file.close()
	print("=> ĐÃ LƯU GAME THÀNH CÔNG VÀO Ổ ĐĨA!")

# HÀM TẢI GAME (LOAD)
func load_game():
	# Kiểm tra xem máy tính này đã từng có file save chưa
	if not FileAccess.file_exists(save_path):
		print("=> CHƯA CÓ FILE SAVE. Chơi game mới!")
		return false
		
	# Nếu có thì mở ra đọc
	var file = FileAccess.open(save_path, FileAccess.READ)
	var loaded_data = file.get_var()
	file.close()
	
	# Đổ dữ liệu từ ổ cứng ngược lại vào "Bộ não"
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
	
	print("=> ĐÃ TẢI GAME CŨ THÀNH CÔNG!")
	return true

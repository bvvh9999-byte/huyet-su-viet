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
var danh_sach_nhiem_vu = {
	"main_01": {
		"ten": "Khởi Nghĩa",
		"loai": "Nhiệm Vụ Chính",
		"trang_thai": 0, 
		"muc_tieu": 3,
		"da_lam": 0,
		"phan_thuong": "Song Kiếm"
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

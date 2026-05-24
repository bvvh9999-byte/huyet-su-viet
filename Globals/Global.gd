extends Node

# --- CHỈ SỐ PLAYER ---
var player_hp = 100
var max_hp = 100
var player_level = 1
var player_exp = 0
var exp_to_next_level = 100
var bonus_damage = 0
var toc_do = 200

# --- KHO ĐỒ ---
var kho_vu_khi = ["Kiếm Gỗ Tầm Sét", "Gươm Rỉ Sét"] 
var kho_vat_pham = ["Bình Máu Nhỏ", "Lá Bùa Hồi Sinh"]

var trang_bi_vu_khi = "Chưa có"
var trang_bi_ao_giap = "Chưa có"
var trang_bi_day_chuyen = "Chưa có"

# --- CUỐN SỔ NHIỆM VỤ ---
# Trạng thái: 0 (Chưa nhận), 1 (Đang làm), 2 (Đã xong)
var danh_sach_nhiem_vu = {
	"main_01": {
		"ten": "Khởi Nghĩa",
		"loai": "Nhiệm Vụ Chính",
		"trang_thai": 0, 
		"muc_tieu": 3, # Cần giết 3 con quái
		"da_lam": 0,
		"phan_thuong": "Song Kiếm"
	}
}

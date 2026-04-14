extends Node

var current_chapter = 1
var player_hp = 100
var max_hp = 100

# Trạng thái Unlock Kỹ năng từ các Anh hùng
var unlocked_song_kiem = false # Nhận từ Hai Bà Trưng (Chap 1)
var unlocked_thuy_kich = false # Nhận từ Ngô Quyền (Chap 2)
var unlocked_hao_khi = false   # Nhận từ Trần Hưng Đạo (Chap 3)

# Lịch sử có bị Bóng Đen xóa sổ không
var history_saved = false

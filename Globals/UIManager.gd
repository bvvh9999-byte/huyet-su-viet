extends Node

# Khai báo đường dẫn đến các bảng UI
var profile_scene = preload("res://UI/profile_screen.tscn")
var skill_tree_scene = preload("res://UI/skill_tree_ui.tscn")
# (Nếu bạn có thêm các bảng khác thì cứ preload vào đây)

# Biến lưu trữ trạng thái của các bảng
var current_ui = null # Biến này ghi nhớ xem Bảng nào ĐANG MỞ

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS # Ép nó sống kể cả khi Pause

# HÀM MỞ/ĐÓNG BẢNG PROFILE (TÚI ĐỒ)
func toggle_profile():
	if current_ui == null:
		# Chưa có bảng nào mở -> Mở Profile lên
		current_ui = profile_scene.instantiate()
		get_tree().root.add_child(current_ui)
		get_tree().paused = true
	elif current_ui.name == "ProfileScreen":
		# Profile đang mở -> Đóng nó lại
		current_ui.queue_free()
		current_ui = null
		get_tree().paused = false
	else:
		print("=> UI LỖI: Đang mở một bảng khác, phải tắt bảng kia trước!")

# HÀM MỞ/ĐÓNG BẢNG SKILL TREE
func toggle_skill_tree():
	if current_ui == null:
		current_ui = skill_tree_scene.instantiate()
		get_tree().root.add_child(current_ui)
		get_tree().paused = true
	elif current_ui.name == "SkillTreeUI":
		current_ui.queue_free()
		current_ui = null
		get_tree().paused = false
	else:
		print("=> UI LỖI: Đang mở một bảng khác, phải tắt bảng kia trước!")

extends Area2D

# Bạn kéo thả file Map tiếp theo vào ô này ở ngoài bảng Inspector nhé
@export_file("*.tscn") var next_scene_path: String = ""

func _ready():
	# Cắm dây điện tự động cho Cổng
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Nếu người bước vào Cổng là Player
	if body.name == "Player":
		
		# Quét xem còn con quái vật nào mang nhãn "Enemy" trên bản đồ không
		var enemies_left = get_tree().get_nodes_in_group("Enemy")
		var quai_con_song = 0
		
		# Bỏ qua những con quái đang trong quá trình bốc hơi
		for enemy in enemies_left:
			if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
				quai_con_song += 1
				
		# Nếu vẫn còn quái vật
		if quai_con_song > 0:
			print("=> Vẫn còn ", quai_con_song, " con quái vật. Cổng đang khóa!")
			
		# Nếu đã giết sạch không còn 1 mống
		else:
			print("=> ĐÃ GIẾT SẠCH! ĐANG CHUYỂN MAP...")
			
			# 👉 AUTO SAVE: LƯU TOÀN BỘ GAME LẠI TRƯỚC KHI SANG MAP MỚI!
			Global.save_game()
			
			# Gọi hàm chuyển map an toàn (Chống Crash Game)
			call_deferred("chuyen_map_an_toan")

# Hàm chuyển map tách rời để tránh văng game do xung đột vật lý
func chuyen_map_an_toan():
	if next_scene_path != "":
		var err = get_tree().change_scene_to_file(next_scene_path)
		if err != OK:
			print("=> LỖI CHÍNH MẠNG: Godot không tìm thấy file Map ở đường dẫn này!")
	else:
		print("=> LỖI: Cổng này chưa được kéo file Map 2 vào ô Next Scene Path!!!")

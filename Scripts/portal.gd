extends Area2D

# DÒNG NÀY SẼ GIÚP HIỆN Ô KÉO THẢ Ở NGOÀI BẢNG INSPECTOR
@export_file("*.tscn") var next_scene_path: String = ""

func _ready():
	# Cắm dây điện tự động
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		
		# Quét xem còn con quái vật nào sống không
		var enemies_left = get_tree().get_nodes_in_group("Enemy")
		var quai_con_song = 0
		
		for enemy in enemies_left:
			if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
				quai_con_song += 1
				
		if quai_con_song > 0:
			print("=> Vẫn còn quái vật, cổng đang khóa!")
		else:
			print("=> ĐÃ GIẾT SẠCH! ĐANG CHUYỂN MAP...")
			
			# Gọi hàm chuyển map an toàn
			call_deferred("chuyen_map_an_toan")

# Hàm chuyển map tách rời để tránh văng game
func chuyen_map_an_toan():
	if next_scene_path != "":
		var err = get_tree().change_scene_to_file(next_scene_path)
		if err != OK:
			print("=> LỖI: Godot không tìm thấy file Map ở đường dẫn này!")
	else:
		print("=> LỖI NGHIÊM TRỌNG: Bạn CHƯA KÉO THẢ file Map vào ô Next Scene Path bên phải!!!")

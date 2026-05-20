extends Area2D

# Mặc định nó sẽ tìm file world_2.tscn ở ngoài cùng.
@export_file("*.tscn") var next_scene_path: String = "res://world_2.tscn"

func _ready():
	# 1. ÉP TỰ ĐỘNG NỐI DÂY (Không sợ quên bấm Connect nữa)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# 2. KHÔNG QUAN TÂM CHỮ HOA CHỮ THƯỜNG
	if body.name.to_lower() == "player":
		
		# 3. ĐẾM QUÁI VẬT MỘT CÁCH CHÍNH XÁC NHẤT
		var all_enemies = get_tree().get_nodes_in_group("Enemy")
		var quai_con_song = 0
		
		# Bỏ qua những con quái đang trong quá trình "bốc hơi"
		for enemy in all_enemies:
			if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
				quai_con_song += 1
				
		# 4. CHỐT HẠ ĐỂ CHUYỂN MÀN
		if quai_con_song > 0:
			print("=> CỔNG KHÓA: Vẫn còn ", quai_con_song, " con quái vật!")
		else:
			print("=> ĐÃ DIỆT SẠCH QUÁI! QUA MÀN!!!")
			
			if next_scene_path != "":
				var err = get_tree().change_scene_to_file(next_scene_path)
				if err != OK:
					print("LỖI: Đường dẫn Map 2 bị sai. Hãy kiểm tra lại tên file world_2.tscn của bạn nằm ở đâu!")
			else:
				print("LỖI: Chưa có đường dẫn Map 2!")

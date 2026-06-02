extends Area2D

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		var enemies_left = get_tree().get_nodes_in_group("Enemy")
		var quai_con_song = 0
		
		for enemy in enemies_left:
			if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
				quai_con_song += 1
				
		if quai_con_song > 0:
			print("=> Vẫn còn quái vật, cổng đang khóa!")
		else:
			print("=> ĐÃ GIẾT SẠCH! ĐANG CHUYỂN MAP...")
			
			# LỆNH GỌI HÀM CHUYỂN MAP MỘT CÁCH AN TOÀN VÀO CUỐI KHUNG HÌNH
			call_deferred("chuyen_map_an_toan")

# --- HÀM CHUYỂN MAP TÁCH RỜI ĐỂ TRÁNH CRASH GAME ---
func chuyen_map_an_toan():
	var duong_dan_map_2 = "res://Scenes/world_2.tscn" # <--- SỬA LẠI ĐƯỜNG DẪN NÀY CHO ĐÚNG NẾU CẦN
	
	var err = get_tree().change_scene_to_file(duong_dan_map_2)
	if err != OK:
		print("=> LỖI CHÍNH MẠNG: ĐƯỜNG DẪN BỊ SAI! Godot không tìm thấy file: ", duong_dan_map_2)

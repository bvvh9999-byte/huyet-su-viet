extends Area2D

@export_file("*.tscn") var next_scene_path: String

func _on_body_entered(body):
	print("\n--- CÓ VẬT THỂ CHẠM VÀO CỔNG ---")
	print("Tên vật thể: ", body.name)
	
	if body.name == "Player":
		print("=> Đã xác nhận là Player!")
		
		# Quét xem còn bao nhiêu con quái
		var enemies_left = get_tree().get_nodes_in_group("Enemy")
		print("=> Số quái vật còn sống trên bản đồ: ", enemies_left.size())
		
		if enemies_left.size() > 0:
			print("=> TỪ CHỐI QUA MÀN: Vẫn còn quái vật chưa chết!")
		else:
			print("=> ĐƯỢC PHÉP QUA MÀN!")
			
			# Kiểm tra xem đã nhét Map 2 vào chưa
			if next_scene_path == "" or next_scene_path == null:
				print("=> LỖI NGHIÊM TRỌNG: Bạn chưa kéo thả file Map 2 vào ô Next Scene Path bên phải!!!")
			else:
				print("=> BÙM! Đang bay sang Map 2...")
				get_tree().change_scene_to_file(next_scene_path)

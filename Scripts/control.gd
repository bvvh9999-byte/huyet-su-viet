extends Control

func _on_button_pressed() -> void:
	print("=> TÔI ĐÃ NGHE THẤY TIẾNG CLICK CHUỘT VÀ TẮT BẢNG!")
	# Hủy diệt cái bảng này (Đóng Popup)
	queue_free()

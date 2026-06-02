extends Area2D

func _ready():
	# Cắm dây điện tự động
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Nếu vật chạm vào bẫy CÓ MÁU (Bất kể là Player hay Quái)
	if body.has_method("take_damage"):
		print("=> CÓ KẺ ĐẠP TRÚNG BẪY CỌC: ", body.name)
		
		# Gây 999 sát thương (Chết ngay lập tức!)
		body.take_damage(999)

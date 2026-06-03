extends Area2D

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		if body.name == "Player":
			Global.player_hp = 0 
			await get_tree().create_timer(0.5).timeout # Đợi 0.5s cho rơi khuất màn hình
			body.take_damage(999) # Bật màn hình Game Over
		else:
			body.take_damage(999) # Quái thì chết luôn

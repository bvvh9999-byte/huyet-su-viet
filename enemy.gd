extends CharacterBody2D

var hp = 30 # Máu của quái vật

# Rơi xuống đất nếu lơ lửng
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

# Hàm xử lý khi bị kiếm chém trúng
func take_damage(damage_amount):
	hp -= damage_amount # Bị trừ máu
	
	# Nháy màu Đỏ để báo hiệu là đang bị đau
	$Sprite2D.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout # Nháy trong 0.1 giây
	$Sprite2D.modulate = Color(0.2, 0, 0.4) # Trở lại màu Tím đen hắc hóa
	
	# Nếu máu về 0 thì bốc hơi
	if hp <= 0:
		queue_free() # Xóa sổ quái vật

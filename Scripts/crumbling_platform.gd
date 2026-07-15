extends AnimatableBody2D

# ==========================================
# KẾT NỐI VỚI CÁC NODE CON
# ==========================================
@onready var fall_timer = $FallTimer
@onready var trigger_area = $TriggerArea

# 👉 CHÚ Ý ĐIỂM NÀY: Đã cập nhật thành Sprite2D thay vì ColorRect cũ
@onready var sprite = $Sprite2D 

var is_falling = false
var original_position = Vector2.ZERO 

func _ready():
	# Nhớ vị trí gốc lúc mới vào game để sau 3s rơi sẽ hồi sinh lại đúng chỗ này
	original_position = global_position 
	
	# Cắm dây điện tự động cho Cảm biến giẫm đạp và Đồng hồ
	if not trigger_area.body_entered.is_connected(_on_body_entered):
		trigger_area.body_entered.connect(_on_body_entered)
	if not fall_timer.timeout.is_connected(_on_fall_timer_timeout):
		fall_timer.timeout.connect(_on_fall_timer_timeout)

# ==========================================
# CƠ CHẾ RƠI TỰ DO
# ==========================================
func _physics_process(delta):
	# Nếu trạng thái Rơi được bật, bệ đất sẽ trôi tuột xuống đáy màn hình
	if is_falling:
		position.y += 400 * delta # Tốc độ rớt 400px/giây

# ==========================================
# KHI CÓ NGƯỜI ĐẠP CHÂN LÊN CẢM BIẾN
# ==========================================
func _on_body_entered(body):
	# Nếu là Player đạp lên, và bệ đất chưa bị rớt
	if body.name == "Player" and not is_falling:
		print("=> ĐÃ GIẪM LÊN BỆ ĐẤT VỠ! Đếm ngược 1 giây...")
		
		# Kích hoạt đồng hồ 1 giây
		fall_timer.start() 
		
		# Gọi hiệu ứng rung lắc cảnh báo
		hieu_ung_rung()

# ==========================================
# HIỆU ỨNG RUNG LẮC CẢNH BÁO
# ==========================================
func hieu_ung_rung():
	# Lắc qua lắc lại 4 lần liên tục
	for i in range(4):
		if sprite != null:
			sprite.position.x += 5
			await get_tree().create_timer(0.05).timeout
			sprite.position.x -= 10
			await get_tree().create_timer(0.05).timeout
			sprite.position.x += 5

# ==========================================
# KHI ĐỒNG HỒ ĐẾM ĐỦ 1 GIÂY -> SỤP ĐỔ!
# ==========================================
func _on_fall_timer_timeout():
	print("=> RỚT!!!")
	is_falling = true
	
	# Tắt khối vật lý cứng đi, để Player rớt lọt qua luôn
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Tô màu hơi mờ đi một chút lúc nó đang rớt cho chân thực
	if sprite != null:
		sprite.modulate = Color(0.6, 0.6, 0.6) 
	
	# Chờ 3 giây sau đó tái tạo lại bệ đất
	await get_tree().create_timer(3.0).timeout
	hoi_sinh()

# ==========================================
# HỒI SINH BỆ ĐẤT VỀ CHỖ CŨ
# ==========================================
func hoi_sinh():
	is_falling = false
	global_position = original_position # Đem nó về lại vị trí cũ
	
	# Bật vật lý cứng lại
	$CollisionShape2D.set_deferred("disabled", false) 
	
	# Trả lại màu sắc bình thường
	if sprite != null:
		sprite.modulate = Color(1, 1, 1) 
		
	print("=> Bệ đất đã phục hồi!")

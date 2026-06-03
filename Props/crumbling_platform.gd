extends AnimatableBody2D

@onready var fall_timer = $FallTimer
@onready var sprite = $ColorRect
@onready var trigger_area = $TriggerArea

var is_falling = false
var original_position = Vector2.ZERO 

func _ready():
	# Nhớ vị trí lúc mới vào game để sau này hồi sinh về đúng chỗ
	original_position = global_position 
	
	# Cắm dây điện tự động
	if not trigger_area.body_entered.is_connected(_on_body_entered):
		trigger_area.body_entered.connect(_on_body_entered)
	if not fall_timer.timeout.is_connected(_on_fall_timer_timeout):
		fall_timer.timeout.connect(_on_fall_timer_timeout)

func _physics_process(delta):
	# Nếu trạng thái Rơi được bật, bệ đất sẽ trôi tuột xuống đáy màn hình
	if is_falling:
		position.y += 400 * delta 

# KHI CÓ NGƯỜI ĐẠP CHÂN LÊN CẢM BIẾN
func _on_body_entered(body):
	if body.name == "Player" and not is_falling:
		print("=> ĐÃ GIẪM LÊN BỆ ĐẤT VỠ! Đếm ngược 1 giây...")
		fall_timer.start() # Bấm đồng hồ 1s
		hieu_ung_rung()

# Lắc qua lắc lại cho Player giật mình
func hieu_ung_rung():
	for i in range(4):
		sprite.position.x += 5
		await get_tree().create_timer(0.05).timeout
		sprite.position.x -= 10
		await get_tree().create_timer(0.05).timeout
		sprite.position.x += 5

# KHI ĐỒNG HỒ ĐẾM ĐỦ 1 GIÂY
func _on_fall_timer_timeout():
	print("=> SỤP ĐỔ!!!")
	is_falling = true
	
	# Tắt khối vật lý cứng đi, để Player rớt lọt qua luôn
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Chờ 3 giây sau đó tái tạo lại bệ đất
	await get_tree().create_timer(3.0).timeout
	hoi_sinh()

func hoi_sinh():
	is_falling = false
	global_position = original_position # Đem nó về lại vị trí cũ
	$CollisionShape2D.set_deferred("disabled", false) # Bật vật lý cứng lại
	print("=> Bệ đất đã phục hồi!")

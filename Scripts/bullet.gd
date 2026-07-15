extends Area2D

var speed = 400.0 # Tốc độ đạn bay
var direction = Vector2.ZERO # Hướng bay sẽ do Quái vật quyết định

func _ready():
	# Cắm dây điện tự động
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Code bay thẳng về phía trước theo hướng đã định
	position += direction * speed * delta

func _on_body_entered(body):
	# Nếu đụng trúng Player thì trừ 10 máu
	if body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(10)
	
	# Dù đụng trúng Player hay đụng vào Cục đất thì đạn cũng tự động tan biến
	queue_free()

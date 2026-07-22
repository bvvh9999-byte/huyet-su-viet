extends Area2D

var player_in_zone = false 
var is_opened = false 

@onready var dialog_text = $Label 
@onready var hinh_ruong = $Sprite2D

func _ready():
	dialog_text.visible = false
	if hinh_ruong != null:
		hinh_ruong.play("idle")
		
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _process(_delta):
	if player_in_zone and not is_opened and Input.is_action_just_pressed("interact"):
		mo_ruong()

func mo_ruong():
	is_opened = true
	dialog_text.visible = false 
	
	if hinh_ruong != null:
		hinh_ruong.play("open") 
		
	await get_tree().create_timer(0.5).timeout
	
	var phan_thuong = Global.quay_gacha_ruong()
	
	if phan_thuong != null:
		var ten_do = phan_thuong["ten"]
		var do_hiem = phan_thuong["rarity"]
		
		dialog_text.text = "+1 " + ten_do
		
		# Đổi màu theo độ hiếm
		if do_hiem == "SSR":
			dialog_text.modulate = Color(1, 0, 0) # Đỏ
			dialog_text.scale = Vector2(1.5, 1.5) 
		elif do_hiem == "Epic":
			dialog_text.modulate = Color(1, 0.8, 0) # Vàng
			dialog_text.scale = Vector2(1.2, 1.2)
		elif do_hiem == "Rare":
			dialog_text.modulate = Color(0.8, 0.2, 1) # Tím
			dialog_text.scale = Vector2(1.1, 1.1)
		else:
			dialog_text.modulate = Color(1, 1, 1) # Trắng
			dialog_text.scale = Vector2(1.0, 1.0)
			
		dialog_text.position = Vector2(-60, -40) 
		dialog_text.visible = true
		
		# Hiệu ứng chữ bay
		var tween = create_tween()
		tween.tween_property(dialog_text, "position:y", dialog_text.position.y - 50, 1.5)
		tween.tween_property(dialog_text, "modulate:a", 0.0, 1.5) 

func _on_body_entered(body):
	if body.name == "Player" and not is_opened:
		player_in_zone = true
		dialog_text.text = "[E] Mở rương"
		dialog_text.modulate = Color(1, 1, 1, 1) 
		dialog_text.scale = Vector2(1.0, 1.0)
		dialog_text.position = Vector2(-40, -40) 
		dialog_text.visible = true 

func _on_body_exited(body):
	if body.name == "Player" and not is_opened:
		player_in_zone = false
		dialog_text.visible = false

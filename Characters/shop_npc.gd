extends Area2D

var player_in_zone = false 
@onready var dialog_text = $Label 

# CHÚ Ý ĐƯỜNG DẪN NÀY: Hãy chắc chắn file shop_ui.tscn bạn lưu đúng chỗ này
var shop_ui_scene = preload("res://UI/shop_ui.tscn")
var shop_instance = null

func _ready():
	dialog_text.visible = false
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _process(delta):
	# Nếu đứng gần và bấm phím E
	if player_in_zone and Input.is_action_just_pressed("interact"):
		if shop_instance == null:
			if shop_ui_scene:
				shop_instance = shop_ui_scene.instantiate()
				get_tree().root.add_child(shop_instance)
				get_tree().paused = true # Đóng băng thế giới
				dialog_text.visible = false
			else:
				print("=> LỖI: Không tìm thấy file shop_ui.tscn !")

func _on_body_entered(body):
	if body.name == "Player":
		player_in_zone = true
		dialog_text.visible = true 

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		dialog_text.visible = false

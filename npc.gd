extends Area2D

var player_in_zone = false 
@onready var dialog_text = $Label 
var dialogue_scene = preload("res://UI/dialogue_box.tscn")

func _ready():
	dialog_text.visible = false

func _process(delta):
	# Nếu đứng gần VÀ bấm E VÀ game đang không bị Pause
	if player_in_zone and Input.is_action_just_pressed("interact") and not get_tree().paused:
		
		dialog_text.visible = false # Giấu cái chữ [E] trên đầu đi
		
		# 1. Gọi Bảng hội thoại ra màn hình
		var box = dialogue_scene.instantiate()
		get_tree().root.add_child(box)
		
		# 2. Đóng băng thời gian (Để quái vật không cắn bạn lúc đang đọc thoại)
		get_tree().paused = true

func nho_hoi_thoai():
	dialog_text.text = "Ta là Anh hùng Lịch sử!\nHãy nhận lấy sức mạnh này để cứu thế giới!"
	# Global.unlocked_song_kiem = true

# HÀM NÀY ĐÃ ĐƯỢC CẮM DÂY
func _on_body_entered(body):
	print(">>> [MÁY QUÉT NPC] Có người vừa bước vào vùng radar! Tên nó là: ", body.name)
	if body.name == "Player":
		player_in_zone = true
		dialog_text.text = "[E] Nói chuyện"
		dialog_text.visible = true 

# HÀM NÀY ĐÃ ĐƯỢC CẮM DÂY
func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		dialog_text.visible = false

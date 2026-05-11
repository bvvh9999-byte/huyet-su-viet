extends Area2D

var player_in_zone = false # Biến kiểm tra xem Player có đứng gần không
@onready var dialog_text = $Label # Kết nối với chữ trên đầu

func _ready():
	# Lúc mới vào game thì giấu dòng chữ đi
	dialog_text.visible = false
	
	# Code tự động cắm dây "Cảm biến" Player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# Khi Player bấm nút
func _process(delta):
	# Nếu Player đứng gần VÀ vừa bấm nút E (interact)
	if player_in_zone and Input.is_action_just_pressed("interact"):
		nho_hoi_thoai() # Chạy hàm nói chuyện

# Hàm chứa nội dung nói chuyện
func nho_hoi_thoai():
	dialog_text.text = "Ta là Anh hùng Lịch sử!\nHãy nhận lấy sức mạnh này để cứu lấy thế giới!"
	# Sau này bạn có thể gõ thêm lệnh Unlock Skill của Global ở đây:
	# Global.unlocked_song_kiem = true

# Khi có người bước vào vòng tròn
func _on_body_entered(body):
	if body.name == "Player":
		player_in_zone = true
		dialog_text.text = "[E] Nói chuyện"
		dialog_text.visible = true # Hiện chữ lên

# Khi người đó bỏ đi xa
func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		dialog_text.visible = false # Giấu chữ đi

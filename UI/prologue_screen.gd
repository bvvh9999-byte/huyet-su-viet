extends Control

@onready var lbl_text = $LblText
@onready var text_timer = $TextTimer

# Lấy Background (Hãy chắc chắn bạn có TextureRect và ColorRect trong Scene nhé)
@onready var hinh_nen = $TextureRect
@onready var lop_suong_mu = $ColorRect 

var full_text = """Ngàn năm trước...

Khi non sông còn chìm trong khói lửa,
có những người đã ngã xuống mà không một ai nhớ tên.

Họ không cầu được lưu danh.

Họ chỉ mong...

Con cháu mai sau còn được gọi hai tiếng:

"Đất Việt."

Nhưng thời gian là kẻ tàn nhẫn.

Nó xóa đi những ngôi mộ.
Xóa đi những chiến công.
Xóa đi cả những anh hùng.

Chỉ còn lại...

Máu.

Máu thấm vào đất.
Máu hóa thành lời nguyền.
Máu chờ đợi một người đủ sức đánh thức nó.

Và người đó...

Là ngươi.

Từ giây phút rút kiếm,
ngươi sẽ không còn đường lui.

Phía trước là quỷ dữ.
Phía sau là quê hương.

Muốn sống...

Hãy chiến đấu.

Muốn trở thành huyền thoại...

Hãy viết nên lịch sử bằng chính máu của mình.

HUYẾT SỬ VIỆT"""

var current_text = ""
var text_index = 0

func _ready():
	lbl_text.text = "" 
	
	if not text_timer.timeout.is_connected(_on_text_timer_timeout):
		text_timer.timeout.connect(_on_text_timer_timeout)
		
	# Tăng tốc độ gõ chữ cho bài văn dài
	text_timer.wait_time = 0.04 
	text_timer.start()

func _on_text_timer_timeout():
	if text_index < full_text.length():
		current_text += full_text[text_index]
		lbl_text.text = current_text
		text_index += 1
		text_timer.start() 
	else:
		text_timer.stop()
		chuyen_canh_dien_anh()

func chuyen_canh_dien_anh():
	# Chờ 5 giây cho người chơi đọc xong
	await get_tree().create_timer(5.0).timeout
	
	# Màn hình chớp Đỏ Máu
	if hinh_nen: hinh_nen.modulate = Color(0.8, 0, 0) 
	if lop_suong_mu: lop_suong_mu.visible = false
	
	await get_tree().create_timer(0.5).timeout 
	
	# CHUYỂN VÀO WORLD 1 (Sửa đường dẫn này nếu bạn lưu world ở chỗ khác)
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _input(event):
	# Bấm Phím Dấu Cách (Space) để Bỏ qua Lời dẫn
	if event.is_action_pressed("jump"): 
		get_tree().change_scene_to_file("res://Scenes/world.tscn")

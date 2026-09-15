extends Camera3D
class_name DebugCamera

@export var base_velocity: float = 10;
@export var sensitivity: float = .001;

var pitch: float;
var yaw: float;

func _process(delta: float) -> void:
	if !self.current:
		return;
	var move_dir: Vector3 = Vector3.ZERO;
	if Input.is_action_pressed("ui_up"):
		move_dir += Vector3.FORWARD;
	if Input.is_action_pressed("ui_down"):
		move_dir += Vector3.BACK;
	if Input.is_action_pressed("ui_left"):
		move_dir += Vector3.LEFT;
	if Input.is_action_pressed("ui_right"):
		move_dir += Vector3.RIGHT;
	move_dir = self.quaternion * move_dir;
	self.position += self.base_velocity * move_dir * delta;

func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey;
	if key_event == null:
		return;
	if !key_event.is_released():
		return;
	if !key_event.is_action("ui_cancel"):
		return;
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).is_released():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	if !self.current:
		return;
	var mouse_move: InputEventMouseMotion = event as InputEventMouseMotion;
	if mouse_move == null:
		return;
	self.pitch += mouse_move.screen_relative.y * self.sensitivity;
	self.yaw += mouse_move.screen_relative.x * self.sensitivity;
	self.rotation = Vector3(-self.pitch,-self.yaw,0);

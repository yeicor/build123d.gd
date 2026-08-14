#@tool
extends Node3D
## Owns the 3D camera and all viewport navigation (orbit / pan / zoom / presets).

var _camera: Camera3D
var _cam_dist: float = 140.0
var _cam_pitch: float = 30.0
var _cam_yaw: float = 45.0
var _cam_target: Vector3 = Vector3.ZERO
var _cam_tween: Tween
var _min_cam_dist: float = 10.0
var _max_cam_dist: float = 1000.0

var _is_orbiting: bool = false
var _is_panning: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO

signal focus_requested

func _ready() -> void:
	_camera = $Camera
	_camera.current = true
	_update_camera()

func animate_view(pitch: float, yaw: float) -> void:
	if _cam_tween and _cam_tween.is_valid():
		_cam_tween.kill()
	_cam_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_cam_tween.tween_property(self, "_cam_pitch", pitch, 0.4)
	_cam_tween.tween_property(self, "_cam_yaw", yaw, 0.4)
	_cam_tween.chain().tween_callback(_update_camera)
	var step_tw := create_tween()
	step_tw.tween_method(func(_v): _update_camera(), 0.0, 1.0, 0.4)

func frame_shape(shape: Variant) -> void:
	## Position the camera to fit the shape's bounding box and derive zoom
	## limits from it. Called on startup / whenever the model changes.
	if shape == null or shape.has_method("is_null") and shape.is_null():
		return
	if _apply_bbox_framing(shape.bounding_box()):
		_update_camera()

func center_on(shape: Variant) -> void:
	if shape == null or shape.has_method("is_null") and shape.is_null():
		return
	if _apply_bbox_framing(shape.bounding_box()):
		animate_view(30.0, 45.0)

func _apply_bbox_framing(bb: Variant) -> bool:
	## Center on a bounding box, set the framing distance and per-model zoom limits.
	if bb == null or bb.is_void():
		return false
	var diag: float = _diagonal_of(bb)
	if diag <= 0.0:
		return false
	_cam_target = bb.center()
	_cam_dist = maxf(10.0, diag * 1.6)
	_min_cam_dist = maxf(2.0, diag * 0.08)
	_max_cam_dist = maxf(100.0, diag * 8.0)
	return true

func _diagonal_of(bb: Variant) -> float:
	if bb == null or bb.is_void():
		return 100.0
	if bb.has_method("diagonal"):
		return bb.diagonal()
	if bb.has_method("diagonal_length"):
		return bb.diagonal_length()
	return bb.size().length()

func handle_view_pane_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				if event.shift_pressed:
					_is_panning = true
				else:
					_is_orbiting = true
				_last_mouse_pos = event.position
			else:
				_is_orbiting = false
				_is_panning = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_cam_dist = maxf(_min_cam_dist, _cam_dist * 0.9)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_cam_dist = minf(_max_cam_dist, _cam_dist * 1.1)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			focus_requested.emit()
	elif event is InputEventMouseMotion:
		if _is_orbiting:
			var delta: Vector2 = event.position - _last_mouse_pos
			_last_mouse_pos = event.position
			_cam_yaw -= delta.x * 0.4
			_cam_pitch = clampf(_cam_pitch + delta.y * 0.4, -89.0, 89.0)
			_update_camera()
		elif _is_panning:
			var delta: Vector2 = event.position - _last_mouse_pos
			_last_mouse_pos = event.position
			var right: Vector3 = _camera.global_transform.basis.x
			var up: Vector3 = _camera.global_transform.basis.y
			_cam_target -= (right * delta.x - up * delta.y) * (_cam_dist * 0.0015)
			_update_camera()

func _update_camera() -> void:
	if _camera == null:
		return
	var pitch_rad: float = deg_to_rad(_cam_pitch)
	var yaw_rad: float = deg_to_rad(_cam_yaw)
	var offset: Vector3 = Vector3(
		_cam_dist * cos(pitch_rad) * sin(yaw_rad),
		_cam_dist * sin(pitch_rad),
		_cam_dist * cos(pitch_rad) * cos(yaw_rad)
	)
	_camera.position = _cam_target + offset
	if _camera.is_inside_tree():
		_camera.look_at(_cam_target, Vector3.UP)

extends BdgLineObject
## BdgPolarLine - Line Object: Polar Line
## Create a line from a start point, with given length and angle (degrees) or direction.
class_name BdgPolarLine

var start_point: Vector3
var end_point: Vector3
var length: float
var angle: float

## Args:
##   (start: Vector3, length: float, angle_deg: float, mode: Mode = ADD)
##   (start: Vector3, length: float, direction: Vector3, mode: Mode = ADD)
##   (length: float, angle_deg: float, mode: Mode = ADD)  # starts at ZERO
func _init(...args) -> void:
	super()
	var mode := BdgEnums.Mode.ADD
	var p0 := Vector3.ZERO
	var len_val := 0.0
	var dir := Vector3.RIGHT

	if args.size() >= 1 and args[0] is Vector3:
		p0 = args[0]
		if args.size() >= 2:
			len_val = float(args[1])
		if args.size() >= 3:
			if args[2] is Vector3:
				dir = (args[2] as Vector3).normalized()
			else:
				angle = float(args[2])
				var rad := deg_to_rad(angle)
				dir = Vector3(cos(rad), sin(rad), 0.0).normalized()
		if args.size() >= 4 and args[3] != null:
			mode = args[3]
	elif args.size() >= 2:
		p0 = Vector3.ZERO
		len_val = float(args[0])
		if args[1] is Vector3:
			dir = (args[1] as Vector3).normalized()
		else:
			angle = float(args[1])
			var rad := deg_to_rad(angle)
			dir = Vector3(cos(rad), sin(rad), 0.0).normalized()
		if args.size() >= 3 and args[2] != null:
			mode = args[2]

	start_point = p0
	length = len_val
	end_point = p0 + dir * len_val

	var edge := BdgEdge.make_line(start_point, end_point)
	_wrapped = edge._wrapped
	_register(mode)

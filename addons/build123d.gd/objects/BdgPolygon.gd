extends BdgSketchObject
## BdgPolygon - Sketch Object: Polygon
## Create an arbitrary 2D polygon face from a sequence of points.
class_name BdgPolygon

var points: Array[Vector3] = []

## Args:
##   (points: Array, rotation: float = 0.0, align: Align = CENTER, mode: Mode = ADD)
func _init(...args) -> void:
	super()
	if args.is_empty():
		return

	var pts: Array[Vector3] = []
	var rot := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var md := BdgEnums.Mode.ADD

	if args[0] is Array:
		for p in args[0]:
			pts.append(BdgPolyline._to_v3(p))
		if args.size() > 1 and args[1] != null:
			rot = float(args[1])
		if args.size() > 2 and args[2] != null:
			align = args[2]
		if args.size() > 3 and args[3] != null:
			md = int(args[3])
	else:
		var i := 0
		while i < args.size():
			if args[i] is Vector3:
				pts.append(args[i])
			elif args[i] is Array and (args[i] as Array).size() >= 3 and (args[i][0] is float or args[i][0] is int):
				pts.append(BdgPolyline._to_v3(args[i]))
			elif args[i] is float:
				rot = args[i]
			elif args[i] is int:
				md = args[i]
			i += 1

	if pts.size() < 3:
		push_error("BdgPolygon requires at least 3 points")
		return

	points = pts
	var face := BdgFace.make_polygon(pts)
	_from_face(face, rot, align, md)

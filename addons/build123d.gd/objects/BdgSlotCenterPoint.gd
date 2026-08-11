extends BdgSketchObject
## BdgSlotCenterPoint - Sketch Object: Slot Center Point
## Create a slot defined by the slot center and the center of one end arc.
## The slot is symmetric about the center point.
class_name BdgSlotCenterPoint

var slot_center: Vector3
var point: Vector3
var slot_height: float

## Args: center, point (Vector3 | Array), height, rotation (deg, default 0),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var mode := BdgEnums.Mode.ADD
	slot_center = _to_v3(args[0])
	point = _to_v3(args[1])
	slot_height = args[2]
	if args.size() > 3 and args[3] != null:
		rotation = args[3]
	if args.size() > 4 and args[4] != null:
		mode = args[4]
	var face := BdgFace.make_slot_center_point(slot_center, point, slot_height)
	if face == null:
		return
	_from_face(face, rotation, BdgEnums.Align.NONE, mode)

static func _to_v3(p: Variant) -> Vector3:
	if p is Vector3:
		return p
	if p is Array and p.size() >= 3:
		return Vector3(float(p[0]), float(p[1]), float(p[2]))
	push_error("BdgSlotCenterPoint: invalid point %s" % p)
	return Vector3.ZERO

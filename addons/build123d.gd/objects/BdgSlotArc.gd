extends BdgSketchObject
## BdgSlotArc - Sketch Object: Slot Arc
## Create a slot along a circular center-line arc edge.
class_name BdgSlotArc

var arc: BdgEdge
var slot_height: float

## Args: arc (BdgEdge), height, rotation (deg, default 0), mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var mode := BdgEnums.Mode.ADD
	arc = args[0]
	slot_height = args[1]
	if args.size() > 2 and args[2] != null:
		rotation = args[2]
	if args.size() > 3 and args[3] != null:
		mode = args[3]
	if arc.geom_type() != BdgEnums.GeomType.CIRCLE:
		push_error("BdgSlotArc currently requires a circular arc edge")
		return
	var center: Vector3 = arc.arc_center()
	var radius: float = arc.radius()
	var sp: Vector3 = arc.start_point()
	var ep: Vector3 = arc.end_point()
	var start_angle := rad_to_deg(atan2(sp.y - center.y, sp.x - center.x))
	var end_angle := rad_to_deg(atan2(ep.y - center.y, ep.x - center.x))
	var sweep := end_angle - start_angle
	while sweep > 180.0:
		sweep -= 360.0
	while sweep <= -180.0:
		sweep += 360.0
	var face := BdgFace.make_slot_arc(center, radius, start_angle, sweep, slot_height)
	_from_face(face, rotation, BdgEnums.Align.NONE, mode)

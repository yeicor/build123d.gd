extends BdgSketchObject
## BdgSlotCenterToCenter - Sketch Object: Slot
## Create a slot from the distance between the centers of the two end arcs.
class_name BdgSlotCenterToCenter

var center_to_center: float
var height: float

## Args: center_to_center, height, rotation (deg about Z, default 0),
##       align: BdgEnums.Align | Array[int] (2 axes, default CENTER*2),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	center_to_center = args[0]
	height = args[1]
	if args.size() > 2 and args[2] != null:
		rotation = args[2]
	if args.size() > 3 and args[3] != null:
		align = args[3]
	if args.size() > 4 and args[4] != null:
		mode = args[4]
	var face := BdgFace.make_slot_center_to_center(center_to_center, height)
	_from_face(face, rotation, align, mode)

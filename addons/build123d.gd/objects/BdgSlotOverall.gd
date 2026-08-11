extends BdgSketchObject
## BdgSlotOverall - Sketch Object: Slot Overall
## Create a slot defined by the overall width and height.
class_name BdgSlotOverall

var width: float
var slot_height: float

## Args: width, height, rotation (deg about Z, default 0),
##       align: BdgEnums.Align | Array[int] (2 axes, default CENTER*2),
##       mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := 0.0
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	width = args[0]
	slot_height = args[1]
	if args.size() > 2 and args[2] != null:
		rotation = args[2]
	if args.size() > 3 and args[3] != null:
		align = args[3]
	if args.size() > 4 and args[4] != null:
		mode = args[4]
	if width < slot_height:
		push_error("Slot requires that width > height")
		return
	var face := BdgFace.make_slot_center_to_center(width - slot_height, slot_height)
	_from_face(face, rotation, align, mode)

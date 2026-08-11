extends BdgPartObject
## BdgWedge - Part Object: Wedge
## Create a wedge with a near face defined by xsize/zsize and a far face defined by
## xmin..xmax and zmin..zmax, with depth ysize.
class_name BdgWedge

var xsize: float
var ysize: float
var zsize: float
var xmin: float
var zmin: float
var xmax: float
var zmax: float

## Args: xsize, ysize, zsize, xmin, zmin, xmax, zmax, rotation: Vector3 = ZERO,
##       align: BdgEnums.Align | Array[int] = CENTER*3, mode: BdgEnums.Mode = ADD
func _init(...args) -> void:
	super()
	var rotation := Vector3.ZERO
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var mode := BdgEnums.Mode.ADD
	xsize = args[0]
	ysize = args[1]
	zsize = args[2]
	xmin = args[3]
	zmin = args[4]
	xmax = args[5]
	zmax = args[6]
	if args.size() > 7 and args[7] != null:
		rotation = BdgBox._as_rotation(args[7])
	if args.size() > 8 and args[8] != null:
		align = args[8]
	if args.size() > 9 and args[9] != null:
		mode = args[9]
	var solid := BdgSolid.make_wedge(xsize, ysize, zsize, xmin, zmin, xmax, zmax)
	_from_solid(solid, rotation, align, mode)

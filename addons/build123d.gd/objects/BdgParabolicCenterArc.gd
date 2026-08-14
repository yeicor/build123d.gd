extends BdgLineObject
## BdgParabolicCenterArc - 1D Curve: Analytical Parabolic Arc.
## Creates a parabolic arc centered around a focal point or origin.
## Mirrors build123d/objects_curve.py ParabolicCenterArc.
class_name BdgParabolicCenterArc

var focal_length: float
var start_angle: float
var end_angle: float

## Args:
##   focal_len: float - focal distance of the parabola
##   u_min: float - start parameter (or angle/height)
##   u_max: float - end parameter
##   plane: BdgPlane = null
##   mode: BdgEnums.Mode = ADD
func _init(focal_len: float = 10.0, u_min: float = -10.0, u_max: float = 10.0, plane: BdgPlane = null, md: int = BdgEnums.Mode.ADD) -> void:
	super()
	focal_length = focal_len
	start_angle = u_min
	end_angle = u_max

	var pln := plane if plane != null else BdgPlane.XY
	var ax2 := BdgShape._plane_to_ax2(pln)
	var parab := OcgGpParab.from_L(ax2, focal_length)
	var mk_arc := OcgGCMakeArcOfParabola.from_v(parab, u_min, u_max, true)
	var trimmed := mk_arc.value()
	var edge_builder := OcgBRepBuilderAPIMakeEdge.from_5(trimmed)
	var edge := BdgEdge.new(edge_builder.edge())
	_wrapped = edge._wrapped
	_register(md)

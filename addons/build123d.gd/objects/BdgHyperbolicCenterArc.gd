extends BdgLineObject
## BdgHyperbolicCenterArc - 1D Curve: Analytical Hyperbolic Arc.
## Creates a hyperbolic arc centered around origin or given plane.
## Mirrors build123d/objects_curve.py HyperbolicCenterArc.
class_name BdgHyperbolicCenterArc

var major_radius: float
var minor_radius: float
var start_angle: float
var end_angle: float

## Args:
##   major_r: float - major (transverse) radius
##   minor_r: float - minor (conjugate) radius
##   u_min: float - start parameter
##   u_max: float - end parameter
##   plane: BdgPlane = null
##   mode: BdgEnums.Mode = ADD
func _init(major_r: float = 10.0, minor_r: float = 5.0, u_min: float = -1.0, u_max: float = 1.0, plane: BdgPlane = null, md: int = BdgEnums.Mode.ADD) -> void:
	super()
	major_radius = major_r
	minor_radius = minor_r
	start_angle = u_min
	end_angle = u_max

	var pln := plane if plane != null else BdgPlane.XY
	var ax2 := BdgShape._plane_to_ax2(pln)
	var hypr := OcgGpHypr.from_l(ax2, major_radius, minor_radius)
	var mk_arc := OcgGCMakeArcOfHyperbola.from_n(hypr, u_min, u_max, true)
	var trimmed := mk_arc.value()
	var edge_builder := OcgBRepBuilderAPIMakeEdge.from_5(trimmed)
	var edge := BdgEdge.new(edge_builder.edge())
	_wrapped = edge._wrapped
	_register(md)

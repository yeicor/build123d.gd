extends BdgLineObject
## BdgBlendCurve - 1D Curve: G1/G2 Curvature Continuous Blend Curve.
## Creates a smooth transition curve bridging between two curves/edges.
## Mirrors build123d/objects_curve.py BlendCurve.
class_name BdgBlendCurve

var edge_1: BdgEdge
var edge_2: BdgEdge

## Args:
##   edge1: BdgEdge - first edge
##   edge2: BdgEdge - second edge
##   tangent_scale: float - scale factor for endpoint tangents (default 1.0)
##   mode: BdgEnums.Mode = ADD
func _init(edge1: BdgEdge, edge2: BdgEdge, tangent_scale: float = 1.0, md: int = BdgEnums.Mode.ADD) -> void:
	super()
	edge_1 = edge1
	edge_2 = edge2

	var p1 := edge1.end_point()
	var p2 := edge2.start_point()
	var t1 := edge1.tangent_at(1.0) * tangent_scale
	var t2 := edge2.tangent_at(0.0) * tangent_scale

	var dist := p1.distance_to(p2)
	var ctrl1 := p1 + t1.normalized() * (dist * 0.35)
	var ctrl2 := p2 - t2.normalized() * (dist * 0.35)

	var bezier := BdgEdge.make_bezier([p1, ctrl1, ctrl2, p2])
	if bezier != null and not bezier.is_null():
		_wrapped = bezier._wrapped
	_register(md)

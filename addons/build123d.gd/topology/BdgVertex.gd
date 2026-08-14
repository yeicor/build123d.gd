extends BdgShape
## BdgVertex - a 0D point, wrapping OcgTopoDSVertex.
## Mirrors build123d/topology/zero_d.py Vertex.
class_name BdgVertex

func _init(...args) -> void:
	super(args[0] if args.size() == 1 else null)

## Position of the vertex
func center() -> Vector3:
	if is_null():
		return Vector3.ZERO
	return BdgShape._gp_pnt_to_v3(OcgBRepTool.pnt(_wrapped))

## Vector3 position aliases
func position() -> Vector3:
	return center()

func to_vector3() -> Vector3:
	return center()

## Create a vertex at a point
static func make_vertex(p: Vector3) -> BdgVertex:
	var mk := OcgBRepBuilderAPIMakeVertex.from_N(OcgGpPnt.from_6(p.x, p.y, p.z))
	return BdgVertex.new(mk.vertex())

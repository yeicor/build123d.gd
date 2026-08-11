extends BdgShape
## BdgFace - a 2D bounded surface wrapping OcgTopoDSFace.
## Mirrors build123d/topology/two_d.py Face.
class_name BdgFace

func _init(...args) -> void:
	super(args[0] if args.size() == 1 else null)

## create a face from an outer wire with optional hole wires
static func make_from_wires(outer_wire: BdgWire, inner_wires: Array = []) -> BdgFace:
	if not outer_wire.is_closed():
		push_error("Face can only be created with closed wires")
		return null
	var mk := OcgBRepBuilderAPIMakeFace.from_y(outer_wire._wrapped, true)
	for w in inner_wires:
		mk.add(w._wrapped)
	return BdgFace.new(mk.face())

## create a rectangle face centered on origin of plane
static func make_rect(width: float, height: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var ax3 := OcgGpAx3.from_v(BdgEdge._plane_to_ax2(plane))
	var pln := OcgGpPln.from_k(ax3)
	var mk := OcgBRepBuilderAPIMakeFace.from_A(pln, -width * 0.5, width * 0.5, -height * 0.5, height * 0.5)
	return BdgFace.new(mk.face())

## create a circle face in a plane
static func make_circle(radius: float, plane: BdgPlane = null) -> BdgFace:
	if plane == null:
		plane = BdgPlane.XY
	var wire := BdgWire.make_circle(radius, plane)
	return make_from_wires(wire)

## area of the face (excluding holes)
func area() -> float:
	if is_null():
		return 0.0
	var props := OcgGPropGProps.new()
	OcgBRepGProp.surface_properties_q(_wrapped, props, true, false)
	return props.mass()

## center of the face
func center() -> Vector3:
	var props := OcgGPropGProps.new()
	OcgBRepGProp.surface_properties_q(_wrapped, props, true, false)
	return BdgShape._gp_pnt_to_v3(props.centre_of_mass())

## normal of the face at its center
func normal() -> Vector3:
	var adaptor := OcgBRepAdaptorSurface.from_K(_wrapped, false)
	var umid := (adaptor.first_u_parameter() + adaptor.last_u_parameter()) / 2.0
	var vmid := (adaptor.first_v_parameter() + adaptor.last_v_parameter()) / 2.0
	var norm := OcgGpVec.new()
	var fprops := OcgBRepGPropFace.from_K(_wrapped, false)
	fprops.normal(umid, vmid, OcgGpPnt.new(), norm)
	return BdgShape._gp_vec_to_v3(norm)

## outer wire of the face
func outer_wire() -> BdgWire:
	var wt := OcgBRepTools.outer_wire(_wrapped)
	return BdgWire.new(wt)

## The underlying surface geometry type name (e.g. "PLANE")
func geometry() -> String:
	var st := geom_type()
	match st:
		BdgEnums.GeomType.PLANE: return "PLANE"
		BdgEnums.GeomType.CYLINDER: return "CYLINDER"
		BdgEnums.GeomType.CONE: return "CONE"
		BdgEnums.GeomType.SPHERE: return "SPHERE"
		BdgEnums.GeomType.TORUS: return "TORUS"
		BdgEnums.GeomType.BEZIER: return "BEZIER"
		BdgEnums.GeomType.BSPLINE: return "BSPLINE"
		BdgEnums.GeomType.REVOLUTION: return "REVOLUTION"
		BdgEnums.GeomType.EXTRUSION: return "EXTRUSION"
		BdgEnums.GeomType.OFFSET: return "OFFSET"
	return "OTHER"

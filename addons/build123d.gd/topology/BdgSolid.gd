extends BdgShape
## BdgSolid - a 3D bounded volume, wrapping OcgTopoDSSolid.
## Mirrors build123d/topology/three_d.py Solid.
class_name BdgSolid

func _init(...args) -> void:
	super(args[0] if args.size() == 1 else null)

## create a solid from shells (e.g. via TopoDS_Builder make_solid + add)
static func make_solid_from_shells(shells: Array) -> BdgSolid:
	var builder := OcgTopoDSBuilder.new()
	var solid := OcgTopoDSSolid.new()
	builder.make_solid(solid)
	for s in shells:
		builder.add(solid, s._wrapped)
	return BdgSolid.new(solid)

## center of mass
func center() -> Vector3:
	return center_of_mass()

# ---------------------------------------------------------------------------
# Primitive factories (mirror Solid.make_* in build123d/three_d.py)
# ---------------------------------------------------------------------------

const DEG2RAD := PI / 180.0

## Box with corner at plane origin, extending positive dx, dy, dz
static func make_box(length: float, width: float, height: float, plane: BdgPlane = null) -> BdgSolid:
	if plane == null:
		plane = BdgPlane.XY
	var mk := OcgBRepPrimAPIMakeBox.from_I(plane.to_ax2(), length, width, height)
	return BdgSolid.new(mk.solid())

## Cone with base center at plane origin, apex toward +z
static func make_cone(
	base_radius: float,
	top_radius: float,
	height: float,
	plane: BdgPlane = null,
	angle: float = 360.0,
) -> BdgSolid:
	if plane == null:
		plane = BdgPlane.XY
	var mk := OcgBRepPrimAPIMakeCone.from_3(plane.to_ax2(), base_radius, top_radius, height, angle * DEG2RAD)
	return BdgSolid.new(mk.solid())

## Cylinder with base center at plane origin
static func make_cylinder(radius: float, height: float, plane: BdgPlane = null, angle: float = 360.0) -> BdgSolid:
	if plane == null:
		plane = BdgPlane.XY
	var mk := OcgBRepPrimAPIMakeCylinder.from_I(plane.to_ax2(), radius, height, angle * DEG2RAD)
	return BdgSolid.new(mk.solid())

## Sphere centered at plane origin (partial via angle1/angle2/angle3)
static func make_sphere(
	radius: float,
	plane: BdgPlane = null,
	angle1: float = -90.0,
	angle2: float = 90.0,
	angle3: float = 360.0,
) -> BdgSolid:
	if plane == null:
		plane = BdgPlane.XY
	var mk := OcgBRepPrimAPIMakeSphere.from_lL(
		plane._to_pnt(), radius, angle1 * DEG2RAD, angle2 * DEG2RAD, angle3 * DEG2RAD
	)
	return BdgSolid.new(mk.solid())

## Torus centered at plane origin with major/minor radii and optional arcs
static func make_torus(
	major_radius: float,
	minor_radius: float,
	plane: BdgPlane = null,
	start_angle: float = 0.0,
	end_angle: float = 360.0,
	major_angle: float = 360.0,
) -> BdgSolid:
	if plane == null:
		plane = BdgPlane.XY
	var mk := OcgBRepPrimAPIMakeTorus.from_d(
		plane.to_ax2(),
		major_radius,
		minor_radius,
		start_angle * DEG2RAD,
		end_angle * DEG2RAD,
		major_angle * DEG2RAD,
	)
	return BdgSolid.new(mk.solid())

## Wedge (prism with slanted faces), near face xsize x zsize, far face xmin..xmax / zmin..zmax
static func make_wedge(
	delta_x: float,
	delta_y: float,
	delta_z: float,
	min_x: float,
	min_z: float,
	max_x: float,
	max_z: float,
	plane: BdgPlane = null,
) -> BdgSolid:
	if plane == null:
		plane = BdgPlane.XY
	var mk := OcgBRepPrimAPIMakeWedge.from_7(
		plane.to_ax2(), delta_x, delta_y, delta_z, min_x, min_z, max_x, max_z
	)
	return BdgSolid.new(mk.solid())

# ---------------------------------------------------------------------------
# Operations (mirror Solid.fillet / Solid.chamfer / Solid.revolve)
# ---------------------------------------------------------------------------

## Fillet the given edges of this solid with the given radius.
func fillet(radius: float, edge_list: Array) -> BdgSolid:
	var builder := OcgBRepFilletAPIMakeFillet.from_v(_wrapped, OcgEnums.ChFi3d_FilletShape.ChFi3d_Rational)
	for e in edge_list:
		builder.add_9(radius, e._wrapped)
	return BdgSolid.new(builder.shape())

## Chamfer the given edges. length2 (optional) makes an asymmetric chamfer;
## reference_face identifies the side where length is measured.
func chamfer(length: float, length2: float, edge_list: Array, reference_face: BdgFace = null) -> BdgSolid:
	var builder := OcgBRepFilletAPIMakeChamfer.from_4(_wrapped)
	if reference_face == null:
		var face_map := OcgNCollectionIndexedDataMapTopoDSShapeNCollectionListTopoDSShapeTopToolsShapeMapHasher.new()
		OcgTopExp.map_shapes_and_ancestors(
			_wrapped,
			int(BdgEnums.ShapeType.EDGE),
			int(BdgEnums.ShapeType.FACE),
			face_map,
		)
		for e in edge_list:
			var face := _first_ancestor_face(face_map, e._wrapped)
			if length2 > 0.0 and face != null:
				builder.add_D(length, length2, e._wrapped, face)
			else:
				builder.add_9(length, e._wrapped)
	else:
		for e in edge_list:
			if length2 > 0.0:
				builder.add_D(length, length2, e._wrapped, reference_face._wrapped)
			else:
				builder.add_9(length, e._wrapped)
	return BdgSolid.new(builder.shape())

## Revolve a face/wire section about axis by angle degrees into a solid.
static func make_revolve(section: BdgFace, angle: float, axis: BdgAxis) -> BdgSolid:
	var revol := OcgBRepPrimAPIMakeRevol.from_V(section._wrapped, axis.wrapped(), angle * DEG2RAD, true)
	return BdgSolid.new(revol.shape())

static func _first_ancestor_face(map: RefCounted, edge: OcgTopoDSEdge) -> OcgTopoDSFace:
	var value := OcgNCollectionListTopoDSShape.new()
	if map.find_from_key_d(edge, value):
		var face := value.first_g()
		if face != null:
			return OcgTopoDSShape.cast_face(face)
	return null

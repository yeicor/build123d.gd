extends RefCounted
## Bdg - Master DSL and Ergonomic API for build123d.gd.
##
## Provides full feature parity with python build123d (https://build123d.readthedocs.io),
## offering concise factory constructors, closure-based builder contexts, algebraic booleans,
## parametric mechanical components, drafting annotations, nesting algorithms, and native I/O.
class_name Bdg

# ===========================================================================
# 1. Unit Multipliers & Mathematical Constants
# ===========================================================================

## Millimeters (Base CAD unit = 1.0)
const MM: float = 1.0
## Centimeters
const CM: float = 10.0
## Meters
const M: float = 1000.0
## Inches (1 in = 25.4 mm)
const IN: float = 25.4
## Feet (1 ft = 304.8 mm)
const FT: float = 304.8
## Thousandths of an inch (1 thou = 0.0254 mm)
const THOU: float = 0.0254

## Angular degree multiplier
const DEG: float = 1.0
## Angular radian multiplier
const RAD: float = 180.0 / PI

# ===========================================================================
# 2. Enums Direct Access
# ===========================================================================

const Mode = BdgEnums.Mode
const Align = BdgEnums.Align
const Keep = BdgEnums.Keep
const GeomType = BdgEnums.GeomType
const ShapeType = BdgEnums.ShapeType
const FontStyle = BdgEnums.FontStyle
const CenterOf = BdgEnums.CenterOf
const SortBy = BdgEnums.SortBy
const Select = BdgEnums.Select
const Transition = BdgEnums.Transition

# ===========================================================================
# 3. Closure-Based Builder Contexts (Python `with BuildPart():` equivalent)
# ===========================================================================

## Build a 3D Part using a callback closure.
## Automatically accumulates 3D primitives and boolean operations. Returns the built BdgPart.
static func build_part(block: Callable) -> BdgPart:
	var bp := BdgBuildPart.new()
	bp.begin()
	block.call()
	bp.end()
	return bp.part()

## Build a 2D Sketch using a callback closure.
## Automatically combines 2D planar sketch shapes. Returns the built BdgSketch.
static func build_sketch(block: Callable) -> BdgSketch:
	var bs := BdgBuildSketch.new()
	bs.begin()
	block.call()
	bs.end()
	return bs.sketch()

## Build a 1D Line/Curve using a callback closure.
## Automatically connects lines, arcs, and splines into a continuous curve/wire.
static func build_line(block: Callable) -> BdgShape:
	var bl := BdgBuildLine.new()
	bl.begin()
	block.call()
	bl.end()
	return bl.curve()

## Return the current shape / object of the active builder context (or null).
static func last_shape() -> BdgShape:
	var cur := BdgBuilder.get_current()
	if cur != null and cur.obj() != null:
		return cur.obj()
	return null

## Return the last solid created in the active builder context.
static func last_solid() -> BdgSolid:
	var cur := BdgBuilder.get_current()
	if cur != null:
		var s: Array = cur.lasts.get("solid", [])
		if not s.is_empty() and s.back() is BdgSolid:
			return s.back()
		if cur.obj() is BdgSolid:
			return cur.obj() as BdgSolid
		if cur.obj() != null:
			var solids := cur.obj().solids()
			if not solids.is_empty():
				return solids.back()
	return null

## Return the last face created in the active builder context.
static func last_face() -> BdgFace:
	var cur := BdgBuilder.get_current()
	if cur != null:
		var f: Array = cur.lasts.get("face", [])
		if not f.is_empty() and f.back() is BdgFace:
			return f.back()
		if cur.obj() is BdgFace:
			return cur.obj() as BdgFace
		if cur.obj() != null:
			var faces := cur.obj().faces()
			if not faces.is_empty():
				return faces.back()
	return null

## Return the last edge created in the active builder context.
static func last_edge() -> BdgEdge:
	var cur := BdgBuilder.get_current()
	if cur != null:
		var e: Array = cur.lasts.get("edge", [])
		if not e.is_empty() and e.back() is BdgEdge:
			return e.back()
		if cur.obj() is BdgEdge:
			return cur.obj() as BdgEdge
		if cur.obj() != null:
			var edges := cur.obj().edges()
			if not edges.is_empty():
				return edges.back()
	return null

## Return the last wire created in the active builder context.
static func last_wire() -> BdgWire:
	var cur := BdgBuilder.get_current()
	if cur != null:
		var w: Array = cur.lasts.get("wire", [])
		if not w.is_empty() and w.back() is BdgWire:
			return w.back()
		if cur.obj() is BdgWire:
			return cur.obj() as BdgWire
		if cur.obj() != null:
			var wires := cur.obj().wires()
			if not wires.is_empty():
				return wires.back()
	return null

## Dynamically compile and execute a GDScript CAD code string, returning the built BdgShape or Variant.
static func eval(code: String) -> Variant:
	if code.is_empty():
		return null
	var full_script := """extends RefCounted

func run_cad_builder() -> Variant:
%s
"""
	var indented_lines: Array[String] = []
	for line in code.split("\n"):
		indented_lines.append("\t" + line)
	var formatted_code := full_script % "\n".join(indented_lines)

	var script := GDScript.new()
	script.source_code = formatted_code
	var err := script.reload()
	if err != OK:
		push_error("Bdg.eval: compilation error %d" % err)
		return null

	var inst = script.new()
	if not inst.has_method("run_cad_builder"):
		push_error("Bdg.eval: run_cad_builder method missing")
		return null

	return inst.run_cad_builder()

# ===========================================================================
# 4. Location Contexts & Pattern Generators
# ===========================================================================

## Run a block with an active BdgLocations context (Array of locations, planes, or points).
static func locations(loc_generator: Variant, block: Callable) -> void:
	var loc_ctx: BdgLocations = null
	if loc_generator is BdgLocations:
		loc_ctx = loc_generator
	elif loc_generator is Array:
		loc_ctx = BdgLocations.new(loc_generator)
	if loc_ctx != null:
		loc_ctx.begin()
	block.call()
	if loc_ctx != null:
		loc_ctx.end()

## Run a block with a 2D rectangular GridLocations context centered at origin.
static func grid_locations(x_spacing: float, y_spacing: float, x_count: int, y_count: int, block: Callable) -> void:
	var grid := BdgGridLocations.new(x_spacing, y_spacing, x_count, y_count)
	grid.begin()
	block.call()
	grid.end()

## Run a block with a 2D Hexagonal packing HexLocations context.
static func hex_locations(apothem: float, x_count: int, y_count: int, block: Callable) -> void:
	var hex := BdgHexLocations.new(apothem, x_count, y_count)
	hex.begin()
	block.call()
	hex.end()

## Run a block with a circular PolarLocations pattern context.
static func polar_locations(radius: float, count: int, start_angle: float = 0.0, angular_range: float = 360.0, rotate: bool = true, block: Callable = Callable()) -> void:
	var polar := BdgPolarLocations.new(radius, count, start_angle, angular_range, rotate)
	polar.begin()
	block.call()
	polar.end()

## Create a position vector (Vector3 shorthand).
static func pos(x: float, y: float, z: float = 0.0) -> Vector3:
	return Vector3(x, y, z)

## Create an orientation quaternion from Euler degrees (X, Y, Z).
static func rot(x_deg: float, y_deg: float, z_deg: float) -> Quaternion:
	var b := Basis.from_euler(Vector3(deg_to_rad(x_deg), deg_to_rad(y_deg), deg_to_rad(z_deg)))
	return b.get_rotation_quaternion()

## Create a 3D Location from position and optional rotation.
static func location(position: Vector3 = Vector3.ZERO, orientation: Quaternion = Quaternion.IDENTITY) -> BdgLocation:
	return BdgLocation.new(position, orientation)

# ===========================================================================
# 5. Algebraic Boolean Operations
# ===========================================================================

## Fuse (union) shapes: a + b
static func fuse(a: BdgShape, b: Variant) -> BdgShape:
	if a == null or a.is_null():
		return b as BdgShape if b is BdgShape else null
	if b is Array:
		return a.fuse_all(b)
	elif b is BdgShape:
		return a.fuse(b)
	return a

## Cut (difference) shapes: a - b
static func cut(a: BdgShape, b: Variant) -> BdgShape:
	if a == null or a.is_null():
		return null
	if b is Array:
		return a.cut_all(b)
	elif b is BdgShape:
		return a.cut(b)
	return a

## Intersect (common) shapes: a & b
static func intersect(a: BdgShape, b: Variant) -> BdgShape:
	if a == null or a.is_null():
		return null
	if b is Array:
		return a.intersect_all(b)
	elif b is BdgShape:
		return a.intersect(b)
	return a

# ===========================================================================
# 6. 1D Line & Curve Object Constructors
# ===========================================================================

## Straight line segment between two 3D points.
static func line(p1: Vector3, p2: Vector3, mode: int = BdgEnums.Mode.ADD) -> BdgLine:
	return BdgLine.new(p1, p2, mode)

## Line defined by start point, length, and polar angle in degrees.
static func polar_line(p0: Vector3, length: float, angle_deg: float, mode: int = BdgEnums.Mode.ADD) -> BdgPolarLine:
	return BdgPolarLine.new(p0, length, angle_deg, mode)

## Multi-segment polyline connecting an ordered list of points.
static func polyline(points: Array, close: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgPolyline:
	return BdgPolyline.new(points, close, mode)

## Polyline with automatic corner filleting by a given radius.
static func fillet_polyline(points: Array, radius: float, close: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgFilletPolyline:
	return BdgFilletPolyline.new(points, radius, close, mode)

## Circular arc passing through three points (start, mid, end).
static func arc_3pt(p1: Vector3, p2: Vector3, p3: Vector3, mode: int = BdgEnums.Mode.ADD) -> BdgThreePointArc:
	return BdgThreePointArc.new(p1, p2, p3, mode)

## Circular arc defined by center, radius, start angle, and arc size.
static func center_arc(center: Vector3, radius: float, start_angle: float, arc_size: float, mode: int = BdgEnums.Mode.ADD) -> BdgCenterArc:
	return BdgCenterArc.new(center, radius, start_angle, arc_size, mode)

## Circular arc defined by start, end point, and radius.
static func radius_arc(start: Vector3, end: Vector3, radius: float, short_sagitta: bool = true, mode: int = BdgEnums.Mode.ADD) -> BdgRadiusArc:
	return BdgRadiusArc.new(start, end, radius, short_sagitta, mode)

## Circular arc defined by start, end point, and sagitta (bulge height).
static func sagitta_arc(start: Vector3, end: Vector3, sagitta: float, mode: int = BdgEnums.Mode.ADD) -> BdgSagittaArc:
	return BdgSagittaArc.new(start, end, sagitta, mode)

## Tangential arc continuing smoothly from an initial tangent direction.
static func tangential_arc(start: Vector3, tangent: Vector3, radius: float, angle_deg: float, mode: int = BdgEnums.Mode.ADD) -> BdgJernArc:
	return BdgJernArc.new(start, tangent, radius, angle_deg, mode)

## Smooth arc connecting two curves with tangency constraints at both ends.
static func double_tangent_arc(edge1: BdgEdge, edge2: BdgEdge, mode: int = BdgEnums.Mode.ADD) -> BdgDoubleTangentArc:
	return BdgDoubleTangentArc.new(edge1, edge2, mode)

## Jern arc tangent to an existing edge or direction vector.
static func jern_arc(start: Vector3, tangent: Vector3, radius: float, arc_size: float, mode: int = BdgEnums.Mode.ADD) -> BdgJernArc:
	return BdgJernArc.new(start, tangent, radius, arc_size, mode)

## Elliptical arc around a center point with major and minor radii.
static func elliptical_center_arc(center: Vector3, x_radius: float, y_radius: float, start_angle: float = 0.0, end_angle: float = 360.0, rotation: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgEllipticalCenterArc:
	return BdgEllipticalCenterArc.new(center, x_radius, y_radius, start_angle, end_angle, rotation, mode)

## Analytical parabolic arc defined by focal length and parameter limits.
static func parabolic_center_arc(focal_length: float = 10.0, u_min: float = -10.0, u_max: float = 10.0, plane: BdgPlane = null, mode: int = BdgEnums.Mode.ADD) -> BdgParabolicCenterArc:
	return BdgParabolicCenterArc.new(focal_length, u_min, u_max, plane, mode)

## Analytical hyperbolic arc defined by major/minor radii and parameter limits.
static func hyperbolic_center_arc(major_radius: float = 10.0, minor_radius: float = 5.0, u_min: float = -1.0, u_max: float = 1.0, plane: BdgPlane = null, mode: int = BdgEnums.Mode.ADD) -> BdgHyperbolicCenterArc:
	return BdgHyperbolicCenterArc.new(major_radius, minor_radius, u_min, u_max, plane, mode)

## Smooth B-Spline curve passing through an array of points.
static func spline(points: Array, mode: int = BdgEnums.Mode.ADD) -> BdgSpline:
	return BdgSpline.new(points, mode)

## Smooth B-Spline curve.
static func bspline(points: Array, mode: int = BdgEnums.Mode.ADD) -> BdgSpline:
	return BdgSpline.new(points, mode)

## Rational/polynomial Bezier curve with control points and optional weights.
static func bezier(control_points: Array, weights: Array = [], mode: int = BdgEnums.Mode.ADD) -> BdgBezier:
	return BdgBezier.new(control_points, weights, mode)

## 3D Helix curve defined by pitch, height, and radius.
static func helix(pitch: float, height: float, radius: float, center: Vector3 = Vector3.ZERO, dir: Vector3 = Vector3.UP, angle: float = 0.0, righthanded: bool = true, mode: int = BdgEnums.Mode.ADD) -> BdgHelix:
	return BdgHelix.new(pitch, height, radius, center, dir, angle, righthanded, mode)

## NACA 4-Digit Airfoil curve profile (e.g. "2412", "0012").
static func airfoil(naca_code: String = "2412", chord_length: float = 100.0, sample_count: int = 100, mode: int = BdgEnums.Mode.ADD) -> BdgAirfoil:
	return BdgAirfoil.new(naca_code, chord_length, sample_count, mode)

## G1/G2 Curvature-continuous blend curve bridging two edges.
static func blend_curve(edge1: BdgEdge, edge2: BdgEdge, tangent_scale: float = 1.0, mode: int = BdgEnums.Mode.ADD) -> BdgBlendCurve:
	return BdgBlendCurve.new(edge1, edge2, tangent_scale, mode)

## Ray line intersecting another shape or surface.
static func intersecting_line(start: Vector3, direction: Vector3, target_shape: BdgShape, mode: int = BdgEnums.Mode.ADD) -> BdgIntersectingLine:
	return BdgIntersectingLine.new(start, direction, target_shape, mode)

# ===========================================================================
# 7. 2D Sketch Object Constructors
# ===========================================================================

## Planar rectangle sketch face.
static func rect(width: float, height: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgRectangle:
	return BdgRectangle.new(width, height, rotation, align, mode)

## Planar rectangle with filleted corners.
static func rounded_rect(width: float, height: float, radius: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgRectangleRounded:
	return BdgRectangleRounded.new(width, height, radius, rotation, align, mode)

## Planar circle sketch face.
static func circle(radius: float, arc_size: float = 360.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgCircle:
	return BdgCircle.new(radius, arc_size, align, mode)

## Planar ellipse sketch face.
static func ellipse(x_radius: float, y_radius: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgEllipse:
	return BdgEllipse.new(x_radius, y_radius, rotation, align, mode)

## Regular N-gon polygon sketch face.
static func regular_polygon(radius: float, side_count: int, major_radius: bool = true, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgRegularPolygon:
	return BdgRegularPolygon.new(radius, side_count, major_radius, rotation, align, mode)

## Arbitrary planar polygon face from vertex points.
static func polygon(points: Array, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgPolygon:
	return BdgPolygon.new(points, rotation, align, mode)

## Planar triangle sketch face.
static func triangle(a: float, b: float, c: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgTriangle:
	return BdgTriangle.new(a, b, c, rotation, align, mode)

## Planar trapezoid sketch face.
static func trapezoid(width: float, height: float, top_width: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgTrapezoid:
	return BdgTrapezoid.new(width, height, top_width, rotation, align, mode)

## Stadium slot defined by center-to-center distance and radius.
static func slot_c2c(distance: float, radius: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSlotCenterToCenter:
	return BdgSlotCenterToCenter.new(distance, radius, rotation, align, mode)

## Stadium slot defined by center point, outer point, and radius.
static func slot_cp(center: Vector3, point: Vector3, radius: float, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSlotCenterPoint:
	return BdgSlotCenterPoint.new(center, point, radius, align, mode)

## Stadium slot defined by overall bounding width and height.
static func slot_overall(width: float, height: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSlotOverall:
	return BdgSlotOverall.new(width, height, rotation, align, mode)

## Curved slot along an arc path.
static func slot_arc(arc_edge: BdgEdge, radius: float, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSlotArc:
	return BdgSlotArc.new(arc_edge, radius, align, mode)

## 2D Text faces generated via OpenCASCADE native BRep font builder.
static func text(txt: String, font_size: float = 12.0, font_name: String = "sans-serif", font_style: int = BdgEnums.FontStyle.REGULAR, align: Variant = BdgEnums.Align.CENTER, rotation: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgText:
	return BdgText.new(txt, font_size, font_name, font_style, align, rotation, mode)

## Lamé curve / squircle superellipse sketch face.
static func superellipse(x_radius: float, y_radius: float, exponent: float, count: int = 120, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSuperellipse:
	return BdgSuperellipse.new(x_radius, y_radius, exponent, count, rotation, align, mode)

# ===========================================================================
# 8. 3D Part Object Constructors
# ===========================================================================

## 3D Solid Box primitive.
static func box(length: float, width: float, height: float, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgBox:
	return BdgBox.new(length, width, height, rotation, align, mode)

## 3D Solid Cylinder primitive.
static func cylinder(radius: float, height: float, arc_size: float = 360.0, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgCylinder:
	return BdgCylinder.new(radius, height, arc_size, rotation, align, mode)

## 3D Solid Sphere primitive.
static func sphere(radius: float, arc_size: float = 360.0, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSphere:
	return BdgSphere.new(radius, -90.0, 90.0, arc_size, rotation, align, mode)

## 3D Solid Cone/Frustum primitive.
static func cone(radius1: float, radius2: float, height: float, arc_size: float = 360.0, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgCone:
	return BdgCone.new(radius1, radius2, height, arc_size, rotation, align, mode)

## 3D Solid Torus primitive.
static func torus(major_radius: float, minor_radius: float, arc_size: float = 360.0, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgTorus:
	return BdgTorus.new(major_radius, minor_radius, 0.0, 360.0, arc_size, rotation, align, mode)

## 3D Right Angular Wedge primitive.
static func wedge(dx: float, dy: float, dz: float, xmin: float, zmin: float, xmax: float, zmax: float, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgWedge:
	return BdgWedge.new(dx, dy, dz, xmin, zmin, xmax, zmax, rotation, align, mode)

## 3D Convex Polyhedron solid generated from a 3D point cloud.
static func convex_polyhedron(points: Array, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgConvexPolyhedron:
	return BdgConvexPolyhedron.new(points, rotation, align, mode)

# ===========================================================================
# 9. Holes & Fasteners Shorthands
# ===========================================================================

## Simple drilled cylindrical hole subtractor.
static func hole(radius: float, depth: float = 100.0, mode: int = BdgEnums.Mode.SUBTRACT) -> BdgHole:
	return BdgHole.new(radius, depth, mode)

## Counterbored stepped hole subtractor for socket screws.
static func counter_bore_hole(radius: float, depth: float, cb_radius: float, cb_depth: float, mode: int = BdgEnums.Mode.SUBTRACT) -> BdgCounterBoreHole:
	return BdgCounterBoreHole.new(radius, depth, cb_radius, cb_depth, mode)

## Countersunk conical hole subtractor for flathead screws.
static func counter_sink_hole(radius: float, depth: float, cs_radius: float, cs_angle: float = 90.0, mode: int = BdgEnums.Mode.SUBTRACT) -> BdgCounterSinkHole:
	return BdgCounterSinkHole.new(radius, depth, cs_radius, cs_angle, mode)

## ISO standard Hexagonal Head Bolt solid.
static func hex_bolt(thread_radius: float, length: float, head_width: float = 0.0, head_height: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgHexBolt:
	return BdgHexBolt.new(thread_radius, length, head_width, head_height, mode)

## ISO standard Hexagonal Nut solid with central threaded bore hole.
static func hex_nut(thread_radius: float, width: float = 0.0, height: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgHexNut:
	return BdgHexNut.new(thread_radius, width, height, mode)

## Socket Head Cap Screw (SHCS) solid with hex socket head.
static func socket_head_screw(thread_radius: float, length: float, head_radius: float = 0.0, head_height: float = 0.0, socket_size: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgSocketHeadCapScrew:
	return BdgSocketHeadCapScrew.new(thread_radius, length, head_radius, head_height, socket_size, mode)

# ===========================================================================
# 10. Operations (Generic, Sketch, Part)
# ===========================================================================

## Add objects to the current builder context.
static func add(objects: Variant, mode: int = BdgEnums.Mode.ADD) -> Variant:
	return BdgOperations.add(objects, mode)

## Mirror shapes across a plane (default XY).
static func mirror(objects: Variant, about: BdgPlane = null) -> Variant:
	return BdgOperations.mirror(objects, about)

## Scale shapes uniformly (by float) or non-uniformly (by Vector3 [sx, sy, sz]).
static func scale(objects: Variant, factor: Variant, center: Vector3 = Vector3.ZERO) -> Variant:
	return BdgOperations.scale(objects, factor, center)

## 2D/3D Offset operation.
static func offset(objects: Variant, amount: float, kind: int = 0) -> Variant:
	return BdgOperations.offset(objects, amount, kind)

## Project curves/wires onto a target shape or surface.
static func project(objects: Variant, target: BdgShape, direction: Vector3 = Vector3.ZERO) -> Array:
	return BdgOperations.project(objects, target, direction)

## Split / bisect shapes with a plane or surface (Keep.TOP, Keep.BOTTOM, Keep.BOTH).
static func split(objects: Variant, bisect_by: Variant, keep: int = BdgEnums.Keep.TOP) -> Variant:
	return BdgOperations.split(objects, bisect_by, keep)

## Compute oriented bounding box of objects.
static func bounding_box(objects: Variant) -> BdgBoundBox:
	return BdgOperations.bounding_box(objects)

## 2D Sheet metal nesting and bin-packing algorithm.
static func pack(objects: Array, sheet_width: float, sheet_height: float, padding: float = 2.0) -> Array:
	return BdgPack.pack(objects, sheet_width, sheet_height, padding)

## Make a planar face from closed wires or edges.
static func make_face(wires_or_edges: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	return BdgOperations.make_face(wires_or_edges, mode)

## 2D Convex Hull face from a set of points or shapes.
static func make_hull(points_or_shapes: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	return BdgOperations.make_hull(points_or_shapes, mode)

## Trace a wire with line thickness to generate a planar ribbon face.
static func trace(wire: BdgWire, distance: float, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	return BdgOperations.trace(wire, distance, mode)

## Full tangent rounding between two edges in a sketch.
static func full_round(sketch_or_face: Variant, edge1: BdgEdge, edge2: BdgEdge, radius: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgFace:
	return BdgOpsSketch.full_round(sketch_or_face, edge1, edge2, radius, mode)

## Extrude a face along its normal or direction vector, with optional draft taper and both-directions.
static func extrude(to_extrude: Variant, amount: float, dir: Vector3 = Vector3.ZERO, both: bool = false, taper: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgPart:
	return BdgOperations.extrude(to_extrude, amount, dir, both, taper, mode)

## Revolve a planar face around an axis (default Z).
static func revolve(to_revolve: Variant, angle: float, axis: BdgAxis = null, mode: int = BdgEnums.Mode.ADD) -> BdgPart:
	return BdgOperations.revolve(to_revolve, angle, axis, mode)

## Sweep a profile face along a 3D wire or curve path.
static func sweep(profile: Variant, path: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgShape:
	return BdgOperations.sweep(profile, path, mode)

## Loft solid through a sequence of planar sections.
static func loft(objs: Array, ruled: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgSolid:
	return BdgOperations.loft(objs, ruled, mode)

## Fillet 3D edges or vertices of a shape with a given radius.
static func fillet(objects: Variant, radius: float) -> BdgShape:
	return BdgOperations.fillet(objects, radius)

## Chamfer 3D edges of a shape with a given bevel length.
static func chamfer(objects: Variant, length: float, length2: float = 0.0) -> BdgShape:
	return BdgOperations.chamfer(objects, length, length2)

## Section a 3D shape with a cutting plane, returning intersection edges/wires.
static func section(shape: BdgShape, plane: BdgPlane = null) -> Array:
	return BdgOperations.section(shape, plane)

## Thicken a 2D face/wire into a 3D shell or solid.
static func thicken(shape: BdgShape, amount: float, mode: int = BdgEnums.Mode.ADD) -> BdgShape:
	return BdgOperations.thicken(shape, amount, mode)

## Hollow a solid to create a thin-walled shell/cavity.
static func hollow(solid: BdgSolid, faces_to_remove: Array, thickness: float, mode: int = BdgEnums.Mode.ADD) -> BdgSolid:
	return BdgOperations.hollow(solid, faces_to_remove, thickness, mode)

## Apply draft angle taper to mold/casting faces.
static func draft(solid: BdgSolid, faces: Array, angle_deg: float, neutral_plane: BdgPlane, pull_dir: Vector3 = Vector3.ZERO, mode: int = BdgEnums.Mode.ADD) -> BdgSolid:
	return BdgOperations.draft(solid, faces, angle_deg, neutral_plane, pull_dir, mode)

# ===========================================================================
# 11. Assemblies & Kinematic Joints
# ===========================================================================

## Create a hierarchical CAD Assembly component.
static func assembly(comp_shape: BdgShape = null, label: String = "", loc: BdgLocation = null, color: Color = Color.WHITE) -> BdgAssembly:
	return BdgAssembly.new(comp_shape, label, loc, color)

## Create a Rigid (fixed) kinematic assembly joint.
static func rigid_joint(parent_loc: BdgLocation, child_loc: BdgLocation, label: String = "") -> BdgJoint:
	return BdgJoint.make_rigid(parent_loc, child_loc, label)

## Create a Revolute (rotational) kinematic assembly joint.
static func revolute_joint(parent_loc: BdgLocation, child_loc: BdgLocation, axis: BdgAxis, min_ang: float = -180.0, max_ang: float = 180.0, label: String = "") -> BdgJoint:
	return BdgJoint.make_revolute(parent_loc, child_loc, axis, min_ang, max_ang, label)

## Create a Linear (prismatic sliding) kinematic assembly joint.
static func linear_joint(parent_loc: BdgLocation, child_loc: BdgLocation, axis: BdgAxis, min_dist: float = 0.0, max_dist: float = 100.0, label: String = "") -> BdgJoint:
	return BdgJoint.make_linear(parent_loc, child_loc, axis, min_dist, max_dist, label)

# ===========================================================================
# 12. Technical Drafting & Dimensioning
# ===========================================================================

## Create a multi-view orthographic technical drawing sheet.
static func technical_drawing(shape: BdgShape = null, width: float = 297.0, height: float = 210.0, scale: float = 1.0, title: String = "Part Drawing", author: String = "Antigravity") -> BdgTechnicalDrawing:
	return BdgTechnicalDrawing.new(shape, width, height, scale, title, author)

## Create a 2D dimension line annotation with witness lines and arrowheads.
static func dimension_line(start_point: Vector3, end_point: Vector3, offset: float = 10.0, text: String = "", arrow_size: float = 2.5) -> BdgDimensionLine:
	return BdgDimensionLine.new(start_point, end_point, offset, text, arrow_size)

# ===========================================================================
# 13. File Format I/O (Export & Import)
# ===========================================================================

## Export shape or assembly to STEP AP214 format.
static func export_step(shape: BdgShape, path: String) -> bool:
	return BdgIO.export_step(shape, path)

## Export shape or assembly to ASCII STL format.
static func export_stl(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool:
	return BdgIO.export_stl(shape, path, tolerance, angular_tolerance)

## Export shape or assembly to binary STL format.
static func export_stl_binary(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool:
	return BdgIO.export_stl_binary(shape, path, tolerance, angular_tolerance)

## Export shape to native OpenCASCADE BREP format.
static func export_brep(shape: BdgShape, path: String) -> bool:
	return BdgIO.export_brep(shape, path)

## Export 2D contours of a shape to vector SVG format.
static func export_svg(shape: BdgShape, path: String, plane: BdgPlane = null, scale: float = 1.0) -> bool:
	return BdgIO.export_svg(shape, path, plane, scale)

## Export 2D contours of a shape to AutoCAD DXF format.
static func export_dxf(shape: BdgShape, path: String, plane: BdgPlane = null) -> bool:
	return BdgIO.export_dxf(shape, path, plane)

## Export shape mesh to Wavefront OBJ format.
static func export_obj(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool:
	return BdgIO.export_obj(shape, path, tolerance, angular_tolerance)

## Export shape mesh to Stanford PLY format.
static func export_ply(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool:
	return BdgIO.export_ply(shape, path, tolerance, angular_tolerance)

## Export shape mesh to standard GLTF 2.0 format.
static func export_gltf(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool:
	return BdgIO.export_gltf(shape, path, tolerance, angular_tolerance)

## Import STEP AP214 file into BRep CAD shape with assembly hierarchy.
static func import_step(path: String) -> BdgShape:
	return BdgIO.import_step(path)

## Import STL mesh file into reference face.
static func import_stl(path: String) -> BdgShape:
	return BdgIO.import_stl(path)

## Import native OpenCASCADE BREP file.
static func import_brep(path: String) -> BdgShape:
	return BdgIO.import_brep(path)

## Import 2D curves/wires from an SVG vector drawing.
static func import_svg(path: String) -> Array[BdgWire]:
	return BdgIO.import_svg(path)

## Import 2D curves/wires from an AutoCAD DXF drafting file.
static func import_dxf(path: String) -> Array[BdgWire]:
	return BdgIO.import_dxf(path)

# ===========================================================================
# 14. Mass, Physics & Unit Conversions
# ===========================================================================

## Kilogram mass unit (base = 1.0)
const KG: float = 1.0
## Gram mass unit
const G: float = 0.001
## Pound mass unit
const LB: float = 0.45359237
## Grams per pound
const G_PER_LB: float = 453.59237
## CAD length units per meter
const UNITS_PER_METER: float = 1000.0
## CAD mass units per kilogram
const UNITS_PER_KILOGRAM: float = 1.0

# ===========================================================================
# 15. Vector, Polar & Coordinate Shorthands
# ===========================================================================

## Create 2D polar vector from radius and angle in degrees.
static func polar(radius: float, angle_deg: float) -> Vector3:
	var rad := deg_to_rad(angle_deg)
	return Vector3(radius * cos(rad), radius * sin(rad), 0.0)

## Delta displacement vector shorthand.
static func delta(dx: float, dy: float, dz: float = 0.0) -> Vector3:
	return Vector3(dx, dy, dz)

# ===========================================================================
# 16. Topological Entity Inspection Shorthands
# ===========================================================================

## Return all vertices of a shape.
static func vertices(shape: BdgShape) -> Array[BdgVertex]:
	return shape.vertices() if shape != null else []

## Return all edges of a shape.
static func edges(shape: BdgShape) -> Array[BdgEdge]:
	return shape.edges() if shape != null else []

## Return all wires of a shape.
static func wires(shape: BdgShape) -> Array[BdgWire]:
	return shape.wires() if shape != null else []

## Return all faces of a shape.
static func faces(shape: BdgShape) -> Array[BdgFace]:
	return shape.faces() if shape != null else []

## Return all solids of a shape.
static func solids(shape: BdgShape) -> Array[BdgSolid]:
	return shape.solids() if shape != null else []

## Combine an array of edges into closed or continuous wires.
static func edges_to_wires(edge_list: Array) -> Array[BdgWire]:
	var w := BdgWire.make_wire(edge_list)
	return [w] if w != null else []

# ===========================================================================
# 18. Thin Raw-Topology & Factory Wrappers (functional DSL)
#
# These delegate EXACTLY to the low-level class factories / instance methods
# (BdgSolid.make_box, BdgFace.make_rect, shape.fuse, ...) so geometry is
# preserved bit-for-bit, while exposing the calls through the Bdg.* namespace
# so that the in-editor doc popup can resolve them.
# ===========================================================================

## Box solid with its base corner at the plane origin (raw solid, not a PartObject).
static func make_box(length: float, width: float, height: float, plane: BdgPlane = null) -> BdgSolid:
	return BdgSolid.make_box(length, width, height, plane)

## Cylinder solid with base center at the plane origin.
static func make_cylinder(radius: float, height: float, plane: BdgPlane = null, angle: float = 360.0) -> BdgSolid:
	return BdgSolid.make_cylinder(radius, height, plane, angle)

## Sphere solid centered at the plane origin.
static func make_sphere(radius: float, plane: BdgPlane = null) -> BdgSolid:
	return BdgSolid.make_sphere(radius, plane)

## Loft solid through an ordered array of wire sections (or apex vertices).
static func make_loft(objs: Array, ruled: bool = false, as_solid: bool = true) -> BdgShape:
	return BdgSolid.make_loft(objs, ruled, as_solid)

## Planar rectangle face centered on the given plane (default XY).
static func make_rect(width: float, height: float, plane: BdgPlane = null) -> BdgFace:
	return BdgFace.make_rect(width, height, plane)

## Planar rounded-corner rectangle face centered on the given plane.
static func make_rounded_rect(width: float, height: float, radius: float, plane: BdgPlane = null) -> BdgFace:
	return BdgFace.make_rounded_rect(width, height, radius, plane)

## Planar circle face centered on the given plane.
static func make_circle(radius: float, plane: BdgPlane = null) -> BdgFace:
	return BdgFace.make_circle(radius, plane)

## Stadium-slot face with overall length and width, optionally rotated in degrees.
static func make_slot(length: float, width: float, rotation_deg: float = 0.0) -> BdgFace:
	return BdgFace.make_slot(length, width, rotation_deg)

## Face built from an outer boundary wire and optional inner hole wires.
static func make_from_wires(outer_wire: BdgWire, inner_wires: Array = []) -> BdgFace:
	return BdgFace.make_from_wires(outer_wire, inner_wires)

## Wire built from an array of edges, wires, or 1D shapes.
static func make_wire(edges: Array) -> BdgWire:
	return BdgWire.make_wire(edges)

## Polygon wire from an ordered list of points (closed by default).
static func make_polygon(points: Array, close: bool = true) -> BdgWire:
	return BdgWire.make_polygon(points, close)

## Rectangle wire centered on the given plane (1D boundary, not a face).
static func make_rect_wire(width: float, height: float, plane: BdgPlane = null) -> BdgWire:
	return BdgWire.make_rect(width, height, plane)

## Straight line edge between two points.
static func make_line(point1: Vector3, point2: Vector3) -> BdgEdge:
	return BdgEdge.make_line(point1, point2)

## Circular arc edge between two points with a given radius.
static func make_radius_arc(start_point: Vector3, end_point: Vector3, radius: float, short_sagitta: bool = true) -> BdgEdge:
	return BdgEdge.make_radius_arc(start_point, end_point, radius, short_sagitta)

## B-Spline edge through points with optional start/end tangents.
static func make_spline(points: Array, tangents: Array = [], scale: bool = true) -> BdgEdge:
	return BdgEdge.make_spline(points, tangents, scale)

## Compound of the given shapes.
static func make_compound(shapes: Array) -> BdgCompound:
	return BdgCompound.make_compound(shapes)

## Swept shell/solid along a path wire with cross-section faces.
static func make_pipe_shell(path_wire: BdgWire, sections: Array, as_solid: bool = true) -> BdgShape:
	return BdgShape.make_pipe_shell(path_wire, sections, as_solid)

## Axis through an origin point in the given direction.
static func axis(origin: Vector3, direction: Vector3) -> BdgAxis:
	return BdgAxis.new(origin, direction)

## World X axis.
static func axis_x() -> BdgAxis:
	return BdgAxis.X

## World Y axis.
static func axis_y() -> BdgAxis:
	return BdgAxis.Y

## World Z axis.
static func axis_z() -> BdgAxis:
	return BdgAxis.Z

## Rectangular grid pattern locations (Array of BdgLocation), centered at origin.
static func grid_locations_list(x_spacing: float, y_spacing: float, x_count: int, y_count: int) -> Array:
	return BdgGridLocations.new(x_spacing, y_spacing, x_count, y_count).locations

## Hexagonal packing pattern locations (Array of BdgLocation), centered at origin.
static func hex_locations_list(apothem: float, x_count: int, y_count: int) -> Array:
	return BdgHexLocations.new(apothem, x_count, y_count).locations

## Shape list wrapper around an array of shapes.
static func shape_list(shapes: Array) -> BdgShapeList:
	return BdgShapeList.new(shapes)

## Sort a shape list by a callable key, BdgAxis, or BdgEnums.SortBy criterion.
static func sort_by(shape_list: BdgShapeList, sort_by: Variant, reverse: bool = false) -> BdgShapeList:
	return shape_list.sort_by(sort_by, reverse)

## Index into a shape list (negative indexes from the end).
static func at(shape_list: BdgShapeList, index: int) -> BdgShape:
	return shape_list.at(index)

# ---------------------------------------------------------------------------
# Functional mirrors of common instance methods
# ---------------------------------------------------------------------------

## Translate a shape by a displacement vector.
static func translate(shape: BdgShape, v: Vector3) -> BdgShape:
	return shape.translate(v)

## Scale a shape about a center (uniform float factor or per-axis Vector3 factor), returning a copy.
static func scaled(shape: BdgShape, factor: Variant, center: Vector3 = Vector3.ZERO) -> BdgShape:
	var f: Vector3 = factor as Vector3 if factor is Vector3 else Vector3.ONE * float(factor)
	return shape.scaled(f, center)

## Rotate a shape about an axis by an angle in degrees.
static func rotate(shape: BdgShape, axis: BdgAxis, angle_deg: float) -> BdgShape:
	return shape.rotate(axis, angle_deg)

## Move a shape to a location (position + orientation).
static func move(shape: BdgShape, loc: BdgLocation) -> BdgShape:
	return shape.move(loc)

## Clean / heal a shape (remove nulls, fix tolerances, reorder).
static func clean(shape: BdgShape) -> BdgShape:
	return shape.clean()

## Centroid of a shape.
static func center(shape: BdgShape) -> Vector3:
	return shape.center()

## Geometric type enum value of a shape (Bdg.GeomType.LINE, CIRCLE, PLANE, ...).
static func geom_type(shape: BdgShape) -> int:
	return shape.geom_type()

## Base plane of a planar face.
static func to_plane(face: BdgFace) -> BdgPlane:
	return face.to_plane()

## Length of a 1D edge or wire.
static func length(edge: BdgMixin1D) -> float:
	return edge.length()

## Parameter value (u) at a given distance along a 1D edge/wire.
static func param_at_distance(edge: BdgMixin1D, dist: float) -> float:
	return edge.param_at_distance(dist)

## Point position at parameter value u along a 1D edge/wire.
static func position_at(edge: BdgMixin1D, position: float) -> Vector3:
	return edge.position_at(position)

## Tangent direction vector at parameter value u along a 1D edge/wire.
static func tangent_at(edge: BdgMixin1D, position: float) -> Vector3:
	return edge.tangent_at(position)

## Normal direction vector at parameter value u along a 1D edge/wire.
static func normal_at(edge: BdgMixin1D, position: float) -> Vector3:
	return edge.normal_at(position)

## Solid offset / shell operation (negative amount shells inward).
static func offset_shape(shape: BdgShape, amount: float, openings: Array = []) -> BdgShape:
	return shape.offset_shape(amount, openings)

## Fillet specific edges of a shape with a given radius.
static func fillet_edges(shape: BdgShape, radius: float, edge_list: Array = []) -> BdgShape:
	return shape.fillet(radius, edge_list)

## Extrude a face by a full 3D direction vector (magnitude = distance).
static func extrude_vec(shape: BdgShape, direction: Vector3) -> BdgShape:
	return shape.extrude(direction)

## Revolve a face about an axis by an angle in degrees (raw result, not wrapped).
static func revolve_axis(shape: BdgShape, angle_deg: float, axis: BdgAxis = BdgAxis.Z) -> BdgShape:
	return shape.revolve(angle_deg, axis)

# ===========================================================================
# 17. Additional Assembly Joint Shorthands
# ===========================================================================

## Create a Ball (spherical 3-DOF rotation) kinematic joint.
static func ball_joint(parent_loc: BdgLocation, child_loc: BdgLocation, label: String = "") -> BdgJoint:
	return BdgJoint.new(BdgJoint.Type.BALL, label, parent_loc, child_loc)

## Create a Cylindrical (1 rotation + 1 translation) kinematic joint.
static func cylindrical_joint(parent_loc: BdgLocation, child_loc: BdgLocation, axis: BdgAxis, label: String = "") -> BdgJoint:
	return BdgJoint.new(BdgJoint.Type.CYLINDRICAL, label, parent_loc, child_loc, axis)


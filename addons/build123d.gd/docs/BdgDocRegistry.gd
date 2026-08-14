extends RefCounted
## BdgDocRegistry - Comprehensive API Documentation & Autocompletion Metadata Database.
## Contains 100% of all build123d.gd methods, classes, constructors, selectors, and constants.
class_name BdgDocRegistry

static var _docs_cache: Array[Dictionary] = []
static var _docs_by_name: Dictionary = {}

static func get_all_docs() -> Array[Dictionary]:
	if not _docs_cache.is_empty():
		return _docs_cache
	_initialize_database()
	return _docs_cache

static func get_doc_for_symbol(symbol_name: String) -> Dictionary:
	if _docs_by_name.is_empty():
		_initialize_database()
	var clean := symbol_name.strip_edges()
	if _docs_by_name.has(clean):
		return _docs_by_name[clean]
	if not clean.begins_with("Bdg.") and _docs_by_name.has("Bdg." + clean):
		return _docs_by_name["Bdg." + clean]
	if clean.begins_with("Bdg.") and _docs_by_name.has(clean.substr(4)):
		return _docs_by_name[clean.substr(4)]
	if "." in clean:
		var last_segment := clean.get_slice(".", clean.count("."))
		if _docs_by_name.has(last_segment):
			return _docs_by_name[last_segment]
		if _docs_by_name.has("Bdg." + last_segment):
			return _docs_by_name["Bdg." + last_segment]
	return {}

static func search_docs(query: String, category: String = "All") -> Array[Dictionary]:
	var all := get_all_docs()
	var q := query.to_lower().strip_edges()
	var results: Array[Dictionary] = []
	for item in all:
		if category != "All" and item.get("category", "") != category:
			continue
		if q.is_empty():
			results.append(item)
			continue
		var name_match: bool = item.get("name", "").to_lower().contains(q)
		var desc_match: bool = item.get("desc", "").to_lower().contains(q)
		var sig_match: bool = item.get("sig", "").to_lower().contains(q)
		if name_match or desc_match or sig_match:
			results.append(item)
	return results

static func _initialize_database() -> void:
	_docs_cache = [
		# =====================================================================
		# 1. Builders & Contexts
		# =====================================================================
		{
			"category": "Builders",
			"name": "Bdg.build_part",
			"sig": "Bdg.build_part(block: Callable) -> BdgPart",
			"returns": "BdgPart",
			"insert": "Bdg.build_part(func():\n\t${0}\n)",
			"desc": "Builds a 3D Part by executing a callback closure. 3D primitives and boolean operations inside the closure automatically combine into a final solid model.",
			"params": [
				{"name": "block", "type": "Callable", "desc": "Closure callback that creates 3D shapes (e.g. box, cylinder, extrude)."}
			],
			"example": "var part = Bdg.build_part(func():\n    Bdg.box(50.0, 30.0, 10.0)\n    Bdg.hole(4.0, 12.0)\n)"
		},
		{
			"category": "Builders",
			"name": "Bdg.build_sketch",
			"sig": "Bdg.build_sketch(block: Callable) -> BdgSketch",
			"returns": "BdgSketch",
			"insert": "Bdg.build_sketch(func():\n\t${0}\n)",
			"desc": "Builds a 2D planar Sketch by executing a callback closure. Combines 2D sketch primitives into unified planar faces for extrusion or revolving.",
			"params": [
				{"name": "block", "type": "Callable", "desc": "Closure callback defining 2D sketch shapes (e.g. rect, circle, polygon)."}
			],
			"example": "var sk = Bdg.build_sketch(func():\n    Bdg.rect(40.0, 20.0)\n    Bdg.circle(5.0, 360.0, Bdg.Align.CENTER, Bdg.Mode.SUBTRACT)\n)"
		},
		{
			"category": "Builders",
			"name": "Bdg.build_line",
			"sig": "Bdg.build_line(block: Callable) -> BdgShape",
			"returns": "BdgShape / BdgWire",
			"insert": "Bdg.build_line(func():\n\t${0}\n)",
			"desc": "Builds a 1D Curve / Wire by executing a callback closure. Automatically connects lines, arcs, and splines into continuous boundary chains.",
			"params": [
				{"name": "block", "type": "Callable", "desc": "Closure callback creating 1D line segments and arcs."}
			],
			"example": "var curve = Bdg.build_line(func():\n    Bdg.line(Vector3.ZERO, Vector3(20, 0, 0))\n    Bdg.center_arc(Vector3(20, 10, 0), 10.0, -90.0, 90.0)\n)"
		},
		{
			"category": "Builders",
			"name": "Bdg.last_shape",
			"sig": "Bdg.last_shape() -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.last_shape()",
			"desc": "Returns the active shape / object from the current builder context (Part, Sketch, or Line). Ideal for referencing the base object for fillets or extrusions.",
			"params": [],
			"example": "Bdg.rounded_rect(60.0, 30.0, 4.0)\nBdg.extrude(Bdg.last_shape(), 10.0)"
		},
		{
			"category": "Builders",
			"name": "Bdg.last_solid",
			"sig": "Bdg.last_solid() -> BdgSolid",
			"returns": "BdgSolid",
			"insert": "Bdg.last_solid()",
			"desc": "Returns the most recent 3D solid created in the active builder context.",
			"params": [],
			"example": "var s = Bdg.last_solid()\nvar vol = s.volume()"
		},
		{
			"category": "Builders",
			"name": "Bdg.last_face",
			"sig": "Bdg.last_face() -> BdgFace",
			"returns": "BdgFace",
			"insert": "Bdg.last_face()",
			"desc": "Returns the most recent 2D face created in the active builder context.",
			"params": [],
			"example": "var f = Bdg.last_face()\nvar area = f.area()"
		},
		{
			"category": "Builders",
			"name": "Bdg.last_edge",
			"sig": "Bdg.last_edge() -> BdgEdge",
			"returns": "BdgEdge",
			"insert": "Bdg.last_edge()",
			"desc": "Returns the most recent 1D curve or edge created in the active builder context.",
			"params": [],
			"example": "var e = Bdg.last_edge()\nvar len = e.length()"
		},
		{
			"category": "Builders",
			"name": "Bdg.last_wire",
			"sig": "Bdg.last_wire() -> BdgWire",
			"returns": "BdgWire",
			"insert": "Bdg.last_wire()",
			"desc": "Returns the most recent wire loop created in the active builder context.",
			"params": [],
			"example": "var w = Bdg.last_wire()\nvar is_closed = w.is_closed()"
		},
		{
			"category": "Builders",
			"name": "Bdg.eval",
			"sig": "Bdg.eval(code: String) -> Variant",
			"returns": "Variant / BdgShape",
			"insert": "Bdg.eval(\"${0}\")",
			"desc": "Dynamically compiles and executes a GDScript CAD code string on the fly, returning the constructed model or assembly compound.",
			"params": [
				{"name": "code", "type": "String", "desc": "GDScript source code returning a BdgShape or BdgAssembly."}
			],
			"example": "var model = Bdg.eval(\"\"\"\nvar b = Bdg.box(20, 20, 20)\nreturn b\n\"\"\")"
		},
		{
			"category": "Builders",
			"name": "Bdg.add",
			"sig": "Bdg.add(shape: Variant, mode: int = Bdg.Mode.ADD) -> void",
			"returns": "void",
			"insert": "Bdg.add(${0:shape})",
			"desc": "Explicitly adds, subtracts, or intersects a shape with the current builder context model.",
			"params": [
				{"name": "shape", "type": "Variant", "desc": "BdgShape, BdgSolid, or BdgCompound to add."},
				{"name": "mode", "type": "int", "desc": "Combination mode: Mode.ADD, Mode.SUBTRACT, Mode.INTERSECT, or Mode.REPLACE."}
			],
			"example": "var pin = Bdg.cylinder(3.0, 10.0)\nBdg.add(pin, Bdg.Mode.ADD)"
		},

		# =====================================================================
		# 2. Location Contexts & Patterns
		# =====================================================================
		{
			"category": "Patterns",
			"name": "Bdg.locations",
			"sig": "Bdg.locations(loc_generator: Variant, block: Callable) -> void",
			"returns": "void",
			"insert": "Bdg.locations([${0:Vector3.ZERO}], func():\n\t\n)",
			"desc": "Executes a block with an active Location context. Objects created inside are automatically cloned to each target position/plane.",
			"params": [
				{"name": "loc_generator", "type": "Variant", "desc": "Array of Vector3, BdgLocation, or BdgPlane."},
				{"name": "block", "type": "Callable", "desc": "Closure callback to execute at each location."}
			],
			"example": "Bdg.locations([Vector3(-20, 0, 0), Vector3(20, 0, 0)], func():\n    Bdg.hole(3.0, 10.0)\n)"
		},
		{
			"category": "Patterns",
			"name": "Bdg.grid_locations",
			"sig": "Bdg.grid_locations(x_spacing: float, y_spacing: float, x_count: int, y_count: int, block: Callable) -> void",
			"returns": "void",
			"insert": "Bdg.grid_locations(${1:10.0}, ${2:10.0}, ${3:3}, ${4:3}, func():\n\t${0}\n)",
			"desc": "Generates a 2D rectangular grid pattern of locations centered at the origin.",
			"params": [
				{"name": "x_spacing", "type": "float", "desc": "Distance between columns along X."},
				{"name": "y_spacing", "type": "float", "desc": "Distance between rows along Y."},
				{"name": "x_count", "type": "int", "desc": "Number of columns."},
				{"name": "y_count", "type": "int", "desc": "Number of rows."},
				{"name": "block", "type": "Callable", "desc": "Closure callback."}
			],
			"example": "Bdg.grid_locations(20.0, 20.0, 4, 3, func():\n    Bdg.cylinder(2.0, 10.0)\n)"
		},
		{
			"category": "Patterns",
			"name": "Bdg.hex_locations",
			"sig": "Bdg.hex_locations(apothem: float, x_count: int, y_count: int, block: Callable) -> void",
			"returns": "void",
			"insert": "Bdg.hex_locations(${1:5.0}, ${2:4}, ${3:4}, func():\n\t${0}\n)",
			"desc": "Generates a 2D hexagonal honeycomb lattice of locations.",
			"params": [
				{"name": "apothem", "type": "float", "desc": "Perpendicular distance from hexagon center to midpoint of sides."},
				{"name": "x_count", "type": "int", "desc": "Number of hex columns."},
				{"name": "y_count", "type": "int", "desc": "Number of hex rows."},
				{"name": "block", "type": "Callable", "desc": "Closure callback."}
			],
			"example": "Bdg.hex_locations(6.0, 5, 4, func():\n    Bdg.regular_polygon(5.0, 6)\n)"
		},
		{
			"category": "Patterns",
			"name": "Bdg.polar_locations",
			"sig": "Bdg.polar_locations(radius: float, count: int, start_angle: float = 0.0, angular_range: float = 360.0, rotate: bool = true, block: Callable = Callable()) -> void",
			"returns": "void",
			"insert": "Bdg.polar_locations(${1:25.0}, ${2:6}, 0.0, 360.0, true, func():\n\t${0}\n)",
			"desc": "Generates a circular polar array of locations around the Z axis.",
			"params": [
				{"name": "radius", "type": "float", "desc": "Pitch radius of bolt circle."},
				{"name": "count", "type": "int", "desc": "Total number of instances."},
				{"name": "start_angle", "type": "float", "desc": "Starting angular offset in degrees (default 0.0)."},
				{"name": "angular_range", "type": "float", "desc": "Total sweep angle in degrees (default 360.0)."},
				{"name": "rotate", "type": "bool", "desc": "Whether to rotate each instance tangent to the circle."}
			],
			"example": "Bdg.polar_locations(30.0, 8, 0.0, 360.0, true, func():\n    Bdg.hole(3.5, 15.0)\n)"
		},
		{
			"category": "Patterns",
			"name": "Bdg.location",
			"sig": "Bdg.location(position: Vector3 = Vector3.ZERO, orientation: Quaternion = Quaternion.IDENTITY) -> BdgLocation",
			"returns": "BdgLocation",
			"insert": "Bdg.location(${1:Vector3.ZERO})",
			"desc": "Constructs a 3D rigid transform with 3D translation vector and orientation quaternion.",
			"params": [
				{"name": "position", "type": "Vector3", "desc": "World origin position."},
				{"name": "orientation", "type": "Quaternion", "desc": "Rotational orientation."}
			],
			"example": "var loc = Bdg.location(Vector3(0, 10, 20), Bdg.rot(0, 45, 0))"
		},
		{
			"category": "Patterns",
			"name": "Bdg.polar",
			"sig": "Bdg.polar(distance: float, angle_deg: float) -> Vector3",
			"returns": "Vector3",
			"insert": "Bdg.polar(${1:distance}, ${2:angle_deg})",
			"desc": "Computes a 2D/3D offset vector from distance and angle in degrees.",
			"params": [
				{"name": "distance", "type": "float", "desc": "Radial distance from origin."},
				{"name": "angle_deg", "type": "float", "desc": "Angle in degrees."}
			],
			"example": "var pt = Bdg.polar(50.0, 45.0)"
		},
		{
			"category": "Patterns",
			"name": "Bdg.delta",
			"sig": "Bdg.delta(dx: float, dy: float, dz: float = 0.0) -> Vector3",
			"returns": "Vector3",
			"insert": "Bdg.delta(${1:dx}, ${2:dy}, ${3:dz})",
			"desc": "Shorthand for relative delta translation vector Vector3(dx, dy, dz).",
			"params": [
				{"name": "dx", "type": "float", "desc": "Delta along X."},
				{"name": "dy", "type": "float", "desc": "Delta along Y."},
				{"name": "dz", "type": "float", "desc": "Delta along Z."}
			],
			"example": "var v = Bdg.delta(10.0, 5.0, -2.0)"
		},

		# =====================================================================
		# 3. 3D Solids
		# =====================================================================
		{
			"category": "3D Solids",
			"name": "Bdg.box",
			"sig": "Bdg.box(length: float, width: float, height: float, center: Vector3 = Vector3.ZERO, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgBox",
			"returns": "BdgBox",
			"insert": "Bdg.box(${1:length}, ${2:width}, ${3:height})",
			"desc": "Constructs a solid 3D rectangular box/cuboid with precise length, width, and height.",
			"params": [
				{"name": "length", "type": "float", "desc": "Dimension along X axis."},
				{"name": "width", "type": "float", "desc": "Dimension along Y axis."},
				{"name": "height", "type": "float", "desc": "Dimension along Z axis."},
				{"name": "align", "type": "Variant", "desc": "Alignment: Align.CENTER, Align.MIN, or Align.MAX."}
			],
			"example": "var b = Bdg.box(80.0, 40.0, 20.0)"
		},
		{
			"category": "3D Solids",
			"name": "Bdg.cylinder",
			"sig": "Bdg.cylinder(radius: float, height: float, angle: float = 360.0, center: Vector3 = Vector3.ZERO, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgCylinder",
			"returns": "BdgCylinder",
			"insert": "Bdg.cylinder(${1:radius}, ${2:height})",
			"desc": "Constructs a solid 3D cylinder or circular sector along the Z axis.",
			"params": [
				{"name": "radius", "type": "float", "desc": "Cylinder radius."},
				{"name": "height", "type": "float", "desc": "Cylinder height along Z."},
				{"name": "angle", "type": "float", "desc": "Sweep angle in degrees (default 360.0)."}
			],
			"example": "var cyl = Bdg.cylinder(15.0, 50.0)"
		},
		{
			"category": "3D Solids",
			"name": "Bdg.sphere",
			"sig": "Bdg.sphere(radius: float, arc_size1: float = -90.0, arc_size2: float = 90.0, center: Vector3 = Vector3.ZERO, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgSphere",
			"returns": "BdgSphere",
			"insert": "Bdg.sphere(${1:radius})",
			"desc": "Constructs a solid 3D sphere with specified radius.",
			"params": [
				{"name": "radius", "type": "float", "desc": "Sphere radius."}
			],
			"example": "var ball = Bdg.sphere(12.0)"
		},
		{
			"category": "3D Solids",
			"name": "Bdg.cone",
			"sig": "Bdg.cone(bottom_radius: float, top_radius: float, height: float, center: Vector3 = Vector3.ZERO, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgCone",
			"returns": "BdgCone",
			"insert": "Bdg.cone(${1:bottom_radius}, ${2:top_radius}, ${3:height})",
			"desc": "Constructs a solid 3D right circular cone or conical frustum.",
			"params": [
				{"name": "bottom_radius", "type": "float", "desc": "Radius at the base (Z=0)."},
				{"name": "top_radius", "type": "float", "desc": "Radius at the apex/top."},
				{"name": "height", "type": "float", "desc": "Total height along Z."}
			],
			"example": "var cone = Bdg.cone(20.0, 8.0, 35.0)"
		},
		{
			"category": "3D Solids",
			"name": "Bdg.torus",
			"sig": "Bdg.torus(major_radius: float, minor_radius: float, angle: float = 360.0, center: Vector3 = Vector3.ZERO, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgTorus",
			"returns": "BdgTorus",
			"insert": "Bdg.torus(${1:major_radius}, ${2:minor_radius})",
			"desc": "Constructs a solid 3D doughnut/torus revolving a circular section around the Z axis.",
			"params": [
				{"name": "major_radius", "type": "float", "desc": "Distance from center to tube center."},
				{"name": "minor_radius", "type": "float", "desc": "Radius of circular cross section."}
			],
			"example": "var ring = Bdg.torus(30.0, 5.0)"
		},
		{
			"category": "3D Solids",
			"name": "Bdg.wedge",
			"sig": "Bdg.wedge(dx: float, dy: float, dz: float, xmin: float, zmin: float, xmax: float, zmax: float, center: Vector3 = Vector3.ZERO, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgWedge",
			"returns": "BdgWedge",
			"insert": "Bdg.wedge(${1:dx}, ${2:dy}, ${3:dz}, ${4:xmin}, ${5:zmin}, ${6:xmax}, ${7:zmax})",
			"desc": "Constructs a 3D solid right angular wedge/pyramidal prism.",
			"params": [
				{"name": "dx", "type": "float", "desc": "Dimension along X."},
				{"name": "dy", "type": "float", "desc": "Dimension along Y."},
				{"name": "dz", "type": "float", "desc": "Dimension along Z."}
			],
			"example": "var w = Bdg.wedge(30, 20, 15, 5, 0, 25, 15)"
		},
		{
			"category": "3D Solids",
			"name": "Bdg.convex_polyhedron",
			"sig": "Bdg.convex_polyhedron(points: Array, mode: int = Bdg.Mode.ADD) -> BdgConvexPolyhedron",
			"returns": "BdgConvexPolyhedron",
			"insert": "Bdg.convex_polyhedron(${1:points})",
			"desc": "Computes the 3D Quickhull convex hull solid enclosing an arbitrary cloud of 3D points.",
			"params": [
				{"name": "points", "type": "Array[Vector3]", "desc": "Array of 3D vertices."}
			],
			"example": "var hull = Bdg.convex_polyhedron([\n    Vector3(0,0,0), Vector3(20,0,0), Vector3(0,20,0), Vector3(0,0,20)\n])"
		},
		{
			"category": "3D Solids",
			"name": "Bdg.hex_bolt",
			"sig": "Bdg.hex_bolt(thread_radius: float, shaft_length: float, head_width: float, head_thickness: float, mode: int = Bdg.Mode.ADD) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.hex_bolt(${1:3.0}, ${2:25.0}, ${3:10.0}, ${4:4.0})",
			"desc": "Constructs a parametric ISO metric hexagonal socket / cap bolt solid.",
			"params": [
				{"name": "thread_radius", "type": "float", "desc": "Major radius of thread shaft (e.g. 3.0 for M6)."},
				{"name": "shaft_length", "type": "float", "desc": "Total length of threaded shaft."},
				{"name": "head_width", "type": "float", "desc": "Width across flats of hexagonal head."},
				{"name": "head_thickness", "type": "float", "desc": "Height/thickness of bolt head."}
			],
			"example": "var m6_bolt = Bdg.hex_bolt(3.0, 30.0, 10.0, 4.0)"
		},
		{
			"category": "3D Solids",
			"name": "Bdg.hex_nut",
			"sig": "Bdg.hex_nut(thread_radius: float, width: float, thickness: float, mode: int = Bdg.Mode.ADD) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.hex_nut(${1:3.0}, ${2:10.0}, ${3:5.0})",
			"desc": "Constructs a parametric ISO metric hexagonal nut with center thread bore.",
			"params": [
				{"name": "thread_radius", "type": "float", "desc": "Inner thread radius (e.g. 3.0 for M6)."},
				{"name": "width", "type": "float", "desc": "Width across flats."},
				{"name": "thickness", "type": "float", "desc": "Nut height/thickness."}
			],
			"example": "var m6_nut = Bdg.hex_nut(3.0, 10.0, 5.0)"
		},

		# =====================================================================
		# 4. 2D Sketches
		# =====================================================================
		{
			"category": "2D Sketches",
			"name": "Bdg.rect",
			"sig": "Bdg.rect(width: float, height: float, rotation: float = 0.0, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgRectangle",
			"returns": "BdgRectangle",
			"insert": "Bdg.rect(${1:width}, ${2:height})",
			"desc": "Constructs a 2D planar rectangle with given width and height.",
			"params": [
				{"name": "width", "type": "float", "desc": "Width along X."},
				{"name": "height", "type": "float", "desc": "Height along Y."}
			],
			"example": "var r = Bdg.rect(60.0, 40.0)"
		},
		{
			"category": "2D Sketches",
			"name": "Bdg.rounded_rect",
			"sig": "Bdg.rounded_rect(width: float, height: float, radius: float, rotation: float = 0.0, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgRectangleRounded",
			"returns": "BdgRectangleRounded",
			"insert": "Bdg.rounded_rect(${1:width}, ${2:height}, ${3:radius})",
			"desc": "Constructs a 2D planar rectangle with smooth circular rounded corners.",
			"params": [
				{"name": "width", "type": "float", "desc": "Width along X."},
				{"name": "height", "type": "float", "desc": "Height along Y."},
				{"name": "radius", "type": "float", "desc": "Corner fillet radius."}
			],
			"example": "var rr = Bdg.rounded_rect(80.0, 40.0, 6.0)"
		},
		{
			"category": "2D Sketches",
			"name": "Bdg.circle",
			"sig": "Bdg.circle(radius: float, arc_size: float = 360.0, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgCircle",
			"returns": "BdgCircle",
			"insert": "Bdg.circle(${1:radius})",
			"desc": "Constructs a 2D circular planar face or sector with given radius.",
			"params": [
				{"name": "radius", "type": "float", "desc": "Circle radius."},
				{"name": "arc_size", "type": "float", "desc": "Sweep angle in degrees (default 360.0)."}
			],
			"example": "var c = Bdg.circle(18.0)"
		},
		{
			"category": "2D Sketches",
			"name": "Bdg.ellipse",
			"sig": "Bdg.ellipse(x_radius: float, y_radius: float, rotation: float = 0.0, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgEllipse",
			"returns": "BdgEllipse",
			"insert": "Bdg.ellipse(${1:x_radius}, ${2:y_radius})",
			"desc": "Constructs a 2D planar ellipse with semi-major and semi-minor radii.",
			"params": [
				{"name": "x_radius", "type": "float", "desc": "Radius along local X."},
				{"name": "y_radius", "type": "float", "desc": "Radius along local Y."}
			],
			"example": "var el = Bdg.ellipse(30.0, 15.0)"
		},
		{
			"category": "2D Sketches",
			"name": "Bdg.regular_polygon",
			"sig": "Bdg.regular_polygon(radius: float, side_count: int, major_radius: bool = true, rotation: float = 0.0, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgRegularPolygon",
			"returns": "BdgRegularPolygon",
			"insert": "Bdg.regular_polygon(${1:radius}, ${2:side_count})",
			"desc": "Constructs an N-sided equilateral regular polygon (e.g. triangle, pentagon, hexagon, octagon).",
			"params": [
				{"name": "radius", "type": "float", "desc": "Circumscribed / inscribed radius."},
				{"name": "side_count", "type": "int", "desc": "Number of polygon sides (>= 3)."}
			],
			"example": "var hex = Bdg.regular_polygon(20.0, 6)"
		},
		{
			"category": "2D Sketches",
			"name": "Bdg.polygon",
			"sig": "Bdg.polygon(points: Array, rotation: float = 0.0, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgPolygon",
			"returns": "BdgPolygon",
			"insert": "Bdg.polygon([${0:Vector3.ZERO}])",
			"desc": "Constructs a 2D planar polygon face bounded by an arbitrary sequence of vertices.",
			"params": [
				{"name": "points", "type": "Array[Vector3]", "desc": "Boundary polygon vertices in order."}
			],
			"example": "var poly = Bdg.polygon([\n    Vector3(0,0,0), Vector3(40,0,0), Vector3(30,30,0), Vector3(0,20,0)\n])"
		},
		{
			"category": "2D Sketches",
			"name": "Bdg.slot_overall",
			"sig": "Bdg.slot_overall(length: float, width: float, rotation: float = 0.0, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgSlotOverall",
			"returns": "BdgSlotOverall",
			"insert": "Bdg.slot_overall(${1:length}, ${2:width})",
			"desc": "Constructs a stadium slot profile defined by its total overall length and width.",
			"params": [
				{"name": "length", "type": "float", "desc": "Overall tip-to-tip length."},
				{"name": "width", "type": "float", "desc": "Slot width (2 * radius)."}
			],
			"example": "var slot = Bdg.slot_overall(50.0, 16.0)"
		},
		{
			"category": "2D Sketches",
			"name": "Bdg.slot_c2c",
			"sig": "Bdg.slot_c2c(distance: float, radius: float, rotation: float = 0.0, align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgSlotCenterToCenter",
			"returns": "BdgSlotCenterToCenter",
			"insert": "Bdg.slot_c2c(${1:distance}, ${2:radius})",
			"desc": "Constructs a stadium slot profile defined by the distance between arc centers and radius.",
			"params": [
				{"name": "distance", "type": "float", "desc": "Center-to-center distance."},
				{"name": "radius", "type": "float", "desc": "End arc radius."}
			],
			"example": "var slot = Bdg.slot_c2c(30.0, 6.0)"
		},
		{
			"category": "2D Sketches",
			"name": "Bdg.make_face",
			"sig": "Bdg.make_face(wires_or_edges: Variant) -> BdgFace",
			"returns": "BdgFace",
			"insert": "Bdg.make_face(${0:wires_or_edges})",
			"desc": "Creates a planar surface Face bounded by a closed wire or collection of boundary curves.",
			"params": [
				{"name": "wires_or_edges", "type": "Variant", "desc": "BdgWire, Array of BdgWire, or Array of BdgEdge."}
			],
			"example": "var face = Bdg.make_face(my_wire)"
		},

		# =====================================================================
		# 5. 1D Curves & Lines
		# =====================================================================
		{
			"category": "1D Curves",
			"name": "Bdg.line",
			"sig": "Bdg.line(p1: Vector3, p2: Vector3, mode: int = Bdg.Mode.ADD) -> BdgLine",
			"returns": "BdgLine",
			"insert": "Bdg.line(${1:p1}, ${2:p2})",
			"desc": "Constructs a straight 3D line segment between point p1 and point p2.",
			"params": [
				{"name": "p1", "type": "Vector3", "desc": "Start vertex."},
				{"name": "p2", "type": "Vector3", "desc": "End vertex."}
			],
			"example": "var l = Bdg.line(Vector3(0,0,0), Vector3(50,0,0))"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.polyline",
			"sig": "Bdg.polyline(points: Array, close: bool = false, mode: int = Bdg.Mode.ADD) -> BdgPolyline",
			"returns": "BdgPolyline",
			"insert": "Bdg.polyline([${0:points}], false)",
			"desc": "Constructs a multi-segment connected 3D polyline.",
			"params": [
				{"name": "points", "type": "Array[Vector3]", "desc": "Sequential vertex coordinates."},
				{"name": "close", "type": "bool", "desc": "Whether to connect end back to start."}
			],
			"example": "var pl = Bdg.polyline([Vector3(0,0,0), Vector3(20,10,0), Vector3(40,0,0)])"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.arc_3pt",
			"sig": "Bdg.arc_3pt(p1: Vector3, p2: Vector3, p3: Vector3, mode: int = Bdg.Mode.ADD) -> BdgThreePointArc",
			"returns": "BdgThreePointArc",
			"insert": "Bdg.arc_3pt(${1:p1}, ${2:p2}, ${3:p3})",
			"desc": "Constructs a circular arc passing through three non-collinear 3D points.",
			"params": [
				{"name": "p1", "type": "Vector3", "desc": "Start point."},
				{"name": "p2", "type": "Vector3", "desc": "Intermediate point on arc."},
				{"name": "p3", "type": "Vector3", "desc": "End point."}
			],
			"example": "var arc = Bdg.arc_3pt(Vector3(0,0,0), Vector3(10,10,0), Vector3(20,0,0))"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.center_arc",
			"sig": "Bdg.center_arc(center: Vector3, radius: float, start_angle: float, arc_size: float, mode: int = Bdg.Mode.ADD) -> BdgCenterArc",
			"returns": "BdgCenterArc",
			"insert": "Bdg.center_arc(${1:center}, ${2:radius}, ${3:start_angle}, ${4:arc_size})",
			"desc": "Constructs a circular arc from center point, radius, starting angle, and sweep arc size in degrees.",
			"params": [
				{"name": "center", "type": "Vector3", "desc": "Arc center point."},
				{"name": "radius", "type": "float", "desc": "Arc radius."},
				{"name": "start_angle", "type": "float", "desc": "Start angle in degrees."},
				{"name": "arc_size", "type": "float", "desc": "Sweep span in degrees."}
			],
			"example": "var arc = Bdg.center_arc(Vector3.ZERO, 25.0, 0.0, 180.0)"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.spline",
			"sig": "Bdg.spline(points: Array, mode: int = Bdg.Mode.ADD) -> BdgSpline",
			"returns": "BdgSpline",
			"insert": "Bdg.spline([${0:points}])",
			"desc": "Constructs a smooth C2 cubic B-spline interpolating smoothly through control points.",
			"params": [
				{"name": "points", "type": "Array[Vector3]", "desc": "Points to interpolate."}
			],
			"example": "var sp = Bdg.spline([Vector3(0,0,0), Vector3(15,10,0), Vector3(30,-5,0), Vector3(45,0,0)])"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.bezier",
			"sig": "Bdg.bezier(control_points: Array, weights: Array = [], mode: int = Bdg.Mode.ADD) -> BdgBezier",
			"returns": "BdgBezier",
			"insert": "Bdg.bezier([${0:control_points}])",
			"desc": "Constructs a rational or polynomial Bézier curve guided by control points.",
			"params": [
				{"name": "control_points", "type": "Array[Vector3]", "desc": "Bézier control polygon vertices."},
				{"name": "weights", "type": "Array[float]", "desc": "Optional rational weights."}
			],
			"example": "var bz = Bdg.bezier([Vector3(0,0,0), Vector3(10,30,0), Vector3(30,30,0), Vector3(40,0,0)])"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.helix",
			"sig": "Bdg.helix(pitch: float, height: float, radius: float, center: Vector3 = Vector3.ZERO, dir: Vector3 = Vector3.UP, angle: float = 0.0, righthanded: bool = true, mode: int = Bdg.Mode.ADD) -> BdgHelix",
			"returns": "BdgHelix",
			"insert": "Bdg.helix(${1:pitch}, ${2:height}, ${3:radius})",
			"desc": "Constructs a 3D cylindrical or conical spiral helix curve.",
			"params": [
				{"name": "pitch", "type": "float", "desc": "Axial distance per 360-degree revolution."},
				{"name": "height", "type": "float", "desc": "Total axial length."},
				{"name": "radius", "type": "float", "desc": "Helix radius."}
			],
			"example": "var h = Bdg.helix(10.0, 50.0, 15.0)"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.airfoil",
			"sig": "Bdg.airfoil(naca_code: String = \"2412\", chord_length: float = 100.0, sample_count: int = 100, mode: int = Bdg.Mode.ADD) -> BdgAirfoil",
			"returns": "BdgAirfoil",
			"insert": "Bdg.airfoil(\"${1:2412}\", ${2:100.0})",
			"desc": "Constructs an analytical NACA 4-digit aerodynamic airfoil profile curve (e.g. NACA 0012, 2415, 4412).",
			"params": [
				{"name": "naca_code", "type": "String", "desc": "NACA 4-digit profile code (e.g. '2415')."},
				{"name": "chord_length", "type": "float", "desc": "Chord length along X."},
				{"name": "sample_count", "type": "int", "desc": "Cosine spacing resolution (default 100)."}
			],
			"example": "var wing_foil = Bdg.airfoil(\"2415\", 120.0)"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.blend_curve",
			"sig": "Bdg.blend_curve(edge1: BdgEdge, edge2: BdgEdge, tangent_scale: float = 1.0, mode: int = Bdg.Mode.ADD) -> BdgBlendCurve",
			"returns": "BdgBlendCurve",
			"insert": "Bdg.blend_curve(${1:edge1}, ${2:edge2})",
			"desc": "Constructs a G1/G2 curvature-continuous blend curve bridging two non-intersecting edges.",
			"params": [
				{"name": "edge1", "type": "BdgEdge", "desc": "First curve."},
				{"name": "edge2", "type": "BdgEdge", "desc": "Second curve."},
				{"name": "tangent_scale", "type": "float", "desc": "Blend tangent influence scale."}
			],
			"example": "var blend = Bdg.blend_curve(e1, e2, 1.2)"
		},

		# =====================================================================
		# 6. Operations & Modifiers
		# =====================================================================
		{
			"category": "Operations",
			"name": "Bdg.extrude",
			"sig": "Bdg.extrude(to_extrude: Variant, amount: float, dir: Vector3 = Vector3.ZERO, both: bool = false, taper: float = 0.0, mode: int = Bdg.Mode.ADD) -> BdgPart",
			"returns": "BdgPart",
			"insert": "Bdg.extrude(${1:profile}, ${2:10.0})",
			"desc": "Extrudes a 2D planar face or wire into a 3D prismatic solid along normal or custom direction.",
			"params": [
				{"name": "to_extrude", "type": "Variant", "desc": "BdgFace, BdgSketch, or BdgWire to extrude."},
				{"name": "amount", "type": "float", "desc": "Extrusion distance."},
				{"name": "dir", "type": "Vector3", "desc": "Direction vector (default perpendicular to face)."},
				{"name": "both", "type": "bool", "desc": "Symmetric extrusion in both directions."},
				{"name": "taper", "type": "float", "desc": "Draft taper angle in degrees."}
			],
			"example": "var solid = Bdg.extrude(sk, 25.0)"
		},
		{
			"category": "Operations",
			"name": "Bdg.revolve",
			"sig": "Bdg.revolve(to_revolve: Variant, angle: float, axis: BdgAxis = null, mode: int = Bdg.Mode.ADD) -> BdgPart",
			"returns": "BdgPart",
			"insert": "Bdg.revolve(${1:profile}, ${2:360.0})",
			"desc": "Revolves a 2D planar face around a 3D rotational axis (default Z axis).",
			"params": [
				{"name": "to_revolve", "type": "Variant", "desc": "Planar face or sketch."},
				{"name": "angle", "type": "float", "desc": "Rotation angle in degrees."},
				{"name": "axis", "type": "BdgAxis", "desc": "Revolution axis (default BdgAxis.Z)."}
			],
			"example": "var torus_part = Bdg.revolve(disk_face, 360.0, BdgAxis.Z)"
		},
		{
			"category": "Operations",
			"name": "Bdg.sweep",
			"sig": "Bdg.sweep(profile: Variant, path: Variant, mode: int = Bdg.Mode.ADD) -> BdgShape",
			"returns": "BdgShape / BdgSolid",
			"insert": "Bdg.sweep(${1:profile}, ${2:path})",
			"desc": "Sweeps a 2D cross-section profile face along an arbitrary 3D trajectory wire or curve.",
			"params": [
				{"name": "profile", "type": "Variant", "desc": "Cross section face or wire."},
				{"name": "path", "type": "Variant", "desc": "3D spine path wire or curve."}
			],
			"example": "var pipe = Bdg.sweep(circle_face, spline_path)"
		},
		{
			"category": "Operations",
			"name": "Bdg.loft",
			"sig": "Bdg.loft(objs: Array, ruled: bool = false, mode: int = Bdg.Mode.ADD) -> BdgSolid",
			"returns": "BdgSolid",
			"insert": "Bdg.loft([${0:sections}])",
			"desc": "Lofts a smooth or ruled 3D solid through a sequence of cross-section wires, faces, or apex vertices.",
			"params": [
				{"name": "objs", "type": "Array", "desc": "Array of section wires, faces, or endpoint vertices."},
				{"name": "ruled", "type": "bool", "desc": "Whether to use ruled straight surface patches (default false)."}
			],
			"example": "var wing = Bdg.loft([root_foil, tip_foil])"
		},
		{
			"category": "Operations",
			"name": "Bdg.fillet",
			"sig": "Bdg.fillet(objects: Variant, radius: float) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.fillet(${1:edges}, ${2:radius})",
			"desc": "Rounds and blends 3D sharp edges of a solid with a smooth constant circular radius.",
			"params": [
				{"name": "objects", "type": "Variant", "desc": "Edge or Array of BdgEdge to fillet."},
				{"name": "radius", "type": "float", "desc": "Fillet radius in millimeters."}
			],
			"example": "Bdg.fillet(Bdg.edges(Bdg.last_shape()), 3.0)"
		},
		{
			"category": "Operations",
			"name": "Bdg.chamfer",
			"sig": "Bdg.chamfer(objects: Variant, length: float, length2: float = 0.0) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.chamfer(${1:edges}, ${2:length})",
			"desc": "Bevels 3D sharp edges of a solid with equal or asymmetrical chamfer distances.",
			"params": [
				{"name": "objects", "type": "Variant", "desc": "Edge or Array of BdgEdge."},
				{"name": "length", "type": "float", "desc": "Chamfer setback distance."},
				{"name": "length2", "type": "float", "desc": "Optional secondary setback distance."}
			],
			"example": "Bdg.chamfer(top_edges, 2.0)"
		},
		{
			"category": "Operations",
			"name": "Bdg.hole",
			"sig": "Bdg.hole(radius: float, depth: float = 0.0, mode: int = Bdg.Mode.SUBTRACT) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.hole(${1:radius}, ${2:depth})",
			"desc": "Cuts a cylindrical through-hole or blind hole at active locations.",
			"params": [
				{"name": "radius", "type": "float", "desc": "Hole radius."},
				{"name": "depth", "type": "float", "desc": "Hole depth (0.0 = through all)."}
			],
			"example": "Bdg.hole(4.0, 20.0)"
		},
		{
			"category": "Operations",
			"name": "Bdg.counter_bore_hole",
			"sig": "Bdg.counter_bore_hole(radius: float, depth: float, counter_bore_radius: float, counter_bore_depth: float, mode: int = Bdg.Mode.SUBTRACT) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.counter_bore_hole(${1:3.5}, ${2:15.0}, ${3:6.0}, ${4:3.0})",
			"desc": "Cuts a stepped counterbored bolt hole with cylindrical recess for fastener heads.",
			"params": [
				{"name": "radius", "type": "float", "desc": "Shaft through-hole radius."},
				{"name": "depth", "type": "float", "desc": "Shaft hole depth."},
				{"name": "counter_bore_radius", "type": "float", "desc": "Recess counterbore radius."},
				{"name": "counter_bore_depth", "type": "float", "desc": "Recess counterbore depth."}
			],
			"example": "Bdg.counter_bore_hole(3.5, 20.0, 6.0, 4.0)"
		},
		{
			"category": "Operations",
			"name": "Bdg.counter_sink_hole",
			"sig": "Bdg.counter_sink_hole(radius: float, depth: float, counter_sink_radius: float, counter_sink_angle: float = 90.0, mode: int = Bdg.Mode.SUBTRACT) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.counter_sink_hole(${1:3.0}, ${2:15.0}, ${3:5.5}, 90.0)",
			"desc": "Cuts a conical countersunk screw hole for flush mounting.",
			"params": [
				{"name": "radius", "type": "float", "desc": "Shaft hole radius."},
				{"name": "depth", "type": "float", "desc": "Shaft hole depth."},
				{"name": "counter_sink_radius", "type": "float", "desc": "Top countersink bevel radius."},
				{"name": "counter_sink_angle", "type": "float", "desc": "Countersink cone angle (default 90.0 deg)."}
			],
			"example": "Bdg.counter_sink_hole(3.0, 15.0, 5.5, 90.0)"
		},
		{
			"category": "Operations",
			"name": "Bdg.fuse",
			"sig": "Bdg.fuse(a: BdgShape, b: Variant) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.fuse(${1:a}, ${2:b})",
			"desc": "Performs exact OpenCASCADE Boolean Union fusing shape a with shape b (or list of shapes).",
			"params": [
				{"name": "a", "type": "BdgShape", "desc": "Primary shape."},
				{"name": "b", "type": "Variant", "desc": "Shape or Array of shapes to union."}
			],
			"example": "var union_solid = Bdg.fuse(body, [boss1, boss2])"
		},
		{
			"category": "Operations",
			"name": "Bdg.cut",
			"sig": "Bdg.cut(a: BdgShape, b: Variant) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.cut(${1:a}, ${2:b})",
			"desc": "Performs exact OpenCASCADE Boolean Difference subtracting tool b from workpiece a (A \\ B).",
			"params": [
				{"name": "a", "type": "BdgShape", "desc": "Workpiece solid/shape."},
				{"name": "b", "type": "Variant", "desc": "Tool solid or array of cutting tools."}
			],
			"example": "var notched = Bdg.cut(block, cutter)"
		},
		{
			"category": "Operations",
			"name": "Bdg.intersect",
			"sig": "Bdg.intersect(a: BdgShape, b: Variant) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.intersect(${1:a}, ${2:b})",
			"desc": "Performs exact OpenCASCADE Boolean Intersection keeping only common overlapping volume (A ∩ B).",
			"params": [
				{"name": "a", "type": "BdgShape", "desc": "First shape."},
				{"name": "b", "type": "Variant", "desc": "Second shape or array of shapes."}
			],
			"example": "var common = Bdg.intersect(sphere, box)"
		},
		{
			"category": "Operations",
			"name": "Bdg.pack",
			"sig": "Bdg.pack(parts: Array, sheet_width: float, sheet_height: float, padding: float = 2.0) -> Array",
			"returns": "Array[BdgShape]",
			"insert": "Bdg.pack(${1:parts}, ${2:sheet_w}, ${3:sheet_h}, ${4:3.0})",
			"desc": "Algorithmic 2D nesting and bin-packing optimizer that packs mixed mechanical parts onto stock sheet metal.",
			"params": [
				{"name": "parts", "type": "Array", "desc": "Array of 2D/3D shapes to nest."},
				{"name": "sheet_width", "type": "float", "desc": "Stock sheet width along X."},
				{"name": "sheet_height", "type": "float", "desc": "Stock sheet height along Y."},
				{"name": "padding", "type": "float", "desc": "Clearance margin between parts."}
			],
			"example": "var nested = Bdg.pack(all_gears, 200.0, 150.0, 4.0)"
		},

		# =====================================================================
		# 7. Typography & Technical Drafting
		# =====================================================================
		{
			"category": "Drafting",
			"name": "Bdg.text",
			"sig": "Bdg.text(text: String, font_size: float = 10.0, font_name: String = \"Arial\", align: Variant = Bdg.Align.CENTER, mode: int = Bdg.Mode.ADD) -> BdgFace",
			"returns": "BdgFace",
			"insert": "Bdg.text(\"${1:Text}\", ${2:12.0})",
			"desc": "Renders high-precision 2D/3D vector text glyphs directly using OpenCASCADE's native BRep font engine (lossless curves).",
			"params": [
				{"name": "text", "type": "String", "desc": "Text string to render."},
				{"name": "font_size", "type": "float", "desc": "Cap height font size in mm."},
				{"name": "font_name", "type": "String", "desc": "System font family name."}
			],
			"example": "var label_face = Bdg.text(\"build123d.gd\", 10.0)\nvar label_solid = Bdg.extrude(label_face, 2.0)"
		},
		{
			"category": "Drafting",
			"name": "Bdg.technical_drawing",
			"sig": "Bdg.technical_drawing(shape: BdgShape, sheet_size: String = \"A4\") -> BdgTechnicalDrawing",
			"returns": "BdgTechnicalDrawing",
			"insert": "Bdg.technical_drawing(${1:shape}, \"A4\")",
			"desc": "Generates a multi-view orthographic technical drafting sheet with Top, Front, Right, and Isometric views and title block.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "3D CAD model to draft."},
				{"name": "sheet_size", "type": "String", "desc": "Sheet standard: 'A4', 'A3', 'A2', 'Letter', etc."}
			],
			"example": "var drawing = Bdg.technical_drawing(bracket, \"A4\")\nBdg.export_svg(drawing.to_compound(), \"drawing.svg\")"
		},
		{
			"category": "Drafting",
			"name": "Bdg.dimension_line",
			"sig": "Bdg.dimension_line(p1: Vector3, p2: Vector3, text: String = \"\", offset: float = 10.0) -> BdgDimensionLine",
			"returns": "BdgDimensionLine",
			"insert": "Bdg.dimension_line(${1:p1}, ${2:p2}, \"${3:50.0mm}\", 10.0)",
			"desc": "Constructs an engineering drafting dimension annotation with extension lines, witness ticks, and text.",
			"params": [
				{"name": "p1", "type": "Vector3", "desc": "First measurement witness point."},
				{"name": "p2", "type": "Vector3", "desc": "Second measurement witness point."},
				{"name": "text", "type": "String", "desc": "Dimension annotation text."},
				{"name": "offset", "type": "float", "desc": "Perpendicular offset distance."}
			],
			"example": "var dim = Bdg.dimension_line(Vector3(0,0,0), Vector3(80,0,0), \"80.0 mm\", 15.0)"
		},

		# =====================================================================
		# 8. Topological Selectors
		# =====================================================================
		{
			"category": "Topology",
			"name": "Bdg.vertices",
			"sig": "Bdg.vertices(shape: BdgShape) -> Array[BdgVertex]",
			"returns": "Array[BdgVertex]",
			"insert": "Bdg.vertices(${1:shape})",
			"desc": "Extracts all topological 0D vertices from a shape or solid.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Source CAD shape."}
			],
			"example": "for v in Bdg.vertices(my_solid):\n    print(v.to_vector3())"
		},
		{
			"category": "Topology",
			"name": "Bdg.edges",
			"sig": "Bdg.edges(shape: BdgShape) -> Array[BdgEdge]",
			"returns": "Array[BdgEdge]",
			"insert": "Bdg.edges(${1:shape})",
			"desc": "Extracts all topological 1D boundary edges from a shape or solid.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Source CAD shape."}
			],
			"example": "var top_edges = Bdg.edges(my_solid).filter(func(e): return e.center().z > 15.0)"
		},
		{
			"category": "Topology",
			"name": "Bdg.wires",
			"sig": "Bdg.wires(shape: BdgShape) -> Array[BdgWire]",
			"returns": "Array[BdgWire]",
			"insert": "Bdg.wires(${1:shape})",
			"desc": "Extracts all connected closed/open wire loops from a shape or solid.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Source CAD shape."}
			],
			"example": "var wire_loops = Bdg.wires(my_face)"
		},
		{
			"category": "Topology",
			"name": "Bdg.faces",
			"sig": "Bdg.faces(shape: BdgShape) -> Array[BdgFace]",
			"returns": "Array[BdgFace]",
			"insert": "Bdg.faces(${1:shape})",
			"desc": "Extracts all 2D surface faces from a shape or solid.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Source CAD shape."}
			],
			"example": "var planar_faces = Bdg.faces(my_solid)"
		},
		{
			"category": "Topology",
			"name": "Bdg.solids",
			"sig": "Bdg.solids(shape: BdgShape) -> Array[BdgSolid]",
			"returns": "Array[BdgSolid]",
			"insert": "Bdg.solids(${1:shape})",
			"desc": "Extracts all 3D solid bodies from a shape or compound.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Source CAD shape / compound."}
			],
			"example": "var bodies = Bdg.solids(my_assembly.to_compound())"
		},
		{
			"category": "Topology",
			"name": "Bdg.edges_to_wires",
			"sig": "Bdg.edges_to_wires(edges: Array) -> Array[BdgWire]",
			"returns": "Array[BdgWire]",
			"insert": "Bdg.edges_to_wires(${1:edges})",
			"desc": "Topologically sorts and chains an unsorted collection of edges into continuous wires.",
			"params": [
				{"name": "edges", "type": "Array[BdgEdge]", "desc": "Edges to connect."}
			],
			"example": "var loops = Bdg.edges_to_wires(edge_list)"
		},

		# =====================================================================
		# 9. Lossless Exporters & Importers
		# =====================================================================
		{
			"category": "I/O",
			"name": "Bdg.export_step",
			"sig": "Bdg.export_step(shape: BdgShape, path: String) -> bool",
			"returns": "bool",
			"insert": "Bdg.export_step(${1:shape}, \"${2:model.step}\")",
			"desc": "Exports shape to standard lossless ISO-10303 STEP AP214 / AP242 CAD format for CNC, injection molding, and mechanical design.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "CAD shape to export."},
				{"name": "path", "type": "String", "desc": "Destination file path (.step / .stp)."}
			],
			"example": "Bdg.export_step(bracket, \"bracket.step\")"
		},
		{
			"category": "I/O",
			"name": "Bdg.import_step",
			"sig": "Bdg.import_step(path: String) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.import_step(\"${1:model.step}\")",
			"desc": "Loads an external STEP CAD file into native OpenCASCADE exact BRep geometry.",
			"params": [
				{"name": "path", "type": "String", "desc": "Source STEP file path."}
			],
			"example": "var imported_part = Bdg.import_step(\"vendor_bearing.step\")"
		},
		{
			"category": "I/O",
			"name": "Bdg.export_stl",
			"sig": "Bdg.export_stl(shape: BdgShape, path: String, linear_deflection: float = 0.01, angular_deflection: float = 0.5, binary: bool = true) -> bool",
			"returns": "bool",
			"insert": "Bdg.export_stl(${1:shape}, \"${2:model.stl}\")",
			"desc": "Tessellates and exports shape to binary or ASCII STL mesh format for 3D printing (slicers).",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "CAD shape to export."},
				{"name": "path", "type": "String", "desc": "Output STL file path."},
				{"name": "linear_deflection", "type": "float", "desc": "Tessellation tolerance in mm (default 0.01)."},
				{"name": "binary", "type": "bool", "desc": "Export as compact binary (true) or text (false)."}
			],
			"example": "Bdg.export_stl(lego_brick, \"lego.stl\")"
		},
		{
			"category": "I/O",
			"name": "Bdg.export_obj",
			"sig": "Bdg.export_obj(shape: BdgShape, path: String, linear_deflection: float = 0.05, angular_deflection: float = 0.5) -> bool",
			"returns": "bool",
			"insert": "Bdg.export_obj(${1:shape}, \"${2:model.obj}\")",
			"desc": "Exports shape to Wavefront OBJ 3D mesh format with vertex normals.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "CAD shape to export."},
				{"name": "path", "type": "String", "desc": "Destination .obj file path."}
			],
			"example": "Bdg.export_obj(my_solid, \"render.obj\")"
		},
		{
			"category": "I/O",
			"name": "Bdg.export_gltf",
			"sig": "Bdg.export_gltf(shape: BdgShape, path: String, linear_deflection: float = 0.05, angular_deflection: float = 0.5) -> bool",
			"returns": "bool",
			"insert": "Bdg.export_gltf(${1:shape}, \"${2:model.gltf}\")",
			"desc": "Exports shape to standard GLTF 2.0 / GLB 3D scene format for web viewers and Godot games.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "CAD shape to export."},
				{"name": "path", "type": "String", "desc": "Destination .gltf file path."}
			],
			"example": "Bdg.export_gltf(assembly, \"game_asset.gltf\")"
		},
		{
			"category": "I/O",
			"name": "Bdg.export_svg",
			"sig": "Bdg.export_svg(shape: BdgShape, path: String, view_dir: Vector3 = Vector3.UP) -> bool",
			"returns": "bool",
			"insert": "Bdg.export_svg(${1:shape}, \"${2:drawing.svg}\")",
			"desc": "Projects shape and exports 2D vector technical drawing in scalable SVG format for laser cutting and documentation.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "CAD shape or drawing."},
				{"name": "path", "type": "String", "desc": "Destination .svg file path."},
				{"name": "view_dir", "type": "Vector3", "desc": "Orthographic projection view vector."}
			],
			"example": "Bdg.export_svg(sheet_pack, \"cut_sheet.svg\")"
		},
		{
			"category": "I/O",
			"name": "Bdg.export_dxf",
			"sig": "Bdg.export_dxf(shape: BdgShape, path: String, view_dir: Vector3 = Vector3.UP) -> bool",
			"returns": "bool",
			"insert": "Bdg.export_dxf(${1:shape}, \"${2:drawing.dxf}\")",
			"desc": "Projects shape and exports 2D CAD engineering drawing in AutoCAD DXF format for CNC waterjet / plasma cutters.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "CAD shape or drawing."},
				{"name": "path", "type": "String", "desc": "Destination .dxf file path."}
			],
			"example": "Bdg.export_dxf(nested_sheet, \"cnc_sheet.dxf\")"
		},

		# =====================================================================
		# 10. Assemblies & Hierarchies
		# =====================================================================
		{
			"category": "Assemblies",
			"name": "Bdg.assembly",
			"sig": "Bdg.assembly(shape: BdgShape = null, label: String = \"\", loc: BdgLocation = null, color: Color = Color.WHITE) -> BdgAssembly",
			"returns": "BdgAssembly",
			"insert": "Bdg.assembly(${1:shape}, \"${2:Label}\", null, Color(${3:0.8, 0.8, 0.9}))",
			"desc": "Constructs a hierarchical CAD Assembly component supporting named sub-assemblies, relative transformations, joint kinematics, and distinct component colors.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Component 3D shape."},
				{"name": "label", "type": "String", "desc": "Unique component label name."},
				{"name": "loc", "type": "BdgLocation", "desc": "Relative 3D transform location."},
				{"name": "color", "type": "Color", "desc": "Display shader color."}
			],
			"example": "var asm = Bdg.assembly()\nasm.add_child(Bdg.assembly(bolt, \"Bolt\", null, Color.GRAY))\nasm.add_child(Bdg.assembly(nut, \"Nut\", Bdg.location(Vector3(0,0,20)), Color.YELLOW))\nreturn asm.to_compound()"
		},

		# =====================================================================
		# 11. Units & Constants
		# =====================================================================
		{
			"category": "Constants",
			"name": "Bdg.MM",
			"sig": "Bdg.MM = 1.0",
			"returns": "float",
			"insert": "Bdg.MM",
			"desc": "Standard metric millimeter unit scalar (1.0).",
			"params": [],
			"example": "var length = 50.0 * Bdg.MM"
		},
		{
			"category": "Constants",
			"name": "Bdg.IN",
			"sig": "Bdg.IN = 25.4",
			"returns": "float",
			"insert": "Bdg.IN",
			"desc": "Imperial inch unit conversion factor (25.4 mm).",
			"params": [],
			"example": "var thickness = 0.25 * Bdg.IN"
		},
		{
			"category": "Constants",
			"name": "Bdg.FT",
			"sig": "Bdg.FT = 304.8",
			"returns": "float",
			"insert": "Bdg.FT",
			"desc": "Imperial foot unit conversion factor (304.8 mm).",
			"params": [],
			"example": "var beam_len = 6.0 * Bdg.FT"
		},
		{
			"category": "Constants",
			"name": "Bdg.THOU",
			"sig": "Bdg.THOU = 0.0254",
			"returns": "float",
			"insert": "Bdg.THOU",
			"desc": "Precision mil / thousandth of an inch unit conversion factor (0.0254 mm).",
			"params": [],
			"example": "var tolerance = 5.0 * Bdg.THOU"
		},
		{
			"category": "Constants",
			"name": "Bdg.Mode.ADD",
			"sig": "Bdg.Mode.ADD",
			"returns": "int",
			"insert": "Bdg.Mode.ADD",
			"desc": "Boolean addition mode: unions created geometry with the active workpiece.",
			"params": [],
			"example": "Bdg.add(boss, Bdg.Mode.ADD)"
		},
		{
			"category": "Constants",
			"name": "Bdg.Mode.SUBTRACT",
			"sig": "Bdg.Mode.SUBTRACT",
			"returns": "int",
			"insert": "Bdg.Mode.SUBTRACT",
			"desc": "Boolean subtraction mode: cuts created geometry from the active workpiece.",
			"params": [],
			"example": "Bdg.add(pocket, Bdg.Mode.SUBTRACT)"
		},
		{
			"category": "Constants",
			"name": "Bdg.Mode.INTERSECT",
			"sig": "Bdg.Mode.INTERSECT",
			"returns": "int",
			"insert": "Bdg.Mode.INTERSECT",
			"desc": "Boolean intersection mode: retains only common volume.",
			"params": [],
			"example": "Bdg.add(mask, Bdg.Mode.INTERSECT)"
		},
		{
			"category": "Constants",
			"name": "Bdg.Align.CENTER",
			"sig": "Bdg.Align.CENTER",
			"returns": "int",
			"insert": "Bdg.Align.CENTER",
			"desc": "Centers the object bounding box at the location origin.",
			"params": [],
			"example": "Bdg.box(20, 20, 20, Vector3.ZERO, Bdg.Align.CENTER)"
		},
		{
			"category": "Constants",
			"name": "Bdg.Align.MIN",
			"sig": "Bdg.Align.MIN",
			"returns": "int",
			"insert": "Bdg.Align.MIN",
			"desc": "Aligns the minimum coordinate edge with the origin.",
			"params": [],
			"example": "Bdg.box(20, 20, 20, Vector3.ZERO, Bdg.Align.MIN)"
		},
		{
			"category": "Constants",
			"name": "Bdg.Align.MAX",
			"sig": "Bdg.Align.MAX",
			"returns": "int",
			"insert": "Bdg.Align.MAX",
			"desc": "Aligns the maximum coordinate edge with the origin.",
			"params": [],
			"example": "Bdg.box(20, 20, 20, Vector3.ZERO, Bdg.Align.MAX)"
		},
		# =====================================================================
		# 19. Raw Topology & Factory Wrappers (functional DSL)
		# =====================================================================
		{
			"category": "Topology",
			"name": "Bdg.make_box",
			"sig": "Bdg.make_box(length: float, width: float, height: float, plane: BdgPlane = null) -> BdgSolid",
			"returns": "BdgSolid",
			"insert": "Bdg.make_box(${0:10}, ${1:10}, ${2:10})",
			"desc": "Box solid with its base corner at the plane origin (raw solid, not a PartObject).",
			"params": [
				{"name": "length", "type": "float", "desc": "Size along X."},
				{"name": "width", "type": "float", "desc": "Size along Y."},
				{"name": "height", "type": "float", "desc": "Size along Z."},
				{"name": "plane", "type": "BdgPlane", "desc": "Base plane (default XY)."}
			],
			"example": "var b = Bdg.make_box(3.0, 3.0, 3.0)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_cylinder",
			"sig": "Bdg.make_cylinder(radius: float, height: float, plane: BdgPlane = null, angle: float = 360.0) -> BdgSolid",
			"returns": "BdgSolid",
			"insert": "Bdg.make_cylinder(${0:radius}, ${1:height})",
			"desc": "Cylinder solid with base center at the plane origin (raw solid, not a PartObject).",
			"params": [
				{"name": "radius", "type": "float", "desc": "Radius of the cylinder."},
				{"name": "height", "type": "float", "desc": "Height along the plane normal."},
				{"name": "plane", "type": "BdgPlane", "desc": "Base plane (default XY)."},
				{"name": "angle", "type": "float", "desc": "Sweep angle in degrees."}
			],
			"example": "var c = Bdg.make_cylinder(30.0, 10.0)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_sphere",
			"sig": "Bdg.make_sphere(radius: float, plane: BdgPlane = null) -> BdgSolid",
			"returns": "BdgSolid",
			"insert": "Bdg.make_sphere(${0:radius})",
			"desc": "Sphere solid centered at the plane origin.",
			"params": [
				{"name": "radius", "type": "float", "desc": "Radius of the sphere."},
				{"name": "plane", "type": "BdgPlane", "desc": "Center plane (default XY)."}
			],
			"example": "var s = Bdg.make_sphere(40.0)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_loft",
			"sig": "Bdg.make_loft(objs: Array, ruled: bool = false, as_solid: bool = true) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.make_loft(${0:objs})",
			"desc": "Loft solid through an ordered array of wire sections (or apex vertices).",
			"params": [
				{"name": "objs", "type": "Array", "desc": "Ordered wires or vertices to loft through."},
				{"name": "ruled", "type": "bool", "desc": "Use ruled (straight) interpolation."},
				{"name": "as_solid", "type": "bool", "desc": "Return a solid instead of a shell."}
			],
			"example": "var k = Bdg.make_loft([base_wire, top_wire], true)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_rect",
			"sig": "Bdg.make_rect(width: float, height: float, plane: BdgPlane = null) -> BdgFace",
			"returns": "BdgFace",
			"insert": "Bdg.make_rect(${0:width}, ${1:height})",
			"desc": "Planar rectangle face centered on the given plane (default XY).",
			"params": [
				{"name": "width", "type": "float", "desc": "Width along the plane X direction."},
				{"name": "height", "type": "float", "desc": "Height along the plane Y direction."},
				{"name": "plane", "type": "BdgPlane", "desc": "Face plane (default XY)."}
			],
			"example": "var f = Bdg.make_rect(18.0, 18.0)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_rounded_rect",
			"sig": "Bdg.make_rounded_rect(width: float, height: float, radius: float, plane: BdgPlane = null) -> BdgFace",
			"returns": "BdgFace",
			"insert": "Bdg.make_rounded_rect(${0:width}, ${1:height}, ${2:radius})",
			"desc": "Planar rounded-corner rectangle face centered on the given plane.",
			"params": [
				{"name": "width", "type": "float", "desc": "Width along the plane X direction."},
				{"name": "height", "type": "float", "desc": "Height along the plane Y direction."},
				{"name": "radius", "type": "float", "desc": "Corner radius."},
				{"name": "plane", "type": "BdgPlane", "desc": "Face plane (default XY)."}
			],
			"example": "var f = Bdg.make_rounded_rect(1.25, 3.0, 0.2)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_circle",
			"sig": "Bdg.make_circle(radius: float, plane: BdgPlane = null) -> BdgFace",
			"returns": "BdgFace",
			"insert": "Bdg.make_circle(${0:radius})",
			"desc": "Planar circle face centered on the given plane.",
			"params": [
				{"name": "radius", "type": "float", "desc": "Radius of the circle."},
				{"name": "plane", "type": "BdgPlane", "desc": "Face plane (default XY)."}
			],
			"example": "var f = Bdg.make_circle(1.0)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_slot",
			"sig": "Bdg.make_slot(length: float, width: float, rotation_deg: float = 0.0) -> BdgFace",
			"returns": "BdgFace",
			"insert": "Bdg.make_slot(${0:length}, ${1:width})",
			"desc": "Stadium-slot face with overall length and width, optionally rotated in degrees.",
			"params": [
				{"name": "length", "type": "float", "desc": "Overall length of the slot."},
				{"name": "width", "type": "float", "desc": "Width of the slot."},
				{"name": "rotation_deg", "type": "float", "desc": "Rotation in degrees."}
			],
			"example": "var f = Bdg.make_slot(3.0, 1.2, 15.0)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_from_wires",
			"sig": "Bdg.make_from_wires(outer_wire: BdgWire, inner_wires: Array = []) -> BdgFace",
			"returns": "BdgFace",
			"insert": "Bdg.make_from_wires(${0:outer_wire})",
			"desc": "Face built from an outer boundary wire and optional inner hole wires.",
			"params": [
				{"name": "outer_wire", "type": "BdgWire", "desc": "Outer boundary wire."},
				{"name": "inner_wires", "type": "Array", "desc": "Optional array of inner hole wires."}
			],
			"example": "var f = Bdg.make_from_wires(outer, [hole_wire])"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_wire",
			"sig": "Bdg.make_wire(edges: Array) -> BdgWire",
			"returns": "BdgWire",
			"insert": "Bdg.make_wire(${0:edges})",
			"desc": "Wire built from an array of edges, wires, or 1D shapes.",
			"params": [
				{"name": "edges", "type": "Array", "desc": "Edges/wires to connect into a single wire."}
			],
			"example": "var w = Bdg.make_wire([e1, e2, arc])"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_polygon",
			"sig": "Bdg.make_polygon(points: Array, close: bool = true) -> BdgWire",
			"returns": "BdgWire",
			"insert": "Bdg.make_polygon(${0:points})",
			"desc": "Polygon wire from an ordered list of points (closed by default).",
			"params": [
				{"name": "points", "type": "Array", "desc": "Ordered array of Vector3 vertices."},
				{"name": "close", "type": "bool", "desc": "Close the wire back to the first point."}
			],
			"example": "var w = Bdg.make_polygon([p1, p2, p3])"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_rect_wire",
			"sig": "Bdg.make_rect_wire(width: float, height: float, plane: BdgPlane = null) -> BdgWire",
			"returns": "BdgWire",
			"insert": "Bdg.make_rect_wire(${0:width}, ${1:height})",
			"desc": "Rectangle wire (1D boundary, not a face) centered on the given plane.",
			"params": [
				{"name": "width", "type": "float", "desc": "Width along the plane X direction."},
				{"name": "height", "type": "float", "desc": "Height along the plane Y direction."},
				{"name": "plane", "type": "BdgPlane", "desc": "Wire plane (default XY)."}
			],
			"example": "var w = Bdg.make_rect_wire(18.0, 18.0)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_line",
			"sig": "Bdg.make_line(point1: Vector3, point2: Vector3) -> BdgEdge",
			"returns": "BdgEdge",
			"insert": "Bdg.make_line(${0:p1}, ${1:p2})",
			"desc": "Straight line edge between two points.",
			"params": [
				{"name": "point1", "type": "Vector3", "desc": "Start point."},
				{"name": "point2", "type": "Vector3", "desc": "End point."}
			],
			"example": "var e = Bdg.make_line(p0, p1)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_radius_arc",
			"sig": "Bdg.make_radius_arc(start_point: Vector3, end_point: Vector3, radius: float, short_sagitta: bool = true) -> BdgEdge",
			"returns": "BdgEdge",
			"insert": "Bdg.make_radius_arc(${0:start}, ${1:end}, ${2:radius})",
			"desc": "Circular arc edge between two points with a given radius.",
			"params": [
				{"name": "start_point", "type": "Vector3", "desc": "Arc start point."},
				{"name": "end_point", "type": "Vector3", "desc": "Arc end point."},
				{"name": "radius", "type": "float", "desc": "Arc radius."},
				{"name": "short_sagitta", "type": "bool", "desc": "Pick the short arc side."}
			],
			"example": "var e = Bdg.make_radius_arc(p1, p2, 50.0, true)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_spline",
			"sig": "Bdg.make_spline(points: Array, tangents: Array = [], scale: bool = true) -> BdgEdge",
			"returns": "BdgEdge",
			"insert": "Bdg.make_spline(${0:points})",
			"desc": "B-Spline edge through points with optional start/end tangents.",
			"params": [
				{"name": "points", "type": "Array", "desc": "Array of Vector3 control points."},
				{"name": "tangents", "type": "Array", "desc": "Optional start/end tangent vectors."},
				{"name": "scale", "type": "bool", "desc": "Scale tangents to the curve."}
			],
			"example": "var e = Bdg.make_spline([p0, p1, p2], [t0, t2], false)"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_compound",
			"sig": "Bdg.make_compound(shapes: Array) -> BdgCompound",
			"returns": "BdgCompound",
			"insert": "Bdg.make_compound(${0:shapes})",
			"desc": "Compound of the given shapes (keeps the inputs unmodified).",
			"params": [
				{"name": "shapes", "type": "Array", "desc": "Array of shapes to group."}
			],
			"example": "var c = Bdg.make_compound([h1, h2, h3])"
		},
		{
			"category": "Topology",
			"name": "Bdg.make_pipe_shell",
			"sig": "Bdg.make_pipe_shell(path_wire: BdgWire, sections: Array, as_solid: bool = true) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.make_pipe_shell(${0:path_wire}, ${1:sections})",
			"desc": "Swept shell/solid along a path wire with cross-section faces.",
			"params": [
				{"name": "path_wire", "type": "BdgWire", "desc": "Path (wire) to sweep along."},
				{"name": "sections", "type": "Array", "desc": "Cross-section faces."},
				{"name": "as_solid", "type": "bool", "desc": "Return a solid instead of a shell."}
			],
			"example": "var h = Bdg.make_pipe_shell(path, [profile], true)"
		},
		{
			"category": "Topology",
			"name": "Bdg.axis",
			"sig": "Bdg.axis(origin: Vector3, direction: Vector3) -> BdgAxis",
			"returns": "BdgAxis",
			"insert": "Bdg.axis(${0:origin}, ${1:direction})",
			"desc": "Axis through an origin point in the given direction.",
			"params": [
				{"name": "origin", "type": "Vector3", "desc": "Axis origin point."},
				{"name": "direction", "type": "Vector3", "desc": "Axis direction vector."}
			],
			"example": "var ax = Bdg.axis(p.origin, p.z_dir)"
		},
		{
			"category": "Topology",
			"name": "Bdg.axis_x",
			"sig": "Bdg.axis_x() -> BdgAxis",
			"returns": "BdgAxis",
			"insert": "Bdg.axis_x()",
			"desc": "World X axis.",
			"params": [],
			"example": "var ax = Bdg.axis_x()"
		},
		{
			"category": "Topology",
			"name": "Bdg.axis_y",
			"sig": "Bdg.axis_y() -> BdgAxis",
			"returns": "BdgAxis",
			"insert": "Bdg.axis_y()",
			"desc": "World Y axis.",
			"params": [],
			"example": "var ax = Bdg.axis_y()"
		},
		{
			"category": "Topology",
			"name": "Bdg.axis_z",
			"sig": "Bdg.axis_z() -> BdgAxis",
			"returns": "BdgAxis",
			"insert": "Bdg.axis_z()",
			"desc": "World Z axis.",
			"params": [],
			"example": "var ax = Bdg.axis_z()"
		},
		{
			"category": "Patterns",
			"name": "Bdg.grid_locations_list",
			"sig": "Bdg.grid_locations_list(x_spacing: float, y_spacing: float, x_count: int, y_count: int) -> Array[BdgLocation]",
			"returns": "Array[BdgLocation]",
			"insert": "Bdg.grid_locations_list(${0:x_spacing}, ${1:y_spacing}, ${2:x_count}, ${3:y_count})",
			"desc": "Rectangular grid pattern locations (Array of BdgLocation), centered at origin.",
			"params": [
				{"name": "x_spacing", "type": "float", "desc": "Spacing along X."},
				{"name": "y_spacing", "type": "float", "desc": "Spacing along Y."},
				{"name": "x_count", "type": "int", "desc": "Number of columns."},
				{"name": "y_count", "type": "int", "desc": "Number of rows."}
			],
			"example": "var locs = Bdg.grid_locations_list(20.0, 20.0, 2, 2)"
		},
		{
			"category": "Patterns",
			"name": "Bdg.hex_locations_list",
			"sig": "Bdg.hex_locations_list(apothem: float, x_count: int, y_count: int) -> Array[BdgLocation]",
			"returns": "Array[BdgLocation]",
			"insert": "Bdg.hex_locations_list(${0:apothem}, ${1:x_count}, ${2:y_count})",
			"desc": "Hexagonal packing pattern locations (Array of BdgLocation), centered at origin.",
			"params": [
				{"name": "apothem", "type": "float", "desc": "Apothem (inradius) of the hexagons."},
				{"name": "x_count", "type": "int", "desc": "Number of columns."},
				{"name": "y_count", "type": "int", "desc": "Number of rows."}
			],
			"example": "var locs = Bdg.hex_locations_list(6.0, 3, 3)"
		},
		{
			"category": "Topology",
			"name": "Bdg.shape_list",
			"sig": "Bdg.shape_list(shapes: Array) -> BdgShapeList",
			"returns": "BdgShapeList",
			"insert": "Bdg.shape_list(${0:shapes})",
			"desc": "Shape list wrapper around an array of shapes.",
			"params": [
				{"name": "shapes", "type": "Array", "desc": "Array of shapes."}
			],
			"example": "var faces = Bdg.shape_list(base_part.faces())"
		},
		{
			"category": "Topology",
			"name": "Bdg.sort_by",
			"sig": "Bdg.sort_by(shape_list: BdgShapeList, sort_by: Variant, reverse: bool = false) -> BdgShapeList",
			"returns": "BdgShapeList",
			"insert": "Bdg.sort_by(${0:shape_list}, ${1:sort_by})",
			"desc": "Sort a shape list by a callable key, BdgAxis, or BdgEnums.SortBy criterion.",
			"params": [
				{"name": "shape_list", "type": "BdgShapeList", "desc": "List to sort."},
				{"name": "sort_by", "type": "Variant", "desc": "Callable, BdgAxis, or BdgEnums.SortBy."},
				{"name": "reverse", "type": "bool", "desc": "Sort in reverse order."}
			],
			"example": "var tops = Bdg.sort_by(faces, Bdg.axis_z()).at(-1)"
		},
		{
			"category": "Topology",
			"name": "Bdg.at",
			"sig": "Bdg.at(shape_list: BdgShapeList, index: int) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.at(${0:shape_list}, ${1:index})",
			"desc": "Index into a shape list (negative indexes from the end).",
			"params": [
				{"name": "shape_list", "type": "BdgShapeList", "desc": "List to index."},
				{"name": "index", "type": "int", "desc": "Index (supports negative)."}
			],
			"example": "var top = Bdg.at(tops, 0)"
		},
		{
			"category": "Operations",
			"name": "Bdg.translate",
			"sig": "Bdg.translate(shape: BdgShape, v: Vector3) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.translate(${0:shape}, ${1:v})",
			"desc": "Translate a shape by a displacement vector.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Shape to translate."},
				{"name": "v", "type": "Vector3", "desc": "Displacement vector."}
			],
			"example": "var moved = Bdg.translate(box, Vector3(0, 0, 5))"
		},
		{
			"category": "Operations",
			"name": "Bdg.scaled",
			"sig": "Bdg.scaled(shape: BdgShape, factor: Variant, center: Vector3 = Vector3.ZERO) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.scaled(${0:shape}, ${1:factor})",
			"desc": "Scale a shape about a center and return a new copy. factor may be a uniform float or a per-axis Vector3 (non-uniform, build123d `scale(by=...)`).",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Shape to scale."},
				{"name": "factor", "type": "Variant", "desc": "Uniform float or per-axis Vector3 scale factor."},
				{"name": "center", "type": "Vector3", "desc": "Scale center (default origin)."}
			],
			"example": "var cavity = Bdg.scaled(key_solid, Vector3(0.925, 0.925, 0.85))"
		},
		{
			"category": "Operations",
			"name": "Bdg.rotate",
			"sig": "Bdg.rotate(shape: BdgShape, axis: BdgAxis, angle_deg: float) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.rotate(${0:shape}, ${1:axis}, ${2:angle_deg})",
			"desc": "Rotate a shape about an axis by an angle in degrees.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Shape to rotate."},
				{"name": "axis", "type": "BdgAxis", "desc": "Rotation axis."},
				{"name": "angle_deg", "type": "float", "desc": "Rotation angle in degrees."}
			],
			"example": "var r = Bdg.rotate(rect, rot_axis, 45.0)"
		},
		{
			"category": "Operations",
			"name": "Bdg.move",
			"sig": "Bdg.move(shape: BdgShape, loc: BdgLocation) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.move(${0:shape}, ${1:loc})",
			"desc": "Move a shape to a location (position + orientation).",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Shape to move."},
				{"name": "loc", "type": "BdgLocation", "desc": "Target location."}
			],
			"example": "var m = Bdg.move(slot_face, loc)"
		},
		{
			"category": "Operations",
			"name": "Bdg.clean",
			"sig": "Bdg.clean(shape: BdgShape) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.clean(${0:shape})",
			"desc": "Clean / heal a shape (remove nulls, fix tolerances, reorder).",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Shape to clean."}
			],
			"example": "var out = Bdg.clean(part)"
		},
		{
			"category": "Topology",
			"name": "Bdg.center",
			"sig": "Bdg.center(shape: BdgShape) -> Vector3",
			"returns": "Vector3",
			"insert": "Bdg.center(${0:shape})",
			"desc": "Centroid of a shape.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Shape to measure."}
			],
			"example": "var c = Bdg.center(edge)"
		},
		{
			"category": "Topology",
			"name": "Bdg.geom_type",
			"sig": "Bdg.geom_type(shape: BdgShape) -> int",
			"returns": "int",
			"insert": "Bdg.geom_type(${0:shape})",
			"desc": "Geometric type enum value of a shape (Bdg.GeomType.LINE, CIRCLE, PLANE, ...).",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Shape to inspect."}
			],
			"example": "if Bdg.geom_type(face) == Bdg.GeomType.PLANE:"
		},
		{
			"category": "Topology",
			"name": "Bdg.to_plane",
			"sig": "Bdg.to_plane(face: BdgFace) -> BdgPlane",
			"returns": "BdgPlane",
			"insert": "Bdg.to_plane(${0:face})",
			"desc": "Base plane of a planar face.",
			"params": [
				{"name": "face", "type": "BdgFace", "desc": "Planar face."}
			],
			"example": "var p = Bdg.to_plane(face)"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.length",
			"sig": "Bdg.length(edge: BdgMixin1D) -> float",
			"returns": "float",
			"insert": "Bdg.length(${0:edge})",
			"desc": "Length of a 1D edge or wire.",
			"params": [
				{"name": "edge", "type": "BdgMixin1D", "desc": "Edge or wire."}
			],
			"example": "var L = Bdg.length(path_edge)"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.param_at_distance",
			"sig": "Bdg.param_at_distance(edge: BdgMixin1D, dist: float) -> float",
			"returns": "float",
			"insert": "Bdg.param_at_distance(${0:edge}, ${1:dist})",
			"desc": "Parameter value (u) at a given distance along a 1D edge/wire.",
			"params": [
				{"name": "edge", "type": "BdgMixin1D", "desc": "Edge or wire."},
				{"name": "dist", "type": "float", "desc": "Distance along the curve."}
			],
			"example": "var u = Bdg.param_at_distance(path_edge, target_dist)"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.position_at",
			"sig": "Bdg.position_at(edge: BdgMixin1D, position: float) -> Vector3",
			"returns": "Vector3",
			"insert": "Bdg.position_at(${0:edge}, ${1:u})",
			"desc": "Point position at parameter value u along a 1D edge/wire.",
			"params": [
				{"name": "edge", "type": "BdgMixin1D", "desc": "Edge or wire."},
				{"name": "position", "type": "float", "desc": "Parameter value u in [0, 1]."}
			],
			"example": "var p = Bdg.position_at(handle_spline, 0.0)"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.tangent_at",
			"sig": "Bdg.tangent_at(edge: BdgMixin1D, position: float) -> Vector3",
			"returns": "Vector3",
			"insert": "Bdg.tangent_at(${0:edge}, ${1:u})",
			"desc": "Tangent direction vector at parameter value u along a 1D edge/wire.",
			"params": [
				{"name": "edge", "type": "BdgMixin1D", "desc": "Edge or wire."},
				{"name": "position", "type": "float", "desc": "Parameter value u in [0, 1]."}
			],
			"example": "var t = Bdg.tangent_at(handle_spline, 0.0)"
		},
		{
			"category": "1D Curves",
			"name": "Bdg.normal_at",
			"sig": "Bdg.normal_at(edge: BdgMixin1D, position: float) -> Vector3",
			"returns": "Vector3",
			"insert": "Bdg.normal_at(${0:edge}, ${1:u})",
			"desc": "Normal direction vector at parameter value u along a 1D edge/wire.",
			"params": [
				{"name": "edge", "type": "BdgMixin1D", "desc": "Edge or wire."},
				{"name": "position", "type": "float", "desc": "Parameter value u in [0, 1]."}
			],
			"example": "var n = Bdg.normal_at(handle_spline, 0.0)"
		},
		{
			"category": "Operations",
			"name": "Bdg.offset_shape",
			"sig": "Bdg.offset_shape(shape: BdgShape, amount: float, openings: Array = []) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.offset_shape(${0:shape}, ${1:amount})",
			"desc": "Solid offset / shell operation (negative amount shells inward).",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Shape to offset."},
				{"name": "amount", "type": "float", "desc": "Offset distance (negative shells inward)."},
				{"name": "openings", "type": "Array", "desc": "Faces to leave open."}
			],
			"example": "var shell = Bdg.offset_shape(solid, -2.0, top_faces)"
		},
		{
			"category": "Operations",
			"name": "Bdg.fillet_edges",
			"sig": "Bdg.fillet_edges(shape: BdgShape, radius: float, edge_list: Array = []) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.fillet_edges(${0:shape}, ${1:radius}, ${2:edge_list})",
			"desc": "Fillet specific edges of a shape with a given radius.",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Shape to fillet."},
				{"name": "radius", "type": "float", "desc": "Fillet radius."},
				{"name": "edge_list", "type": "Array", "desc": "Edges to fillet (empty = all)."}
			],
			"example": "var f = Bdg.fillet_edges(key_solid, 1.0, top_edges)"
		},
		{
			"category": "Operations",
			"name": "Bdg.extrude_vec",
			"sig": "Bdg.extrude_vec(shape: BdgShape, direction: Vector3) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.extrude_vec(${0:shape}, ${1:direction})",
			"desc": "Extrude a face by a full 3D direction vector (magnitude = distance).",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Face to extrude."},
				{"name": "direction", "type": "Vector3", "desc": "Extrusion direction and distance."}
			],
			"example": "var solid = Bdg.extrude_vec(face, p.z_dir * 0.1)"
		},
		{
			"category": "Operations",
			"name": "Bdg.revolve_axis",
			"sig": "Bdg.revolve_axis(shape: BdgShape, angle_deg: float, axis: BdgAxis = BdgAxis.Z) -> BdgShape",
			"returns": "BdgShape",
			"insert": "Bdg.revolve_axis(${0:shape}, ${1:angle_deg})",
			"desc": "Revolve a face about an axis by an angle in degrees (raw result, not wrapped).",
			"params": [
				{"name": "shape", "type": "BdgShape", "desc": "Face to revolve."},
				{"name": "angle_deg", "type": "float", "desc": "Revolve angle in degrees."},
				{"name": "axis", "type": "BdgAxis", "desc": "Revolve axis (default Z)."}
			],
			"example": "var solid = Bdg.revolve_axis(coin_face, 360.0, Bdg.axis_z())"
		},
		{
			"category": "Constants",
			"name": "Bdg.GeomType",
			"sig": "Bdg.GeomType (enum alias of BdgEnums.GeomType)",
			"returns": "int enum",
			"insert": "Bdg.GeomType.",
			"desc": "Enum of shape geometric types: LINE, CIRCLE, ARC, ELLIPSE, HYPERBOLA, PARABOLA, BEZIER, BSPLINE, OFFSET, OTHER, PLANE, CYLINDER, CONE, SPHERE, TORUS.",
			"params": [],
			"example": "if Bdg.geom_type(face) == Bdg.GeomType.PLANE:"
		},
		{
			"category": "Constants",
			"name": "Bdg.GeomType.PLANE",
			"sig": "Bdg.GeomType.PLANE",
			"returns": "int",
			"insert": "Bdg.GeomType.PLANE",
			"desc": "Planar surface geometric type.",
			"params": [],
			"example": "if Bdg.geom_type(face) == Bdg.GeomType.PLANE:"
		},
		{
			"category": "Constants",
			"name": "Bdg.GeomType.CIRCLE",
			"sig": "Bdg.GeomType.CIRCLE",
			"returns": "int",
			"insert": "Bdg.GeomType.CIRCLE",
			"desc": "Circular curve geometric type.",
			"params": [],
			"example": "if Bdg.geom_type(edge) == Bdg.GeomType.CIRCLE:"
		},
		{
			"category": "Constants",
			"name": "Bdg.GeomType.LINE",
			"sig": "Bdg.GeomType.LINE",
			"returns": "int",
			"insert": "Bdg.GeomType.LINE",
			"desc": "Linear curve geometric type.",
			"params": [],
			"example": "if Bdg.geom_type(edge) == Bdg.GeomType.LINE:"
		}
	]

	_docs_by_name.clear()
	for doc in _docs_cache:
		var n: String = doc["name"]
		_docs_by_name[n] = doc
		if n.begins_with("Bdg."):
			_docs_by_name[n.substr(4)] = doc

static func get_categories() -> Array[String]:
	return [
		"All",
		"Builders",
		"Patterns",
		"3D Solids",
		"2D Sketches",
		"1D Curves",
		"Operations",
		"Drafting",
		"Topology",
		"I/O",
		"Assemblies",
		"Constants"
	]

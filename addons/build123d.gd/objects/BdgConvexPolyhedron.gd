extends BdgPartObject
## BdgConvexPolyhedron - Part Object: 3D Convex Polyhedron Solid.
## Generates a 3D convex hull solid from a set of 3D points.
## Mirrors build123d/objects_part.py ConvexPolyhedron.
class_name BdgConvexPolyhedron

var points: Array[Vector3] = []

## Args:
##   pts: Array[Vector3] - point cloud to compute convex hull for
##   rotation: Vector3 = Vector3.ZERO
##   align: Variant = BdgEnums.Align.CENTER
##   mode: BdgEnums.Mode = ADD
func _init(pts: Array = [], rot: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, md: int = BdgEnums.Mode.ADD) -> void:
	super()
	if pts.size() < 4:
		push_error("BdgConvexPolyhedron: at least 4 non-coplanar points required")
		return

	points = []
	for p in pts:
		if p is Vector3:
			points.append(p)

	var solid := _build_convex_hull_solid(points)
	if solid != null:
		_from_solid(solid, rot, align, md)

static func _build_convex_hull_solid(pts: Array[Vector3]) -> BdgSolid:
	# Compute 3D convex hull triangles using 3D Quickhull algorithm
	var triangles := _quickhull_3d(pts)
	if triangles.is_empty():
		return null

	var sewing := OcgBRepBuilderAPISewing.new()
	for tri in triangles:
		var p0: Vector3 = tri[0]
		var p1: Vector3 = tri[1]
		var p2: Vector3 = tri[2]
		var face := BdgFace.make_polygon([p0, p1, p2])
		if face != null and not face.is_null():
			sewing.add(face._wrapped)

	sewing.perform(OcgMessageProgressRange.new())
	var sewed := sewing.sewed_shape()
	if sewed == null or sewed.is_null():
		return null

	var explorer := OcgTopExpExplorer.from_4(sewed, int(BdgEnums.ShapeType.SHELL), int(BdgEnums.ShapeType.SHAPE))
	var shell: OcgTopoDSShell = null
	while explorer.more():
		shell = OcgTopoDSShell.cast(explorer.current())
		break

	if shell == null:
		return null

	var mk_solid := OcgBRepBuilderAPIMakeSolid.from_C(shell)
	var solid_shape := mk_solid.solid()
	return BdgSolid.new(solid_shape)

# 3D Convex Hull Implementation
static func _quickhull_3d(pts: Array[Vector3]) -> Array:
	var n := pts.size()
	if n < 4:
		return []

	# Find 6 extreme points
	var min_x := 0
	var max_x := 0
	var min_y := 0
	var max_y := 0
	var min_z := 0
	var max_z := 0
	for i in range(1, n):
		if pts[i].x < pts[min_x].x: min_x = i
		if pts[i].x > pts[max_x].x: max_x = i
		if pts[i].y < pts[min_y].y: min_y = i
		if pts[i].y > pts[max_y].y: max_y = i
		if pts[i].z < pts[min_z].z: min_z = i
		if pts[i].z > pts[max_z].z: max_z = i

	var p0 := pts[min_x]
	var p1 := pts[max_x]
	if p0.distance_squared_to(p1) < 1e-6:
		p1 = pts[max_y]

	# Find third point maximizing distance to line p0-p1
	var line_dir := (p1 - p0).normalized()
	var max_dist := -1.0
	var p2 := Vector3.ZERO
	for p in pts:
		var dist := (p - p0).cross(line_dir).length()
		if dist > max_dist:
			max_dist = dist
			p2 = p

	if max_dist < 1e-4:
		return []

	# Find fourth point maximizing distance to plane p0-p1-p2
	var normal := (p1 - p0).cross(p2 - p0).normalized()
	max_dist = -1.0
	var p3 := Vector3.ZERO
	for p in pts:
		var dist := absf((p - p0).dot(normal))
		if dist > max_dist:
			max_dist = dist
			p3 = p

	if max_dist < 1e-4:
		return []

	# Initial tetrahedron faces oriented outward
	var center := (p0 + p1 + p2 + p3) * 0.25
	var faces: Array = [
		[p0, p1, p2],
		[p0, p2, p3],
		[p0, p3, p1],
		[p1, p3, p2],
	]

	for i in faces.size():
		var f: Array = faces[i]
		var fn: Vector3 = (f[1] - f[0]).cross(f[2] - f[0]).normalized()
		if fn.dot(f[0] - center) < 0:
			faces[i] = [f[0], f[2], f[1]]

	# Iteratively expand hull with remaining points
	for p in pts:
		var visible_faces: Array = []
		for f in faces:
			var fn: Vector3 = (f[1] - f[0]).cross(f[2] - f[0]).normalized()
			if fn.dot(p - f[0]) > 1e-5:
				visible_faces.append(f)

		if visible_faces.is_empty():
			continue

		# Find horizon edges
		var edges_count: Dictionary = {}
		for f in visible_faces:
			for e_i in 3:
				var a: Vector3 = f[e_i]
				var b: Vector3 = f[(e_i + 1) % 3]
				var k1 := "%s->%s" % [a, b]
				var k2 := "%s->%s" % [b, a]
				edges_count[k1] = edges_count.get(k1, 0) + 1

		var horizon: Array = []
		for f in visible_faces:
			for e_i in 3:
				var a: Vector3 = f[e_i]
				var b: Vector3 = f[(e_i + 1) % 3]
				var k1 := "%s->%s" % [a, b]
				var k2 := "%s->%s" % [b, a]
				if not edges_count.has(k2):
					horizon.append([a, b])

		# Remove visible faces
		for vf in visible_faces:
			faces.erase(vf)

		# Add new faces connecting horizon edges to p
		for edge in horizon:
			faces.append([edge[0], edge[1], p])

	return faces

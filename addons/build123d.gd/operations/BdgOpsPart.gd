extends RefCounted
## BdgOpsPart - 3D solid operations for parts.
## Mirrors build123d/operations_part.py.
class_name BdgOpsPart

## Extrude a Face (or shape with faces) along normal or direction vector.
## Supports taper angle in degrees (draft angle) and bidirectional extrusion.
static func extrude(
	to_extrude: Variant,
	amount: float,
	dir: Vector3 = Vector3.ZERO,
	both: bool = false,
	taper: float = 0.0,
	mode: int = BdgEnums.Mode.ADD,
) -> BdgPart:
	var faces: Array = []
	if to_extrude is Array:
		for f in to_extrude:
			if f is BdgShape:
				faces.append(f)
	elif to_extrude is BdgShape:
		faces = to_extrude.faces()
	else:
		push_error("BdgOpsPart.extrude: unsupported input")

	var solids: Array = []
	for face in faces:
		var direction: Vector3 = face.normal() * amount
		if dir != Vector3.ZERO:
			direction = dir.normalized() * amount
		var result: BdgShape = face.extrude(direction)
		var solid: BdgSolid = result as BdgSolid if result is BdgSolid else (result.solids()[0] if not result.solids().is_empty() else null)
		if solid != null and not is_zero_approx(taper):
			var side_faces: Array = []
			for sf in solid.faces():
				if absf(sf.normal().dot(direction.normalized())) < 0.8:
					side_faces.append(sf)
			var drafted := solid.draft(side_faces, taper, face.to_plane(), direction.normalized())
			if drafted != null:
				solid = drafted
		if solid != null:
			solids.append(solid)

	if both:
		for face in faces:
			var direction: Vector3 = face.normal() * (-amount)
			if dir != Vector3.ZERO:
				direction = dir.normalized() * (-amount)
			var result: BdgShape = face.extrude(direction)
			var solid: BdgSolid = result as BdgSolid if result is BdgSolid else (result.solids()[0] if not result.solids().is_empty() else null)
			if solid != null and not is_zero_approx(taper):
				var side_faces: Array = []
				for sf in solid.faces():
					if absf(sf.normal().dot(direction.normalized())) < 0.8:
						side_faces.append(sf)
				var drafted := solid.draft(side_faces, taper, face.to_plane(), direction.normalized())
				if drafted != null:
					solid = drafted
			if solid != null:
				solids.append(solid)

	var compound := BdgShape.make_compound_of(solids)
	var result_part := BdgPart.new(compound._wrapped, solids)
	if BdgBuilder.has_context(BdgBuildPart.TAG):
		BdgBuilder.add_to_current(result_part, mode, BdgBuildPart.TAG)
	return result_part

## Revolve a profile/face around an axis by an angle in degrees.
static func revolve(
	to_revolve: Variant,
	angle: float,
	axis: BdgAxis = null,
	mode: int = BdgEnums.Mode.ADD,
) -> BdgPart:
	var ax := axis if axis != null else BdgAxis.Z
	var shape: BdgShape = null
	if to_revolve is Array:
		var faces: Array = []
		for f in to_revolve:
			if f is BdgShape:
				faces.append(f)
		shape = BdgShape.make_compound_of(faces)
	elif to_revolve is BdgShape:
		shape = to_revolve
	else:
		push_error("BdgOpsPart.revolve: unsupported input")
		return null

	var result: BdgShape = shape.revolve(angle, ax)
	var solids: Array = []
	if result is BdgSolid:
		solids.append(result)
	elif result is BdgCompound:
		solids = result.solids()

	var result_part := BdgPart.new(BdgShape.make_compound_of(solids)._wrapped, solids)
	if BdgBuilder.has_context(BdgBuildPart.TAG):
		BdgBuilder.add_to_current(result_part, mode, BdgBuildPart.TAG)
	return result_part

## Sweep a profile face/wire along a path wire.
static func sweep(
	profile: Variant,
	path: Variant,
	mode: int = BdgEnums.Mode.ADD,
) -> BdgShape:
	var shape: BdgShape = null
	if profile is Array:
		var faces: Array = []
		for f in profile:
			if f is BdgShape:
				faces.append(f)
		shape = BdgShape.make_compound_of(faces)
	elif profile is BdgShape:
		shape = profile
	else:
		push_error("BdgOpsPart.sweep: unsupported input")
		return null

	var wire_path: BdgWire = null
	if path is BdgWire:
		wire_path = path
	elif path is BdgEdge:
		wire_path = BdgWire.make_wire([path])
	elif path is BdgShape:
		var ws := (path as BdgShape).wires()
		if not ws.is_empty():
			wire_path = ws[0]
		else:
			var es := (path as BdgShape).edges()
			if not es.is_empty():
				wire_path = BdgWire.make_wire(es)
			else:
				wire_path = BdgWire.new((path as BdgShape)._wrapped)

	if wire_path == null:
		push_error("BdgOpsPart.sweep: invalid path wire")
		return null

	var result: BdgShape = shape.sweep(wire_path)
	if result != null and BdgBuilder.has_context(BdgBuildPart.TAG):
		BdgBuilder.add_to_current(result, mode, BdgBuildPart.TAG)
	return result

## Loft a solid through the given sections (wires / vertices).
static func loft(objs: Array, ruled: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgSolid:
	var result: BdgShape = BdgShape.make_loft(objs, ruled, true)
	if result == null:
		return null
	var solid: BdgSolid = result as BdgSolid
	if solid == null:
		push_error("BdgOpsPart.loft did not produce a solid")
		return null
	var result_part := BdgPart.new(BdgShape.make_compound_of([result])._wrapped, [result])
	if BdgBuilder.has_context(BdgBuildPart.TAG):
		BdgBuilder.add_to_current(result_part, mode, BdgBuildPart.TAG)
	return solid

## Fillet edges of a solid with given radius.
static func fillet(objects: Variant, radius: float) -> BdgShape:
	var edges: Array = []
	var parent: BdgShape = null
	if objects is Array:
		for o in objects:
			if o is BdgEdge:
				edges.append(o)
				parent = parent if parent != null else o.topo_parent
			elif o is BdgVertex:
				parent = parent if parent != null else o.topo_parent
	elif objects is BdgEdge:
		edges = [objects]
		parent = objects.topo_parent
	if edges.is_empty() or parent == null:
		push_error("BdgOpsPart.fillet: no edges to fillet")
		return null
	if parent is BdgSolid:
		return (parent as BdgSolid).fillet(radius, edges)
	if parent is BdgCompound:
		var sols := (parent as BdgCompound).solids()
		if not sols.is_empty():
			return (sols[0] as BdgSolid).fillet(radius, edges)
	push_error("BdgOpsPart.fillet: parent is not a solid")
	return null

## Chamfer edges of a solid.
static func chamfer(objects: Variant, length: float, length2: float = 0.0) -> BdgShape:
	var edges: Array = []
	var parent: BdgShape = null
	if objects is Array:
		for o in objects:
			if o is BdgEdge:
				edges.append(o)
				parent = parent if parent != null else o.topo_parent
	elif objects is BdgEdge:
		edges = [objects]
		parent = objects.topo_parent
	if edges.is_empty() or parent == null:
		push_error("BdgOpsPart.chamfer: no edges to chamfer")
		return null
	if parent is BdgSolid:
		return (parent as BdgSolid).chamfer(length, length2, edges)
	if parent is BdgCompound:
		var sols := (parent as BdgCompound).solids()
		if not sols.is_empty():
			return (sols[0] as BdgSolid).chamfer(length, length2, edges)
	push_error("BdgOpsPart.chamfer: parent is not a solid")
	return null

## Section a shape with a plane.
static func section(shape: BdgShape, plane: BdgPlane = null) -> Array:
	if shape == null:
		return []
	return shape.section(plane)

## Thicken a face into a solid with thickness.
static func thicken(shape: BdgShape, amount: float, mode: int = BdgEnums.Mode.ADD) -> BdgShape:
	if shape == null:
		return null
	var result := shape.thicken(amount)
	if result != null and BdgBuilder.has_context(BdgBuildPart.TAG):
		BdgBuilder.add_to_current(result, mode, BdgBuildPart.TAG)
	return result

## Hollow out a solid leaving face openings.
static func hollow(solid: BdgSolid, faces_to_remove: Array, thickness: float, mode: int = BdgEnums.Mode.ADD) -> BdgSolid:
	if solid == null:
		return null
	var result := solid.hollow(faces_to_remove, thickness)
	if result != null and BdgBuilder.has_context(BdgBuildPart.TAG):
		BdgBuilder.add_to_current(result, mode, BdgBuildPart.TAG)
	return result

## Apply draft angle to solid faces.
static func draft(solid: BdgSolid, faces: Array, angle_deg: float, neutral_plane: BdgPlane, pull_dir: Vector3 = Vector3.ZERO, mode: int = BdgEnums.Mode.ADD) -> BdgSolid:
	if solid == null:
		return null
	var result := solid.draft(faces, angle_deg, neutral_plane, pull_dir)
	if result != null and BdgBuilder.has_context(BdgBuildPart.TAG):
		BdgBuilder.add_to_current(result, mode, BdgBuildPart.TAG)
	return result

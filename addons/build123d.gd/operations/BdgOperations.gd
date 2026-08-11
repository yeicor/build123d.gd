extends RefCounted
## BdgOperations - module-level operation functions.
## Mirrors build123d operations_part.py / operations_generic.py.
class_name BdgOperations

## Extrude a Face (or a shape with faces) by an amount along the face normal,
## or along an explicit direction. Returns a BdgPart containing the solids.
## Args:
##   to_extrude: BdgFace or any BdgShape (its faces are used) or Array of faces
##   amount: float - extrusion distance (sign controls direction)
##   dir: Vector3 - optional explicit direction (magnitude multiplied by amount)
##   both: bool - extrude in both directions
##   mode: BdgEnums.Mode - reserved for builder context, ignored here
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
		push_error("BdgOperations.extrude: unsupported input")
	var solids: Array = []
	for face in faces:
		var direction: Vector3 = face.normal() * amount
		if dir != Vector3.ZERO:
			direction = dir.normalized() * amount
		var result: BdgShape = face.extrude(direction)
		if result is BdgSolid:
			solids.append(result)
		elif result is BdgCompound:
			for s in result.solids():
				solids.append(s)
	if both:
		var both_solids: Array = []
		for face in faces:
			var direction: Vector3 = face.normal() * (-amount)
			if dir != Vector3.ZERO:
				direction = dir.normalized() * (-amount)
			var result: BdgShape = face.extrude(direction)
			if result is BdgSolid:
				both_solids.append(result)
			elif result is BdgCompound:
				for s in result.solids():
					both_solids.append(s)
		solids.append_array(both_solids)
	var result_part := BdgPart.new(BdgShape.make_compound_of(solids), solids)
	if BdgBuilder.has_context(BdgBuildPart.TAG):
		BdgBuilder.add_to_current(result_part, mode, BdgBuildPart.TAG)
	return result_part

## Fillet the given edges (or vertices, via their parent) with the given radius.
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
		push_error("BdgOperations.fillet: no edges to fillet")
		return null
	if parent is BdgSolid:
		return parent.fillet(radius, edges)
	if parent is BdgCompound:
		var sols: Array = parent.solids()
		if not sols.is_empty():
			return sols[0].fillet(radius, edges)
	push_error("BdgOperations.fillet: parent is not a solid")
	return null

## Chamfer the given edges of a solid.
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
		push_error("BdgOperations.chamfer: no edges to chamfer")
		return null
	if parent is BdgSolid:
		return parent.chamfer(length, length2, edges)
	if parent is BdgCompound:
		var sols: Array = parent.solids()
		if not sols.is_empty():
			return sols[0].chamfer(length, length2, edges)
	push_error("BdgOperations.chamfer: parent is not a solid")
	return null

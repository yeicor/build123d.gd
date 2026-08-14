extends RefCounted
## BdgOpsGeneric - Generic operations applicable across 1D, 2D, and 3D shapes.
## Mirrors build123d/operations_generic.py.
class_name BdgOpsGeneric

## Add shapes/objects to the active builder context.
static func add(objects: Variant, mode: int = BdgEnums.Mode.ADD) -> Variant:
	var shape_to_add: BdgShape = null
	if objects is Array:
		var valid: Array = []
		for o in objects:
			if o is BdgShape:
				valid.append(o)
		if not valid.is_empty():
			shape_to_add = BdgShape.make_compound_of(valid)
	elif objects is BdgShape:
		shape_to_add = objects

	if shape_to_add == null or shape_to_add.is_null():
		return null

	var cur := BdgBuilder.get_current()
	if cur != null:
		cur._add_to_context(shape_to_add, mode)
	return shape_to_add

## Mirror a shape across a given plane (defaults to XY).
static func mirror(objects: Variant, about: BdgPlane = null) -> Variant:
	var pln := about if about != null else BdgPlane.XY
	var pnt := OcgGpPnt.from_6(pln.origin.x, pln.origin.y, pln.origin.z)
	var n := OcgGpDir.from_6(pln.z_dir.x, pln.z_dir.y, pln.z_dir.z)
	var vx := OcgGpDir.from_6(pln.x_dir.x, pln.x_dir.y, pln.x_dir.z)
	var ax2 := OcgGpAx2.from_S(pnt, n, vx)
	var trsf := OcgGpTrsf.new()
	trsf.set_mirror_v(ax2)

	var transform_fn := func(s: BdgShape) -> BdgShape:
		if s == null or s.is_null():
			return null
		var tf := OcgBRepBuilderAPITransform.from_l(s._wrapped, trsf, true, true)
		return BdgShape.cast(tf.shape())

	if objects is Array:
		var result: Array = []
		for o in objects:
			if o is BdgShape:
				result.append(transform_fn.call(o))
		return result
	elif objects is BdgShape:
		return transform_fn.call(objects)
	return null

## Scale a shape uniformly (by float) or non-uniformly (by Vector3 / [sx, sy, sz]).
static func scale(objects: Variant, factor: Variant, center: Vector3 = Vector3.ZERO) -> Variant:
	var is_uniform := false
	var scale_val := 1.0
	var sx := 1.0
	var sy := 1.0
	var sz := 1.0

	if factor is float or factor is int:
		is_uniform = true
		scale_val = float(factor)
	elif factor is Vector3:
		var v: Vector3 = factor
		sx = v.x
		sy = v.y
		sz = v.z
		if is_equal_approx(sx, sy) and is_equal_approx(sy, sz):
			is_uniform = true
			scale_val = sx
	elif factor is Array and (factor as Array).size() >= 3:
		sx = float(factor[0])
		sy = float(factor[1])
		sz = float(factor[2])

	var transform_fn := func(s: BdgShape) -> BdgShape:
		if s == null or s.is_null():
			return null
		if is_uniform:
			var trsf := OcgGpTrsf.new()
			trsf.set_scale(OcgGpPnt.from_6(center.x, center.y, center.z), scale_val)
			var tf := OcgBRepBuilderAPITransform.from_l(s._wrapped, trsf, true, true)
			return BdgShape.cast(tf.shape())
		else:
			var mat := OcgGpMat.new()
			mat.set_value(1, 1, sx)
			mat.set_value(2, 2, sy)
			mat.set_value(3, 3, sz)
			var gtrsf := OcgGpGTrsf.new()
			gtrsf.set_vectorial_part(mat)
			gtrsf.set_translation_part(OcgGpXYZ.from_6(center.x * (1.0 - sx), center.y * (1.0 - sy), center.z * (1.0 - sz)))
			var gtf := OcgBRepBuilderAPIGTransform.from_D(s._wrapped, gtrsf, true)
			return BdgShape.cast(gtf.shape())

	if objects is Array:
		var result: Array = []
		for o in objects:
			if o is BdgShape:
				result.append(transform_fn.call(o))
		return result
	elif objects is BdgShape:
		return transform_fn.call(objects)
	return null

## Offset a shape in 2D (face/wire) or 3D (solid).
static func offset(objects: Variant, amount: float, kind: int = 0) -> Variant:
	var offset_fn := func(s: BdgShape) -> BdgShape:
		if s == null or s.is_null():
			return null
		if s is BdgWire:
			return (s as BdgWire).offset_2d(amount, kind)
		elif s is BdgFace:
			return (s as BdgFace).offset_2d(amount, kind)
		elif s is BdgSolid:
			var off := OcgBRepOffsetAPIMakeOffsetShape.new()
			off.perform_by_simple(s._wrapped, amount)
			if off.is_done():
				return BdgShape.cast(off.shape())
		return null

	if objects is Array:
		var result: Array = []
		for o in objects:
			if o is BdgShape:
				result.append(offset_fn.call(o))
		return result
	elif objects is BdgShape:
		return offset_fn.call(objects)
	return null

## Project a shape onto target shape surface.
static func project(objects: Variant, target: BdgShape, direction: Vector3 = Vector3.ZERO) -> Array:
	if objects is BdgEdge:
		return (objects as BdgEdge).project_to_shape(target, direction)
	elif objects is BdgWire:
		var es: Array = []
		for e in (objects as BdgWire).edges():
			es.append_array(e.project_to_shape(target, direction))
		return es
	elif objects is Array:
		var es: Array = []
		for o in objects:
			if o is BdgEdge:
				es.append_array((o as BdgEdge).project_to_shape(target, direction))
			elif o is BdgWire:
				for e in (o as BdgWire).edges():
					es.append_array(e.project_to_shape(target, direction))
		return es
	return []

## Split a shape with a bisecting plane or face.
## keep: BdgEnums.Keep (TOP / BOTTOM / BOTH / ALL)
static func split(objects: Variant, bisect_by: Variant, keep: int = BdgEnums.Keep.TOP) -> Variant:
	var pln: BdgPlane = bisect_by if bisect_by is BdgPlane else BdgPlane.XY
	var split_fn := func(s: BdgShape) -> Variant:
		if s == null or s.is_null():
			return null
		if s is BdgFace:
			if bisect_by is BdgWire:
				return (s as BdgFace).split_by_perimeter(bisect_by as BdgWire, keep)
		# General 3D half-space split with bisecting plane
		var box := s.bounding_box()
		var sz := box.diagonal() * 3.0
		var half_box_solid := BdgSolid.make_box(sz, sz, sz, pln)
		if keep == BdgEnums.Keep.TOP:
			return s.intersect(half_box_solid)
		elif keep == BdgEnums.Keep.BOTTOM:
			return s.cut(half_box_solid)
		elif keep == BdgEnums.Keep.BOTH or keep == BdgEnums.Keep.ALL:
			return [s.intersect(half_box_solid), s.cut(half_box_solid)]
		return s

	if objects is Array:
		var result: Array = []
		for o in objects:
			if o is BdgShape:
				result.append(split_fn.call(o))
		return result
	elif objects is BdgShape:
		return split_fn.call(objects)
	return null

## Compute total bounding box for one or more shapes.
static func bounding_box(objects: Variant) -> BdgBoundBox:
	if objects is BdgShape:
		return (objects as BdgShape).bounding_box()
	elif objects is Array:
		var list := BdgShapeList.new(objects)
		return list.bounding_box()
	return BdgBoundBox.new(Vector3.ZERO, Vector3.ZERO)

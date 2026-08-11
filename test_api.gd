extends SceneTree

func _init():
	# Check full inheritance chain methods for Fuse
	print("Fuse parent: ", ClassDB.get_parent_class("OcgBRepAlgoAPIFuse"))
	print("BooleanOp parent: ", ClassDB.get_parent_class("OcgBRepAlgoAPIBooleanOperation"))
	print("BuilderAlgo parent: ", ClassDB.get_parent_class("OcgBRepAlgoAPIBuilderAlgo"))
	# Check if has shape via property
	var b1 := OcgBRepPrimAPIMakeBox.from_6(10.0, 10.0, 10.0).solid()
	var b2 := OcgBRepPrimAPIMakeBox.from_X(OcgGpPnt.from_6(5.0, 0.0, 0.0), 10.0, 10.0, 10.0).solid()
	var rng := OcgMessageProgressRange.new()
	var fuse := OcgBRepAlgoAPIFuse.from_b(b1, b2, rng)
	# Check all getable properties
	print("fuse props: ", fuse.get_property_list().map(func(p): return p.name))
	quit()

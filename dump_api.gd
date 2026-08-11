extends SceneTree

func _init():
	var f := FileAccess.open("/tmp/opencode/occt_api/classes.txt", FileAccess.WRITE)
	var classes := []
	for c in ClassDB.get_class_list():
		if c.begins_with("Ocg"):
			classes.append(c)
	classes.sort()
	f.store_line("TOTAL: %d classes" % classes.size())
	for c in classes:
		f.store_line("=== %s ===" % c)
		var methods := ClassDB.class_get_method_list(c, true)
		methods.sort_custom(func(a, b): return a.name < b.name)
		for m in methods:
			var args := []
			for a in m.args:
				args.append("%s:%s" % [a.name, a.type])
			f.store_line("  func %s(%s) -> %s" % [m.name, ", ".join(args), m.return.type])
		var props := ClassDB.class_get_property_list(c, true)
		props.sort_custom(func(a, b): return a.name < b.name)
		for p in props:
			f.store_line("  prop %s: %s" % [p.name, p.type])
	f.close()
	print("Done")
	quit()

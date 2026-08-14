extends SceneTree

func _init() -> void:
	var example = (preload("res://demo/examples/ExTeaCup.gd") as GDScript).new()
	var res: Variant = example.build()
	var metrics := BdgExample.get_metrics(res)
	print("VOLUME: ", metrics["volume"])
	print("BBOX: ", metrics["bbox_size"])
	print("FACES: ", metrics["faces"])
	print("EDGES: ", metrics["edges"])
	print("VERTS: ", metrics["vertices"])
	quit()

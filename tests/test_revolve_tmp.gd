extends SceneTree

func _init() -> void:
	# Minimal: rectangle from x=0..10, y=0..2, in XY plane, revolve around Y axis
	var wire := BdgWire.make_polygon([Vector3(0,0,0), Vector3(10,0,0), Vector3(10,2,0), Vector3(0,2,0)], true)
	var face := BdgFace.make_from_wires(wire)
	print("face bbox: ", face.bounding_box().size())
	var rev := face.revolve(360.0, BdgAxis.Y)
	print("revolve around Y bbox: ", rev.bounding_box().size())
	print("revolve around Y vol: ", rev.volume())
	# expected: radius 10 cylinder height 2 -> bbox 20 x 2 x 20, vol pi*100*2=628.3
	var rev2 := face.revolve(360.0, BdgAxis.Z)
	print("revolve around Z bbox: ", rev2.bounding_box().size())
	print("revolve around Z vol: ", rev2.volume())
	quit()

extends RefCounted
## BdgExampleRegistry - Registry of ported official build123d showcase examples for the IDE.
class_name BdgExampleRegistry

const ExBoxesOnFaces = preload("res://demo/examples/ExBoxesOnFaces.gd")
const ExPillowBlock = preload("res://demo/examples/ExPillowBlock.gd")
const ExLego = preload("res://demo/examples/ExLego.gd")
const ExHandle = preload("res://demo/examples/ExHandle.gd")
const ExTeaCup = preload("res://demo/examples/ExTeaCup.gd")
const ExDinRail = preload("res://demo/examples/ExDinRail.gd")
const ExVase = preload("res://demo/examples/ExVase.gd")
const ExHoles = preload("res://demo/examples/ExHoles.gd")
const ExFastGridHoles = preload("res://demo/examples/ExFastGridHoles.gd")
const ExKeyCap = preload("res://demo/examples/ExKeyCap.gd")
const ExMakerCoin = preload("res://demo/examples/ExMakerCoin.gd")
const ExClock = preload("res://demo/examples/ExClock.gd")
const ExCanadianFlag = preload("res://demo/examples/ExCanadianFlag.gd")

static func get_examples() -> Array[Dictionary]:
	return [
		{
			"id": "boxes_on_faces",
			"name": "1. Boxes on Faces",
			"category": "Basics",
			"instance": ExBoxesOnFaces.new(),
		},
		{
			"id": "pillow_block",
			"name": "2. Pillow Block",
			"category": "Intermediate",
			"instance": ExPillowBlock.new(),
		},
		{
			"id": "lego",
			"name": "3. Parametric Lego Brick",
			"category": "Basics",
			"instance": ExLego.new(),
		},
		{
			"id": "handle",
			"name": "4. Drawer Handle",
			"category": "Intermediate",
			"instance": ExHandle.new(),
		},
		{
			"id": "teacup",
			"name": "5. Porcelain Tea Cup",
			"category": "Advanced",
			"instance": ExTeaCup.new(),
		},
		{
			"id": "din_rail",
			"name": "6. 35x7.5mm DIN Rail",
			"category": "Industrial",
			"instance": ExDinRail.new(),
		},
		{
			"id": "vase",
			"name": "7. Organic Fluted Vase",
			"category": "Advanced",
			"instance": ExVase.new(),
		},
		{
			"id": "holes",
			"name": "8. CAD Hole Types",
			"category": "Intermediate",
			"instance": ExHoles.new(),
		},
		{
			"id": "fast_grid_holes",
			"name": "9. Hex Grid Perforated Plate",
			"category": "Intermediate",
			"instance": ExFastGridHoles.new(),
		},
		{
			"id": "key_cap",
			"name": "10. Cherry MX Key Cap",
			"category": "Mechanical",
			"instance": ExKeyCap.new(),
		},
		{
			"id": "maker_coin",
			"name": "11. Maker Coin with Detents",
			"category": "Precision CAD",
			"instance": ExMakerCoin.new(),
		},
		{
			"id": "clock",
			"name": "12. Parametric Clock Face",
			"category": "Precision CAD",
			"instance": ExClock.new(),
		},
		{
			"id": "canadian_flag",
			"name": "13. Canadian Flag Relief",
			"category": "Artistic CAD",
			"instance": ExCanadianFlag.new(),
		},
	]

extends RefCounted
## BdgColor - RGBA color mirroring build123d/geometry.py Color.
## Godot-native: wraps a Color but keeps the build123d Color palette + names.
class_name BdgColor

var color: Color = Color.WHITE

## build123d palette
const BLACK := "black"
const WHITE := "white"
const RED := "red"
const GREEN := "green"
const BLUE := "blue"
const YELLOW := "yellow"
const CYAN := "cyan"
const MAGENTA := "magenta"
const GRAY := "gray"
const GREY := "grey"
const ORANGE := "orange"
const PURPLE := "purple"
const PINK := "pink"

static var _palette := {
	"black": Color(0, 0, 0, 1),
	"white": Color(1, 1, 1, 1),
	"red": Color(1, 0, 0, 1),
	"green": Color(0, 1, 0, 1),
	"blue": Color(0, 0, 1, 1),
	"yellow": Color(1, 1, 0, 1),
	"cyan": Color(0, 1, 1, 1),
	"magenta": Color(1, 0, 1, 1),
	"gray": Color(0.5, 0.5, 0.5, 1),
	"grey": Color(0.5, 0.5, 0.5, 1),
	"orange": Color(1, 0.5, 0, 1),
	"purple": Color(0.5, 0, 0.5, 1),
	"pink": Color(1, 0.75, 0.8, 1),
}

## Construct. Args:
##   ()              -> white
##   (name: String)  -> from palette
##   (color: Color)  -> Godot color
##   (color: BdgColor)
func _init(value = null) -> void:
	if value == null:
		color = Color.WHITE
	elif value is BdgColor:
		color = value.color
	elif value is Color:
		color = value
	elif value is String:
		if _palette.has(value.to_lower()):
			color = _palette[value.to_lower()]
		else:
			color = Color(value)
	elif value is Array and value.size() >= 3:
		color = Color(value[0], value[1], value[2], value[3] if value.size() > 3 else 1.0)
	else:
		push_error("BdgColor: unsupported color value %s" % value)
		color = Color.WHITE

## Generate a distinct color from categorical palette index
static func categorical_set(idx: int) -> BdgColor:
	var palette_keys := _palette.keys()
	var key: String = palette_keys[posmod(idx, palette_keys.size())]
	return BdgColor.new(_palette[key])

func _to_string() -> String:
	return "Color(%s)" % color


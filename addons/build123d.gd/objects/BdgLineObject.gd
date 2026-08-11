extends BdgShape
## BdgLineObject - base class for BuildLine objects & operations.
## Mirrors build123d/objects_curve.py BaseEdgeObject.
class_name BdgLineObject

var mode: int = BdgEnums.Mode.ADD

func _init(...args) -> void:
	super()

## Finish construction: register with the current BdgBuildLine context.
func _register(md: int) -> void:
	mode = md
	if BdgBuilder.has_context(BdgBuildLine.TAG):
		BdgBuilder.add_to_current(self, mode, BdgBuildLine.TAG)

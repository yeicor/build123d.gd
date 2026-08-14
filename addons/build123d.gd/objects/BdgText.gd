extends BdgSketchObject
## BdgText - Sketch Object: 2D Text
## Create 2D planar text faces using native OpenCASCADE BRep font rendering.
class_name BdgText

var text: String = ""
var font_size: float = 12.0
var font_name: String = "sans-serif"
var font_style: int = BdgEnums.FontStyle.REGULAR

## Args:
##   text: String, font_size: float, font_name: String = "sans-serif",
##   font_style: BdgEnums.FontStyle = REGULAR,
##   align: Align | Array[Align] = [CENTER, CENTER],
##   rotation: float = 0.0,
##   mode: Mode = ADD
func _init(...args) -> void:
	super()
	if args.is_empty():
		return

	var txt: String = str(args[0])
	var sz: float = 12.0
	var fname: String = "sans-serif"
	var style: int = BdgEnums.FontStyle.REGULAR
	var align: Variant = [BdgEnums.Align.CENTER, BdgEnums.Align.CENTER]
	var rot: float = 0.0
	var md: int = BdgEnums.Mode.ADD

	if args.size() > 1 and args[1] != null:
		sz = float(args[1])
	if args.size() > 2 and args[2] != null:
		fname = str(args[2])
	if args.size() > 3 and args[3] != null:
		style = int(args[3])
	if args.size() > 4 and args[4] != null:
		align = args[4]
	if args.size() > 5 and args[5] != null:
		rot = float(args[5])
	if args.size() > 6 and args[6] != null:
		md = int(args[6])

	text = txt
	font_size = sz
	font_name = fname
	font_style = style
	mode = md
	rotation = rot

	var occt_aspect: int = OcgEnums.Font_FontAspect.Font_FontAspect_Regular
	match style:
		BdgEnums.FontStyle.BOLD:
			occt_aspect = OcgEnums.Font_FontAspect.Font_FontAspect_Bold
		BdgEnums.FontStyle.ITALIC:
			occt_aspect = OcgEnums.Font_FontAspect.Font_FontAspect_Italic
		BdgEnums.FontStyle.BOLD_ITALIC:
			occt_aspect = OcgEnums.Font_FontAspect.Font_FontAspect_BoldItalic

	var font_utf := OcgNCollectionUtfStringChar.from_T(fname, -1)
	var font := OcgStdPrsBRepFont.from_R(
		font_utf,
		occt_aspect,
		sz,
		OcgEnums.Font_StrictLevel.Font_StrictLevel_Any
	)

	if font == null:
		push_error("BdgText: could not load font '%s'" % fname)
		return

	var text_utf := OcgNCollectionUtfStringChar.from_T(txt, -1)
	var text_builder := OcgStdPrsBRepTextBuilder.new()
	var ax3 := OcgGpAx3.new()
	var h_align := OcgEnums.Graphic3d_HorizontalTextAlignment.Graphic3d_HTA_LEFT
	var v_align := OcgEnums.Graphic3d_VerticalTextAlignment.Graphic3d_VTA_BOTTOM

	var raw_shape := text_builder.perform_i(font, text_utf, ax3, h_align, v_align)
	if raw_shape == null or raw_shape.is_null():
		push_error("BdgText: failed to generate text geometry")
		return

	var shape := BdgShape.cast(raw_shape)
	var part: BdgShape = shape

	# Handle 2D alignment
	if align is int and align != BdgEnums.Align.NONE:
		var offset := _align_offset_2d(part.bounding_box(), align)
		if offset != Vector3.ZERO:
			part = part.translate(offset)
	elif align is Array:
		var offset := _align_offset_2d(part.bounding_box(), align)
		if offset != Vector3.ZERO:
			part = part.translate(offset)

	if rotation != 0.0:
		part = part.rotated_about(BdgAxis.Z, rotation)

	var faces := part.faces()
	_wrapped = BdgShape.make_compound_of(faces)._wrapped
	children = faces

	if BdgBuilder.has_context(BdgBuildSketch.TAG):
		BdgBuilder.add_to_current(self, mode, BdgBuildSketch.TAG)

using fwt
using gfx

** This will hopefully prevent millions of different style objs from being created.
** It essentially internalises 'RichTextStyle' objects.
internal class StyleCache {
	
	private Obj:Obj		cache	:= [:]
	
	RichTextStyle get(Color fg, Color bg, Font font, RichTextUnderline underline) {
		level1 := cache		.getOrAdd(underline){ [:] } as Obj:Obj
		level2 := level1	.getOrAdd(font)		{ [:] } as Obj:Obj
		level3 := level2	.getOrAdd(bg)		{ [:] } as Obj:Obj
		level4 := level3	.getOrAdd(fg)		{
			RichTextStyle {
				it.fg				= fg
				it.bg				= bg
				it.font				= font
				it.underlineColor	= fg
				it.underline		= underline
			}
		} as RichTextStyle
		return level4
	}
}

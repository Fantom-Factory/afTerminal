using gfx::Color

** 256 ANSI colour palette.
const class AnsiPalette {
		
	private static Color[] paletteVga() {
		Color[
			Color.makeRgb(  0,   0,   0),	// black
			Color.makeRgb(170,   0,   0),	// red
			Color.makeRgb(  0, 170,   0),	// green
			Color.makeRgb(170,  85,   0),	// brown/yellow
			Color.makeRgb(  0,  0,  170),	// blue
			Color.makeRgb(170,  0,  170),	// magenta
			Color.makeRgb(  0, 170, 170),	// cyan
			Color.makeRgb(170, 170, 170),	// grey
			Color.makeRgb( 85,  85,  85),	// dark grey
			Color.makeRgb(255,  85,  85),	// bright red
			Color.makeRgb( 85, 255,  85),	// bright green
			Color.makeRgb(255, 255,  85),	// yellow
			Color.makeRgb( 85,  85, 255),	// bright blue
			Color.makeRgb(255,  85, 255),	// bright magenta
			Color.makeRgb( 85, 255, 255),	// bright cyan
			Color.makeRgb(255, 255, 255)	// white
		]
	}

	private static Color[] paletteXp() {
		Color[
			Color.makeRgb(  0,   0,   0),	// black
			Color.makeRgb(128,   0,   0),	// red
			Color.makeRgb(  0, 128,   0),	// green
			Color.makeRgb(128, 128,   0),	// brown/yellow
			Color.makeRgb(  0,   0, 128),	// blue
			Color.makeRgb(128,   0, 128),	// magenta
			Color.makeRgb(  0, 128, 128),	// cyan
			Color.makeRgb(192, 192, 192),	// grey
			Color.makeRgb(128, 128, 128),	// dark grey
			Color.makeRgb(255,   0,   0),	// bright red
			Color.makeRgb(  0, 255,   0),	// bright green
			Color.makeRgb(255, 255,   0),	// yellow
			Color.makeRgb(  0,   0, 255),	// bright blue
			Color.makeRgb(255,   0, 255),	// bright magenta
			Color.makeRgb(  0, 255, 255),	// bright cyan
			Color.makeRgb(255, 255, 255)	// white
		]
	}

	private static Color[] paletteMac() {
		Color[
			Color.makeRgb(  0,   0,   0),	// black
			Color.makeRgb(194,  54,  33),	// red
			Color.makeRgb( 37, 188,  36),	// green
			Color.makeRgb(173, 173,  39),	// brown/yellow
			Color.makeRgb( 73,  46, 225),	// blue
			Color.makeRgb(211,  56, 211),	// magenta
			Color.makeRgb( 51, 187, 200),	// cyan
			Color.makeRgb(203, 204, 205),	// grey
			Color.makeRgb(129, 131, 131),	// dark grey
			Color.makeRgb(252,  57,  31),	// bright red
			Color.makeRgb( 49, 231,  34),	// bright green
			Color.makeRgb(234, 236,  35),	// yellow
			Color.makeRgb( 88,  51, 255),	// bright blue
			Color.makeRgb(249,  53, 248),	// bright magenta
			Color.makeRgb( 20, 240, 240),	// bright cyan
			Color.makeRgb(233, 235, 235)	// white
		]
	}

	private static Color[] palettePutty() {
		Color?[
			Color.makeRgb(  0,   0,   0),	// black
			Color.makeRgb(187,   0,   0),	// red
			Color.makeRgb(  0, 187,   0),	// green
			Color.makeRgb(187, 187,   0),	// brown/yellow
			Color.makeRgb(  0,   0, 187),	// blue
			Color.makeRgb(187,   0, 187),	// magenta
			Color.makeRgb(  0, 187, 187),	// cyan
			Color.makeRgb(187, 187, 187),	// grey
			Color.makeRgb( 85,  85,  85),	// dark grey
			Color.makeRgb(255,  85,  85),	// bright red
			Color.makeRgb( 85, 255,  85),	// bright green
			Color.makeRgb(255, 255,  85),	// yellow
			Color.makeRgb( 85,  85, 255),	// bright blue
			Color.makeRgb(255,  85, 255),	// bright magenta
			Color.makeRgb( 85, 255, 255),	// bright cyan
			Color.makeRgb(255, 255, 255)	// white
		]
	}

	private static Color[] paletteXterm() {
		Color[
			Color.makeRgb(  0,   0,   0),	// black
			Color.makeRgb(205,   0,   0),	// red
			Color.makeRgb(  0, 205,   0),	// green
			Color.makeRgb(205, 205,   0),	// brown/yellow
			Color.makeRgb(  0,   0, 238),	// blue
			Color.makeRgb(205,   0, 205),	// magenta
			Color.makeRgb(  0, 205, 205),	// cyan
			Color.makeRgb(229, 229, 229),	// grey
			Color.makeRgb(127, 127, 127),	// dark grey
			Color.makeRgb(255,   0,   0),	// bright red
			Color.makeRgb(  0, 255,   0),	// bright green
			Color.makeRgb(255, 255,   0),	// yellow
			Color.makeRgb(  92, 92, 255),	// bright blue
			Color.makeRgb(255,   0, 255),	// bright magenta
			Color.makeRgb(  0, 255, 255),	// bright cyan
			Color.makeRgb(255, 255, 255)	// white
		]
	}

	private const Color?[]	palette

	** Selects the palette according to your OS:
	**  - XP for Windows, 
	**  - Mac for sad people, 
	**  - XTerm for everyone else.
	static new make() {
		if (Env.cur.os == "win32")
			return AnsiPalette(paletteXp)
		if (Env.cur.os == "macosx")
			return AnsiPalette(paletteMac)
		return AnsiPalette(paletteXterm)
	}

	** Creates a standard VGA palette.
	static AnsiPalette vga() {
		AnsiPalette(paletteVga)
	}

	** Creates an XP CMD prompt palette.
	static AnsiPalette xp() {
		AnsiPalette(paletteXp)
	}

	** Creates a Mac Terminal palette.
	static AnsiPalette mac() {
		AnsiPalette(paletteMac)
	}

	** Creates a Putty palette.
	static AnsiPalette putty() {
		AnsiPalette(palettePutty)
	}

	** Creates an XTerm palette.
	static AnsiPalette xterm() {
		AnsiPalette(paletteXterm)
	}

	private static const Int[] _safeVals := [0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF]

	private new makeWithPalette(Color[] palette) {
		if (palette.size < 16)
			throw ArgErr("Palette size too small: ${palette.size}")

//		echo("----")
		palette = palette.rw
		palette.capacity = 256
		// 6x6x6 color matrix
		(16..231).each |i| {
			color	:= i - 16
			blue	:= _safeVals[color % 6]
			color	 = color / 6
			green	:= _safeVals[color % 6]
			color	 = color / 6
			red		:= _safeVals[color % 6]
//			echo("$i - ${Color.makeRgb(red, green, blue)}".upper)
			palette.add(Color.makeRgb(red, green, blue))
		}

//		echo("----")
		// greyscale
		(232..255).each |i| {
			// add the 5 offset so the min is #555555 and the max is #FAFAFA
			// user can then use std black and white to give a 26 colour greyscale 
			grey := ((i - 232) * 256 / 24) + 5
//			echo("$i - ${Color.makeRgb(grey, grey, grey)}".upper)
			palette.add(Color.makeRgb(grey, grey, grey))
		}

		this.palette = palette
	}
	
	** Gets the colour associated with the given index.
	** 'index' should be in the range of 0..255
	@Operator
	Color get(Int index) {
		palette[index]
	}
	
	** Converts the given colour to its nearest in the palette.
	Color safe(Color col) {
		err  := |Color c1, Color c2 -> Int| { safeErr(c1, col) <=> safeErr(c2, col) }
		std  := (0..15).toList.map { palette[it] }.min(err)
		cube := Color.makeRgb(safeVal(col.r), safeVal(col.g), safeVal(col.b))
		grey := (232..255).toList.map { palette[it] }.min(err)
		return [std, cube, grey].min(err)
	}

	** Returns the palette index of the given colour. 
	** Note the colour is first converted to a *safe* colour to ensure this method 
	** always returns a value.
	Int index(Color colour) {
		palette.index(safe(colour))
	}
	
	private Int safeErr(Color c1, Color c2) {
		(c1.r - c2.r).abs + (c1.g - c2.g).abs + (c1.b - c2.b).abs
	}

	private Int safeVal(Int v) {
		_safeVals.min |p1, p2| { (p1 - v).abs <=> (p2 - v).abs }
	}
}

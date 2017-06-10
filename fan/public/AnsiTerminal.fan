using fwt
using gfx

** ANSI Terminal FWT Widget.
class AnsiTerminal {

	** The underlying `RichText` widget. 
	RichText	richText
	
	** Default style to use when the ANSI reset command is printed.
	const RichTextStyle defStyle
	
	** Default style to use when printing errors.
	const RichTextStyle errStyle
	
	** The palette to use when printing indexed colours.
	const AnsiPalette ansiPalette
	
	private AnsiModel	_ansiModel
	private AnsiPrinter	_ansiPrinter

	** Standard it-block ctor. Use to set the styles and palette:
	** 
	** pre>
	** syntax: fantom
	** terminal := AnsiTerminal {
	**     defStyle = RichTextStyle { ... }
	**     errStyle = RichTextStyle { ... }
	**     palette  = AnsiPalette.putty
	** }
	** <pre
	new make(|This| f) {
		defFont		:= Font { name = "monospace"; size = 10 }
		defFg		:= Color(0xCFCFCF)
		defBg		:= Color(0x202020)
		defFgErr	:= Color(0xFF3333)
		
		this.defStyle		= RichTextStyle { fg = defFg   ; bg = defBg; font = defFont }
		this.errStyle		= RichTextStyle { fg = defFgErr; bg = defBg; font = defFont }
		this.ansiPalette	= AnsiPalette()

		// let the it-block override the styles
		f(this)
		
		this._ansiModel 	= AnsiModel(this.defStyle)

		richText = RichText() {
			it.border	= false
			it.editable	= false	// luckily we still get all the events!
			it.fg		= this.defStyle.fg
			it.bg		= this.defStyle.bg
			it.font		= this.defStyle.font
			it.model 	= _ansiModel.richTextModel
		}
		
		_ansiModel.richText = this.richText
		
		_ansiPrinter = AnsiPrinter {
			it.palette	= this.ansiPalette
			it.model	= _ansiModel
			it.defStyle	= this.defStyle
			it.errStyle	= this.errStyle
		}
	}
	
	
	
	// ---- Widget Methods ------------------------------------------------------------------------	
	
	** The terminals current caret position.
	Point caretPos() {
		_ansiModel.caretPos
	}
	
	** The carets current character offset.
	Int caretOffset() {
		_ansiModel.caretOffset
	}
	
	** The terminals current text.
	Str text() {
		_ansiModel.text
	}
	
	** A best guess as to the number of columns that are visible on the screen.
	Int cols() {
		richText.bounds.w / richText.font.width("W") - 4
	}

	** A best guess as to the number of rows that are visible on the screen.
	Int rows() {
		(richText.bounds.h / richText.font.height  ) - 4
	}

	
	
	// ---- Print Methods -------------------------------------------------------------------------

	** Prints the given object; usually a 'Str' or an 'AnsiBuf'.
	This print(Obj? str) {
		_ansiPrinter.print(str).flush
		return this
	}

	** Prints the given object; usually a 'Str' or an 'AnsiBuf'.
	This printErr(Obj? str) {
		_ansiPrinter.printErr(str).flush
		return this
	}
	
	** Convenience for:
	** 
	**   syntax: fantom
	**   terminal.print(AnsiBuf().clearScreen.toAnsi) 
	This clear() {
		_ansiPrinter.print(AnsiBuf().clearScreen.toAnsi).flush
		return this		
	}
}

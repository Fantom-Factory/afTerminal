using fwt::RichTextStyle

@NoDoc
class AnsiTester {

	private AnsiModel	ansiModel
	private AnsiPrinter	ansiPrinter

	RichTextStyle defStyle	:= RichTextStyle()
	RichTextStyle errStyle	:= RichTextStyle()
	
	new make(|This| in) {
		in(this)
		ansiModel	= AnsiModel(defStyle)
		ansiPrinter	= AnsiPrinter {
			it.palette	= AnsiPalette()
			it.model	= ansiModel
			it.defStyle	= this.defStyle
			it.errStyle	= this.errStyle
		}
	}
	
	Void print(Str str) {
		ansiPrinter.print(str)
	}

	Void printErr(Str str) {
		ansiPrinter.printErr(str)
	}
	
	Str lastLineText() {
		ansiModel.richTextModel.line(ansiModel.richTextModel.lineCount - 1)
	}

	Obj[]? lastLineStyling() {
		ansiModel.richTextModel.lineStyling(ansiModel.richTextModel.lineCount - 1)
	}
	
	Str text() {
		ansiModel.text
	}
}

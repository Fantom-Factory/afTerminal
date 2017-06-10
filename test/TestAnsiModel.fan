using fwt::RichTextStyle

internal class TestAnsiModel : Test {
	
	AnsiModel?		model
	AnsiPalette?	pal
	
	override Void setup() {
		pal		= AnsiPalette.xp
		model	= AnsiModel(AnsiTerminal().defStyle)
	}
	
	Void testClearToEnd() {
		model.newLine

		verifyEq(model.currentLine.styling.size, 2)
		verifyEq(model.currentLine.textStr, "")

		model.addStr("prompt> ")
		model.setFg(pal[1])
		model.addStr("error")
		model.setFg(pal[2])
		model.caretLeft(5)

		verifyEq(model.currentLine.styling.size, 6)
		verifyEq(model.currentLine.textStr, "prompt> error")

		model.clearLineToEnd

		verifyEq(model.currentLine.styling.size, 2)
		verifyEq(model.currentLine.textStr, "prompt> ")		
	}
}

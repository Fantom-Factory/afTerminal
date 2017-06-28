
internal class TestAnsiPrompt : Test {
	AnsiTester? printer
	
	override Void setup() {
		printer = AnsiTester()
	}
	
	Void testPrompt() {
		output {
			print("C:\\> ")
			curSave
			
			curRestore; clearLineToEnd; print("h")
			curRestore; clearLineToEnd; print("hel")
			curRestore; clearLineToEnd; print("hell")
			curRestore; clearLineToEnd; print("hello")
			curRestore; clearLineToEnd; print("hello!")
		} 

		verifyText("C:\\> hello!")
	}
	
	Void output(|AnsiBuf| f) {
		b := AnsiBuf()
		f(b)
		printer.print(b)
	}
	
	Void verifyText(Str text) {
		verifyEq(text, printer.text)
	}
}

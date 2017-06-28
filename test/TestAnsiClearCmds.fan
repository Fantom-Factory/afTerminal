
internal class TestAnsiClearCmds : Test {
	AnsiTester? printer
	
	override Void setup() {
		printer = AnsiTester()
	}
	
	Void testClearScreen() {
		print { it.print("#####\n#####\n#####\n##") } 
		verifyText("#####\n#####\n#####\n##")

		print { it.clearScreen } 
		verifyText("")
	}
	
	Void testClearLine() {
		print { it.print("#####\n#####\n##") } 
		verifyText("#####\n#####\n##")

		print { it.clearLine } 
		verifyText("#####\n#####\n  ")
	}

	Void testClearLineToStart() {
		print { it.print("#####\n###==") } 
		verifyText("#####\n###==")

		print { it.curLeft(2).clearLineToStart } 
		verifyText("#####\n   ==")
	}
	
	Void testClearLineToEnd() {
		print { it.print("#####\n###==") } 
		verifyText("#####\n###==")

		print { it.curLeft(2).clearLineToEnd } 
		verifyText("#####\n###")
	}
	
	Void print(|AnsiBuf| f) {
		b := AnsiBuf()
		f(b)
		printer.print(b)
	}
	
	Void verifyText(Str text) {
		verifyEq(text, printer.text)
	}
}

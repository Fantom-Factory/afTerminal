
internal class TestAnsiCursorCmds : Test {
	AnsiTester? printer
	
	override Void setup() {
		printer = AnsiTester()
	}
	
	Void testOneLine() {
		printer.print("Hello!")
		verifyText("Hello!")
	}
	
	Void testTwoLines() {
		printer.print("Hello\nMum!")
		verifyText("Hello\nMum!")
	}
	
	Void testCurUp() {
		print { it.print("#####\n#####\n#####\n##").curUp.print("-") } 
		verifyText("#####\n#####\n##-###\n##")

		print { it.curUp(2).print("=") } 
		verifyText("###=##\n#####\n##-###\n##")

		print { it.curUp(0) } 
		verifyText("###=##\n#####\n##-###\n##")
		print { it.curUp(null) } 
		verifyText("###=##\n#####\n##-###\n##")
	}

	Void testCurDown() {
		print { it.print("#####\n#####\n#####\n##").curUp(3).curDown.print("-") } 
		verifyText("#####\n##-###\n#####\n##")

		print { it.curDown(2).print("=") } 
		verifyText("#####\n##-###\n#####\n## =")

		print { it.curDown(0) } 
		verifyText("#####\n##-###\n#####\n## =")
		print { it.curDown(null) } 
		verifyText("#####\n##-###\n#####\n## =")
	}

	Void testCurLeft() {
		print { it.print("#####").curLeft.print("-") } 
		verifyText("####-#")

		print { it.curLeft(2).print("=") } 
		verifyText("###=#-#")

		print { it.curLeft(0) } 
		verifyText("###=#-#")
		print { it.curLeft(null) } 
		verifyText("###=#-#")
	}
	
	Void testCurRight() {
		print { it.print("#####").curLeft(5).curRight.print("-") } 
		verifyText("#-####")

		print { it.curRight(2).print("=") } 
		verifyText("#-##=##")

		print { it.curRight(0) } 
		verifyText("#-##=##")
		print { it.curRight(null) } 
		verifyText("#-##=##")
	}

	Void testCurHorizontal() {
		print { it.print("#####").curHorizonal.print("-") } 
		verifyText("-#####")

		print { it.curHorizonal(3).print("=") } 
		verifyText("-#=####")

		print { it.curHorizonal(0) } 
		verifyText("-#=####")
		print { it.curHorizonal(null) } 
		verifyText("-#=####")
	}
	
	Void testCurHome() {
		print { it.print("#####").curHome.print("-") } 
		verifyText("-#####")

		print { it.curHome.print("=") } 
		verifyText("=-#####")
	}
	
	Void testCurEnd() {
		print { it.print("#####").curHome.curEnd.print("-") } 
		verifyText("#####-")

		print { it.curHome.curEnd.print("=") } 
		verifyText("#####-=")
	}

	Void testCurSaveRestore() {
		print { it.print("##").curRestore }	// test curRestore is safe if no curSave 
		verifyText("##")

		print { it.curSave.print("##") } 
		verifyText("####")

		print { it.curRestore.print("--") } 
		verifyText("##--##")

		print { it.curRestore.print("==") } 
		verifyText("##==--##")
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

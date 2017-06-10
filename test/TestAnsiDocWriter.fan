using fandoc

class TestAnsiDocWriter : Test {
	
	Void testLineSplit() {
		lines := Str[,]

		lines = write("xxxx", 5)
		verifyEq(lines, ["xxxx"])

		lines = write("xxxxx", 5)
		verifyEq(lines, ["xxxxx"])

		lines = write("xxxxxx", 5)
		verifyEq(lines, ["xxxxxx"])

		lines = write("xxx xxx", 5)
		verifyEq(lines, ["xxx", "xxx"])

		lines = write("xxxxx x", 5)
		verifyEq(lines, ["xxxxx", "x"])

		lines = write("xxxx x", 5)
		verifyEq(lines, ["xxxx", "x"])

		lines = write("x x x x x x", 6)
		verifyEq(lines, ["x x x", "x x x"])
	}
	
	Void testPre() {
		lines := Str[,]

		lines = write("  xxxx", 10)
		verifyEq(lines, ["  xxxx"])		
	}
	
	private Str[] write(Str str, Int maxWidth) {
		buf := AnsiBuf()
		FandocParser().parseStr(str).write(AnsiDocWriter(buf, maxWidth))
		return buf.toAnsi.trimEnd.splitLines
	}
}

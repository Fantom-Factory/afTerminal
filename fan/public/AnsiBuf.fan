using fandoc
using gfx::Color

** Generates a sequence of ANSI escape codes.
** 
** TODO create a tput command that takes escape aliases - see http://linuxcommand.org/lc3_adv_tput.php
class AnsiBuf {
	
	public static const Int ESC	:= 0x1B
	
	private StrBuf	buf		:= StrBuf()
	private Bool	inSgr	:= false
	
	new make(Str? str := null) {
		if (str != null)
			buf.add(str)
	}
	
	** Writes the *Control Sequence Initiator*, the chars 'ESC['.
	This csi() {
		endSgr.addChar(ESC).addChar('[')
		return this
	}
	
	** Passing in '0' or 'null' does nothing. 
	This curUp(Int? rows := 1) {
		if (rows == null || rows == 0)	return this
		if (rows < 0 || rows > 0xFF)
			throw ArgErr("Invalid row: 0..0xFF != $rows")
		return csi.add(rows.toStr).addChar('A')
	}

	** Passing in '0' or 'null' does nothing. 
	This curDown(Int? rows := 1) {
		if (rows == null || rows == 0)	return this
		if (rows < 0 || rows > 0xFF)
			throw ArgErr("Invalid row: 0..0xFF != $rows")
		return csi.add(rows.toStr).addChar('B')
	}

	** Passing in '0' or 'null' does nothing. 
	This curLeft(Int? cols := 1) {
		if (cols == null || cols == 0)	return this
		if (cols < 0 || cols > 0xFF)
			throw ArgErr("Invalid column: 0..0xFF != $cols")
		return csi.add(cols.toStr).addChar('D')
	}

	** Passing in '0' or 'null' does nothing. 
	This curRight(Int? cols := 1) {
		if (cols == null || cols == 0)	return this
		if (cols < 0 || cols > 0xFF)
			throw ArgErr("Invalid column: 0..0xFF != $cols")
		return csi.add(cols.toStr).addChar('C')
	}

	** Note that ANSI standards state that 'column' is 1 based, so 'curHorizonal(1)' returns the cursor to the start of the line.
	** Passing in '0' or 'null' does nothing. 
	This curHorizonal(Int? column := 1) {
		if (column == null || column == 0)	return this
		if (column < 1 || column > 0xFF)
			throw ArgErr("Invalid column: 0..0xFF != $column")
		return csi.add(column.toStr).addChar('G')
	}

	** Moves the cursor to the start of the current line.
	** 
	** Note this is a Fish extension - not an ANSI standard.
	** 
	**   ansi-sequence: ESC[v
	This curHome() {
		csi.addChar('v')
	}

	** Moves the cursor to the end of the current line.
	** 
	** Note this is a Fish extension - not an ANSI standard.
	** 
	**   ansi-sequence: ESC[w
	This curEnd() {
		// TODO Linux Terminal - replace curEnd() with something portable (so we can use a non-Fantom terminal)
		csi.addChar('w')
	}

	** Saves the cursor position - both horizontal and vertical. 
	** 
	**   ansi-sequence: ESC[s
	This curSave() {
		csi.addChar('s')
	}
	
	** Restores the cursor position - both horizontal and vertical.
	** Does nothing if a cursor position has not yet been saved. 
	** 
	**   ansi-sequence: ESC[u
	This curRestore() {
		csi.addChar('u')		
	}

	** Clears the screen.
	** 
	**   ansi-sequence: ESC[2J
	This clearScreen() {
		csi.addChar('2').addChar('J')		
	}
	
	** Clears the current line.
	** The cursor position is unaffected. 
	This clearLine() {
		csi.addChar('2').addChar('K')
	}
		
	This clearLineToStart() {
		csi.addChar('1').addChar('K')
	}
		
	This clearLineToEnd() {
		csi.addChar('0').addChar('K')
	}
		
	This reset() {
		endSgr.addChar(ESC).addChar('[').addChar('m')
		return this
	}

	This fgRgb(Int? rgb) {
		if (rgb == null)	return this
		if (rgb < 0 || rgb > 0xFF_FF_FF)
			throw ArgErr("Invalid colour index: 0..0xFFFFFF != $rgb")
		c := Color(rgb)
		startSgr.addChar('3').addChar('8').addChar(';').addChar('2').addChar(';').add(c.r.toStr).addChar(';').add(c.g.toStr).addChar(';').add(c.b.toStr)
		return this
	}

	This fg(Color? col) {
		if (col == null)	return this
		startSgr.addChar('3').addChar('8').addChar(';').addChar('2').addChar(';').add(col.r.toStr).addChar(';').add(col.g.toStr).addChar(';').add(col.b.toStr)
		return this
	}

	This fgIdx(Int? i) {
		if (i == null)	return this
		if (i < 0 || i > 255)
			throw ArgErr("Invalid colour index: 0..255 != $i")
		startSgr.addChar('3').addChar('8').addChar(';').addChar('5').addChar(';').add(i.toStr)
		return this
	}

	This fgReset() {
		startSgr.addChar('3').addChar('9')
		return this
	}

	This bgRgb(Int? rgb) {
		if (rgb == null)	return this
		if (rgb < 0 || rgb > 0xFF_FF_FF)
			throw ArgErr("Invalid colour index: 0..0xFFFFFF != $rgb")
		c := Color(rgb)
		startSgr.addChar('4').addChar('8').addChar(';').addChar('2').addChar(';').add(c.r.toStr).addChar(';').add(c.g.toStr).addChar(';').add(c.b.toStr)
		return this
	}

	This bg(Color? col) {
		if (col == null)	return this
		startSgr.addChar('4').addChar('8').addChar(';').addChar('2').addChar(';').add(col.r.toStr).addChar(';').add(col.g.toStr).addChar(';').add(col.b.toStr)
		return this
	}

	This bgIdx(Int? i) {
		if (i == null)	return this
		if (i < 0 || i > 255)
			throw ArgErr("Invalid colour index: 0..255 != $i")
		startSgr.addChar('4').addChar('8').addChar(';').addChar('5').addChar(';').add(i.toStr)
		return this
	}

	This bgReset() {
		startSgr.addChar('4').addChar('9')
		return this
	}

	This bold(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('1')
		else
			startSgr.addChar('2').addChar('1')
		return this
	}

	This italic(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('3')
		else
			startSgr.addChar('2').addChar('3')
		return this
	}

	This underline(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('4')
		else
			startSgr.addChar('2').addChar('4')
		return this
	}

	This crossedOut(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('9')
		else
			startSgr.addChar('2').addChar('9')
		return this
	}

	This conceal(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('8')
		else
			startSgr.addChar('2').addChar('8')
		return this
	}

	** Optimized implementation for 'print(ch.toChar)'.
	This printChar(Int ch) {
		endSgr.addChar(ch)
		return this
	}

	** Adds 'x.toStr' to the end of this buffer. If 'x' is null then the string "null" is added.
	This print(Obj? x := "") {
		endSgr.add(x)
		return this
	}

	** Adds 'x.toStr + "\n"' to the end of this buffer. If 'x' is null then the string "null" is added.
	This printLine(Obj? x := "") {
		endSgr.add(x).addChar('\n')
		return this
	}

	** Prints the given fandoc string to the buffer, converting bold and italic formatting to their 
	** ANSI representation.
	** 
	** If 'maxWidth' is given then all text is wrapped at that width.
	** 
	** TIP: Pass the terminal column width as 'maxWidth' to ensure all text is visible on screen.   
	This printFandoc(Str fandoc, Int? maxWidth := null) {
		endSgr
		FandocParser().parseStr(fandoc).write(AnsiDocWriter(this, maxWidth))
		return this
	}

	** Convenience for "printChar('\n')".
	This newLine() {
		endSgr.addChar('\n')
		return this
	}
	
	** Convenience for "printChar('\b')".
	This backspace() {
		endSgr.addChar('\b')
		return this		
	}
		
	** Returns the contents of this ANSI buffer as a string.
	Str toAnsi() {
		endSgr.toStr
	}

	** Clear the contents of the string buffer so that is has a size of zero. Return this.
	This clear() {
		buf.clear
		inSgr = false
		return this
	}
		
	** Returns the number of chars in the buf.
	Int size() {
		buf.size
	}
	
	// ---- Convenience methods -----------------------------------------------
		
	** Convenience for 'printChar()'.
	This addChar(Int ch) {
		printChar(ch)
	}

	** Convenience for 'printChar()'.
	This writeChar(Int ch) {
		printChar(ch)
	}
		
	** Convenience for 'print()'.
	This write(Obj? x) {
		print(x)
	}

	** Convenience for 'print()'.
	This add(Obj? x) {
		print(x)
	}

	// ---- Private Stuff  ----------------------------------------------------

	private StrBuf startSgr() {
		if (inSgr)
			buf.addChar(';')
		else
			csi
		inSgr = true
		return buf
	}

	private StrBuf endSgr() {
		if (inSgr)
			buf.addChar('m')
		inSgr = false
		return buf
	}
	
	** Returns 'toAnsi()'.
	override Str toStr() {
		toAnsi
	}

	** Returns a copy of this ANSI string with all the escape codes and non-printable characters removed.
	Str toPlain() {
		removeEscapeCodes(endSgr.toStr)
	}
	
	** Removes all escape codes and non-printable characters from the given string.
	static Str removeEscapeCodes(Str str) {
		expect := expectNothing
		newStr := StrBuf()

		printChar := |Int char| {
			// continue an escape sequence
			if (expect > expectNothing) {
				if (expect == expectCsi) {
					if (char != '[') {
						// nothing we can do, except keep calm and carry on
						expect = expectNothing
						return
					}
					expect = expectCsiCmd
					return
				}
				
				if (expect == expectCsiCmd) {
					if (char.isDigit) {
						return
					}
					if (char == ';') {
						return
					}
					if (char == 'm') {
						expect = expectNothing
						return
					}
	
					// nothing we can do, except keep calm and carry on
					expect = expectNothing
					return
				}
			}
			
			// the start of an escape sequence
			if (char == '\u001b') {
				expect = expectCsi
				return
			}
			
			newStr.addChar(char)
		}

		str.each { printChar(it) }
		
		return newStr.toStr
	}
	
	private static const Int expectNothing	:=	0
	private static const Int expectCsi		:=	1
	private static const Int expectCsiCmd	:=	2
}

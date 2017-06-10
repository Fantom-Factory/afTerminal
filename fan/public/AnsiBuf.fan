using fandoc
using gfx::Color

// TODO create a tput command that takes escape aliases - see http://linuxcommand.org/lc3_adv_tput.php
** Generates a sequence of ANSI escape codes.
** 
** Note that generated SGR command sequences are optimised where possible.
class AnsiBuf {
	
	** The 'ESC' char, '0x1B'.
	static const Int ESC	:= 0x1B
	
	private StrBuf	buf		:= StrBuf()
	private Bool	inSgr	:= false
	
	** Creates an 'AnsiBuf' instance , optionally with the given string / ANSI sequence.
	new make(Str? str := null) {
		if (str != null)
			buf.add(str)
	}
	
	** Writes the *Control Sequence Initiator*.
	** 
	**   ansi-sequence: ESC[
	This csi() {
		endSgr.addChar(ESC).addChar('[')
		return this
	}
	
	** Moves the cursor up a number of rows.
	** Passing in '0' or 'null' does nothing. 
	** 
	**   ansi-sequence: ESC[${rows}A
	This curUp(Int? rows := 1) {
		if (rows == null || rows == 0)	return this
		if (rows < 0 || rows > 0xFF)
			throw ArgErr("Invalid row: 0..0xFF != $rows")
		return csi.add(rows.toStr).addChar('A')
	}

	** Moves the cursor up a number of rows.
	** Passing in '0' or 'null' does nothing. 
	** 
	**   ansi-sequence: ESC[${rows}B
	This curDown(Int? rows := 1) {
		if (rows == null || rows == 0)	return this
		if (rows < 0 || rows > 0xFF)
			throw ArgErr("Invalid row: 0..0xFF != $rows")
		return csi.add(rows.toStr).addChar('B')
	}

	** Moves the cursor left a number of rows.
	** Passing in '0' or 'null' does nothing. 
	** 
	**   ansi-sequence: ESC[${cols}D
	This curLeft(Int? cols := 1) {
		if (cols == null || cols == 0)	return this
		if (cols < 0 || cols > 0xFF)
			throw ArgErr("Invalid column: 0..0xFF != $cols")
		return csi.add(cols.toStr).addChar('D')
	}

	** Moves the cursor right a number of rows.
	** Passing in '0' or 'null' does nothing. 
	** 
	**   ansi-sequence: ESC[${cols}C
	This curRight(Int? cols := 1) {
		if (cols == null || cols == 0)	return this
		if (cols < 0 || cols > 0xFF)
			throw ArgErr("Invalid column: 0..0xFF != $cols")
		return csi.add(cols.toStr).addChar('C')
	}

	** Moves the cursor to an absolute column position.
	** Note that ANSI standards state that 'column' is 1 based, so 'curHorizonal(1)' returns the cursor to the start of the line.
	** Passing in '0' or 'null' does nothing. 
	** 
	**   ansi-sequence: ESC[${col}G
	This curHorizonal(Int? column := 1) {
		if (column == null || column == 0)	return this
		if (column < 1 || column > 0xFF)
			throw ArgErr("Invalid column: 0..0xFF != $column")
		return csi.add(column.toStr).addChar('G')
	}

	** Moves the cursor to the start of the current line.
	** 
	**   ansi-sequence: ESC[v
	** 
	** Note this is an Alien-Factory extension - not an ANSI standard.
	This curHome() {
		// TODO Linux Terminal - this is not an ANSI standard (curHome) 
		csi.addChar('v')
	}

	** Moves the cursor to the end of the current line.
	** 
	**   ansi-sequence: ESC[w
	** 
	** Note this is an Alien-Factory extension - not an ANSI standard.
	This curEnd() {
		// TODO Linux Terminal - this is not an ANSI standard (curEnd) 
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
	** 
	**   ansi-sequence: ESC[2K
	This clearLine() {
		csi.addChar('2').addChar('K')
	}
		
	** Clears the current line from the cursor to the start.
	** The cursor position is unaffected. 
	** 
	**   ansi-sequence: ESC[1K
	This clearLineToStart() {
		csi.addChar('1').addChar('K')
	}
		
	** Clears the current line from the cursor to the end.
	** The cursor position is unaffected. 
	** 
	**   ansi-sequence: ESC[0K
	This clearLineToEnd() {
		csi.addChar('0').addChar('K')
	}
		
	** Resets text to:
	**  - default foreground colour
	**  - default background colour
	**  - non-bold
	**  - non-italics
	**  - no underline
	**  
	**   ansi-sequence: ESC[m
	This reset() {
		endSgr.addChar(ESC).addChar('[').addChar('m')
		return this
	}

	** Sets the foreground colour to the given RGB integer.
	** If 'null' is passed, this method does nothing.
	** 
	**  - bits 16-23 red
	**  - bits 8-15 green
	**  - bits 0-7 blue
	**  
	** For example orange would be '0xFF_A5_00'.
	** 
	**   ansi-sequence: ESC[38;2;${r};${g};${b}m
	This fgRgb(Int? rgb) {
		if (rgb == null) return this
		if (rgb < 0 || rgb > 0xFF_FF_FF)
			throw ArgErr("Invalid colour index: 0..0xFFFFFF != $rgb")
		return fg(Color(rgb))
	}

	** Sets the foreground colour to the given Color. Any alpha value is ignored.
	** If 'null' is passed, this method does nothing.
	**  
	**   ansi-sequence: ESC[38;2;${r};${g};${b}m
	This fg(Color? col) {
		if (col == null) return this
		startSgr.addChar('3').addChar('8').addChar(';').addChar('2').addChar(';').add(col.r.toStr).addChar(';').add(col.g.toStr).addChar(';').add(col.b.toStr)
		return this
	}

	** Sets the foreground colour to the given palette colour. (0..255)
	** If 'null' is passed, this method does nothing.
	**  
	**   ansi-sequence: ESC[38;5;${i}m
	This fgIdx(Int? i) {
		if (i == null)	return this
		if (i < 0 || i > 255)
			throw ArgErr("Invalid colour index: 0..255 != $i")
		startSgr.addChar('3').addChar('8').addChar(';').addChar('5').addChar(';').add(i.toStr)
		return this
	}

	** Resets the foreground colour to default.
	**  
	**   ansi-sequence: ESC[39m
	This fgReset() {
		startSgr.addChar('3').addChar('9')
		return this
	}

	** Sets the background colour to the given RGB integer.
	** If 'null' is passed, this method does nothing.
	** 
	**  - bits 16-23 red
	**  - bits 8-15 green
	**  - bits 0-7 blue
	**  
	** For example orange would be '0xFF_A5_00'.
	** 
	**   ansi-sequence: ESC[48;2;${r};${g};${b}m
	This bgRgb(Int? rgb) {
		if (rgb == null)	return this
		if (rgb < 0 || rgb > 0xFF_FF_FF)
			throw ArgErr("Invalid colour index: 0..0xFFFFFF != $rgb")
		return bg(Color(rgb))
	}

	** Sets the background colour to the given Color. Any alpha value is ignored.
	** If 'null' is passed, this method does nothing.
	**  
	**   ansi-sequence: ESC[48;2;${r};${g};${b}m
	This bg(Color? col) {
		if (col == null)	return this
		startSgr.addChar('4').addChar('8').addChar(';').addChar('2').addChar(';').add(col.r.toStr).addChar(';').add(col.g.toStr).addChar(';').add(col.b.toStr)
		return this
	}

	** Sets the background colour to the given palette colour (0..255).
	** If 'null' is passed, this method does nothing.
	**  
	**   ansi-sequence: ESC[48;5;${i}m
	This bgIdx(Int? i) {
		if (i == null)	return this
		if (i < 0 || i > 255)
			throw ArgErr("Invalid colour index: 0..255 != $i")
		startSgr.addChar('4').addChar('8').addChar(';').addChar('5').addChar(';').add(i.toStr)
		return this
	}

	** Resets the foreground colour to default.
	**  
	**   ansi-sequence: ESC[49m
	This bgReset() {
		startSgr.addChar('4').addChar('9')
		return this
	}

	** Turns bold on or off.
	**  
	**   ansi-sequence: ESC[1m or ESC[21m
	This bold(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('1')
		else
			startSgr.addChar('2').addChar('1')
		return this
	}

	** Turns italics on or off.
	**  
	**   ansi-sequence: ESC[3m or ESC[23m
	This italic(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('3')
		else
			startSgr.addChar('2').addChar('3')
		return this
	}

	** Turns underline on or off.
	**  
	**   ansi-sequence: ESC[4m or ESC[24m
	This underline(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('4')
		else
			startSgr.addChar('2').addChar('4')
		return this
	}

	** Turns crossed out on or off.
	**  
	**   ansi-sequence: ESC[4m or ESC[24m
	** 
	** Note this is represented by a squiggly underline in the ANSI Terminal.
	This crossedOut(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('9')
		else
			startSgr.addChar('2').addChar('9')
		return this
	}

	** Turns concealed text on or off.
	**  
	**   ansi-sequence: ESC[8m or ESC[28m
	** 
	** *Not implemented.*
	This conceal(Bool onOff := true) {
		if (onOff)
			startSgr.addChar('8')
		else
			startSgr.addChar('2').addChar('8')
		return this
	}

	** Optimised implementation for 'print(ch.toChar)'.
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

	** Convenience for printChar('\n').
	This newLine() {
		endSgr.addChar('\n')
		return this
	}
	
	** Convenience for printChar('\b').
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

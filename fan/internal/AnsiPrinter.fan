using gfx
using fwt

** 'OuStream' wannabe that processes ANSI escape sequences for 'FishEditor'.
** 
** @see `https://en.wikipedia.org/wiki/ANSI_escape_code`
** @see [XTerm Control Sequences]`http://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-Functions-using-CSI-_-ordered-by-the-final-character_s_`
internal class AnsiPrinter {
	
	static	private const Log log			:= AnsiPrinter#.pod.log
	static	private const Int expectNothing	:=	0
	static	private const Int expectCsi		:=	1
	static	private const Int expectCsiCmd	:=	2
	
			private Int			expect
			private Str[]		n		:= Str[,]
	
				AnsiPalette		palette
				AnsiModel		model
				RichTextStyle	defStyle
				RichTextStyle	errStyle

	new make(|This| f) { f(this) }
	
	This print(Obj? str := null) {
		if (str != null) {
			txt := str is AnsiBuf ? ((AnsiBuf) str).toAnsi : str.toStr
			txt.toStr.each {
				_printChar(it)
				// this is called after ever char in an escape sequence - not required, just after every printable char - maybe move to model.addChar()!
				model.decacheLineOffsets
			}
		}
		return this
	}
	
	This printErr(Obj? str := null) {
		if (str != null) {
			oldStyle := model.getStyle()
			model.setStyle(errStyle)
			print(str)
			model.setStyle(oldStyle)
		}
		return this
	}
	
	This flush() {
		model.flush
		return this
	}

	private Void _printChar(Int char) {
		// continue an escape sequence
		if (expect > expectNothing) {
			if (expect == expectCsi) {
				if (char != '[') {
					// nothing we can do, except keep calm and carry on
					log.warn("Invalid ANSI escape sequence 'ESC${char.toChar}'")
					expect = expectNothing
					return
				}
				expect = expectCsiCmd
				return
			}
			
			if (expect == expectCsiCmd) {
				// for ESC[?47h & ESC[?47l
				if (char.isDigit || char == '?') {
					num := n.pop
					n.push((num ?: "") + char.toChar)
					return
				}
				if (char == ';') {
					n.push("")
					return
				}
				if (char == 'm') {
					if (n.isEmpty)	n.push("0")
					processSgr(n)
					n.clear
					expect = expectNothing
					return
				}
				if ((char >= 'A' && char <= 'H') || char == 'J' || char == 'K' || char == 'S' || char == 'T' || (char >= 's' && char <= 'w')) {
					if (char == 'f')
						char = 'H'

					if (n.isEmpty) {
						if (char >= 'A' && char <= 'H')
							n.push("1")
	
						if (char == 'J' || char == 'K')
							n.push("0")

						if (char == 'S' || char == 'T')
							n.push("1")
					}
					
					processCsi(char, n)
					n.clear
					expect = expectNothing					
					return
				}

				// nothing we can do, except keep calm and carry on
				log.warn("Invalid ANSI escape sequence 'ESC[${char.toChar}'")
				expect = expectNothing
				return
			}
		}
		
		// the start of an escape sequence
		if (char == '\u001b') {
			expect = expectCsi
			return
		}
		
		model.addChar(char)
	}

	
	
	private Void processCsi(Int char, Str[] cmds) {
		try {
			n := (cmds.size > 0 && cmds[0][0] != '?') ? cmds.removeAt(0).toInt : null
			switch (char) {
				case 'A'	: model.caretUp(n)
				case 'B'	: model.caretDown(n)
				case 'C'	: model.caretRight(n)
				case 'D'	: model.caretLeft(n)
				case 'E'	: model.deltaY(-n)
				case 'F'	: model.deltaY(n)
				case 'G'	: 
					pos := 0.max(n-1) - model.caretX
					if (pos < 0)
						model.caretLeft(-pos)
					if (pos > 0)
						model.caretRight(pos)
				
				case 'H'	: // Cursor Position
				// CSI n ; m H
				// Moves the cursor to row n {\displaystyle n} n, column m {\displaystyle m} m. The
				// case 'I'	: // Print screen + options
					echo("TODO ANSI H")
					
				case 'J'	: // Erase Display
					if (n == null || n == 0)
						// TODO model.clearToEnd
						echo("TODO ANSI J")
					if (n == 1)
						// TODO model.clearToStart
						echo("TODO ANSI J")
					if (n == 2)
						model.clear
				case 'K'	: // Erase in Line
					if (n == null || n == 0)
						model.clearLineToEnd
					if (n == 1)
						model.clearLineToStart
					if (n == 2)
						model.clearLine
				case 'S'	: echo("TODO ANSI S")	// TODO Scroll Up
				case 'T'	: echo("TODO ANSI T")	// TODO Scroll Down
				case 'h'	: if (cmds.first == "?47")	{}	// TODO alt screen
				case 'l'	: if (cmds.first == "?47")	{}	// TODO normal screen
				case 's'	: model.caretSave
				case 'u'	: model.caretRestore 
				case 'v'	: model.caretHome	// Fish Extension - not a valid ANSI code
				case 'w'	: model.caretEnd 	// Fish Extension - not a valid ANSI code
				
				default:
					log.warn("Unknown ANSI CMD: ${char}")
			}
		} catch (Err err) {
			log.warn("Dodgy ANSI CMD: " + cmds.join(",") + "m - ${err.typeof} - ${err.msg}")
		}
	}
	
	// https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_codes
	// https://github.com/mihnita/ansi-econsole/blob/master/AnsiConsole/src/mnita/ansiconsole/utils/AnsiCommands.java
	// http://stackoverflow.com/questions/15682537/ansi-color-specific-rgb-sequence-bash
	private static const Int sgr_reset			:= 0
	private static const Int sgr_boldOn			:= 1
	private static const Int sgr_faintOn		:= 2	// not supported
	private static const Int sgr_italicOn		:= 3
	private static const Int sgr_underlineOn	:= 4
	private static const Int sgr_blinkSlow		:= 5	// not supported
	private static const Int sgr_blinkRapid		:= 6	// not supported
	private static const Int sgr_negativeOn		:= 7
	private static const Int sgr_concealOn		:= 8
	private static const Int sgr_crossedOutOn	:= 9

	private static const Int sgr_defaultFont	:= 10
	//											:= 11 - 20 // alt font
	
	private static const Int sgr_frakturFont	:= 20
	private static const Int sgr_boldOff		:= 21	// double underline?
	private static const Int sgr_faintOff		:= 22	// not bold / not faint - normal Intensity
	private static const Int sgr_italicOff		:= 23
	private static const Int sgr_underlineOff	:= 24
	private static const Int sgr_blinkOff		:= 25
	private static const Int sgr_reserved1		:= 26
	private static const Int sgr_negativeOff	:= 27
	private static const Int sgr_concealOff		:= 28
	private static const Int sgr_crossedOutOff	:= 29

	//											:= 30 - 37	// fg colour
	private static const Int sgr_extendedFg		:= 38		// 2;r;g;b 
	private static const Int sgr_defaultFg		:= 39
	//											:= 40 - 47 // bg colour
	private static const Int sgr_extendedBg		:= 48		// 2;r;g;b
	private static const Int sgr_defaultBg		:= 49

	private static const Int sgr_reserved2		:= 50
	private static const Int sgr_framedOn		:= 51
	private static const Int sgr_encircled		:= 52
	private static const Int sgr_overlinedOn	:= 53
	private static const Int sgr_framedOff		:= 54	// not framed / not encircled
	private static const Int sgr_overlinedOff	:= 55
	private static const Int sgr_reserved3		:= 56
	private static const Int sgr_reserved4		:= 57
	private static const Int sgr_reserved5		:= 58
	private static const Int sgr_reserved6		:= 59
	//											:=  90 -  97 // Hi intensity fg colour
	//											:= 100 - 107 // Hi intensity bg colour
	
	private Void processSgr(Str[] cmds) {
		try {
			while (cmds.size > 0) {
				cmd := cmds.removeAt(0).toInt
				switch (cmd) {
					case sgr_reset:
						model.setStyle(defStyle)
					
					case sgr_boldOn:
						model.setBold(true)
						// TODO bold doesn't do much, so increase the fg too - need to know the index though
					case sgr_boldOff:
						model.setBold(false)
					
					case sgr_italicOn:
						model.setItalic(true)
					case sgr_italicOff:
						model.setItalic(false)
					
					case sgr_underlineOn:
						model.setUnderline(RichTextUnderline.single)
					case sgr_underlineOff:
						model.setUnderline(RichTextUnderline.none)
					
					case sgr_crossedOutOn:
						model.setUnderline(RichTextUnderline.squiggle)
					case sgr_crossedOutOff:
						model.setUnderline(RichTextUnderline.none)
					
					case sgr_faintOn:
					case sgr_faintOff:
					case sgr_blinkSlow:
					case sgr_blinkRapid:
					case sgr_blinkOff:
					case sgr_negativeOn:
					case sgr_negativeOff:
					case sgr_concealOn:
					case sgr_concealOff:
					case sgr_framedOn:
					case sgr_framedOff:
					case sgr_overlinedOn:
					case sgr_overlinedOff:
					case sgr_encircled:
					case sgr_frakturFont:
					case sgr_reserved1:
					case sgr_reserved2:
					case sgr_reserved3:
					case sgr_reserved4:
					case sgr_reserved5:
					case sgr_reserved6:
						null?.toStr		// not supported

					case 30:
					case 31:
					case 32:
					case 33:
					case 34:
					case 35:
					case 36:
					case 37:
						model.setFg(palette[cmd-30])
					case sgr_defaultFg:
						model.setFg(defStyle.fg)
					case sgr_extendedFg:
						model.setFg(extendedColour(cmd, cmds))
					case 90:
					case 91:
					case 92:
					case 93:
					case 94:
					case 95:
					case 96:
					case 97:
						model.setFg(palette[cmd-90+7])
	
					case 40:
					case 41:
					case 42:
					case 43:
					case 44:
					case 45:
					case 46:
					case 47:
						model.setBg(palette[cmd-40])
					case sgr_defaultBg:
						model.setFg(defStyle.bg)
					case sgr_extendedBg:
						model.setBg(extendedColour(cmd, cmds))
					case 100:
					case 101:
					case 102:
					case 103:
					case 104:
					case 105:
					case 106:
					case 107:
						model.setBg(palette[cmd-100+7])
	
					default:
						log.warn("Unknown ANSI CMD: ${cmd}m")
				}
			}
		} catch (Err err) {
			log.warn("Dodgy ANSI CMD: " + cmds.join(",") + "m - ${err.typeof} - ${err.msg}")
		}
	}
	
	private Color? extendedColour(Int cmd, Str[] cmds) {
		if (cmds.isEmpty) {
			log.warn("Unknown ANSI CMD: ${cmd}m")
			return null
		}

		format := cmds.first.toInt
		if (format == 5) {
			if (cmds.size < 2) {
				log.warn("Unknown ANSI CMD: ${cmd};" + cmds.join(";") + "m")
				return null
			}
			cmds.removeAt(0)
			idx := cmds.removeAt(0).toInt
			return palette[idx]
		}

		if (format == 2) {
			if (cmds.size < 4) {
				log.warn("Unknown ANSI CMD: ${cmd};" + cmds.join(";") + "m")
				return null
			}
			cmds.removeAt(0)
			r := cmds.removeAt(0).toInt
			g := cmds.removeAt(0).toInt
			b := cmds.removeAt(0).toInt
			return Color.makeRgb(r, g, b)
		}
		
		log.warn("Unknown ANSI CMD: ${cmd};" + cmds.join(";") + "m")
		return null
	}	
}

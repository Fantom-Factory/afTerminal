using gfx
using fwt

internal class AnsiModel {
	internal static const Int fillChar	:= ' '	// change to 'X' to see where space is added when you cursor up and down
	
			Line[]	 		lines 		:= [,]
	private	StyleCache		styleCache	:= StyleCache()
	private RichTextStyle	defStyle
	 		RichText?		richText
	internal Int			caretX
	private Int				caretY
	private Int?			caretYMin
	private TextMods		textMods	:= TextMods()
	private Int[]?			caretCache
	private Log				log			:= Log.get("afFish.AnsiModel")
		AnsiRichTextModel	richTextModel

	new make(RichTextStyle defStyle) {
		this.defStyle		= defStyle
		this.richTextModel	= AnsiRichTextModel(this)
		this.lines.add(Line(styleCache, null).addStyle(0, defStyle))
		
//		richTextModel.onModify.add |e| { onMod(e.data)  }	// for Debugging
//		log.level = LogLevel.debug
	}

	// for Debugging - ensuring we sent the correct data to onModify
	private StrBuf buf := StrBuf()
	Void onMod(TextChange e) {
		echo("----")
		if (e.startOffset == buf.size)
			buf.add(e.newText)
		else {
			srt := e.startOffset
			end := e.startOffset + e.oldText.size
			buf.replaceRange(srt..<end, e.newText)
		}
		echo(buf)
		rep:= lines.join("\n") { it.textStr }
		echo("====")
		echo(rep)
	}
	
	Int noOfLines() {
		lines.size
	}
	
	** For testing only - model should encapsulate the lines
	Line currentLine() {
		lines[caretY]
	}
	
	Str text() {
		buf := StrBuf()
		lines.each { buf.add(it.textStr).addChar('\n') }
		return buf.toStr
	}

	Void flush() {
		log.debug("flush()")
		textMods.fire(richTextModel)
		richText.caretOffset = currentLine.offset + caretX			
		richText.showLine(caretY)
		// TODO richText.showColumn(caretX) or richText.scrollTo(x, y)
		// see http://help.eclipse.org/kepler/topic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/custom/StyledText.html#setHorizontalIndex(int)
	}
	
	Void clear() {
		log.debug("clear()")
		oldText  := this.text
		lines.clear
		lines.add(Line(styleCache, null).addStyle(0, defStyle))
		caretX = 0
		caretY = 0		
		textMods.clearAll(oldText)
	}

	Void addStr(Str str) {
		str.each { addChar(it) }
	}

	Void addChar(Int char) {
		if (log.isDebug) {
			if (char < 32 || char > 127) {
				if (char == 10)
					log.debug("addChar('\\n')")
				else
					log.debug("addChar(0x${char.toHex(2).upper})")
			} else
				log.debug("addChar('${char.toChar}')")
		}

		if (char == '\r') {
			// windows newline is '/r/n', also known as CR+LF (Carriage Return + Line Feed) 
			// but we can't honour the CR (=caretHome) because to honour Fantom's version of LF
			// (\n same as Unix and Mac) we split the line on LF, 
			// so /r/n just puts everything on the bottom line!
			// Ergo it's easier to just ignore CR
			return
		}

		if (char == '\f') {
			caretDown(1); return
		}
		
		if (char == '\n') {
			newLine; return
		}
		
		if (char == '\b') {
			// TODO delete \n and join lines - do for DEL too!
			if (caretX > 0) {
				caretX = caretX - 1
				del := currentLine.delChar(caretX)
				if (del != null)
					textMods.delChar(currentLine.offset + caretX, del)
			}
			return
		}

		if (char == 127) {	// DEL
			del := currentLine.delChar(caretX)
			if (del != null)
				textMods.delChar(currentLine.offset + caretX, del)
			return
		}

		// non-printable ASCII chars
		if (char < 32)
			return

		currentLine.addChar(caretX, char)
		textMods.addChar(currentLine.offset + caretX, char)
		caretX = caretX + 1
	}

	Void decacheLineOffsets() {
//		log.debug("decacheLineOffsets()")
		// TODO this gets called A LOT - re-think and optimise, or comment to say it's okay!
		if (caretYMin != null)
			// we only need to clear until we find the last cleared point
			(caretYMin..<lines.size).eachWhile { lines[it].clearOffset }
		caretYMin = null
	}

	Point caretPos() {
		Point(caretX, caretY)
	}
	
	Int caretOffset() {
		currentLine.offset + caretX
	}

	Void caretUp(Int n) {
		log.debug("caretUp(${n})")
		caretY = 0.max(caretY - n)
		currentLine.ensureSize(caretX, textMods)
		caretYMin = caretY.min(caretYMin ?: caretY)
	}
	
	Void caretDown(Int n) {
		log.debug("caretDown(${n})")
		caretY = (lines.size - 1).min(caretY + n)
		currentLine.ensureSize(caretX, textMods)
		caretYMin = caretY.min(caretYMin ?: caretY)
	}
	
	Void caretLeft(Int n) {
		log.debug("caretLeft(${n})")
		caretX = 0.max(caretX - n)
	}
	
	Void caretRight(Int n) {
		log.debug("caretRight(${n})")
		caretX = caretX + n
		currentLine.ensureSize(caretX, textMods)
	}
	
	Void caretSave() {
		log.debug("caretSave()")
		caretCache = [caretX, caretY]
	}

	** Does not clear the restore point, so may be called multiple times.
	** If there is no restore point, then does nothing.
	Void caretRestore() {
		log.debug("caretRestore() => ${caretCache}")
		cl := currentLine
		if (caretCache != null) {
			caretX = caretCache[0]
			caretY = caretCache[1]
		}
	}

	Void caretHome() {
		log.debug("caretHome()")
		caretX = 0
	}

	Void caretEnd() {
		log.debug("caretEnd()")
		caretX = currentLine.size
	}
	
	Void deltaY(Int n) {
		log.debug("deltaY(${n})")
		caretX = 0
		if (n < 0)	caretUp(n)
		if (n > 0)	caretDown(n)
	}
	
	Void clearLine() {
		log.debug("clearLine()")
		if (currentLine.size > 0) {
			str := "".padl(caretX, fillChar)
			textMods.delStr(currentLine.offset, currentLine.textStr)
			textMods.addStr(currentLine.offset, str)
			currentLine.replaceRange(0..caretX, str)
		}
	}

	Void clearLineToStart() {
		log.debug("clearLineToStart()")
		if (caretX > 0) {
			str := "".padl(caretX, fillChar)
			textMods.delStr(currentLine.offset, currentLine[0..<caretX])
			textMods.addStr(currentLine.offset, str)
			currentLine.replaceRange(0..caretX, str)
		}
	}
	
	Void clearLineToEnd() {
		log.debug("clearLineToEnd()")
		if (caretX < currentLine.size) {
			textMods.delStr(currentLine.offset + caretX, currentLine[caretX..-1])
			currentLine.replaceRange(caretX..-1, "")
		}
	}
	
	Line newLine() {
		log.debug("newLine()")
		textMods.addChar(currentLine.offset + caretX, '\n')

		currentLine.trimStyling
		newLine	:= currentLine.splitAt(caretX)
		
		nextLine := lines.getSafe(caretY + 1)
		if (nextLine != null)
			nextLine.prevLine = newLine
		
		lines.insert(caretY + 1, newLine)

		caretYMin = caretY.min(caretYMin ?: caretY)
		caretY = caretY + 1
		caretX = 0

		return newLine
	}
	
	RichTextStyle getStyle() {
		currentLine.getStyle(caretX)
	}

	Void setStyle(RichTextStyle style) {
		if (log.isDebug)
			log.debug("setStyle(${style})")
		currentLine.addStyle(caretX, style)
	}

	Void setFg(Color _it) {
		if (log.isDebug)
			log.debug("setFg(${_it})")
		currentLine.setFg(caretX, _it)
	}
	
	Void setBg(Color _it) {
		if (log.isDebug)
			log.debug("setBg(${_it})")
		currentLine.setBg(caretX, _it)
	}
	
	Void setBold(Bool _it) {
		if (log.isDebug)
			log.debug("setBold(${_it})")
		currentLine.setBold(caretX, _it)
	}

	Void setItalic(Bool _it) {
		if (log.isDebug)
			log.debug("setItalic(${_it})")
		currentLine.setItalic(caretX, _it)
	}

	Void setUnderline(RichTextUnderline _it) {
		if (log.isDebug)
			log.debug("setUnderline(${_it})")
		currentLine.setUnderline(caretX, _it)
	}
}

internal class Line {
			Line? prevLine
	private Int?  offsetCache
	
	** Zero based offset from start of document
	Int offset() {
		if (offsetCache == null)
			offsetCache = prevLine?.offsetEnd?.plus(1) ?: 0
		return offsetCache
	}

	** Text of line (without delimiter)
	private StrBuf text		:= StrBuf()

	** Offset/RichTextStyle pairs
	Obj[] styling	:= Obj[,] {
		private set
	}

	private StyleCache styleCache
	
	Void setFg(Int pos, Color _it) {
		style := getStyle(pos); if (style.fg != _it) setStyleBits(pos, _it, style.bg, style.font, style.underline)
	}
	
	Void setBg(Int pos, Color _it) {
		style := getStyle(pos); if (style.bg != _it) setStyleBits(pos, style.fg, _it, style.font, style.underline)
	}
	
	Void setBold(Int pos, Bool _it) {
		style := getStyle(pos); if (style.font.bold != _it) setStyleBits(pos, style.fg, style.bg, newFont(style.font, _it, null), style.underline) 			
	}

	Void setItalic(Int pos, Bool _it) {
		style := getStyle(pos); if (style.font.italic != _it) setStyleBits(pos, style.fg, style.bg, newFont(style.font, null, _it), style.underline)
	}

	Void setUnderline(Int pos, RichTextUnderline _it) {
		style := getStyle(pos); if (style.underline != _it) setStyleBits(pos, style.fg, style.bg, style.font, _it)
	}

	This addStyle(Int pos, RichTextStyle style) {
		i := 0
		while (i < styling.size) {
			offset := (Int) styling[i]
			if (offset == pos) {
				styling[i + 1] = style
				return this
			}
			if (offset > pos) {
				styling.insert(i, style)
				styling.insert(i, pos)
				return this
			}
			i+=2
		}
		// add style to the end
		styling.add(pos)
		styling.add(style)
		return this
	}

	new make(StyleCache styleCache, Line? prevLine) {
		this.styleCache = styleCache
		this.prevLine	= prevLine
	}
	
	Int offsetEnd() {
		offset + text.size
	}
	
	Str textStr() {
		text.toStr	// keeps text private
	}
	
	Int size() {
		text.size
	}
	
	Void clear() {
		this.text.clear
		this.styling.size = 0
	}
	
	Void debug() {
		echo(textStr)
		echo(styling)
	}
	
	@Operator
	Str get(Range range) {
		text.getRange(range)
	}
	
	Void replaceRange(Range r, Str str) {
		i := 0
		a := text.getRange(r).size + str.size
		s := r.start
		e := r.end
		
		if (e < 0 && e != -1)
			throw ArgErr("Invalid range $r")
		if (e == -1)
			e = text.size
		
		while (i < styling.size) {
			offset := (Int) styling[i]
			if (offset < r.start) {
				i += 2
			} else
			if (offset >= s && offset <= e) {
				styling.removeAt(i)
				styling.removeAt(i)
			} else
			{
				styling[i] = offset + a
				i += 2
			}
		}

		text.replaceRange(r, str)
	}

	** Called during normal typing
	Void modify(Int start, Int len, Str newText) {
		if (len > 0)
			text.replaceRange(start..<(start+len), newText)
		else
			text.insert(start, newText)
		trimStyling
	}

	Void addChar(Int pos, Int ch) {
		if (pos == text.size)
			text.addChar(ch)
		else {
			text.insert(pos, ch.toChar)
			
			i := 0
			while (i < styling.size) {
				offset := (Int) styling[i]
				if (offset >= pos)
					styling[i] = offset + 1
				i+=2
			}
		}
	}

	Int? delChar(Int pos) {
		if (pos >= text.size)
			return null

		del := text[pos]
		text.remove(pos)

		i := 0
		while (i < styling.size) {
			offset := (Int) styling[i]
			if (offset == pos) {
				styling.removeAt(i)
				styling.removeAt(i)
			} else {
				if (offset > pos) 
					styling[i] = offset - 1
				i+=2
			}
		}
		return del
	}
	
	** Return no of spaces added.
	Int ensureSize(Int caretX, TextMods textMods) {
		deficit := caretX - text.size
		if (deficit > 0) {
			str := "".padl(deficit, AnsiModel.fillChar)
			textMods.addStr(offsetEnd, str)
			text.add(str)
		}
		return 0.max(deficit)
	}
	
	Void detach() {
		prevLine = null
	}
	
	Obj? clearOffset() {
		if (offsetCache == null)
			return true
		offsetCache = null
		return null
	}
	
	Line splitAt(Int caretX) {
		newLine	:= Line(styleCache, this)
		newLine.text.add(text.getRange(caretX..-1))
		text.replaceRange(caretX..-1, "")
		
		// new lines reset to a default style - so copy any existing style over
		newLine.addStyle(0, getStyle(caretX))
		
		i := 0
		while (i < styling.size) {
			offset := (Int) styling[i]
			if (offset > caretX) {
				posit := (Int) styling.removeAt(i)
				style := styling.removeAt(i)
				newLine.addStyle(posit - caretX, style)
			} else
				i+=2
		}
		return newLine
	}

	override Str toStr() { text.toStr }

	RichTextStyle getStyle(Int pos) {
		lastStyle := null as RichTextStyle
		i := 0
		while (i < styling.size) {
			offset := (Int) styling[i]
			if (offset == pos)
				return styling[i + 1]
			if (offset > pos)
				break
			lastStyle = styling[i + 1]
			i+=2
		}
		
		if (lastStyle == null)
			lastStyle = prevLine?.lastStyle ?: throw Err("Could not find last style - ran out of lines!")
		
		return lastStyle
	}
	
	RichTextStyle lastStyle() {
		getStyle(text.size)
	}
	
	private Font? newFont(Font font, Bool? bold, Bool? italic) {
		bold	 = bold   ?: font.bold
		italic	 = italic ?: font.italic
		
		if (bold == font.bold && italic == font.italic)
			return font
		
		if (!bold && !italic)
			return font.toPlain
		if (bold && italic)
			return font.toBold.toItalic
		if (bold && !italic)
			return font.toPlain.toBold
		if (!bold && italic)
			return font.toPlain.toItalic

		throw Err("WTF: $font -> bold $bold -> italic $italic")
	}

	** We need to set them all because Font = bold + italic + font, we can't just switch on 'bold'
	private Void setStyleBits(Int pos, Color fg, Color bg, Font font, RichTextUnderline underline) {
		style := styleCache.get(fg, bg, font, underline)
		addStyle(pos, style)
	}	

	Void trimStyling() {
		max := 0
		while (max < styling.size && styling[max] <= text.size)
			max += 2
		styling.size = max
		styling.trim
	}
}

** I'm under the impression that 'RichTextModel.doModify()' takes a long time
internal class TextMods {
	private Obj[][]	mods	:= [,]
	
	Void addChar(Int pos, Int char) {
		addStr(pos, char.toChar)
	}

	Void addStr(Int pos, Str text) {
		if (text.isEmpty) throw Err("Text is \"\" @ $pos")
		// optimise calls to onModify() by updating the last event (if we can)
		mod := mods.last
		if (mod != null) {
			cmd := (Str)	mod[0]
			off := (Int)	mod[1]
			str := (StrBuf)	mod[2]
			if (cmd == "ADD") {
				if (pos == (off + str.size)) {
					str.add(text)
					return
				}
			}
		}
		mods.add(["ADD", pos, StrBuf().add(text)])
	}
	
	Void delChar(Int pos, Int char) {
		delStr(pos, char.toChar)
	}

	Void delStr(Int pos, Str text) {
		if (text.isEmpty) throw Err("Text is \"\" @ $pos")
		// optimise calls to onModify() by updating the last event (if we can)
		mod := mods.last
		if (mod != null) {
			cmd := (Str)	mod[0]
			off := (Int)	mod[1]
			str := (StrBuf)	mod[2]
			// TODO we could turn this into a mini text-ed so "add / del / add" only results in the one text mod - note it's more complicated than you first think!
			if (cmd == "DEL  ") {
				if (pos == (off - text.size)) {
					str.insert(0, text)
					mod[1] = pos
					return
				}
			}
		}
		mods.add(["DEL", pos, StrBuf().add(text)])
	}
	
	Void clearAll(Str oldText) {
		mods.add(["CLS", 0, StrBuf().add(oldText)])		
	}
	
	Void fire(AnsiRichTextModel model) {
		mods.each |mod| {
			cmd := (Str)	mod[0]
			pos := (Int)	mod[1]
			str := (StrBuf)	mod[2]

			if (cmd == "ADD")
				// TODO we sometimes get errs printed on line 0 - maybe set null instead of "" ?
				// NPE fwt::RichTextPeer.onModelModify (RichTextPeer.java:390)
				// FIXME EventListeners.fire() logs errs, have virtual onListenerErr(Err err) so we can override with custom behaviour --> err!? How to override!?
				model.doModify(pos, "", str.toStr)

			if (cmd == "DEL")
				model.doModify(pos, str.toStr, "")

			if (cmd == "CLS")
				model.clear(str.toStr)				
		}
		mods.clear
	}
}

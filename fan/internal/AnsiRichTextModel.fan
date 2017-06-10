using gfx
using fwt

internal class AnsiRichTextModel : RichTextModel {
	
	private AnsiModel ansiModel
	
	new make(AnsiModel ansiModel) {
		this.ansiModel = ansiModel
	}
	
	override Str text {
		get { ansiModel.text }
		set { throw UnsupportedErr("setText") }
	}

	override Int	charCount()				{ lines.isEmpty ? 0		: lines.last.offsetEnd	}
	override Int	lineCount()				{ lines.size									}
	override Str	line(Int index)			{ lines.isEmpty ? ""	: lines[index].textStr	}
	override Int	offsetAtLine(Int index)	{ lines.isEmpty ? 0		: lines[index].offset	}
	override Obj[]?	lineStyling(Int index)	{ lines.isEmpty ? null	: lines[index].styling	}
	override Int	lineAtOffset(Int offset) {
		line := lines.binaryFind |line, val| { (line.offset..line.offsetEnd).contains(offset) ? 0 : (offset <=> line.offsetEnd) }
		if (line < 0) {
			if (-line - 1 == lines.size)
				return lines.size
			else
				throw Err("Could not find line @ offset $offset, text size = ${text.size} :: ${-line-1} != ${lines.size}")
		}
		return line
	}
	
	override Void modify(Int start, Int len, Str newText) {
		oldText := textRange(start, len)
		lineIdx := lineAtOffset(start)
		line := lines[lineIdx]
		line.modify(start - line.offset, len, newText)
		doModify(start, oldText, newText, lineIdx)
	}
	
	internal Void doModify(Int startOffset, Str? oldText, Str? newText, Int? lineIdx := null) {
		startLine := lineIdx ?: lineAtOffset(startOffset)

		tc  := TextChange {
			it.startOffset	= startOffset
			it.startLine	= startLine
			it.oldText		= oldText
			it.newText		= newText			
		}
		this.onModify.fire(Event { id = EventId.modified; data = tc })
	}
	
	internal Void clear(Str oldText) {
		tc  := TextChange {
			it.startOffset	= 0
			it.startLine	= 0
			it.oldText		= oldText
			it.newText		= ""
			
			// a newNumNewlines of 0 generates fwt errors, so bump it up to 1
			// there is always 1 lines anyway, even if it's empty!
			if (newText == "")
				newNumNewlines = 1
			
			// we get an fwt index err(?) if 1!? - See AR Drone Intro screen
//			if (oldNumNewlines == 1)
//				oldNumNewlines = 0
			
			// Note it seems this is only required when clearing the screen - maybe something to do with multiple lines
			// further investigation required!
		}
		this.onModify.fire(Event { id = EventId.modified; data = tc })
	}
	
	private Line[] lines() {
		ansiModel.lines
	}
}

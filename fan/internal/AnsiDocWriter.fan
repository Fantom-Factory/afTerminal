using fandoc

internal class AnsiDocWriter : DocWriter {

	private AnsiBuf out
	private ListIndex[] listIndexes := [,]
	private Bool inBlockquote
	private Bool inPre
	private Bool inListItem
	private Int? maxWidth

	private	Str		line  := ""
	private	StrBuf	buf	  := StrBuf()

	new make(AnsiBuf out, Int? maxWidth) {
		this.out		= out
		this.maxWidth	= maxWidth
	}

	** Callback to perform link resolution and checking for
	** every Link element
	|Link link|? onLink := null

	** Callback to perform image link resolution and checking
	|Image img|? onImage := null

	override Void docStart(Doc doc) { }
	override Void docEnd  (Doc doc) { flush; out.print(line.trimEnd) }

	override Void elemStart(DocElem elem) {
		switch (elem.id) {
			case DocNodeId.emphasis:
				out.italic(true)

			case DocNodeId.strong:
				out.bold(true)

			case DocNodeId.code:
				writeChar('\'')

			case DocNodeId.link:
				link := (Link) elem
				onLink?.call(link)
				writeChar('[')

			case DocNodeId.image:
				img := (Image) elem
				onImage?.call(img)
				print("![${img.alt}")

			case DocNodeId.para:
				para := (Para) elem
				if (!listIndexes.isEmpty) {
					indent := listIndexes.size * 2
					newLine
					newLine
					print(Str.defVal.padl(indent))
				}

				if (inBlockquote)
					print("> ")
				if (para.admonition != null)
					print("${para.admonition}: ")
				if (para.anchorId != null)
					print("[#${para.anchorId}]")

			case DocNodeId.pre:
				inPre = true
				flush
				if (line.size > 0)
					newLine
				else {
					indentSize := (listIndexes.size * 2) + (inPre ? 2 : 0)
					out.print("".justl(indentSize))
				}

			case DocNodeId.blockQuote:
				inBlockquote = true

			case DocNodeId.unorderedList:
				listIndexes.push(ListIndex())
				if (listIndexes.size > 1)
					newLine

			case DocNodeId.orderedList:
				ol := (OrderedList) elem
				listIndexes.push(ListIndex(ol.style))
				if (listIndexes.size > 1)
					newLine

			case DocNodeId.listItem:
				indent := (listIndexes.size - 1) * 2
				print(Str.defVal.padl(indent))
				print(listIndexes.peek.toStr)
				listIndexes.peek.increment
				inListItem = true
		}
	}

	override Void elemEnd(DocElem elem) {
		switch (elem.id) {
			case DocNodeId.emphasis:
				out.italic(false)

			case DocNodeId.strong:
				out.bold(false)

			case DocNodeId.code:
				writeChar('\'')

			case DocNodeId.link:
				link := (Link) elem
				print("]`${link.uri}`")

			case DocNodeId.image:
				img := (Image) elem
				print("]`${img.uri}`")

			case DocNodeId.para:
				newLine
				newLine

			case DocNodeId.heading:
				head := (Heading) elem
				size := head.title.size
				if (head.anchorId != null) {
					print(" [#${head.anchorId}]")
					size += head.anchorId.size + 4
				}
				char := "#*=-".chars[head.level-1]
				line := Str.defVal.padl(size.max(3), char)
				newLine
				print(line)
				newLine

			case DocNodeId.pre:
				inPre = false

			case DocNodeId.blockQuote:
				inBlockquote = false

			case DocNodeId.unorderedList:
				listIndexes.pop
				if (listIndexes.isEmpty)
					newLine

			case DocNodeId.orderedList:
				listIndexes.pop
				if (listIndexes.isEmpty)
					newLine

			case DocNodeId.listItem:
				item := (ListItem) elem
				newLine
				inListItem = false
		}
	}

	override Void text(DocText text) {
		if (inPre) {
			if (!listIndexes.isEmpty)
				newLine
			text.str.splitLines.each {
				print(it)
				newLine
			}
			newLine
		} else {
			print(text.str)
		}
	}
	
	internal Void writeChar(Int ch) {
		buf.addChar(ch)
	}

	internal Void print(Str str) {		
		str.each |ch, i| {
			if (!ch.isSpace) {
				buf.addChar(ch)
				return
			}

			flush
			line += ch.toChar
		}
	}
	
	private Void newLine() {
		flush
		doNewLine
	}

	private Void flush() {
		if (maxWidth != null && (line.size + buf.size) > maxWidth && line.size > 0)
			doNewLine
		
		line += buf.toStr
		buf.clear
	}

	private Void doNewLine() {
		out.print(line.trimEnd)
		line = ""
		indentSize := (listIndexes.size * 2) + (inPre ? 2 : 0)
		out.writeChar('\n').print("".justl(indentSize))
	}
}

internal class ListIndex {
	private static const Int:Str romans	:= sortr([1000:"M", 900:"CM", 500:"D", 400:"CD", 100:"C", 90:"XC", 50:"L", 40:"XL", 10:"X", 9:"IX", 5:"V", 4:"IV", 1:"I"])

	OrderedListStyle? style
	Int index	:= 1

	new make(OrderedListStyle? style := null) {
		this.style = style
	}

	This increment() {
		index++
		return this
	}

	override Str toStr() {
		switch (style) {
			case null:
				return "- "
			case OrderedListStyle.number:
				return "${index}. "
			case OrderedListStyle.lowerAlpha:
				return "${toB26(index).lower}. "
			case OrderedListStyle.upperAlpha:
				return "${toB26(index).upper}. "
			case OrderedListStyle.lowerRoman:
				return "${toRoman(index).lower}. "
			case OrderedListStyle.upperRoman:
				return "${toRoman(index).upper}. "
		}
		throw Err("Unsupported List Style: $style")
	}

	private static Str toB26(Int int) {
		int--
		dig := ('A' + (int % 26)).toChar
		return (int >= 26) ? toB26(int / 26) + dig : dig
	}

	private static Str toRoman(Int int) {
		l := romans.keys.find { it <= int }
		return (int > l) ? romans[l] + toRoman(int - l) : romans[l]
	}

	private static Int:Str sortr(Int:Str unordered) {
		// no ordered literal map... grr...
		// http://fantom.org/sidewalk/topic/1837#c14431
		sorted := [:] { it.ordered = true }
		unordered.keys.sortr.each { sorted[it] = unordered[it] }
		return sorted
	}
}

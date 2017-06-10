    using gfx::Size
    using fwt::Window
    using afTerminal

    class Example {
        Void main() {
            term := AnsiTerminal()
            ansi := AnsiBuf()
                .fgIdx( 9).print("RED\n").reset
                .fgIdx(10).print("GREEN\n").reset
                .fgIdx(12).print("BLUE\n").reset
                .underline.print("Underline").reset

            Window {
                it.title = "ANSI Terminal"
                it.size = Size(320, 200)
                it.add(term.richText)
                it.onOpen.add |->| {
                    term.print(ansi)
                }
            }.open
        }
    }
    
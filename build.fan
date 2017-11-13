using build

class Build : BuildPod {

	new make() {
		podName = "afTerminal"
		summary = "ANSI Terminal FWT Widget"
		version = Version("0.9.1")

		meta = [
			"pod.dis"		: "ANSI Terminal",
			"repo.tags"		: "fwt",
			"repo.public"	: "true",
		]

		depends = [
			"sys          1.0.70 - 1.0",
			"gfx          1.0.70 - 1.0",
			"fwt          1.0.70 - 1.0",
			"fandoc       1.0.70 - 1.0",
		]

		srcDirs = [`fan/`, `fan/advanced/`, `fan/internal/`, `fan/public/`, `test/`]
		resDirs = [`doc/`]
	}
}

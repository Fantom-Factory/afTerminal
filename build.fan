using build

class Build : BuildPod {

	new make() {
		podName = "afTerminal"
		summary = "ANSI Terminal FWT Widget"
		version = Version("0.0.1")

		meta = [
			"pod.dis"		: "ANSI Terminal",
			"repo.tags"		: "fwt",
			"repo.public"	: "true",
		]

		depends = [
			"sys          1.0.69 - 1.0",
			"gfx          1.0.69 - 1.0",
			"fwt          1.0.69 - 1.0",
			"fandoc       1.0.69 - 1.0",
			"syntax       1.0.69 - 1.0",
			"compiler     1.0.69 - 1.0",
			"compilerDoc  1.0.69 - 1.0",
			"concurrent   1.0.69 - 1.0",

			"afBeanUtils  1.0.8  - 1.0",
			"afConcurrent 1.0.19 - 1.0",	// *****
			"afPlastic    1.1.2  - 1.1",
			"afIoc        3.0.5  - 3.0",	// *****
			"afIocConfig  1.1.0  - 1.1",

			//"afProcess  0+",
		]

		srcDirs = [`fan/`, `fan/advanced/`, `fan/internal/`, `fan/public/`, `test/`]
		resDirs = [,]
	}
}

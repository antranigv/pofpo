

fast:
		./loksh < build.Tool

sixel:
		./loksh compiler.Compile /x src/polpo/POLPO.SXL.Display.Mod
		./loksh compiler.Compile /s src/polpo/POLPO.SXL.Input.Mod

x11:
		./loksh compiler.Compile /x src/polpo/POLPO.Display.Mod
		./loksh compiler.Compile /s src/polpo/POLPO.Input.Mod

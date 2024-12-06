	CNOP 0,4
variables			DS.B variables_size

	CNOP 0,4
_SysBase			DC.L 0
_DOSBase			DC.L 0
	IFD USE_GRAPHICS_LIBRARY
_GfxBase			DC.L 0
	ENDC
	IFND USE_INTUI_LIBRARY
_IntuitionBase			DC.L 0
	ENDC


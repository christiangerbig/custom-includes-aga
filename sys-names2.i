dos_library_name		DC.B "dos.library",0
	EVEN
	IFD USE_GRAPHICS_LIBRARY
graphics_library_name		DC.B "graphics.library",0
		EVEN
	ENDC
	IFD USE_INTUITION_LIBRARY
intuition_library_name		DC.B "intuition.library",0
		EVEN
	ENDC

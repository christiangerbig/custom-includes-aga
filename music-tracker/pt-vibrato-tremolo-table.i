; 4 "Vibrato" or 6 "Vibrato + Volume Slide" or 7 "Tremolo"
	IFNE pt_usedfx&(pt_cmdbitvibrato|pt_cmdbittremolo)
pt_VibTreSineTable	
		DC.B 0,24,49,74,97,120,141,161
		DC.B 180,197,212,224,235,244,250,253
		DC.B 255,253,250,244,235,224,212,197
		DC.B 180,161,141,120,97,74,49,24
	ENDC

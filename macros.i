	INCLUDE "macros-general.i"
	INCLUDE "macros-copper.i"
	INCLUDE "macros-blitter.i"
	INCLUDE "macros-playfields.i"
	INCLUDE "macros-sprites.i"

	IFD PROTRACKER_VERSION_2
		INCLUDE "music-tracker/pt-macros.i"
		INCLUDE "music-tracker/pt2-macros.i"
	ENDC
	IFD PROTRACKER_VERSION_3
		INCLUDE "music-tracker/pt-macros.i"
		INCLUDE "music-tracker/pt3-macros.i"
	ENDC

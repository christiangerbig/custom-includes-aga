; Includedatei: "normsource-includes/macros.i"
; Datum:        2.7.2024
; Version:      9.9

  INCLUDE "macros-general.i"
  INCLUDE "macros-copper.i"
  INCLUDE "macros-blitter.i"
  INCLUDE "macros-playfields.i"
  INCLUDE "macros-sprites.i"

  IFD pt_v2.3a
    INCLUDE "music-tracker/pt-macros.i"
    INCLUDE "music-tracker/pt2-macros.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt-macros.i"
    INCLUDE "music-tracker/pt3-macros.i"
  ENDC

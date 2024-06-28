; Includedatei: "normsource-includes/macros.i"
; Datum:        5.7.2023
; Version:      9.8

  INCLUDE "macros-general.i"

  INCLUDE "macros-copper.i"
  INCLUDE "macros-blitter.i"
  INCLUDE "macros-playfields.i"
  IFD spr_used_number
    INCLUDE "macros-sprites.i"
  ENDC

  IFD pt_v2.3a
    INCLUDE "music-tracker/pt-macros.i"
    INCLUDE "music-tracker/pt2-macros.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt-macros.i"
    INCLUDE "music-tracker/pt3-macros.i"
  ENDC

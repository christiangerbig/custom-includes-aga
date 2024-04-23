; Includedatei: "normsource-includes/sprite-structure.i"
; Datum:        19.04.2024
; Version:      1.2

; ** Struktur, die alle Eigenschaften der Sprites enthält **
; ----------------------------------------------------------
  IFNE spr_number

    RSRESET

sprite_attr        RS.B 0

sprite_attr_x_size RS.L 1
sprite_attr_y_size RS.L 1
sprite_attr_depth  RS.L 1

sprite_attr_SIZE   RS.B 0
  ENDC

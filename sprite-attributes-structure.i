; Includedatei: "normsource-includes/sprite-attributes-structure.i"
; Datum:        19.04.2024
; Version:      1.2


  IFNE spr_number

    RSRESET

sprite_attribues      RS.B 0

sa_x_size             RS.L 1
sa_y_size             RS.L 1
sa_depth              RS.L 1

sprite_attribues_size RS.B 0
  ENDC

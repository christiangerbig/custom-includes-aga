; Includedatei: "normsource-includes/extra-pf-attributes-structure.i"
; Datum:        19.04.2024
; Version:      1.3

; ** Struktur, die alle Eigenschaften des Extra-Playfields enthält **
; -------------------------------------------------------------------
  IFNE extra_pf_number

    RSRESET

extra_pf_attribute        RS.B 0

extra_pf_attribute_x_size RS.L 1
extra_pf_attribute_y_size RS.L 1
extra_pf_attribute_depth  RS.L 1

extra_pf_attribute_SIZE   RS.B 0
  ENDC

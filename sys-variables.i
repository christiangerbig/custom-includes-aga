; Includedatei: "normsource-includes/sys-variables.i"
; Datum:        27.10.2023
; Version:      2.1

; ## Speicherstellen allgemein ##
; -------------------------------
  CNOP 0,4
variables                DS.B variables_size
  CNOP 0,4
_ExecBase                DC.L 0
  IFND sys_taken_over
_DOSBase                 DC.L 0
  ENDC
_GFXBase                 DC.L 0

  IFND sys_taken_over
_IntuitionBase           DC.L 0
_CIABase                 DC.L 0
exception_vecs_save      DS.B exception_vectors_size
    IFD pass_global_references
global_references_table  DS.B global_references_SIZE
    ENDC
  ENDC

  IFNE extra_pf_number
  CNOP 0,4
extra_pf_attributes DS.B extra_pf_attribute_size*extra_pf_number
  ENDC

  IFNE spr_number
    IFNE spr_x_size1
    CNOP 0,4
sprite_attributes1       DS.B sprite_attr_size*spr_number
    ENDC
    IFNE spr_x_size2
    CNOP 0,4
sprite_attributes2       DS.B sprite_attr_size*spr_number
    ENDC
  ENDC

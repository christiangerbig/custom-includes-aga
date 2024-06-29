; Includedatei: "normsource-includes/sys-variables.i"
; Datum:        27.10.2023
; Version:      2.1

; ## Speicherstellen allgemein ##
; -------------------------------
  CNOP 0,4
variables                DS.B variables_size
  CNOP 0,4
_SysBase                 DC.L 0
  IFND LINKER_SYS_TAKEN_OVER
_DOSBase                 DC.L 0
  ENDC
_GfxBase                 DC.L 0

  IFND LINKER_SYS_TAKEN_OVER
_IntuitionBase           DC.L 0
_CIABase                 DC.L 0
exception_vecs_save      DS.B exception_vectors_size
    IFD LINKER_PASS_GLOBAL_REFERENCES
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

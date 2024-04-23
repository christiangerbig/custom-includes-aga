; Includedatei: "normsource-includes/except-vecs-offsets.i"
; Datum:        02.09.2000
; Version:      1.0

; ** Struktur, die alle Exception-Vektoren-Offsets enthält **
; -----------------------------------------------------------
  RSRESET

RESET_INITIAL_SSP       RS.L 1
RESET_INITIAL_PC        RS.L 1
BUS_ERROR               RS.L 1
ADDRESS_ERROR           RS.L 1
ILLEGAL_INSTRUCTION     RS.L 1
ZERO_DIVIDE             RS.L 1
CHK_INSTRUCTION         RS.L 1
TRAPV_INSTRUCTION       RS.L 1
PRIVILEGE_VIOLATION     RS.L 1
TRACE                   RS.L 1
LINE_A_INSTRUCTION      RS.L 1
LINE_F_INSTRUCTION      RS.L 1
RESERVED1               RS.L 1
COPROCESSOR_VIOLATION   RS.L 1
FORMAT_ERROR            RS.L 1
UNINITIALIZED_INTERRUPT RS.L 1
RESERVED2               RS.L 8
SPURIOUS_INTERRUPT      RS.L 1
LEVEL_1_AUTOVECTOR      RS.L 1
LEVEL_2_AUTOVECTOR      RS.L 1
LEVEL_3_AUTOVECTOR      RS.L 1
LEVEL_4_AUTOVECTOR      RS.L 1
LEVEL_5_AUTOVECTOR      RS.L 1
LEVEL_6_AUTOVECTOR      RS.L 1
LEVEL_7_AUTOVECTOR      RS.L 1
TRAP_0_VECTOR           RS.L 1
TRAP_1_VECTOR           RS.L 1
TRAP_2_VECTOR           RS.L 1
TRAP_3_VECTOR           RS.L 1
TRAP_4_VECTOR           RS.L 1
TRAP_5_VECTOR           RS.L 1
TRAP_6_VECTOR           RS.L 1
TRAP_7_VECTOR           RS.L 1
TRAP_8_VECTOR           RS.L 1
TRAP_9_VECTOR           RS.L 1
TRAP_10_VECTOR          RS.L 1
TRAP_11_VECTOR          RS.L 1
TRAP_12_VECTOR          RS.L 1
TRAP_13_VECTOR          RS.L 1
TRAP_14_VECTOR          RS.L 1
TRAP_15_VECTOR          RS.L 1
FLOATING_POINT_ERRORS   RS.L 7
RESERVED3               RS.L 1
MMU_ERRORS              RS.L 3
RESERVED4               RS.L 5
USER_DEVICE_INTERRUPTS  RS.L 192

exception_vectors_SIZE  RS.B 0

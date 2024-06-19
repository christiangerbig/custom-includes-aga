; Includedatei: "normsource-includes/continuous-timers-start.i"
; Datum:        19.06.2024
; Version:      1.3

; ** CIA-Timer starten **
; -----------------------
  IFEQ CIAA_TA_continuous_enabled&CIAA_TB_continuous_enabled&CIAB_TA_continuous_enabled&CIAB_TB_continuous_enabled
    CNOP 0,4
start_CIA_timers
    IFEQ CIAA_TA_continuous_enabled
      moveq   #CIACRAF_START,d0
      or.b    d0,CIACRA(a4)      ;CIA-A-Timer-A starten
    ENDC
    IFEQ CIAA_TB_continuous_enabled
      moveq   #CIACRBF_START,d0
      or.b    d0,CIACRB(a4)      ;CIA-A-Timer-B starten
    ENDC
    IFEQ CIAB_TA_continuous_enabled
      moveq   #CIACRAF_START,d0
      or.b    d0,CIACRA(a5)      ;CIA-B-Timer-A starten
    ENDC
    IFEQ CIAB_TB_continuous_enabled
      moveq   #CIACRBF_START,d0
      or.b    d0,CIACRB(a5)      ;CIA-B-Timer-B starten
    ENDC
    rts
  ENDC


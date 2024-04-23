; Includedatei: "normsource-includes/continuous-timers-start.i"
; Datum:        13.12.2007
; Version:      1.2

; ** CIA-Timer starten **
; -----------------------
  CNOP 0,4
start_CIA_timers
  IFEQ CIAA_TA_continuous
    moveq   #CIACRAF_START,d0
    or.b    d0,CIACRA(a4)      ;CIA-A-Timer-A starten
  ENDC
  IFEQ CIAA_TB_continuous
    moveq   #CIACRBF_START,d0
    or.b    d0,CIACRB(a4)      ;CIA-A-Timer-B starten
  ENDC
  IFEQ CIAB_TA_continuous
    moveq   #CIACRAF_START,d0
    or.b    d0,CIACRA(a5)      ;CIA-B-Timer-A starten
  ENDC
  IFEQ CIAB_TB_continuous
    moveq   #CIACRBF_START,d0
    or.b    d0,CIACRB(a5)      ;CIA-B-Timer-B starten
  ENDC
  rts


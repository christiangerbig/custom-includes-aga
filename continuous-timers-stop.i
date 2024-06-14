; Includedatei: "normsource-includes/continuous-timers-stop.i"
; Datum:        13.12.2007
; Version:      1.3

; ** Timer stoppen **
; -------------------
  CNOP 0,4
stop_CIA_timers
  IFNE CIAA_TA_time 
    moveq   #~(CIACRAF_START),d0
    and.b   d0,CIACRA(a4)      ;CIA-A-Timer-A stoppen
  ENDC
  IFNE CIAA_TB_time 
    moveq   #~(CIACRBF_START),d0
    and.b   d0,CIACRB(a4)      ;CIA-A-Timer-B stoppen
  ENDC
  IFNE CIAB_TA_time
    moveq   #~(CIACRAF_START),d0
    and.b   d0,CIACRA(a5)      ;CIA-B-Timer-A stoppen
  ENDC
  IFNE CIAB_TB_time 
    moveq   #~(CIACRBF_START),d0
    and.b   d0,CIACRB(a5)      ;CIA-B-Timer-B stoppen
  ENDC
  rts


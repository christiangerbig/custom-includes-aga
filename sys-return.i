; Includedatei: "normsource-includes/sys-return.i"
; Datum:        27.10.2023
; Version:      5.8

; ## System wieder in Ausganszustand zurücksetzen ##
; --------------------------------------------------

; ** Eigene Interrupts stoppen **
; -------------------------------
  IFNE (INTENABITS-INTF_SETCLR)|(CIAAICRBITS-CIAICRF_SETCLR)|(CIABICRBITS-CIAICRF_SETCLR)
    CNOP 0,4
stop_own_interrupts
    IFNE INTENABITS-INTF_SETCLR
      IFND sys_taken_over
        move.w  #INTF_INTEN,INTENA-DMACONR(a6) ;Interrupts aus
      ELSE
        move.w  #INTENABITS&(~INTF_SETCLR),INTENA-DMACONR(a6) ;Interrupts aus
      ENDC
    ENDC
    rts
  ENDC

; ** Eigenes Display stoppen **
; -----------------------------
  CNOP 0,4
stop_own_display
  IFNE COPCONBITS&COPCONF_CDANG
    moveq   #0,d0
    move.w  d0,COPCON-DMACONR(a6) ;Copper kann nicht auf Blitterregister zugreifen
  ENDC
  bsr     wait_beam_position
  IFNE DMABITS&DMAF_BLITTER
    WAITBLITTER
  ENDC
  IFD sys_taken_over
    move.w  #DMABITS&(~DMAF_SETCLR),DMACON-DMACONR(a6) ;DMA aus
  ELSE
    move.w  #DMAF_MASTER,DMACON-DMACONR(a6) ;DMA aus
  ENDC
  rts

  IFND sys_taken_over
; ** Wichtige Register löschen **
; -------------------------------
    CNOP 0,4
clear_important_registers2
    move.w  #$7fff,d0
    move.w  d0,DMACON-DMACONR(a6) ;DMA aus
    move.w  d0,INTENA-DMACONR(a6) ;Interrupts aus
    move.w  d0,INTREQ-DMACONR(a6) ;Interrupts löschen
    move.w  d0,ADKCON-DMACONR(a6) ;ADKCON löschen
  
    moveq   #0,d0
    move.w  d0,AUD0VOL-DMACONR(a6) ;Lautstärke aus
    move.w  d0,AUD1VOL-DMACONR(a6)
    move.w  d0,AUD2VOL-DMACONR(a6)
    move.w  d0,AUD3VOL-DMACONR(a6)
  
    move.w  d0,FMODE-DMACONR(a6) ;Fetchmode Sprites & Bitplanes = 1x
    move.l  d0,SPR0DATA-DMACONR(a6) ;Spritebitmaps manuell löschen
    move.l  d0,SPR1DATA-DMACONR(a6)
    move.l  d0,SPR2DATA-DMACONR(a6)
    move.l  d0,SPR3DATA-DMACONR(a6)
    move.l  d0,SPR4DATA-DMACONR(a6)
    move.l  d0,SPR5DATA-DMACONR(a6)
    move.l  d0,SPR6DATA-DMACONR(a6)
    move.l  d0,SPR7DATA-DMACONR(a6)
  
    moveq   #$7f,d0
    move.b  d0,CIAICR(a4)    ;CIA-A-Interrupts aus
    move.b  d0,CIAICR(a5)    ;CIA-B-Interrupts aus
    IFNE CIAAICRBITS-CIAICRF_SETCLR
      move.b  CIAICR(a4),d0  ;CIA-A-Interrupts löschen
    ENDC
    IFNE CIABICRBITS-CIAICRF_SETCLR
      move.b  CIAICR(a5),d0  ;CIA-B-Interrupts löschen
    ENDC
    rts
  
; ** Alten Inhalt in Register zurückschreiben **
; ----------------------------------------------
    CNOP 0,4
restore_hardware_registers
    move.b  os_CIAAPRA(a3),CIAPRA(a4)
  
    move.b  os_CIAATALO(a3),CIATALO(a4)
    nop
    move.b  os_CIAATAHI(a3),CIATAHI(a4)
  
    move.b  os_CIAATBLO(a3),CIATBLO(a4)
    nop
    move.b  os_CIAATBHI(a3),CIATBHI(a4)
  
    move.b  os_CIAAICR(a3),d0
    tas     d0               ;Bit 7 ggf. setzen
    move.b  d0,CIAICR(a4)
  
    move.b  os_CIAACRA(a3),d0
    btst    #CIACRAB_RUNMODE,d0 ;Continuous-Modus ?
    bne.s   CIAA_TA_no_continuous ;Nein -> verzweige
    or.b    #CIACRAF_START,d0 ;Ja -> Timer A starten
CIAA_TA_no_continuous
    move.b  d0,CIACRA(a4)
  
    move.b  os_CIAACRB(a3),d0
    btst    #CIACRBB_RUNMODE,d0 ;Continuous-Modus ?
    bne.s   CIAA_TB_no_continuous ;Nein -> verzweige
    or.b    #CIACRBF_START,d0 ;Ja -> Timer B starten
CIAA_TB_no_continuous
    move.b  d0,CIACRB(a4)
  
    move.b  os_CIABPRB(a3),CIAPRB(a5)
  
    move.b  os_CIABTALO(a3),CIATALO(a5)
    nop
    move.b  os_CIABTAHI(a3),CIATAHI(a5)
  
    move.b  os_CIABTBLO(a3),CIATBLO(a5)
    nop
    move.b  os_CIABTBHI(a3),CIATBHI(a5)
  
    move.b  os_CIABICR(a3),d0
    tas     d0               ;Bit 7 ggf. setzen
    move.b  d0,CIAICR(a5)
  
    move.b  os_CIABCRA(a3),d0
    btst    #CIACRAB_RUNMODE,d0 ;Continuous-Modus ?
    bne.s   CIAB_TA_no_continuous ;Nein -> verzweige
    or.b    #CIACRAF_START,d0 ;Ja -> Timer A starten
CIAB_TA_no_continuous
    move.b  d0,CIACRA(a5)
  
    move.b  os_CIABCRB(a3),d0
    btst    #CIACRBB_RUNMODE,d0 ;Continuous-Modus ?
    bne.s   CIAB_TB_no_continuous ;Nein -> verzweige
    or.b    #CIACRBF_START,d0 ;Ja -> Timer B starten
CIAB_TB_no_continuous
    move.b  d0,CIACRB(a5)
  
    move.l  tod_time_save(a3),d0 ;Zeit vor Programmstart
    moveq   #0,d1
    move.b  CIATODHI(a4),d1  ;CIA-A TOD-clock Bits 23-16
    swap    d1               ;Bits in richtige Position bringen
    move.b  CIATODMID(a4),d1 ;CIA-A TOD-clock Bits 15-8
    lsl.w   #8,d1            ;Bits in richtige Position bringen
    move.b  CIATODLOW(a4),d1 ;CIA-A TOD-clock Bits 7-0
    cmp.l   d0,d1            ;TOD Überlauf?
    bge.s   no_tod_overflow  ;Nein -> verzweige
    move.l  #$ffffff,d2      ;Maximalwert
    sub.l   d0,d2            ;Differenz bis zum Überlauf
    add.l   d2,d1            ;+ Wert nach dem Überlauf
    bra.s   save_tod
    CNOP 0,4
no_tod_overflow
    sub.l   d0,d1            ;Normale Differenz
save_tod
    move.l  d1,tod_time_save(a3) 
  
    IFD save_BEAMCON0
      move.w  os_BEAMCON0(a3),BEAMCON0-DMACONR(a6)
    ENDC
    IFNE cl2_size3
      move.l  os_COP2LC(a3),COP2LC-DMACONR(a6)
    ENDC
    IFNE cl1_size3
      move.l  os_COP1LC(a3),COP1LC-DMACONR(a6)
    ENDC
    moveq   #0,d0
    move.w  d0,COPJMP1-DMACONR(a6)
  
    move.w  os_DMACON(a3),d0
    and.w   #~DMAF_RASTER,d0 ;Bitplane-DMA ggf. aus
    or.w    #DMAF_SETCLR,d0  ;Bit 15 ggf. setzen
    move.w  d0,DMACON-DMACONR(a6)
    move.w  os_INTENA(a3),d0
    or.w    #INTF_SETCLR,d0  ;Bit 15 ggf. setzen
    move.w  d0,INTENA-DMACONR(a6)
    move.w  os_ADKCON(a3),d0
    or.w    #ADKF_SETCLR,d0  ;Bit 15 ggf. setzen
    move.w  d0,ADKCON-DMACONR(a6)
    move.l  os_VBR(a3),d0
    lea     write_VBR(pc),a5 ;Zeiger auf Supervisor-Routine
    CALLEXECQ Supervisor
  
    IFD all_caches
enable_os_caches
      move.l  os_CACR(a3),d0
      move.l  #CACRF_EnableI+CACRF_FreezeI+CACRF_ClearI+CACRF_IBE+CACRF_EnableD+CACRF_FreezeD+CACRF_ClearD+CACRF_DBE+CACRF_WriteAllocate+CACRF_EnableE+CACRF_CopyBack,d1 ;Alle Bits ändern
      CALLEXECQ CacheControl
    ENDC
  
    IFD no_store_buffer
enable_store_buffer
      ENABLE_060_STORE_BUFFER
    ENDC
  
  ; ** Alte Exception-Vektoren ggf. zurückschreiben **
  ; --------------------------------------------------
    CNOP 0,4
restore_exception_vectors
    lea     exception_vecs_save(pc),a0 ;Quelle
    move.l  os_VBR(a3),a1    ;Ziel = Reset (Initial SSP)
    MOVEF.W (exception_vectors_SIZE/LONGWORDSIZE)-1,d7 ;Anzahl der Vektoren
copy_vectors_loop3
    move.l  (a0)+,(a1)+      ;Vektor kopieren
    dbf     d7,copy_vectors_loop3
    CALLEXECQ CacheClearU
  
  ; ** Betriebssystem wieder aktivieren **
  ; --------------------------------------
    CNOP 0,4
enable_system
    CALLEXEC Enable          ;Interrupts an

update_clock
    move.l  tod_time_save(a3),d0 ;Vergangene Zeit, als System ausgeschaltet war
    moveq   #0,d1
    move.b  VBlankFrequency(a6),d1 ;Frequenz ermitteln
    lea     timer_io_structure(pc),a1 ;Zeiger auf Timer-IO-Struktur
    divu.w  d1,d0            ;/Vertikalfrequenz (50Hz) = Sekunden, Rest Microsekunden
    move.w  #TR_SETSYSTIME,IO_command(a1) ;Befehl für Timer-Device
    move.l  d0,d1            
    ext.l   d0               ;Auf 32 Bit erweitern
    swap    d1               ;Rest der Division
    add.l   d0,IO_SIZE+TV_SECS(a1) ;Unix-Time Sekunden setzen
    mulu.w  #10000,d1        ;In µs
    add.l   d1,IO_SIZE+TV_MICRO(a1) ;Unix-Time Mikrosekunden setzen
    CALLLIBS DoIO
  
restore_os_view
    CALLGRAF DisOwnBlitter
    sub.l    a1,a1           ;Kein Display
    CALLLIBS LoadView
    CALLLIBS WaitTOF
    CALLLIBS WaitTOF         ;Bei Interlace
    move.l   os_view(a3),a1
    CALLLIBS LoadView
    CALLLIBS WaitTOF
    CALLLIBS WaitTOF         ;Bei Interlace
    move.l  downgrade_screen(a3),a0
    CALLINT CloseScreen
  
    IFNE workbench_fade_enabled
free_screen_color_table32
      move.l  screen_color_table32(a3),d0 ;Wurde der Speicher belegt ?
      beq.s   restore_os_sprite_resolution ;Nein -> verzweige
      move.l  d0,a1          ;Zeiger auf Speicherbereich
      move.l  #(1+(wbf_colors_number_max*3)+1)*LONGWORDSIZE,d0 ;Größe der Speicherbereiches
      CALLEXEC FreeMem       ;Speicher freigeben
    ENDC
  
restore_os_sprite_resolution
    move.l  os_screen(a3),a2
    lea     spr_taglist(pc),a1
    move.l  sc_ViewPort+vp_ColorMap(a2),a0
    move.l  #VTAG_SPRITERESN_SET,sprtl_VTAG_SPRITERESN+ti_Tag(a1)
    move.l  os_sprite_resolution(a3),sprtl_VTAG_SPRITERESN+ti_Data(a1) ;alte Auflösung
    CALLGRAF VideoControl
    move.l  a2,a0            ;Zeiger auf alten Screen
    CALLINT MakeScreen
    CALLLIBS RethinkDisplay
  
    IFEQ workbench_fade_enabled
wbfi_check_monitor_id
      move.l  os_monitor_id(a3),d0
      CMPF.L  DEFAULT_MONITOR_ID,d0 ;15 kHz Default ?
      beq.s   wbfi_wait_fade_in ;Ja -> verzweige
      cmp.l   #PAL_MONITOR_ID,d0 ;15 kHz PAL ?
      beq.s   wbfi_wait_fade_in ;Ja -> verzweige
      MOVEF.L delay_time2,d1 ;Auf Umschalten des Monitors warten
      CALLDOS Delay
  
wbfi_wait_fade_in
      CALLGRAF WaitTOF
      bsr.s   workbench_fade_enabledr_in
      bsr     wbf_set_new_colors32
      tst.w   wbfi_active(a3)
      beq.s   wbfi_wait_fade_in
  
wbf_free_color_values32_memory
      move.l  wbf_color_values32(a3),d0 ;Wurde der Speicher belegt ?
      beq.s   wbf_free_color_cache32_memory ;Nein -> verzweige
      move.l  d0,a1          ;Zeiger auf Speicherbereich
      move.l  #wbf_colors_number_max*3*LONGWORDSIZE,d0
      CALLEXEC FreeMem       ;Speicher freigeben
wbf_free_color_cache32_memory
      move.l  wbf_color_cache32(a3),d0  ;Wurde der Speicher belegt ?
      beq.s   wbfi_skip_fade_in ;Nein -> verzweige
      move.l  d0,a1          ;Zeiger auf Speicherbereich
      move.l  #(1+(wbf_colors_number_max*3)+1)*LONGWORDSIZE,d0
      CALLLIBQ FreeMem       ;Speicher freigeben
      CNOP 0,4
wbfi_skip_fade_in
      rts
  
; ** Farben einblenden **
; -----------------------
  CNOP 0,4
workbench_fade_enabledr_in
      tst.w   wbfi_active(a3) ;Fading-In an ?
      bne     no_workbench_fade_enabledr_in ;Nein -> verzweige
      MOVEF.W wbf_colors_number_max*3,d6 ;Anzahl der Farbwerte*3 = Zähler
      move.l  wbf_color_cache32(a3),a0 ;Puffer für Farbwerte
      addq.w  #4,a0
      move.w  #wbfi_fader_speed,a4 ;Additions-/Subtraktionswert für RGB-Werte
      move.l  wbf_color_values32(a3),a1 ;Sollwerte
      MOVEF.W wbf_colors_number_max-1,d7 ;Anzahl der Farbwerte
workbench_fade_enabledr_in_loop
      moveq   #0,d0
      move.b  (a0),d0        ;8-Bit Rot-Istwert
      moveq   #0,d1
      move.b  4(a0),d1       ;8-Bit Grün-Istwert
      moveq   #0,d2
      move.b  8(a0),d2       ;8-Bit Blau-Istwert
      moveq   #0,d3
      move.b  (a1),d3        ;8-Bit Rot-Sollwert
      moveq   #0,d4
      move.b  4(a1),d4       ;8-Bit Grün-Sollwert
      moveq   #0,d5
      move.b  8(a1),d5       ;8-Bit Blau-Sollwert
  
; ** Rotwert **
wbfi_check_red
      cmp.w   d3,d0          ;Ist-Rotwert mit Soll-Rotwert vergleichen
      bgt.s   wbfi_decrease_red ;Wenn Ist-Rotwert < Soll-Rotwert -> verzweige
      blt.s   wbfi_increase_red ;Wenn Ist-Rotwert > Soll-Rotwert -> verzweige
wbfi_matched_red
      subq.w  #1,d6          ;Zähler verringern
  
; ** Grünwert **
wbfi_check_green
      cmp.w   d4,d1          ;Ist-Grünwert mit Soll-Grünwert vergleichen
      bgt.s   wbfi_decrease_green ;Wenn Ist-Grünwert < Soll-Grünwert -> verzweige
      blt.s   wbfi_increase_green ;Wenn Ist-Grünwert > Soll-Grünwert -> verzweige
wbfi_matched_green
      subq.w  #1,d6          ;Zähler verringern
  
; ** Blauwert **
wbfi_check_blue
      cmp.w   d5,d2          ;Ist-Blauwert mit Soll-Blauwert vergleichen
      bgt.s   wbfi_decrease_blue ;Wenn Ist-Blauwert < Soll-Blauwert -> verzweige
      blt.s   wbfi_increase_blue ;Wenn Ist-Blauwert > Soll-Blauwert -> verzweige
wbfi_matched_blue
      subq.w  #1,d6          ;Zähler verringern
  
wbfi_set_rgb
      move.b  d0,(a0)+       ;4x 8-Bit Rotwert in Cache schreiben
      move.b  d0,(a0)+
      move.b  d0,(a0)+
      move.b  d0,(a0)+
      move.b  d1,(a0)+       ;4x 8-Bit Grünwert in Cache schreiben
      move.b  d1,(a0)+
      move.b  d1,(a0)+
      move.b  d1,(a0)+
      move.b  d2,(a0)+       ;4x 8-Bit Blauwert in Cache schreiben
      move.b  d2,(a0)+
      addq.w  #8,a1          ;nächstes 32-Bit-Tripple (4*3)
      move.b  d2,(a0)+
      addq.w  #4,a1
      move.b  d2,(a0)+
      dbf     d7,workbench_fade_enabledr_in_loop
      tst.w   d6             ;Fertig mit ausblenden ?
      bne.s   wbfi_not_finished ;Nein -> verzweige
      not.w   wbfi_active(a3) ;Fading-In aus
wbfi_not_finished
      CALLEXEC CacheClearU   ;Caches flushen
no_workbench_fade_enabledr_in
      rts
      CNOP 0,4
wbfi_decrease_red
      sub.w   a4,d0          ;Rotanteil verringern
      cmp.w   d3,d0          ;Ist-Rotwert > Soll-Rotwert ?
      bgt.s   wbfi_check_green ;Ja -> verzweige
      move.w  d3,d0          ;Ist-Rotwert <= Soll-Rotwert
      bra.s   wbfi_matched_red
      CNOP 0,4
wbfi_increase_red
      add.w   a4,d0          ;Rotanteil erhöhen
      cmp.w   d3,d0          ;Ist-Rotwert <= Soll-Rotwert ?
      blt.s   wbfi_check_green ;Ja -> verzweige
      move.w  d3,d0          ;Ist-Rotwert >= Soll-Rotwert
      bra.s   wbfi_matched_red
      CNOP 0,4
wbfi_decrease_green
      sub.w   a4,d1          ;Grünanteil verringern
      cmp.w   d4,d1          ;Ist-Grünwert > Soll-Grünwert ?
      bgt.s   wbfi_check_blue ;Ja -> verzweige
      move.w  d4,d1          ;Ist-Grünwert <= Soll-Grünwert
      bra.s   wbfi_matched_green
      CNOP 0,4
wbfi_increase_green
      add.w   a4,d1          ;Grünanteil erhöhen
      cmp.w   d4,d1          ;Ist-Grünwert < Soll-Grünwert ?
      blt.s   wbfi_check_blue ;Ja -> verzweige
      move.w  d4,d1          ;Ist-Grünwert >= Soll-Grünwert
      bra.s   wbfi_matched_green
      CNOP 0,4
wbfi_decrease_blue
      sub.w   a4,d2          ;Blauanteil verringern
      cmp.w   d5,d2          ;Ist-Blauwert > Soll-Blauwert ?
      bgt.s   wbfi_set_rgb   ;Ja -> verzweige
      move.w  d5,d2          ;Ist-Blauwert <= Soll-Blauwert
      bra.s   wbfi_matched_blue
      CNOP 0,4
wbfi_increase_blue
      add.w   a4,d2          ;Blauanteil erhöhen
      cmp.w   d5,d2          ;Ist-Blauwert < Soll-Blauwert ?
      blt.s   wbfi_set_rgb   ;Ja -> verzweige
      move.w  d5,d2          ;Ist-Blauwert >= Soll-Blauwert
      bra.s   wbfi_matched_blue
    ELSE
exit_check_monitor_id
      move.l  os_monitor_id(a3),d0
      CMPF.L  DEFAULT_MONITOR_ID,d0 ;15 kHz Default ?
      beq.s   no_delay       ;Ja -> verzweige
      cmp.l   #NTSC_MONITOR_ID,d0 ;15 kHz NTSC ?
      beq.s   no_delay       ;Ja -> verzweige
      cmp.l   #PAL_MONITOR_ID,d0 ;15 kHz PAL ?
      beq.s   no_delay       ;Ja -> verzweige
      MOVEF.L delay_time2,d1 ;Auf Umschalten des Monitors warten
      CALLDOSQ Delay
      CNOP 0,4
no_delay
      rts
    ENDC
  
  ; ** formatierten Text ausgeben **
  ; --------------------------------
    IFEQ text_output_enabled
      CNOP 0,4
print_text
      lea     format_string(pc),a0
      lea     data_stream(pc),a1 ;Daten für den Format-String
      lea     put_ch_proc(pc),a2 ;Zeiger auf Kopierroutine
      move.l  a3,-(a7)
      lea     put_ch_data(pc),a3 ;Zeiger auf Ausgabestring
      CALLEXEC RawDoFmt
      move.l  (a7)+,a3
      CALLDOS Output
      move.l  d0,d1
      beq.s   no_print_text  ;Wenn Fehler -> verzweige
      lea     put_ch_data(pc),a0 ;Zeiger auf Text
      move.l  a0,d2
      moveq   #0,d3          ;Zeichenzähler = Null
search_nullbyte
      tst.b   (a0)+          ;Nullbyte gefunden ?
      beq.s   nullbyte_found ;Ja- > verzweige
      addq.w  #1,d3
      bra.s   search_nullbyte
nullbyte_found
      CALLLIBQ Write
      CNOP 0,4
no_print_text
      rts
      CNOP 0,4
put_ch_proc
      move.b  d0,(a3)+       ;Daten in den Ausgabestring schreiben
      rts
    ENDC
  
; ** Speicher für Vektoren wieder freigeben **
; --------------------------------------------
    CNOP 0,4
free_vectors_memory
    move.l  exception_vectors_base(a3),d0
    beq.s   no_free_vectors_memory ;Wenn Null -> verzweige
    move.l  d0,a1
    move.l  #exception_vectors_SIZE,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_vectors_memory
    rts
  ENDC

; ** Speicher für CHIP-Memory freigeben **
; ----------------------------------------
  IFNE CHIP_memory_size
    CNOP 0,4
free_chip_memory
    move.l  chip_memory(a3),d0
    beq.s   no_free_chip_memory ;Wenn Null -> verzweige
    move.l  d0,a1            
    MOVEF.L chip_memory_size,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_chip_memory
    rts
  ENDC

; ** Speicher für Extra-Memory freigeben **
; -----------------------------------------
  IFNE extra_memory_size
    CNOP 0,4
free_extra_memory
    move.l  extra_memory(a3),d0
    beq.s   no_free_extra_memory ;Wenn Null -> verzweige
    move.l  d0,a1            
    MOVEF.L extra_memory_size,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_extra_memory
    rts
  ENDC

; ** Speicher für Disk-Data wieder freigeben **
; ---------------------------------------------
  IFNE disk_memory_size
    CNOP 0,4
free_disk_memory
    move.l  disk_data(a3),d0
    beq.s   no_free_disk_memory ;Wenn Null -> verzweige
    move.l  d0,a1           
    MOVEF.L disk_memory_size,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_disk_memory
    rts
  ENDC

; ** Speicher für Audio-Data wieder freigeben **
; ----------------------------------------------
  IFNE audio_memory_size
    CNOP 0,4
free_audio_memory
    move.l  audio_data(a3),d0
    beq.s   no_free_audio_memory ;Wenn Null -> verzweige
    move.l  d0,a1         
    MOVEF.L audio_memory_size,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_audio_memory
    rts
  ENDC

; ** Speicher für zweite Sprite-Bitmap wieder freigeben **
; --------------------------------------------------------
  IFNE spr_x_size2
    CNOP 0,4
free_sprite_memory2
    lea     spr0_bitmap2(a3),a2
    moveq   #spr_number-1,d7 ;Anzahl der Hardware-Sprites (1-8)
free_sprite_memory2_loop
    move.l  (a2)+,d0
    beq.s   no_free_sprite_memory2 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAF FreeBitMap
    dbf     d7,free_sprite_memory2_loop
no_free_sprite_memory2
    rts
  ENDC

; ** Speicher für erste Sprite-Bitmap wieder freigeben **
; -------------------------------------------------------
  IFNE spr_x_size1
    CNOP 0,4
free_sprite_memory1
    lea     spr0_bitmap1(a3),a2
    moveq   #spr_number-1,d7 ;Anzahl der Hardware-Sprites (1-8)
free_sprite_memory1_loop
    move.l  (a2)+,d0
    beq.s   no_free_sprite_memory1 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAF FreeBitMap
    dbf     d7,free_sprite_memory1_loop
no_free_sprite_memory1
    rts
  ENDC

; ** Speicher für Extra-Playfield-Bitmap wieder freigeben **
; ----------------------------------------------------------
  IFNE extra_pf_number
    CNOP 0,4
free_extra_pf_memory
    lea     extra_pf_bitmap1(a3),a2
    moveq   #extra_pf_number-1,d7 ;Anzahl der Extra-Playfields
extra_pf_memory_loop2
    move.l  (a2)+,d0
    beq.s   no_free_extra_pf_memory ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAF FreeBitMap
    dbf     d7,extra_pf_memory_loop2
no_free_extra_pf_memory
    rts
  ENDC

; ** Speicher für dritte Playfield-Bitmap wieder freigeben **
; -----------------------------------------------------------
  IFNE pf2_x_size3
    CNOP 0,4
free_pf2_memory3
    move.l  pf2_bitmap3(a3),d0
    beq.s   no_free_pf2_memory3 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf2_memory3
    rts
  ENDC

; ** Speicher für zweite Playfield-Bitmap wieder freigeben **
; -----------------------------------------------------------
  IFNE pf2_x_size2
    CNOP 0,4
free_pf2_memory2
    move.l  pf2_bitmap2(a3),d0
    beq.s   no_free_pf2_memory2 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf2_memory2
    rts
  ENDC

; ** Speicher für erste Playfield-Bitmap wieder freigeben **
; ----------------------------------------------------------
  IFNE pf2_x_size1
    CNOP 0,4
free_pf2_memory1
    move.l  pf2_bitmap1(a3),d0
    beq.s   no_free_pf2_memory1 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf2_memory1
    rts
  ENDC

; ** Speicher für dritte Playfield-Bitmap wieder freigeben **
; -----------------------------------------------------------
  IFNE pf1_x_size3
    CNOP 0,4
free_pf1_memory3
    move.l  pf1_bitmap3(a3),d0
    beq.s   no_free_pf1_memory3 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf1_memory3
    rts
  ENDC

; ** Speicher für zweite Playfield-Bitmap wieder freigeben **
; -----------------------------------------------------------
  IFNE pf1_x_size2
    CNOP 0,4
free_pf1_memory2
    move.l  pf1_bitmap2(a3),d0
    beq.s   no_free_pf1_memory2 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf1_memory2
    rts
  ENDC

; ** Speicher für erste Playfield-Bitmap wieder freigeben **
; ----------------------------------------------------------
  IFNE pf1_x_size1
    CNOP 0,4
free_pf1_memory1
    move.l  pf1_bitmap1(a3),d0
    beq.s   no_free_pf1_memory1 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf1_memory1
    rts
  ENDC

; ** Speicher dritte Copperliste wieder freigeben **
; --------------------------------------------------
  IFNE cl2_size3
    CNOP 0,4
free_cl2_memory3
    move.l  cl2_display(a3),d0
    beq.s   no_free_cl2_memory3 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl2_size3,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl2_memory3
    rts
  ENDC

; ** Speicher zweite Copperliste wieder freigeben **
; --------------------------------------------------
  IFNE cl2_size2
    CNOP 0,4
free_cl2_memory2
    move.l  cl2_construction2(a3),d0
    beq.s   no_free_cl2_memory2 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl2_size2,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl2_memory2
    rts
  ENDC

; ** Speicher erste Copperliste wieder freigeben **
; -------------------------------------------------
  IFNE cl2_size1
    CNOP 0,4
free_cl2_memory1
    move.l  cl2_construction1(a3),d0
    beq.s   no_free_cl2_memory1 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl2_size1,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl2_memory1
    rts
  ENDC

; ** Speicher dritte Copperliste wieder freigeben **
; --------------------------------------------------
  IFNE cl1_size3
    CNOP 0,4
free_cl1_memory3
    move.l  cl1_display(a3),d0
    beq.s   no_free_cl1_memory3 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl1_size3,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl1_memory3
    rts
  ENDC

; ** Speicher zweite Copperliste wieder freigeben **
; --------------------------------------------------
  IFNE cl1_size2
    CNOP 0,4
free_cl1_memory2
    move.l  cl1_construction2(a3),d0 ;Zeiger auf Speicherbereich
    beq.s   no_free_cl1_memory2 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl1_size2,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl1_memory2
    rts
  ENDC

; ** Speicher erste Copperliste wieder freigeben **
; -------------------------------------------------
  IFNE cl1_size1
    CNOP 0,4
free_cl1_memory1
    move.l  cl1_construction1(a3),d0
    beq.s   no_free_cl1_memory1 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl1_size1,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl1_memory1
    rts
  ENDC

  IFND sys_taken_over
; ** Timer-Device schließen **
; ----------------------------
    CNOP 0,4
close_timer_device
    lea     timer_io_structure(pc),a1
    CALLEXECQ CloseDevice
  
  ; ** Intuition-Libary schließen **
  ; --------------------------------
    CNOP 0,4
close_intuition_library
    move.l  _IntuitionBase(pc),a1
    CALLEXECQ CloseLibrary

; ** Graphics-Libary schließen **
; -------------------------------
    CNOP 0,4
close_graphics_library
    move.l  _GFXBase(pc),a1
    CALLEXECQ CloseLibrary

  IFND sys_taken_over
; ** Fehler ausgeben **
; ---------------------
    CNOP 0,4
print_error_message
    move.w  custom_error_code(a3),d4 ;Ist ein eigener Fehler aufgetreten ?
    beq.s   no_print_error_message ;Nein -> verzweige
    CALLINT WBenchToFront
    lea     file_name(pc),a0
    move.l  a0,d1
    move.l  #MODE_OLDFILE,d2 ;Modus: Alt (Muß sein!)
    CALLDOS Open
    move.l  d0,file_handle(a3)
    beq.s   raw_open_error   ;Wenn NULL -> verzweige
    subq.w  #1,d4            ;Start-Offset 0
    lea     custom_error_table(pc),a0
    move.l  (a0,d4.w*8),d2   ;Zeiger auf Fehlertext
    move.l  4(a0,d4.w*8),d3  ;Länge des Fehlertextes
    move.l  d0,d1            ;Zeiger auf Datei-Handle
    CALLLIBS Write
    move.l  file_handle(a3),d1
    lea     raw_buffer(a3),a0
    move.l  a0,d2            ;Zeiger auf Puffer
    moveq   #1,d3            ;Anzahl der Zeichen zum Lesen
    CALLLIBS Read
    move.l  file_handle(a3),d1
    CALLLIBS Close
no_print_error_message
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
raw_open_error
    moveq   #RETURN_ERROR,d0
    rts
  ENDC

; ** DOS-Libary schließen **
; --------------------------
    CNOP 0,4
close_dos_library
    move.l  _DOSBase(pc),a1
    CALLEXECQ CloseLibrary

; ** WB-Message ggf. noch beantworten **
; --------------------------------------
    IFEQ workbench_start_enabled
      CNOP 0,4
reply_wb_message
      move.l  wb_message(a3),d2
      bne.s   wb_message_ok  ;Wenn WB-Message vorhandern -> verzweige
      rts
      CNOP 0,4
wb_message_ok
      CALLEXEC Forbid
      move.l  d2,a1
      CALLLIBS ReplyMsg
      CALLLIBQ Permit
    ENDC
  ENDC

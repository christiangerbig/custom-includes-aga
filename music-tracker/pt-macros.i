; Includedatei: "normsource-includes/music-tracker/macros-pt.i"
; Datum:        4.6.2023
; Version:      1.0


PT_FADE_OUT MACRO
; \1 STRING: Variablen-Offset für Variable, die auf TRUE gesetzt wird, wenn fertig
  CNOP 0,4
pt_fade_out_music
  tst.w   pt_fade_out_music_active(a3) ;FALSE ?
  bne.s   pt_no_fade_out_music ;Ja -> verzweige
  lea     pt_audchan1temp(pc),a0  ;Temporäre Audio-Daten
  lea     AUD0VOL-DMACONR(a6),a1
  bsr.s   pt_fade_out_channel_volume
  lea     pt_audchan2temp(pc),a0
  bsr.s   pt_fade_out_channel_volume
  lea     pt_audchan3temp(pc),a0
  bsr.s   pt_fade_out_channel_volume
  lea     pt_audchan4temp(pc),a0
  bsr.s   pt_fade_out_channel_volume
  move.w  pt_fade_out_delay_counter(a3),d0 ;Verzögerungszähler auslesen
  subq.w  #1,d0              ;und verringern
  bne.s   pt_no_fade_out_volume ;Wenn <> Null -> verzweige
pt_fade_out_volume
  move.w  pt_master_volume(a3),d1 ;Mastervolume = Null ?
  beq.s   pt_fade_out_music_finished ;Ja -> verzweige
  subq.w  #1,d1              ;Mastervolume verringern
  move.w  d1,pt_master_volume(a3) ;neuen Wert retten
  moveq   #pt_fade_out_delay,d0 ;Neustart des Verzögerungszählers
pt_no_fade_out_volume
  move.w  d0,pt_fade_out_delay_counter(a3) ;Verzögerungszähler retten
pt_no_fade_out_music
  rts
  CNOP 0,4
pt_fade_out_channel_volume
  moveq   #0,d0
  move.b  n_volume(a0),d0    ;aktuelle Kanallautstärke
  mulu.w  pt_master_volume(a3),d0 ;derzeitige allgemeine Lautstärke
  lsr.w   #6,d0              ;/ Mastervolume
  move.w  d0,(a1)            ;AUDxVOL
  ADDF.W  16,a1              ;nächstes Volume-Register
  rts
  CNOP 0,4
pt_fade_out_music_finished
  not.w   pt_fade_out_music_active(a3) ;Fader aus
  IFNC "","\1"
    moveq   #0,d0
    move.w  d0,\1(a3)        ;Ggf. zusätzliche Variable setzen
  ENDC
  rts
  ENDM


PT_DETECT_SYS_FREQUENCY MACRO
  CNOP 0,4
pt_DetectSysFrequ
  move.l  _GfxBase(pc),a0    ;Pointer to gfx library base
  move.w  gb_DisplayFlags(a0),d0 ;Get display flags
  move.l  #pt_pal125bpmrate,d1 ;Set PAL 125 bpm rate
  btst    #REALLY_PALn,d0    ;Crystalfrequency 50Hz ? (OS3.0+)
  bne.s   pt_PalSysFreqDetected ;Yes -> skip
  btst    #PALn,d0           ;Frequency50Hz (OS1.2...OS2.04) ?
  bne.s   pt_PalSysFreqDetected ;Yes -> skip
pt_NtscSysFreqDetected
  move.l   #pt_ntsc125bpmrate,d1 ;Set NTSC 125 BPM rate
pt_PalSysFreqDetected
  move.l   d1,pt_125BPMrate(a3) ;Save 125 BPM rate
  rts
  ENDM


PT_INIT_TIMERS MACRO
  IFEQ pt_ciatiming_enabled
    move.l  pt_125bpmrate(a3),d0 ;Get 125 bpm PAL/NTSC rate
    divu.w  #pt_defaultbpm,d0 ;/125 BPM = default to normal 50 Hz timer
    move.b  d0,CIATALO(a5)   ;Set CIA-B timer A counter value low bits
    lsr.w   #BYTE_SHIFT_BITS,d0 ;Get counter value high bits
    move.b  d0,CIATAHI(a5)   ;Set CIA-B timer A counter value high bits
    moveq   #ciab_cra_bits,d0
    move.b  d0,CIACRA(a5)    ;Loadnewtimercontinuousvalue
  ENDC
  moveq   #ciab_tb_time&BYTE_MASK,d0 ;DMA wait
  move.b  d0,CIATBLO(a5)     ;Set CIA-B timer B counter value low bits
  moveq   #ciab_tb_time>>BYTE_SHIFT_BITS,d0
  move.b  d0,CIATBHI(a5)     ;Set CIA-B timer B counter value high bits
  moveq   #ciab_crb_bits,d0
  move.b  d0,CIACRB(a5)      ;Load new timer oneshot value
  ENDM


PT_INIT_REGISTERS MACRO
  CNOP 0,4
pt_InitRegisters
  moveq   #CIAF_LED,d0
  or.b    d0,CIAPRA(a4)      ;Turn sound filte roff
  moveq   #0,d0
  move.w  d0,AUD0VOL-DMACONR(a6) ;Clear volume for all channels
  move.w  d0,AUD1VOL-DMACONR(a6)
  move.w  d0,AUD2VOL-DMACONR(a6)
  move.w  d0,AUD3VOL-DMACONR(a6)
  IFD LINKER_SYS_TAKEN_OVER
    moveq   #DMAF_AUD0+DMAF_AUD1+DMAF_AUD2+DMAF_AUD3,d0
    move.w  d0,DMACON-DMACONR(a6) ;Channel DMA off
  ENDC
  rts
  ENDM


PT_INIT_AUDIO_TEMP_STRUCTURES MACRO
  CNOP 0,4
pt_InitAudTempStrucs
  moveq   #DMAF_AUD0,d0      ;DMA bit for channel1
  lea     pt_audchan1temp+n_dmabit(pc),a0
  move.w  d0,(a0)            ;Set DMA channel1 bit
  moveq   #FALSE,d1
  IFEQ pt_track_volumes_enabled
    move.b  d1,n_note_trigger-n_dmabit(a0) ;Disable note trigger flag
  ENDC
  move.b  d1,n_rtnsetchandma-n_dmabit(a0) ;Deactivate channel1 set routine for "Retrig Note" or "Note Delay"
  moveq   #DMAF_AUD1,d0      ;DMA bit for channel2
  move.b  d1,n_rtninitchandata-n_dmabit(a0) ;Deactivate channel1 init routine for "Retrig Note" or "Note Delay"
  lea     pt_audchan2temp+n_dmabit(pc),a0
  move.w  d0,(a0)            ;Set DMA channel2 bit
  IFEQ pt_track_volumes_enabled
   move.b d1,n_note_trigger-n_dmabit(a0) ;Disablenewnoteflag
  ENDC
  move.b  d1,n_rtnsetchandma-n_dmabit(a0) ;Deactivate channel2 set routine for "Retrig Note" or "Note Delay"
  moveq   #DMAF_AUD2,d0      ;DMA bit for channel3
  move.b  d1,n_rtninitchandata-n_dmabit(a0) ;Deactivate channel2 init routine for "Retrig Note" or "Note Delay"
  lea     pt_audchan3temp+n_dmabit(pc),a0
  move.w  d0,(a0)            ;Set DMA channel3 bit
  IFEQ pt_track_volumes_enabled
    move.b  d1,n_note_trigger-n_dmabit(a0) ;Disable trigger note flag
  ENDC
  move.b  d1,n_rtnsetchandma-n_dmabit(a0) ;Deactivateb channel3 set routine for "Retrig Note" or "Note Delay"
  moveq   #DMAF_AUD3,d0   ;DMAbitforchannel4
  move.b  d1,n_rtninitchandata-n_dmabit(a0) ;Deactivatechannel3initroutinefor"RetrigNote"or"NoteDelay"
  lea     pt_audchan4temp+n_dmabit(pc),a0
  move.w  d0,(a0)            ;SetDMAchannel4bit
  IFEQ pt_track_volumes_enabled
   move.b  d1,n_note_trigger-n_dmabit(a0) ;Disable note trigger flag
  ENDC
  move.b  d1,n_rtnsetchandma-n_dmabit(a0) ;Deactivate channel4 set routine for "Retrig Note" or "Note Delay"
  move.b  d1,n_rtninitchandata-n_dmabit(a0) ;Deactivate channel4 init routine for "Retrig Note"or "Note Delay"
  rts
  ENDM


PT_EXAMINE_SONG_STRUCTURE MACRO
  CNOP 0,4
pt_ExamineSongStruc
  move.l  pt_SongDataPointer(a3),a0 ;Pointer to song data
  moveq   #0,d0           ;First pattern number (count starts at zero)
  move.b  pt_sd_numofpatt(a0),pt_SongLength(a3) ;Get number of patterns
  moveq   #TRUE,d1           ;Highest pattern number
  lea     pt_sd_pattpos(a0),a1 ;Pointer to table with pattern positions in song
  MOVEF.W pt_maxsongpos-1,d7 ;Maximum number of song positions
pt_InitLoop
  move.b  (a1)+,d0           ;Get patter nnumber out of song position table
  cmp.b   d1,d0              ;Pattern number <= previous pattern number ?
  ble.s   pt_InitSkip        ;Yes -> skip
  move.l  d0,d1              ;Save higher pattern number
pt_InitSkip
  dbf     d7,pt_InitLoop
  IFNE pt_split_module_enabled
    addq.w  #1,d1            ;Decrease highest pattern number (count starts at zero)
  ENDC
  ADDF.W  pt_sd_sampleinfo+pt_si_samplelength,a0 ;First sample length
  IFNE pt_split_module_enabled
    MULUF.W pt_pattsize/8,d1 ;Offset points to end of last pattern
  ENDC
  moveq   #TRUE,d2           ;Clear first word in sample data
  moveq   #1,d3              ;Length in words for oneshot sample
  IFNE pt_split_module_enabled
    lea     pt_sd_patterndata-pt_sd_id(a1,d1.w*8),a2 ;Skip MOD-ID and patterndata -> Pointer to first sample data in module
  ELSE
    move.l  pt_SamplesDataPointer(a3),a2 ;Pointers to samples
  ENDC
  lea     pt_SampleStarts(pc),a1 ;Table for sample pointers
  moveq   #pt_sampleinfo_size,d1 ;Length of sample info structure in bytes
  moveq   #pt_samplesnum-1,d7 ;Number of samples in module
pt_InitLoop2
  move.l  a2,(a1)+           ;Save pointer to sample data
  move.w  (a0),d0            ;Get sample length
  beq.s   pt_NoSample        ;If length = zero -> skip
  MULUF.W 2,d0               ;*2=Sample length in bytes
  move.w  d2,(a2)            ;Clear first word in sample data
  add.l   d0,a2              ;Add sample length to get pointer to next sample data
  move.w  pt_si_repeatlength-pt_si_samplelength(a0),d0 ;Fasttracker module with repeat length = 0 ?
  bne.s   pt_NoSample        ;If not -> skip
  move.w  d3,pt_si_repeatlength-pt_si_samplelength(a0) ;Set repeat length = 1 for Protracker compability
pt_NoSample
  add.l   d1,a0              ;Next sample info structure in module
  dbf     d7,pt_InitLoop2
  rts
  ENDM


PT_INIT_FINETUNING_PERIOD_TABLE_STARTS MACRO
  CNOP 0,4
pt_InitFtuPeriodTableStarts
  lea     pt_PeriodTable(pc),a0 ;Period table pointer, finetune = 0
  lea     pt_FtuPeriodTableStarts(pc),a1 ;Table for period table pointers
  moveq   #pt_PeriodTableEnd-pt_PeriodTable,d0 ;Period table length in bytes
  moveq   #pt_finetunenum-1,d7 ;Number of finetune values
pt_InitFtuPerTableStartsLoop
  move.l  a0,(a1)+           ;Save pointer
  add.l   d0,a0              ;Pointer to next period table, finetune + n
  dbf     d7,pt_InitFtuPerTableStartsLoop
  rts
  ENDM


PT_TIMER_INTERRUPT_SERVER MACRO
;--> E9 "Retrig Note" or ED "Note Delay"used <--
  IFNE pt_usedefx&(pt_ecmdbitretrignote+pt_ecmdbitnotedelay)
    tst.w   pt_RtnDMACONtemp(a3) ;Effect command "Retrig Note" or "Note Delay" for any audio channel used?
    beq.s   pt_NoRtnChannels ;If not -> skip
    move.w  pt_audchan1temp+n_rtnsetchandma(pc),d0 ;Get init + set state for channel1
    bpl     pt_RtnSetChan1DMA ;If set state = TRUE -> skip
    tst.b   d0               ;Init state = TRUE?
    beq     pt_RtnInitChan1Data ;Yes -> skip
    move.w  pt_audchan2temp+n_rtnsetchandma(pc),d0 ;Get init + set state for channel2
    bpl     pt_RtnSetChan2DMA ;If set state = TRUE -> skip
    tst.b   d0               ;Init state = TRUE?
    beq     pt_RtnInitChan2Data ;Yes -> skip
    move.w  pt_audchan3temp+n_rtnsetchandma(pc),d0 ;Get init + set state for channel3
    bpl     pt_RtnSetChan3DMA ;If set state = TRUE -> skip
    tst.b   d0               ;Init state = TRUE?
    beq     pt_RtnInitChan3Data ;Yes -> skip
    move.w  pt_audchan4temp+n_rtnsetchandma(pc),d0 ;Get init + set state for channel4
    bpl     pt_RtnSetChan4DMA ;If set state = TRUE -> skip
    tst.b   d0               ;Init state = TRUE?
    beq     pt_RtnInitChan4Data ;Yes -> skip
pt_NoRtnChannels
  ENDC
  tst.b   pt_SetAllChanDMAFlag(a3) ;Set flag = TRUE?
  beq.s   pt_SetAllChanDMA   ;Yes -> skip
 
;--> Init all audio channels loop data <--
pt_InitAllChanLoopData
  move.l  pt_audchan1temp+n_loopstart(pc),AUD0LCH-DMACONR(a6) ;Set loop start for channel1
  moveq   #FALSE,d0
  move.b  d0,pt_InitAllChanLoopDataFlag(a3) ;Deactivate this routine
  move.w  pt_audchan1temp+n_replen(pc),AUD0LEN-DMACONR(a6) ;Set repeat length for channel1
  move.l  pt_audchan2temp+n_loopstart(pc),AUD1LCH-DMACONR(a6) ;Set loop start for channel2
  move.w  pt_audchan2temp+n_replen(pc),AUD1LEN-DMACONR(a6) ;Set repeat length for channel2
  move.l  pt_audchan3temp+n_loopstart(pc),AUD2LCH-DMACONR(a6) ;Set loop start for channel3
  move.w  pt_audchan3temp+n_replen(pc),AUD2LEN-DMACONR(a6) ;Set repeat length for channel3
  move.l  pt_audchan4temp+n_loopstart(pc),AUD3LCH-DMACONR(a6) ;Set loop start for channel4
  move.w  pt_audchan4temp+n_replen(pc),AUD3LEN-DMACONR(a6) ;Set repeat length for channel4
  rts
 
;--> Set all audio channels DMA <--
  CNOP 0,4
pt_SetAllChanDMA
  move.w  pt_DMACONtemp(a3),d0 ;Get channel DMA bits
  or.w    #DMAF_SETCLR,d0    ;DMA on
  move.w  d0,DMACON-DMACONR(a6) ;Set channel DMA bits
  moveq   #FALSE,d0          ;FALSE upper byte = Deactivate this routine
  addq.b  #CIACRBF_START,CIACRB(a5) ;Start CIA-B timerB for DMA wait
  clr.b   d0                 ;TRUE lower byte = Activate init routine
  move.w  d0,pt_SetAllChanDMAFlag(a3) ;Save new routine states
  rts
 
;--> E9 "Retrig Note" or ED "Note Delay" <--
  IFNE pt_usedefx&(pt_ecmdbitretrignote+pt_ecmdbitnotedelay)
    CNOP 0,4
pt_RtnSetChan1DMA
    lea     pt_audchan1temp+n_rtnsetchandma(pc),a0 ;Pointer to set + init state
    move.w  #DMAF_AUD0+DMAF_SETCLR,DMACON-DMACONR(a6) ;Set audio channel DMA
    moveq   #FALSE,d0         ;FALSE upper byte = Deactivate this routine
    addq.b  #CIACRBF_START,CIACRB(a5) ;Start CIA-B timerB for DMA wait
    clr.b   d0                ;TRUE lower byte = Activate init routine
    move.w  d0,(a0)           ;Save new routine states
    rts
 
    CNOP 0,4
pt_RtnInitChan1Data
    lea     pt_audchan1temp+n_period(pc),a0 ;Pointer to note period
    move.w  (a0)+,AUD0PER-DMACONR(a6) ;Noteperiod
    moveq   #FALSE,d0
    move.b  d0,n_rtninitchandata-n_loopstart(a0) ;FALSE = Deactivate this routine
    move.l  (a0)+,AUD0LCH-DMACONR(a6) ;Setloopstart
    moveq   #DMAF_AUD1+DMAF_AUD2+DMAF_AUD3,d0 ;Mask out channel1 DMA bit
    move.w  (a0),AUD0LEN-DMACONR(a6) ;Set repeat length

;--> Check next audio channel bit for "Retrig Note" or "Note Delay" command <--
 ;d0...MaskefürRetrigDMACONtemp
pt_RtnChkNextChan
    and.w   d0,pt_RtnDMACONtemp(a3) ;Clear audio channel DMA bit
    bne.s   pt_RtnStartChanTimer ;If other channel DMA bits are set -> skip
pt_RtnChkSetAllChanDMA
    tst.b   pt_SetAllChanDMAFlag(a3) ;Flag set?
    bne.s   pt_NoSetAllChanDMA ;No -> skip
pt_RtnStartChanTimer
    addq.b  #CIACRBF_START,CIACRB(a5) ;Start CIA-B timerB for DMA wait
pt_NoSetAllChanDMA
    rts
  
    CNOP 0,4
pt_RtnSetChan2DMA
    lea     pt_audchan2temp+n_rtnsetchandma(pc),a0
    move.w  #DMAF_AUD1+DMAF_SETCLR,DMACON-DMACONR(a6) ;Set audio channel DMA
    moveq   #FALSE,d0        ;FALSE upper byte = Deactivate this routine
    addq.b  #CIACRBF_START,CIACRB(a5) ;Start CIA-B timerB for DMA wait
    clr.b   d0               ;TRUE lower byte = Activate ini troutine
    move.w  d0,(a0)          ;Save new routine states
    rts
  
    CNOP 0,4
pt_RtnInitChan2Data
    lea     pt_audchan2temp+n_period(pc),a0 ;Pointer to note period
    move.w  (a0)+,AUD1PER-DMACONR(a6) ;Note period
    moveq   #FALSE,d0
    move.b  d0,n_rtninitchandata-n_loopstart(a0) ;Deactivate this routine
    move.l  (a0)+,AUD1LCH-DMACONR(a6) ;Set loop start
    moveq   #DMAF_AUD2+DMAF_AUD3,d0 ;Mask out channel1+2 DMA bit
    move.w  (a0),AUD1LEN-DMACONR(a6) ;Set repeat length
    bra.s   pt_RtnChkNextChan
  
    CNOP 0,4
pt_RtnSetChan3DMA
    lea     pt_audchan3temp+n_rtnsetchandma(pc),a0
    move.w  #DMAF_AUD2+DMAF_SETCLR,DMACON-DMACONR(a6) ;Set audio channel DMA
    moveq   #FALSE,d0        ;FALSE upper byte = Deactivate this routine
    addq.b  #CIACRBF_START,CIACRB(a5) ;Start CIA-B timerB for DMA wait
    clr.b   d0               ;TRUE lower byte = Activate init routine
    move.w  d0,(a0)          ;Save new routine states
    rts
  
    CNOP 0,4
pt_RtnInitChan3Data
    lea     pt_audchan3temp+n_period(pc),a0 ;Pointer to note period
    move.w  (a0)+,AUD2PER-DMACONR(a6) ;Note period
    moveq   #FALSE,d0
    move.b  d0,n_rtninitchandata-n_loopstart(a0) ;Deactivate this routine
    move.l  (a0)+,AUD2LCH-DMACONR(a6) ;Set loop start
    moveq   #DMAF_AUD3,d0    ;Mask out channel1+2+3 DMA bit
    move.w  (a0),AUD2LEN-DMACONR(a6) ;Set repeat length
    bra.s   pt_RtnChkNextChan
  
    CNOP 0,4
pt_RtnSetChan4DMA
    lea     pt_audchan4temp+n_rtnsetchandma(pc),a0
    move.w  #DMAF_AUD3+DMAF_SETCLR,DMACON-DMACONR(a6) ;Set audio channel DMA
    moveq   #FALSE,d0        ;FALSE upper byte = Deactivate this routine
    addq.b  #CIACRBF_START,CIACRB(a5) ;Start CIA-B timerB for DMA wait
    clr.b   d0               ;TRUE lower byte = Activate init routine
    move.w  d0,(a0)          ;Save new routine states
    rts
  
    CNOP 0,4
pt_RtnInitChan4Data
    subq.w  #DMAF_AUD3,pt_RtnDMACONtemp(a3) ;Clear channel4 DMA bit
    lea     pt_audchan4temp+n_period(pc),a0 ;Pointer to note period
    move.w  (a0)+,AUD3PER-DMACONR(a6) ;Note period
    moveq   #FALSE,d0
    move.b  d0,n_rtninitchandata-n_loopstart(a0) ;FALSE = Deactivate this routine
    move.l  (a0)+,AUD3LCH-DMACONR(a6) ;Set loop start
    move.w  (a0),AUD3LEN-DMACONR(a6) ;Set repeat length
    bra     pt_RtnChkSetAllChanDMA
  ENDC
  ENDM

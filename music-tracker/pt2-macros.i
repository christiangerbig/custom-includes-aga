; Includedatei: "normsource-includes/music-tracker/macros-pt2.i"
; Datum:        4.6.2023
; Version:      1.0


PT2_INIT_VARIABLES MACRO
; \1 STRING "NOPOINTERS" are initialized
  IFC "","\1"
    lea     pt_auddata,a0
    move.l  a0,pt_SongDataPointer(a3)
    IFEQ pt_split_module_enabled
      lea     pt_audsmps,a0
      move.l  a0,pt_SamplesDataPointer(a3)
    ENDC
  ENDC
  moveq   #0,d0
  move.w  d0,pt_Counter(a3)
  moveq   #pt_defaultticks,d2
  move.w  d2,pt_CurrSpeed(a3) ;Set as default 6 ticks
  move.w  d0,pt_DMACONtemp(a3)
  move.w  d0,pt_PatternPosition(a3)
  move.w  d0,pt_SongPosition(a3)
;--> E9 "Retrig Note" or ED "Note Delay" used <--
  IFNE pt_usedefx&(pt_ecmdbitretrignote|pt_ecmdbitnotedelay)
    move.w d0,pt_RtnDMACONtemp(a3)
  ENDC
  moveq #FALSE,d1
  IFEQ pt_music_fader_enabled
    move.w d1,pt_fade_out_music_active(a3) ;Deactivate volume fader
    moveq #pt_fade_out_delay,d2
    move.w d2,pt_fade_out_delay_counter(a3) ;Set volume fader delay in ticks
    moveq #pt_maxvol,d2
    move.w d2,pt_master_volume(a3) ;Set maximum master volume
  ENDC
  move.b  d1,pt_SetAllChanDMAFlag(a3) ;Deactivate set routine
  move.b  d1,pt_InitAllChanLoopDataFlag(a3) ;Deactivate init routine
;--> Bxx "Position Jump"or Dxx "Pattern Break" <--
  IFNE pt_usedfx&(pt_cmdbitposjump|pt_cmdbitpattbreak)
    move.b  d0,pt_PBreakPosition(a3)
    move.b  d0,pt_PosJumpFlag(a3)
  ENDC
;--> E1 "Fine Portamento Up" or E2 "Fine Portamento Down" <--
  IFNE pt_usedefx&(pt_ecmdbitfineportup|pt_ecmdbitfineportdown)
    move.b  d0,pt_LowMask(a3)
  ENDC
;--> E6x "Jump to Loop" <--
  IFNE pt_usedefx&pt_ecmdbitjumptoloop
    move.b  d0,pt_PBreakFlag(a3)
  ENDC
;--> EEx" Pattern Delay" <--
  IFNE pt_usedefx&pt_ecmdbitpattdelay
    move.b  d0,pt_PattDelayTime(a3)
    move.b  d0,pt_PattDelayTime2(a3)
  ENDC
  ENDM


PT2_REPLAY MACRO
; \1 LABEL: Subroutine for effect command 8 called at tick #1 optional
pt_PlayMusic
  move.l  a6,-(a7)
  moveq   #TRUE,d5           ;Constant: zero longword for all clear operations
  addq.w  #1,pt_Counter(a3)  ;Increment ticks counter
  move.w  #pt_cmdpermask,d6  ;Constant: Mask out samplenumber/FALSE.b
  move.w  pt_Counter(a3),d0  ;Get ticks
  ADDF.W  AUD0LCH-2,a6       ;Pointer to first audio channel address in CUSTOMCHIP space
  cmp.w   pt_CurrSpeed(a3),d0 ;Ticks < speedticks?
  blo.s   pt_NoNewNote       ;Yes -> skip
  move.w  d5,pt_Counter(a3)  ;If ticks >= speedticks -> set back ticks counter = tick#1
;--> EEx "Pattern Delay" <--
  IFNE pt_usedefx&pt_ecmdbitpattdelay
    tst.b   pt_PattDelayTime2(a3) ;Any pattern delay time2 ?
    beq     pt_GetNewNote    ;If zero -> skip
  ELSE
    bra     pt_GetNewNote
  ENDC
  bsr.s   pt_NoNewAllChannels
  bra     pt_Dskip
 
;--> No new note <--
  CNOP 0,4
pt_NoNewNote
  bsr.s   pt_NoNewAllChannels
  bra     pt_NoNewPositionYet
 
;--> Check audio channels for effect commands at ticks #2..#speedticks <--
  CNOP 0,4
pt_NoNewAllChannels
  lea     pt_audchan1temp(pc),a2 ;Pointer to first channel temporary structure
  bsr.s   pt_CheckEffects
  ADDF.W  16,a6              ;Pointer to next audio channel
  lea     pt_audchan2temp(pc),a2
  bsr.s   pt_CheckEffects
  ADDF.W  16,a6
  lea     pt_audchan3temp(pc),a2
  bsr.s   pt_CheckEffects
  ADDF.W  16,a6
  lea     pt_audchan4temp(pc),a2
  bsr.s   pt_CheckEffects
;--> E9 "Retrig Note" or ED "Note Delay" used <--
  IFNE pt_usedefx&(pt_ecmdbitretrignote|pt_ecmdbitnotedelay)
pt_RtnChkAllChannels
    tst.w    pt_RtnDMACONtemp(a3) ;"Retrig Note" or "Note Delay" used by one of the channels?
    beq.s    pt_NoRtnSetTimer ;Zero -> skip
    moveq    #CIACRBF_START,d0
    or.b     d0,CIACRB(a5)   ;Start CIA-B timerB for DMA wait
pt_NoRtnSetTimer
  ENDC
  rts
 
;--> Effect commands at ticks #2..#speedticks <--
  CNOP 0,4
pt_CheckEffects
;--> EFx" InvertLoop" used <--
  IFNE pt_usedefx&pt_ecmdbitinvertloop
    bsr     pt_UpdateInvert
  ENDC
  IFNE pt_usedfx
    move.w  n_cmd(a2),d0       ;Get channel effect command
    and.w   d6,d0              ;without lower nibble of sample number
    beq.s   pt_ChkEfxPerNop    ;If no command -> skip
    ;moveq   #pt_cmdmask,d0    ;Get channel effect command number without lower nibble of sample number
    ;and.b   n_cmd(a2),d0
    lsr.w   #BYTE_SHIFT_BITS,d0  ;Shift command number to lower nibble
  ENDC
;--> 0xy "Normal play" or "Arpeggio" <--
  IFNE pt_usedfx&pt_cmdbitarpeggio
    beq.s pt_Arpeggio
  ENDC
;--> 1xx "Portamento Up" <--
  IFNE pt_usedfx&pt_cmdbitportup
    cmp.b   #pt_cmdportup,d0
    beq     pt_PortamentoUp
  ENDC
;--> 2xx "PortamentoDown" <--
  IFNE pt_usedfx&pt_cmdbitportdown
    cmp.b   #pt_cmdportdown,d0
    beq     pt_PortamentoDown
  ENDC
;--> 3xx "Tone Portamento" <--
  IFNE pt_usedfx&pt_cmdbittoneport
    cmp.b   #pt_cmdtoneport,d0
    beq     pt_TonePortamento
  ENDC
;--> 4xy"Vibrato" <--
  IFNE pt_usedfx&pt_cmdbitvibrato
    cmp.b   #pt_cmdvibrato,d0
    beq     pt_Vibrato
  ENDC
;--> 5xy "Tone Portamento + Volume Slide" <--
  IFNE pt_usedfx&pt_cmdbittoneportvolslide
    cmp.b   #pt_cmdtoneportvolslide,d0
    beq     pt_TonePortaPlusVolSlide
  ENDC
;--> 6xy "Vibrato + Volume Slide" <--
  IFNE pt_usedfx&pt_cmdbitvibratovolslide
    cmp.b   #pt_cmdvibratovolslide,d0
    beq     pt_VibratoPlusVolSlide
  ENDC
;--> E "Extended commands" <--
  IFNE pt_usedfx&pt_cmdbitextended
   cmp.b    #pt_cmdextended,d0
   beq      pt_ExtCommands
  ENDC
pt_SetBack
  move.w  n_period(a2),6(a6);AUDxPERSetbackperiod
;--> 7xy"Tremolo" <--
  IFNE pt_usedfx&pt_cmdbittremolo
    cmp.b   #pt_cmdtremolo,d0
    beq     pt_Tremolo
  ENDC
;--> Axy "VolumeSlide" <--
  IFNE pt_usedfx&pt_cmdbitvolslide
    cmp.b   #pt_cmdvolslide,d0
    beq     pt_VolumeSlide
  ENDC
  rts
  IFNE pt_usedfx
    CNOP 0,4
pt_ChkEfxPerNop
    move.w n_period(a2),6(a6)  ;AUDxPER Set period back
    rts
  ENDC

;--> 0xy "Normal play" or "Arpeggio" <--
  IFNE pt_usedfx&pt_cmdbitarpeggio
    PT2_EFFECT_ARPEGGIO
  ENDC
 
;--> 1xx "PortamentoUp" <--
  IFNE pt_usedfx&pt_cmdbitportup
    PT2_EFFECT_PORTAMENTO_UP
  ELSE
    IFNE pt_usedefx&pt_ecmdbitfineportup
      PT2_EFFECT_PORTAMENTO_UP
    ENDC
  ENDC

;--> 2xx "Portamento Down" <--
  IFNE pt_usedfx&pt_cmdbitportdown
    PT2_EFFECT_PORTAMENTO_DOWN
  ELSE
    IFNE pt_usedefx&pt_ecmdbitfineportdown
      PT2_EFFECT_PORTAMENTO_DOWN
    ENDC
  ENDC

;--> 5xy "Tone Portamento + Volume Slide" <--
  IFNE pt_usedfx&pt_cmdbittoneportvolslide
    PT2_EFFECT_TONE_PORTAMENTO_VOLUME_SLIDE
  ENDC

;--> 3xx "Tone Portamento" or 5xy "Tone Portamento + Volume Slide" <--
  IFNE pt_usedfx&(pt_cmdbittoneport|pt_cmdbittoneportvolslide)
    PT2_EFFECT_TONE_PORTAMENTO
  ENDC
 
;--> 4xy "Vibrato" or 6xy "Vibrato + Volume Slide" <--
  IFNE pt_usedfx&(pt_cmdbitvibrato|pt_cmdbitvibratovolslide)
    PT2_EFFECT_VIBRATO
  ENDC

;--> 6xy "Vibrato + Volume Slide" <--
  IFNE pt_usedfx&pt_cmdbitvibratovolslide
    PT2_EFFECT_VIBRATO_VOLUME_SLIDE
  ENDC

;--> Exy"Extended commands" at ticks #2..#speed <--
  IFNE pt_usedefx
    CNOP 0,4
pt_ExtCommands
    IFNE pt_usedefx&(pt_ecmdbitretrignote|pt_ecmdbitnotecut|pt_ecmdbitnotedelay)
      move.b  n_cmdlo(a2),d0 ;Get channel extended effect command number
      lsr.b   #NIBBLE_SHIFT_BITS,d0 ;Shift command number to lower nibble
      cmp.b   #pt_ecmdnotused,d0
      ble.s   pt_ExtCommandsEnd
    ENDC
;--> E9x "Retrig Note" <--
    IFNE pt_usedefx&pt_ecmdbitretrignote
      cmp.b   #pt_ecmdretrignote,d0
      beq     pt_RetrigNote
    ENDC
;--> ECx "NoteCut" <--
    IFNE pt_usedefx&pt_ecmdbitnotecut
      cmp.b   #pt_ecmdnotecut,d0
      beq     pt_NoteCut
    ENDC
;--> EDx "NoteDelay" <--
    IFNE pt_usedefx&pt_ecmdbitnotedelay
      cmp.b   #pt_ecmdnotedelay,d0
      beq     pt_NoteDelay
    ENDC
pt_ExtCommandsEnd
    rts
  ENDC

;--> 7xy"Tremolo" <--
  IFNE pt_usedfx&pt_cmdbittremolo
    PT2_EFFECT_TREMOLO
  ENDC

;--> 5xy "Tone Portamento + Volume Slide" or 6xy "Vibrato + Volume Slide or Axy "Volume Slide" <--
  IFNE pt_usedfx&(pt_cmdbittoneport|pt_cmdbittoneportvolslide|pt_cmdbitvibratovolslide|pt_cmdbitvolslide)
    PT2_EFFECT_VOLUME_SLIDE
  ELSE
    IFNE pt_usedefx&pt_ecmdbitfinevolslideup
      PT2_EFFECT_VOLUME_SLIDE
    ELSE
      IFNE pt_usedefx&pt_ecmdbitfinevolslidedown
        PT2_EFFECT_VOLUME_SLIDE
      ENDC
    ENDC
  ENDC

;--> Get new note and pattern position at tick #1 <--
  CNOP 0,4
pt_GetNewNote
  move.l  pt_SongDataPointer(a3),a0 ;Pointer to module
  move.w  pt_SongPosition(a3),d0 ;Get song position
  moveq   #TRUE,d1           ;Needed for word access
  move.b  (pt_sd_pattpos,a0,d0.w),d1 ;Get pattern number in song position table
  MULUF.W pt_pattsize/4,d1   ;Pattern offset
  add.w   pt_PatternPosition(a3),d1 ;Add pattern position
  move.w  d5,pt_DMACONtemp(a3) ;ClearDMAbits
  lea     pt_audchan1temp(pc),a2 ;Pointer to audio channel temporary structure
  bsr.s   pt_PlayVoice
  ADDF.W  16,a6              ;Next audio channel
  lea     pt_audchan2temp(pc),a2
  bsr.s   pt_PlayVoice
  ADDF.W  16,a6
  lea     pt_audchan3temp(pc),a2
  bsr.s   pt_PlayVoice
  ADDF.W  16,a6
  lea     pt_audchan4temp(pc),a2
  bsr.s   pt_PlayVoice
  bra     pt_SetDMA
 
;--> Get new note data <--
  CNOP 0,4
pt_PlayVoice
  tst.l   (a2)               ;Get last note data
  bne.s   pt_PlvSkip         ;If note period or effect command -> skip
  move.w  n_period(a2),6(a6) ;AUDxPER Set note period
pt_PlvSkip
  moveq   #TRUE,d2           ;Needed for word access
  move.l  (pt_sd_patterndata,a0,d1.l*4),(a2) ;Get new note data from pattern
  MOVEF.B NIBBLE_MASK_HIGH,d0    ;Mask for upper nibble of sample number
  move.b  n_cmd(a2),d2
  lsr.b   #NIBBLE_SHIFT_BITS,d2 ;Get lower nibble of sample number
  and.b   (a2),d0            ;Get upper nibble of sample number
  addq.w  #pt_noteinfo_size/4,d1 ;Next channel data
  or.b    d0,d2              ;Get sample number $01..$1f
  beq.s   pt_SetRegisters    ;If no sample number -> skip
  subq.w  #1,d2              ;x = sample number - 1
  lea     pt_SampleStarts(pc),a1 ;Pointer to sample pointers table
  move.w  d2,d3              ;Save x
  ;MULUF.W 2,d2               ;x*2
  ;move.w  d2,d3              ;Savex*2
  ;MULUF.W 2,d2               ;x*2
  move.l  (a1,d2.w*4),a1     ;Get sample data pointer
  ;MULUF.W 8,d2               ;x*8
  MULUF.W 16,d2              ;x*16
  move.l  a1,n_start(a2)     ;Savesamplestart
  sub.w   d3,d2              ;(x*16)-x=sampleinfostructurelengthinwords
  ;sub.w   d3,d2              ;(x*32)-(x*2)=sampleinfostructurelengthinbytes
  movem.w pt_sd_sampleinfo+pt_si_samplelength(a0,d2.w*2),d0/d2-d4 ;length, finetune, volume, repeat point, repeat length
  ;movem.w pt_sd_sampleinfo+pt_si_samplelength(a0,d2.w),d0/d2-d4   ;length, finetune, volume, repeat point, repeat length
  move.w  d0,n_reallength(a2) ;Save real sample length
  move.w  d2,n_finetune(a2)  ;Save finetune and sample volume
  ext.w   d2                 ;Extend lower byte to word
  IFEQ pt_music_fader_enabled
    mulu.w  pt_master_volume(a3),d2 ;volume * master_volume
    lsr.w   #6,d2            ;/ maximum master volume
  ENDC
  IFEQ pt_track_periods_enabled
    move.w  d2,n_current_volume(a2) ;Save new volume
  ENDC
  IFEQ pt_mute_enabled
    move.w  d5,8(a6)         ;AUDxVOL No volume
  ELSE
    move.w  d2,8(a6)         ;AUDxVOL Set new volume
  ENDC
  cmp.w   #1,d4              ;Repeat length = 1 word ?
  beq.s   pt_NoLoopSample    ;Yes -> skip
pt_LoopSample
  move.w  d3,d0              ;Save repeat point
  MULUF.W 2,d3               ;*2 = repeat point in bytes
  add.w   d4,d0              ;Add repeat length
  add.l   d3,a1              ;Add repeat point
pt_NoLoopSample
  move.w  d0,n_length(a2)    ;Save length
  move.w  d4,n_replen(a2)    ;Save repeat length
  move.l  a1,n_loopstart(a2) ;Save loop start
  move.l  a1,n_wavestart(a2) ;Save wave start
 
pt_SetRegisters
  move.w  (a2),d3            ;Get note period from pattern position
  and.w   d6,d3              ;without higher nibble of sample number
  beq     pt_CheckMoreEffects ;If no note period -> skip
  move.w  n_cmd(a2),d4       ;Get effect command
  and.w   #pt_ecmdmask,d4    ;without lower nibble of sample number and command data
  beq.s   pt_SetPeriod       ;If no effect command -> skip
;--> E5x"Set Sample Finetune" <--
  IFNE pt_usedefx&pt_ecmdbitsetsamplefinetune
    cmp.w   #$0e50,d4
    beq     pt_DoSetSampleFinetune
  ENDC
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmd(a2),d0       ;Get channel effect command number without lower nibble of sample nu<mber
;--> 3xx "Tone Portamento" <--
  IFNE pt_usedfx&pt_cmdbittoneport
    cmp.b   #pt_cmdtoneport,d0
    beq     pt_ChkTonePorta
  ENDC
;--> 5xy "Tone Portamento + VolumeSlide" <--
  IFNE pt_usedfx&pt_cmdbittoneportvolslide
    cmp.b   #pt_cmdtoneportvolslide,d0
    beq     pt_ChkTonePorta
  ENDC
;--> 9xx"Set Sample Offset" <--
  IFNE pt_usedfx&pt_cmdbitsetsampleoffset
    cmp.b   #pt_cmdsetsampleoffset,d0
    bne.s   pt_SetPeriod
    bsr     pt_SetSampleOffset
  ENDC
 
pt_SetPeriod
  IFEQ pt_finetune_enabled
    moveq   #0,d0         ;Needed for word access
    move.b  n_finetune(a2),d0 ;Get finetune
    beq.s   pt_NoFinetune    ;If no finetune -> skip
    lea     pt_PeriodTable(pc),a1 ;Pointer to periods table
    moveq   #((pt_PeriodTableEnd-pt_PeriodTable)/2)-1,d7 ;Number of periods
pt_FtuLoop
   cmp.w    (a1)+,d3         ;Note period >= table note period ?
   dbhs     d7,pt_FtuLoop    ;If not -> loop until counter = FALSE
pt_FtuFound
   lea      pt_FtuPeriodTableStarts(pc),a1 ;Pointer to finetune period table pointers
   move.l   (a1,d0.w*4),a1   ;Get period table address for given finetune value
   moveq    #((pt_PeriodTableEnd-pt_PeriodTable)/2)-1,d0
   sub.w    d7,d0            ;Number of periods - loopcounter = offset in periods table
   move.w   (a1,d0.w*2),d3   ;Get new note period from table
pt_NoFinetune
  ENDC
  move.w  d3,n_period(a2)    ;Save new note period
 ;--> EDx "Note Delay" <--
  IFNE pt_usedefx&pt_ecmdbitnotedelay
    cmp.w   #$0ed0,d4
    beq     pt_CheckMoreEffects
  ENDC
  move.w  n_dmabit(a2),d0   ;Get audio channel DMA bit
  or.w    d0,pt_DMACONtemp(a3) ;Set audio channel DMA bit
  move.w  d0,_CUSTOM+DMACON ;Audiochannel DMA off
;--> 4xy "Vibrato" <--
  IFNE pt_usedfx&pt_cmdbitvibrato
    btst   #pt_vibnoretrigbit,n_wavecontrol(a2) ;Vibratotype 4 - no retrig waveform ?
    bne.s pt_VibNoC          ;Yes -> skip
    move.b d5,n_vibratopos(a2) ;Clear vibrato position
pt_VibNoC
  ENDC
;--> 7xy"Tremolo" <--
  IFNE pt_usedfx&pt_cmdbittremolo
    btst   #pt_trenoretrigbit,n_wavecontrol(a2) ;Tremolotype 4 - no retrig waveform ?
    bne.s  pt_TreNoC     ;Yes -> skip
    move.b d5,n_tremolopos(a2) ;Clear tremolo position
pt_TreNoC
  ENDC
  IFEQ pt_track_volumes_enabled
    move.b d5,n_note_trigger(a2) ;Set note trigger flag
  ENDC
  move.l  n_start(a2),(a6)   ;AUDxLCH Set sample start
  move.l  n_length(a2),4(a6) ;AUDxLEN Set length & new note period

;--> More effect commands at tick #1 <--
pt_CheckMoreEffects
;--> EFx "Invert Loop" <--
  IFNE pt_usedefx&pt_ecmdbitinvertloop
    bsr     pt_UpdateInvert
  ENDC
  IFNE pt_usedfx&(pt_cmdbitnotused|pt_cmdbitsetsampleoffset|pt_cmdbitposjump|pt_cmdbitsetvolume|pt_cmdbitpattbreak|pt_cmdbitextended|pt_cmdbitsetspeed)
    moveq   #pt_cmdmask,d0
    and.b   n_cmd(a2),d0       ;Get channel effect command number without lower nibble of sample number
    cmp.b   #pt_cmdnotused,d0  ;0-8 ?
;--> 8xy "Not used/custom" <--
    IFEQ pt_usedfx&pt_cmdbitnotused
      ble.s   pt_ChkMoreEfxPerNop ;<= 8 -> skip
    ELSE
      blt.s   pt_ChkMoreEfxPerNop ;< 8 -> skip
      beq     \1
    ENDC
  ENDC
;--> 9xx "Set Sample Offset" <--
  IFNE pt_usedfx&pt_cmdbitsetsampleoffset
    cmp.b   #pt_cmdsetsampleoffset,d0
    beq.s   pt_SetSampleOffset
  ENDC
;--> Bxx "Position Jump" <--
  IFNE pt_usedfx&pt_cmdbitposjump
    cmp.b   #pt_cmdposjump,d0
    beq.s   pt_PositionJump
  ENDC
;--> Cxx "Set Volume" <--
  IFNE pt_usedfx&pt_cmdbitsetvolume
    cmp.b   #pt_cmdsetvolume,d0
    beq.s   pt_SetVolume
  ENDC
;--> Dxx "Pattern Break" <--
  IFNE pt_usedfx&pt_cmdbitpattbreak
    cmp.b   #pt_cmdpattbreak,d0
    beq.s   pt_PatternBreak
  ENDC
;--> E "Extended commands" <--
  IFNE pt_usedfx&pt_cmdbitextended
    cmp.b   #pt_cmdextended,d0
    beq     pt_MoreExtCommands
  ENDC
;--> Fxx "Set Speed" <--
  IFNE pt_usedfx&pt_cmdbitsetspeed
    cmp.b   #pt_cmdsetspeed,d0
    beq     pt_SetSpeed
  ENDC
pt_ChkMoreEfxPerNop
  move.w n_period(a2),6(a6)  ;AUDxPER Set note period
  rts
 
;--> 9xx "Set Sample Offset" <--
  IFNE pt_usedfx&pt_cmdbitsetsampleoffset
    PT2_EFFECT_SET_SAMPLE_OFFSET
  ENDC
 
;--> Bxx "Position Jump" <--
  IFNE pt_usedfx&pt_cmdbitposjump
    PT2_EFFECT_POSITION_JUMP
  ENDC
 
;--> Cxx "Set Volume" <--
  IFNE pt_usedfx&pt_cmdbitsetvolume
    PT2_EFFECT_SET_VOLUME
  ENDC
 
;--> Dxx "Pattern Break" <--
  IFNE pt_usedfx&pt_cmdbitpattbreak
    PT2_EFFECT_PATTERN_BREAK
  ENDC
 
;--> Exy "Extended commands"at tick #1 <--
  CNOP 0,4
pt_MoreExtCommands
  IFNE pt_usedefx
    move.b  n_cmdlo(a2),d0     ;Get channel extended effect command number
    lsr.b   #NIBBLE_SHIFT_BITS,d0 ;Shift command number to lower nibble
  ENDC
;--> E0x "Set Filter" <--
  IFNE pt_usedefx&pt_ecmdbitsetfilter
    beq.s   pt_SetFilter
  ENDC
;--> E1x "Fine Portamento Up" <--
  IFNE pt_usedefx&pt_ecmdbitfineportup
    cmp.b   #pt_ecmdfineportup,d0
    beq     pt_FinePortamentoUp
  ENDC
;--> E2x "Fine Portamento Down" <--
  IFNE pt_usedefx&pt_ecmdbitfineportdown
    cmp.b   #pt_ecmdfineportdown,d0
    beq     pt_FinePortamentoDown
  ENDC
;--> E3x "Set Glissando Control" <--
  IFNE pt_usedefx&pt_ecmdbitsetglisscontrol
    cmp.b   #pt_ecmdsetglisscontrol,d0
    beq     pt_SetGlissandoControl
  ENDC
;--> E4x "Set Vibrato Waveform" <--
  IFNE pt_usedefx&pt_ecmdbitsetvibwaveform
    cmp.b   #pt_ecmdsetvibwaveform,d0
    beq     pt_SetVibratoWaveform
  ENDC
;--> E5x "Set Sample Finetune" <--
  IFNE pt_usedefx&pt_ecmdbitsetsamplefinetune
    cmp.b   #pt_ecmdsetsamplefinetune,d0
    beq     pt_SetSampleFinetune
  ENDC
;--> E6x "Jump to Loop" <--
  IFNE pt_usedefx&pt_ecmdbitjumptoloop
    cmp.b   #pt_ecmdjumptoloop,d0
    beq     pt_JumpToLoop
  ENDC
;--> E7x "Set Tremolo Waveform" <--
  IFNE pt_usedefx&pt_ecmdbitsettrewaveform
    cmp.b   #pt_ecmdsettrewaveform,d0
    beq     pt_SetTremoloWaveform
  ENDC
;--> E9x "Retrig Note" <--
  IFNE pt_usedefx&pt_ecmdbitretrignote
    cmp.b   #pt_ecmdretrignote,d0
    beq     pt_RetrigNote
  ENDC
;--> EAx "Fine Volume Slide Up" <--
  IFNE pt_usedefx&pt_ecmdbitfinevolslideup
    cmp.b   #pt_ecmdfinevolslideup,d0
    beq     pt_FineVolumeSlideUp
  ENDC
;--> EBy "Fine Volume Slide Down" <--
  IFNE pt_usedefx&pt_ecmdbitfinevolslidedown
    cmp.b   #pt_ecmdfinevolslidedown,d0
    beq     pt_FineVolumeSlideDown
  ENDC
;--> ECx "Note Cut" <--
  IFNE pt_usedefx&pt_ecmdbitnotecut
    cmp.b   #pt_ecmdnotecut,d0
    beq     pt_NoteCut
  ENDC
;--> EDx "Note Delay" <--
  IFNE pt_usedefx&pt_ecmdbitnotedelay
    cmp.b   #pt_ecmdnotedelay,d0
    beq     pt_NoteDelay
  ENDC
;--> EEx "Pattern Delay" <--
  IFNE pt_usedefx&pt_ecmdbitpattdelay
    cmp.b   #pt_ecmdpattdelay,d0
    beq     pt_PatternDelay
  ENDC
;--> EFx "Invert Loop" <--
  IFNE pt_usedefx&pt_ecmdbitinvertloop
    cmp.b   #pt_ecmdinvertloop,d0
    beq     pt_InvertLoop
  ENDC
  rts
 
;--> E0x "Set Filter" <--
  IFNE pt_usedefx&pt_ecmdbitsetfilter
    PT2_EFFECT_SET_FILTER
  ENDC 

;--> E1x "Fine Portamento Up" <--
  IFNE pt_usedefx&pt_ecmdbitfineportup
    PT2_EFFECT_FINE_PORTAMENTO_UP
  ENDC 

;--> E2x "Fine Portamento Down" <--
  IFNE pt_usedefx&pt_ecmdbitfineportdown
    PT2_EFFECT_FINE_PORTAMENTO_DOWN
  ENDC 

;--> E3x "Set Glissando Control" <--
  IFNE pt_usedefx&pt_ecmdbitsetglisscontrol
    PT2_EFFECT_SET_GLISSANDO_CONTROL
  ENDC
 
;--> E4x "Set Vibrato Waveform" <--
  IFNE pt_usedefx&pt_ecmdbitsetvibwaveform
    PT2_EFFECT_SET_VIBRATO_WAVEFORM
  ENDC 

;--> E5x "Set Sample Finetune" <--
  IFNE pt_usedefx&pt_ecmdbitsetsamplefinetune
    PT2_EFFECT_SET_SAMPLE_FINETUNE
  ENDC 

;--> E6x "Jump to Loop" <--
  IFNE pt_usedefx&pt_ecmdbitjumptoloop
    PT2_EFFECT_JUMP_TO_LOOP
  ENDC 

;--> E7x "Set Tremolo Waveform" <--
  IFNE pt_usedefx&pt_ecmdbitsettrewaveform
    PT2_EFFECT_SET_TREMOLO_WAVEFORM
  ENDC 

;--> E9x "Retrig Note" or EDx "Note Delay" <--
  IFNE pt_usedefx&(pt_ecmdbitretrignote|pt_ecmdbitnotedelay)
    PT2_EFFECT_RETRIG_NOTE
  ENDC 

;--> EAx "Fine Volume Slide Up" <--
  IFNE pt_usedefx&pt_ecmdbitfinevolslideup
    PT2_EFFECT_FINE_VOLUME_SLIDE_UP
  ENDC 

;--> EBy "Fine Volume Slide Down" <--
  IFNE pt_usedefx&pt_ecmdbitfinevolslidedown
    PT2_EFFECT_FINE_VOLUME_SLIDE_DOWN
  ENDC 

;--> ECx "Note Cut" <--
  IFNE pt_usedefx&pt_ecmdbitnotecut
    PT2_EFFECT_NOTE_CUT
  ENDC 

;--> EDx "Note Delay" <--
  IFNE pt_usedefx&pt_ecmdbitnotedelay
    PT2_EFFECT_NOTE_DELAY
  ENDC 

;--> EEx "Pattern Delay" <--
  IFNE pt_usedefx&pt_ecmdbitpattdelay
    PT2_EFFECT_PATTERN_DELAY
  ENDC

;--> EFx "Invert Loop" <--
  IFNE pt_usedefx&pt_ecmdbitinvertloop
    PT2_EFFECT_INVERT_LOOP
  ENDC

;--> Fxx "Set Speed" <--
  IFNE pt_usedfx&pt_cmdbitsetspeed
    PT2_EFFECT_SET_SPEED
  ENDC

;--> E5x "Set Sample Finetune" <--
  IFNE pt_usedefx&pt_ecmdbitsetsamplefinetune
    CNOP 0,4
pt_DoSetSampleFinetune
    bsr    pt_SetSampleFinetune
    bra    pt_SetPeriod
  ENDC

;--> 3 "Tone Portamento" or 5 "Tone Portamento + Volume Slide" <--
  IFNE pt_usedfx&(pt_cmdbittoneport|pt_cmdbittoneportvolslide)
    CNOP 0,4
pt_ChkTonePorta
    bsr.s  pt_SetTonePorta
    bra    pt_CheckMoreEffects
  ENDC

;--> 3 "Tone Portamento" or 5 "Tone Portamento + Volume Slide" <--
  IFNE pt_usedfx&(pt_cmdbittoneport|pt_cmdbittoneportvolslide)
    CNOP 0,4
pt_SetTonePorta
    IFEQ pt_finetune_enabled
      move.b  n_finetune(a2),d0 ;Get finetune value
      beq.s   pt_StpNoFinetune ;If no finetune -> skip
      lea     pt_FtuPeriodTableStarts(pc),a1 ;Pointer to finetune offset periods table
      move.l  (a1,d0.w*4),a1 ;Get period table address
      move.l  a1,d2          ;Save period table address
      moveq   #((pt_PeriodTableEnd-pt_PeriodTable)/2)-1,d7 ;Number of periods
pt_StpLoop
      cmp.w   (a1)+,d3       ;Note period >= table note period ?
      dbhs    d7,pt_StpLoop  ;If not -> loop until counter = FALSE
      bhs.s   pt_StpFound    ;If found -> skip
      moveq   #TRUE,d7       ;Last note period in table
pt_StpFound
      moveq   #((pt_PeriodTableEnd-pt_PeriodTable)/2)-1,d0 ;Number of periods
      sub.w   d7,d0          ;Offset in period table
      move.l  d2,a1          ;Get period table address
      moveq   #NIBBLE_SIGN_MASK,d2 ;Mask for sign bit in nibble
      and.b   n_finetune(a2),d2 ;Sign bit for negative nibble value set ?
      beq.s   pt_StpGoss     ;If positive -> skip
      tst.w   d0             ;Counter = zero ?
      beq.s   pt_StpGoss     ;Yes -> skip
      subq.w  #1,d0          ;Increment counter
pt_StpGoss
      move.w  (a1,d0.w*2),d3 ;Get table note period
pt_StpNoFinetune
    ENDC
    move.w  d3,n_wantedperiod(a2) ;and save as wanted note period
    move.b  d5,n_toneportdirec(a2) ;Clear tone portamento direction
    cmp.w   n_period(a2),d3  ;Check wanted note period
    beq.s   pt_ClearTonePorta ;If wanted note period = note period -> stop tone portamento
    bgt.s   pt_StpEnd        ;If wanted note period > note period -> skip
    moveq   #1,d0
    move.b  d0,n_toneportdirec(a2) ;If wanted note period < note period -> Set to new portamento direction = 1
pt_StpEnd
    rts
    CNOP 0,4
pt_ClearTonePorta
    IFEQ pt_track_volumes_enabled
      move.b  d5,n_note_trigger(a2) ;Set note trigger flag
    ENDC
    move.w  d5,n_wantedperiod(a2) ;Clear wanted note period
    rts
  ENDC

  CNOP 0,4
pt_SetDMA
  move.b  d5,pt_SetAllChanDMAFlag(a3) ;TRUE = Activate SetDMA-interrupt routine
  moveq   #CIACRBF_START,d0
  or.b    d0,CIACRB(a5)    ;Start CIA-B timerB for DMA wait
 
pt_Dskip
  addq.w  #pt_pattposdata_size/4,pt_PatternPosition(a3) ;Next pattern position
 ;--> EEx "Pattern Delay" <--
  IFNE pt_usedefx&pt_ecmdbitpattdelay
   move.b  pt_PattDelayTime(a3),d0 ;Get pattern delay time
   beq.s   pt_DskipC         ;If zero -> skip
   move.b  d0,pt_PattDelayTime2(a3) ;Save pattern delay time2
   move.b  d5,pt_PattDelayTime(a3) ;Clear pattern delay time
pt_DskipC
   tst.b   pt_PattDelayTime2(a3) ;Get pattern delay time2
   beq.s   pt_DskipA         ;If zero -> skip
   subq.b  #1,pt_PattDelayTime2(a3) ;Decrement pattern delay time2
   beq.s   pt_DskipA         ;If zero -> skip
   subq.w  #pt_pattposdata_size/4,pt_PatternPosition(a3) ;Previous pattern position
pt_DskipA
  ENDC
;--> E6x "Jump to Loop" <--
  IFNE pt_usedefx&pt_ecmdbitjumptoloop
   tst.b   pt_PBreakFlag(a3) ;Pattern break flag set ?
   beq.s   pt_Nnpysk         ;If zero -> skip
   move.b  d5,pt_PBreakFlag(a3) ;Clear pattern break flag
   moveq   #0,d0          ;Needed for word access
   move.b  pt_PBreakPosition(a3),d0 ;Get pattern break position
   MULUF.W 2,d0              ;*(pt_pattposdata_size/4)
   move.b  d5,pt_PBreakPosition(a3) ;Clear pattern break position
   MULUF.W 2,d0
   move.w  d0,pt_PatternPosition(a3) ;Set new pattern position
pt_Nnpysk
  ENDC
  cmp.w    #pt_pattsize/4,pt_PatternPosition(a3) ;End of pattern reached ?
  blo.s    pt_NoNewPositionYet ;No -> skip
pt_NextPosition
  move.b  d5,pt_PosJumpFlag(a3) ;Clear position jump flag
  moveq   #0,d0         ;Needed for word access
  move.b  pt_PBreakPosition(a3),d0 ;Get pattern break position
  move.b  d5,pt_PBreakPosition(a3) ;Set back pattern break position = Zero
  MULUF.W pt_pattposdata_size/4,d0 ;Offset to pattern data
  move.w  d0,pt_PatternPosition(a3) ;Save new pattern position
  move.w  pt_SongPosition(a3),d1 ;Get song position
  addq.w  #1,d1              ;Next song position
  and.w   #pt_maxsongpos-1,d1 ;If maximum song position reached -> restart at song position NULL
  move.w  d1,pt_SongPosition(a3) ;Save new song position
  cmp.b   pt_SongLength(a3),d1 ;Last song position reached ?
  blo.s   pt_NoNewPositionYet ;No -> skip
  move.w  d5,pt_SongPosition(a3) ;Set back song position = Zero
pt_NoNewPositionYet
  tst.b   pt_PosJumpFlag(a3) ;Positionjump flag set ?
  bne.s   pt_NextPosition  ;Yes -> skip
  move.l (a7)+,a6
  rts
  ENDM

;--> PT2-Effects <--
PT2_EFFECT_ARPEGGIO MACRO
  CNOP 0,4
pt_Arpeggio
  move.w  pt_Counter(a3),d0  ;Get ticks
pt_ArpDivLoop
  subq.w  #pt_ArpDiv,d0      ;Substract divisor from dividend
  bge.s   pt_ArpDivLoop      ;until dividend < divisor
  addq.w  #pt_ArpDiv,d0      ;Adjust division remainder
  subq.w  #1,d0              ;Remainder = $0001 = Add first halftone at tick #2 ?
  beq.s   pt_Arpeggio1       ;Yes -> skip
  subq.w  #1,d0              ;Remainder = $0002 = Add second halftone at tick #3 ?
  beq.s   pt_Arpeggio2       ;Yes -> skip
;--> 000 "Normal Play" 1st note <--
pt_Arpeggio0
  move.w  n_period(a2),d2    ;Play note period at tick #1
pt_ArpeggioSet
  IFEQ pt_track_periods_enabled
    move.w  d2,n_current_period(a2) ;Save new period
  ENDC
  move.w  d2,6(a6)           ;AUDxPER Set new note period
  rts
;--> 0x0 "Arpeggio" 2nd note <--
  CNOP 0,4
pt_Arpeggio1
  move.b  n_cmdlo(a2),d0     
  lsr.b   #NIBBLE_SHIFT_BITS,d0 ;Get command data: x-first halftone
  bra.s   pt_ArpeggioFind
;--> 00y "Arpeggio" 3rd note <--
  CNOP 0,4
pt_Arpeggio2
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: y-second halftone
pt_ArpeggioFind
  move.w  n_period(a2),d2    ;Get note period
  IFEQ pt_finetune_enabled
    moveq   #TRUE,d7         ;Needed for word access
    move.b  n_finetune(a2),d7 ;Get finetune value
    lea     pt_FtuPeriodTableStarts(pc),a1 ;Pointer to finetune period table pointers
    move.l  (a1,d7.w*4),a1   ;Get period table address for given finetune value
  ELSE
    lea     pt_PeriodTable(pc),a1 ;Pointer to period table
  ENDC
  moveq   #((pt_PeriodTableEnd-pt_PeriodTable)/2)-1,d7 ;Number of periods
pt_ArpLoop
  cmp.w   (a1)+,d2           ;Note period >= table note period ?
  dbhs   d7,pt_ArpLoop       ;If not -> loop until counter = FALSE
pt_ArpFound
  move.w  -2(a1,d0.w*2),d2   ;Get note period + first or second halftone addition
  bra.s   pt_ArpeggioSet
  ENDM


PT2_EFFECT_PORTAMENTO_UP MACRO
  CNOP 0,4
pt_PortamentoUp
  move.b  n_cmdlo(a2),d0     ;Get command data: xx-upspeed
  move.w  n_period(a2),d2    ;Get note period
;--> E1x "Fine Portamento Up" <--
  IFNE pt_usedefx&pt_ecmdbitfineportup
    and.b   pt_LowMask(a3),d0 ;Use 4 or 8 bits of upspeed
  ENDC
  sub.w   d0,d2              ;Note period - upspeed
;--> E1x "Fine Portamento Up" <--
  IFNE pt_usedefx&pt_ecmdbitfineportup
    move.b  d6,pt_LowMask(a3) ;Set back low mask to $ff
  ENDC
  cmp.w   #pt_portminper,d2   ;Note period >= note period "B-3" ?
  bpl.s   pt_PortaUpSkip     ;Yes -> skip
  moveq   #pt_portminper,d2   ;Set note period "B-3"
pt_PortaUpSkip
  move.w  d2,n_period(a2)    ;Save new note period
  IFEQ pt_track_periods_enabled
    move.w  d2,n_current_period(a2) ;Save new period
  ENDC
  move.w  d2,6(a6)           ;AUDxPER Set new note period
pt_PortaUpEnd
  rts
  ENDM


PT2_EFFECT_PORTAMENTO_DOWN MACRO
  CNOP 0,4
pt_PortamentoDown
  move.b  n_cmdlo(a2),d0     ;Get command data: xx-downspeed
  move.w  n_period(a2),d2    ;Get note period
;--> E2x "Fine Portamento Down" <--
  IFNE pt_usedefx&pt_ecmdbitfineportdown
    and.b   pt_LowMask(a3),d0 ;Use 4 or 8 bits of downspeed
  ENDC
  add.w   d0,d2              ;Note period + downspeed
;--> E2x "Fine Portamento Down" <--
  IFNE pt_usedefx&pt_ecmdbitfineportdown
    move.b  d6,pt_LowMask(a3) ;Set back low mask to $ff
  ENDC
  cmp.w   #pt_portmaxper,d2  ;Note period < note period "C-1" ?
  bmi.s   pt_PortaDownSkip   ;Yes -> skip
  move.w  #pt_portmaxper,d2  ;Set note period "C-1"
pt_PortaDownSkip
  move.w  d2,n_period(a2)    ;Save new note period
  IFEQ pt_track_periods_enabled
    move.w  d2,n_current_period(a2) ;Save new period
  ENDC
  move.w  d2,6(a6)           ;AUDxPER Set new note period
pt_PortaDownEnd
  rts
  ENDM


PT2_EFFECT_TONE_PORTAMENTO MACRO
  CNOP 0,4
pt_TonePortamento
  move.b  n_cmdlo(a2),d0     ;Get command data: xx-up/down speed
  beq.s   pt_TonePortaNoChange ;If zero -> skip
  move.b  d0,n_toneportspeed(a2) ;Save up/down speed
  move.b  d5,n_cmdlo(a2)     ;Clear command data
pt_TonePortaNoChange
  move.w  n_wantedperiod(a2),d2 ;Get wanted note period
  beq.s   pt_TonePortaEnd    ;If zero -> skip
  move.w  n_period(a2),d3    ;Get note period
  move.b  n_toneportspeed(a2),d0 ;Get up/down speed
  tst.b   n_toneportdirec(a2) ;Check tone portamento direction
  bne.s   pt_TonePortaUp     ;If not zero -> up speed
pt_TonePortaDown
  add.w   d0,d3              ;Note period + down speed
  cmp.w   d3,d2              ;Wanted note period > note period ?
  bgt.s   pt_TonePortaSetPer ;Yes -> skip
  move.w  d2,d3              ;Note period = wanted note period
  IFEQ pt_track_volumes_enabled
    move.b  d5,n_note_trigger(a2) ;Set note trigger flag
  ENDC
  moveq   #TRUE,d2           ;Clear wanted note period
  bra.s   pt_TonePortaSetPer
  CNOP 0,4
pt_TonePortaUp
  sub.w   d0,d3              ;Note period - up speed
  cmp.w   d3,d2              ;Wanted note period < note period ?
  blt.s   pt_TonePortaSetPer ;Yes -> skip
  move.w  d2,d3              ;Note period = wanted note period
  IFEQ pt_track_volumes_enabled
    move.b  d5,n_note_trigger(a2) ;Set note trigger flag
  ENDC
  moveq   #TRUE,d2           ;Clear wanted note period
pt_TonePortaSetPer
  move.w  d2,n_wantedperiod(a2) ;Save new state
  moveq   #NIBBLE_MASK_LOW,d0
  move.w  d3,n_period(a2)    ;Save new note period
  and.b   n_glissinvert(a2),d0 ;Get glissando state
  beq.s   pt_GlissSkip       ;If zero -> skip
  IFEQ pt_finetune_enabled
    move.b  n_finetune(a2),d0 ;Get finetune value
    lea     pt_FtuPeriodTableStarts(pc),a1 ;Pointer to finetune period table pointers
    move.l  (a1,d0.w*4),a1   ;Get period table address for given finetune value
  ELSE
    lea     pt_PeriodTable(pc),a1 ;Pointer to period table
  ENDC
  moveq   #((pt_PeriodTableEnd-pt_PeriodTable)/2)-1,d7 ;Number of periods
pt_GlissLoop
  cmp.w   (a1)+,d3           ;Note period >= table note period ?
  dbhs   d7,pt_GlissLoop     ;If not -> loop until counter = FALSE
pt_GlissFound
  move.w  -2(a1),d3          ;Get note period from period table
pt_GlissSkip
  IFEQ pt_track_periods_enabled
    move.w  d3,n_current_period(a2) ;Save new period
  ENDC
  move.w  d3,6(a6)           ;AUDxPER Set new period
pt_TonePortaEnd
  rts
  ENDM


PT2_EFFECT_VIBRATO MACRO
  CNOP 0,4
pt_Vibrato
  move.b  n_cmdlo(a2),d0     ;Get command data: x-speed y-depth
  beq.s   pt_Vibrato2        ;If zero -> skip
  move.b  n_vibratocmd(a2),d2 ;Get vibrato command data
  and.b   #NIBBLE_MASK_LOW,d0   ;Get command data: y-depth
  beq.s   pt_VibSkip         ;If zero -> skip
  and.b   #NIBBLE_MASK_HIGH,d2   ;Clear old depth
  or.b    d0,d2              ;Set new depth in vibrato command data
pt_VibSkip
  MOVEF.B NIBBLE_MASK_HIGH,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: x-speed
  beq.s   pt_VibSkip2        ;If zero -> skip
  and.b   #NIBBLE_MASK_LOW,d2   ;Clear old speed
  or.b   d0,d2               ;Set new speed in vibrato command data
pt_VibSkip2
  move.b  d2,n_vibratocmd(a2) ;Save new vibrato command data
pt_Vibrato2
  lea     pt_VibTreSineTable(pc),a1 ;Pointer to vibrato modulation table
  move.b  n_vibratopos(a2),d0 ;Get vibrato position
  lsr.b   #2,d0              ;/4
  moveq   #pt_wavetypemask,d2
  and.w   #$001f,d0          ;Mask out vibrato position overflow
  and.b   n_wavecontrol(a2),d2 ;Get vibrato waveform type
  beq.s   pt_VibSine         ;If zero -> vibrato waveform 0-sine
  MULUF.B 8,d0               ;*8
  subq.b  #1,d2              ;Vibrato waveform 1-ramp down ?
  beq.s   pt_VibRampdown     ;Yes -> skip
pt_VibSquare
  MOVEF.W 255,d2             ;Square amplitude
  bra.s   pt_VibSet
  CNOP 0,4
pt_VibRampdown
  tst.b   n_vibratopos(a2)   ;Vibrato position positive ?
  bpl.s   pt_VibRampdown2    ;Yes -> skip
  MOVEF.W 255,d2             ;Rampdown amplitude
  sub.b   d0,d2              ;Reduce rampdown amplitude
  bra.s   pt_VibSet
  CNOP 0,4
pt_VibRampdown2
  move.b  d0,d2              ;Rampdown amplitude
  bra.s   pt_VibSet
  CNOP 0,4
pt_VibSine
  move.b  (a1,d0.w),d2       ;Get sine amplitude
pt_VibSet
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_vibratocmd(a2),d0 ;Get depth
  mulu.w  d0,d2              ;depth * amplitude
  move.w  n_period(a2),d0    ;Get note period
  lsr.w   #7,d2              ;Period amplitude = (depth * amplitude) / 128
  tst.b   n_vibratopos(a2)   ;Vibrato position negative ?
  bmi.s   pt_VibratoNeg      ;Yes -> skip
  add.w   d2,d0              ;Note period + period amplitude
  bra.s   pt_Vibrato3
  CNOP 0,4
pt_VibratoNeg
  sub.w   d2,d0              ;Note period - period amplitude
pt_Vibrato3
  move.b  n_vibratocmd(a2),d2 ;Get vibrato command data
  IFEQ pt_track_periods_enabled
    move.w  d0,n_current_period(a2) ;Save new period
  ENDC
  lsr.b   #2,d2              ;/4
  move.w  d0,6(a6)           ;AUDxPER Set new note period
  and.b   #$3c,d2            ;Mask out vibrato position overflow
  add.b   d2,n_vibratopos(a2) ;Next vibrato position
  rts
  ENDM


PT2_EFFECT_TONE_PORTAMENTO_VOLUME_SLIDE MACRO
  CNOP 0,4
pt_TonePortaPlusVolSlide
  bsr.s   pt_TonePortaNoChange
  bra     pt_VolumeSlide
  ENDM


PT2_EFFECT_VIBRATO_VOLUME_SLIDE MACRO
  CNOP 0,4
pt_VibratoPlusVolSlide
  bsr.s   pt_Vibrato2
  bra     pt_VolumeSlide
  ENDM


PT2_EFFECT_TREMOLO MACRO
  CNOP 0,4
pt_Tremolo
  move.b  n_cmdlo(a2),d0     ;Get command data: x-speed y-depth
  beq.s   pt_Tremolo2        ;If zero -> skip
  move.b  n_tremolocmd(a2),d2 ;Get tremolo command data
  and.b   #NIBBLE_MASK_LOW,d0   ;Get command data: y-depth
  beq.s   pt_TreSkip         ;If zero -> skip
  and.b   #NIBBLE_MASK_HIGH,d2   ;Clear old depth
  or.b    d0,d2              ;Set new depth in tremolo command data
pt_TreSkip
  MOVEF.B NIBBLE_MASK_HIGH,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: x-speed
  beq.s   pt_TreSkip2        ;If zero -> skip
  and.b   #NIBBLE_MASK_LOW,d2   ;Clear old speed
  or.b    d0,d2              ;Set new speed in tremolo command data
pt_TreSkip2
  move.b  d2,n_tremolocmd(a2) ;Save new tremolo command data
pt_Tremolo2
  lea   pt_VibTreSineTable(pc),a1 ;Pointer to tremolo modulation table
  move.b  n_tremolopos(a2),d0 ;Get tremolo position
  lsr.b   #2,d0              ;/4
  move.b  n_wavecontrol(a2),d2 ;Get tremolo waveform
  lsr.b   #NIBBLE_SHIFT_BITS,d2 ;Move upper nibble to lower position
  and.w   #$001f,d0          ;Mask out tremolo position overflow
  and.w   #pt_wavetypemask,d2 ;Get tremolo waveform type
  beq.s   pt_TreSine         ;If tremolo waveform 0-sine -> skip
  MULUF.B 8,d0               ;*8
  subq.b  #1,d2              ;Tremolo waveform 1-ramp down ?
  beq.s   pt_TreRampdown     ;Yes -> skip
pt_TreSquare
  MOVEF.W 255,d2             ;Square amplitude
  bra.s   pt_TreSet
  CNOP 0,4
pt_TreRampdown
  tst.b   n_tremolopos(a2)   ;Tremolo position positiv ?
  bpl.s   pt_TreRampdown2    ;Yes -> skip
  MOVEF.W 255,d2             ;Rampdown amplitude
  sub.b   d0,d2              ;Reduce rampdown amplitude
  bra.s   pt_TreSet
  CNOP 0,4
pt_TreRampdown2
  move.b  d0,d2              ;Rampdown amplitude
  bra.s   pt_TreSet
  CNOP 0,4
pt_TreSine
  move.b  (a1,d0.w),d2       ;Get sine amplitude
pt_TreSet
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_tremolocmd(a2),d0 ;Get depth
  mulu.w  d0,d2              ;depth * amplitude
  move.b  n_volume(a2),d0    ;Get volume
  lsr.w   #6,d2              ;Volume amplitude = (depth * amplitude) / 64
  tst.b   n_tremolopos(a2)   ;Tremolo position negative ?
  bmi.s   pt_TremoloNeg      ;Yes -> skip
  add.w   d2,d0              ;Volume + volume amplitude
  bra.s   pt_Tremolo3
  CNOP 0,4
pt_TremoloNeg
  sub.w   d2,d0              ;Volume - volume amplitude
pt_Tremolo3
  bpl.s   pt_TremoloSkip     ;If new volume >= zero -> skip
  moveq   #pt_minvol,d0      ;Set minimum volume
pt_TremoloSkip
  cmp.w   #pt_maxvol,d0      ;New volume <= maximum volume ?
  bls.s   pt_TremoloOk       ;Yes -> skip
  moveq   #pt_maxvol,d0      ;Set maximum volume
pt_TremoloOk
  IFEQ pt_music_fader_enabled
    mulu.w  pt_master_volume(a3),d0 ;volume*master volume
    lsr.w   #6,d0            ;/maximum master volume
  ENDC
  move.b  n_tremolocmd(a2),d2 ;Get tremolo command data
  IFEQ pt_track_periods_enabled
    move.w  d0,n_current_volume(a2) ;Save new volume
  ENDC
  lsr.b   #2,d2              ;/4
  IFEQ pt_mute_enabled
    move.w  d5,8(a6)         ;AUDxVOL No volume
  ELSE
    move.w  d0,8(a6)         ;AUDxVOL Set new volume
  ENDC
  and.b   #$3c,d2            ;Mask out tremolo position overflow
  add.b   d2,n_tremolopos(a2) ;Next tremolo position
  rts
  ENDM


PT2_EFFECT_VOLUME_SLIDE MACRO
  CNOP 0,4
pt_VolumeSlide
  move.b  n_cmdlo(a2),d0     
  lsr.b   #NIBBLE_SHIFT_BITS,d0 ;Get command data: x-upspeed
  beq.s   pt_VolSlideDown    ;If zero -> skip
;--> Ax0 "Volume Slide Up" <--
pt_VolSlideUp
  moveq   #TRUE,d2           ;Word access
  move.b  n_volume(a2),d2    ;Get volume
  add.b   d0,d2              ;Volume + upspeed
  cmp.b   #pt_maxvol,d2      ;volume < maximum volume ?
  bls.s   pt_VsuSkip         ;Yes -> skip
  moveq   #pt_maxvol,d2      ;Set maximum volume
pt_VsuSkip
  move.b  d2,n_volume(a2)    ;Save new volume
  IFEQ pt_music_fader_enabled
    mulu.w  pt_master_volume(a3),d2 ;volume * master volume
    lsr.w   #6,d2            ;/ maximum master volume
  ENDC
  IFEQ pt_track_periods_enabled
    move.w  d2,n_current_volume(a2) ;Save new volume
  ENDC
  IFEQ pt_mute_enabled
    move.w  d5,8(a6)         ;AUDxVOL No volume
  ELSE
    move.w  d2,8(a6)         ;AUDxVOL Set new volume
  ENDC
pt_VSUEnd
  rts
;--> A0y "Volume Slide Down" <--
  CNOP 0,4
pt_VolSlideDown
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: y-downspeed
  moveq   #TRUE,d2           ;Needed for word access
  move.b  n_volume(a2),d2    ;Get volume
  sub.b   d0,d2              ;Volume - downspeed
  bpl.s   pt_VsdSkip         ;If >= zero -> skip
  moveq   #pt_minvol,d2      ;Set minimum volume
pt_VsdSkip
  move.b  d2,n_volume(a2)    ;Save new volume
  IFEQ pt_music_fader_enabled
    mulu.w  pt_master_volume(a3),d2 ;volume * master volume
    lsr.w   #6,d2            ;/ maximum master volume
  ENDC
  IFEQ pt_track_periods_enabled
    move.w  d2,n_current_volume(a2) ;Save new volume
  ENDC
  IFEQ pt_mute_enabled
    move.w  d5,8(a6)         ;AUDxVOL No volume
  ELSE
    move.w  d2,8(a6)         ;AUDxVOL Set new volume
  ENDC
pt_VsdEnd
  rts
  ENDM


PT2_EFFECT_SET_SAMPLE_OFFSET MACRO
  CNOP 0,4
pt_SetSampleOffset
  move.b  n_cmdlo(a2),d0     ;Get command data: xx-sample offset
  beq.s   pt_SetSoNoNew      ;If zero -> skip
  move.b  d0,n_sampleoffset(a2) ;Save new sample offset
pt_SetSoNoNew
  move.b  n_sampleoffset(a2),d0 ;Get sample offset
  MULUF.W 128,d0             ;offset * 128
  cmp.w   n_length(a2),d0    ;offset * 128 >= length ?
  bge.s   pt_SetSoSkip       ;Yes -> skip
  sub.w   d0,n_length(a2)    ;length - offset
  MULUF.W 2,d0               ;*2 = offset in bytes
  add.l   d0,n_start(a2)     ;sample start + offset
  rts
  CNOP 0,4
pt_SetSoSkip
  moveq   #1,d0
  move.w  d0,n_length(a2)    ;Set length = 1 Word
  rts
  ENDM


PT2_EFFECT_POSITION_JUMP MACRO
  CNOP 0,4
pt_PositionJump
  move.b  n_cmdlo(a2),d0     ;Get command data: xx-song position
  subq.b  #1,d0              ;Decrement song position
  move.w  d0,pt_SongPosition(a3) ;Save new song position
  move.b  d5,pt_PBreakPosition(a3) ;Clear pattern break position
  move.b  d6,pt_PosJumpFlag(a3) ;Position jump flag = FALSE
  rts
  ENDM


PT2_EFFECT_SET_VOLUME MACRO
  CNOP 0,4
pt_SetVolume
  move.b  n_cmdlo(a2),d0     ;Get command data: xx-volume
  cmp.b   #pt_maxvol,d0      ;volume <= maximum volume ?
  bls.s   pt_MaxVolOk        ;Yes -> skip
  moveq   #pt_maxvol,d0      ;Set maximum volume
pt_MaxVolOk
  move.b  d0,n_volume(a2)    ;Save new volume
  IFEQ pt_music_fader_enabled
    mulu.w  pt_master_volume(a3),d0 ;volume * master volume
    lsr.w   #6,d0            ;/ maximum master volume
  ENDC
  IFEQ pt_track_periods_enabled
    move.w  d0,n_current_volume(a2) ;Save new volume
  ENDC
  IFEQ pt_mute_enabled
    move.w  d5,8(a6)         ;AUDxVOL No volume
  ELSE
    move.w  d0,8(a6)         ;AUDxVOL Set new volume
  ENDC
  rts
  ENDM


PT2_EFFECT_PATTERN_BREAK MACRO
  CNOP 0,4
pt_PatternBreak
  move.b  n_cmdlo(a2),d0     ;Get command data: xx-break position (decimal)
  moveq   #NIBBLE_MASK_LOW,d2
  and.b   d0,d2              ;Only lower nibble digits = 0..9
  lsr.b   #NIBBLE_SHIFT_BITS,d0 ;Move upper nibble to lower position
  MULUF.B 10,d0,d7           ;Upper nibble *10 = digits 10..60
  add.b   d2,d0              ;Get decimal number
  cmp.b   #pt_maxpattpos-1,d0 ;Break position > last position in pattern ?
  bhi.s   pt_PB2             ;Yes -> no pattern break
  move.b  d0,pt_PBreakPosition(a3) ;Save new pattern break position
  move.b  d6,pt_PosJumpFlag(a3) ;Position jump flag = FALSE
  rts
  CNOP 0,4
pt_PB2
  move.b  d5,pt_PBreakPosition(a3) ;Clear pattern break position
  move.b  d6,pt_PosJumpFlag(a3) ;Position jump flag = FALSE
  rts
  ENDM


PT2_EFFECT_SET_FILTER MACRO
  CNOP 0,4
pt_SetFilter
  moveq   #1,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: 0-filter on 1-filter off
  bne.s   pt_FilterOff       ;If 1-filter off -> skip
pt_FilterOn
  MOVEF.B (~CIAF_LED),d0
  and.b   d0,(a4)            ;Turn filter on
  rts
  CNOP 0,4
pt_FilterOff
  moveq   #CIAF_LED,d0
  or.b    d0,(a4)            ;Turn filter off
  rts
  ENDM


PT2_EFFECT_FINE_PORTAMENTO_UP MACRO
  CNOP 0,4
pt_FinePortamentoUp
  moveq   #NIBBLE_MASK_LOW,d0
  move.b  d0,pt_LowMask(a3)  ;Only lower nibble of mask
  bra     pt_PortamentoUp
  ENDM


PT2_EFFECT_FINE_PORTAMENTO_DOWN MACRO
  CNOP 0,4
pt_FinePortamentoDown
  moveq   #NIBBLE_MASK_LOW,d0
  move.b  d0,pt_LowMask(a3)  ;Only lower nibble of mask
  bra     pt_PortamentoDown
  ENDM


PT2_EFFECT_SET_GLISSANDO_CONTROL MACRO
  CNOP 0,4
pt_SetGlissandoControl
  MOVEF.B NIBBLE_MASK_HIGH,d2
  and.b   n_glissinvert(a2),d2 ;Clear old glissando state lower nibble
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: glissando state 0-off 1-on
  or.b    d0,d2              ;Set new glissando state
  move.b  d2,n_glissinvert(a2) ;Save new glissando state
  rts
  ENDM


PT2_EFFECT_SET_VIBRATO_WAVEFORM MACRO
;--> Vibrato waveform type values <--
; 0 - sine (default)
; 4  (without retrigger)
; 1 - ramp down
; 5  (without retrigger)
; 2 - square
; 6  (without retrigger)
  CNOP 0,4
pt_SetVibratoWaveform
  MOVEF.B NIBBLE_MASK_HIGH,d2
  and.b   n_wavecontrol(a2),d2 ;Clear old vibrato waveform
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: vibrato waveform 0-sine 1-ramp down 2-square
  or.b    d0,d2              ;Set new vibrato waveform
  move.b  d2,n_wavecontrol(a2) ;Save new vibrato waveform
  rts
  ENDM


PT2_EFFECT_SET_SAMPLE_FINETUNE MACRO
  CNOP 0,4
pt_SetSampleFinetune
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: new finetune value
  move.b  d0,n_finetune(a2)  ;Set new finetune value
  rts
  ENDM


PT2_EFFECT_JUMP_TO_LOOP MACRO
  CNOP 0,4
pt_JumpToLoop
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: x-times
  beq.s   pt_SetLoop         ;If zero -> set loop
  tst.b   n_loopcount(a2)    ;Get loop counter
  beq.s   pt_JmpLoopCnt      ;If zero -> set counter
  subq.b  #1,n_loopcount(a2) ;Decrease loop counter
  beq.s   pt_JmpLoopEnd      ;If zero -> skip
pt_JmpLoop
  move.b  n_pattpos(a2),pt_PBreakPosition(a3) ;Save pattern break position
  move.b  d6,pt_PBreakFlag(a3) ;pattern break flag = FALSE
pt_JmpLoopEnd
  rts
  CNOP 0,4
pt_JmpLoopCnt
  move.b  d0,n_loopcount(a2) ;Save times in loop counter
  bra.s   pt_JmpLoop
  CNOP 0,4
pt_SetLoop
  move.w  pt_PatternPosition(a3),d0 ;Get pattern position
  lsr.w   #2,d0              ;/(pt_pattposdata_size/4)
  move.b  d0,n_pattpos(a2)   ;Save pattern position
  rts
  ENDM


PT2_EFFECT_SET_TREMOLO_WAVEFORM MACRO
;--> Tremolo waveform types <--
; 0 - sine (default)
; 4  (without retrigger)
; 1 - ramp down
; 5  (without retrigger)
; 2 - square
; 6  (without retrigger)
  CNOP 0,4
pt_SetTremoloWaveform
  move.b  n_cmdlo(a2),d0     ;Get command data: tremolo waveform 0-sine 1-ramp down 2-square
  moveq   #NIBBLE_MASK_LOW,d2
  and.b   n_wavecontrol(a2),d2 ;Clear old tremolo waveform
  lsl.b   #NIBBLE_SHIFT_BITS,d0 ;Move tremolo waveform to upper nibble
  or.b    d0,d2              ;Set new tremolo waveform
  move.b  d2,n_wavecontrol(a2) ;Save new tremolo waveform
  rts
  ENDM


PT2_EFFECT_RETRIG_NOTE MACRO
  CNOP 0,4
pt_RetrigNote
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: x-blanks
  beq.s   pt_RtnEnd          ;If zero -> skip
  move.w  pt_Counter(a3),d2  ;Get ticks
  bne.s   pt_RtnSkip         ;If not tick #1 -> skip
  move.w  (a2),d7            ;Get note period from pattern position
  and.w   d6,d7              ;Only 12 bits note period
  bne.s   pt_RtnEnd          ;If note period -> skip
pt_RtnSkip
  sub.w   d0,d2              ;Substract divisor from dividend
  bge.s   pt_RtnSkip         ;until dividend < divisor
  add.w   d0,d2              ;Adjust division remainder
  bne.s   pt_RtnEnd          ;If blanks not ticks -> skip
  move.w  n_dmabit(a2),d0    ;Get audio channel DMA bit
  or.w    d0,pt_RtnDMACONtemp(a3) ;Set effect "Retrig Note" or "Note Delay" for audio channel
  move.b  d5,n_rtnsetchandma(a2) ;Activate interrupt set routine
  IFEQ pt_track_volumes_enabled
    move.b  d5,n_note_trigger(a2) ;Set note trigger flag
  ENDC
  move.w  d0,_CUSTOM+DMACON  ;Audio channel DMA off
  move.l  n_start(a2),(a6)   ;AUDxLCH Set sample start
  move.w  n_length(a2),4(a6) ;AUDxLEN Set length
pt_RtnEnd
  rts
  ENDM


PT2_EFFECT_FINE_VOLUME_SLIDE_UP MACRO
  CNOP 0,4
pt_FineVolumeSlideUp
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: y-downspeed
  bra     pt_VolSlideUp
  ENDM


PT2_EFFECT_FINE_VOLUME_SLIDE_DOWN MACRO
  CNOP 0,4
pt_FineVolumeSlideDown
  bra     pt_VolSlideDown
  ENDM


PT2_EFFECT_NOTE_CUT MACRO
  CNOP 0,4
pt_NoteCut
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: x-blanks
  cmp.w   pt_Counter(a3),d0  ;blanks = ticks ?
  bne.s   pt_NoteCutEnd      ;No -> skip
  move.b  d5,n_volume(a2)    ;Clear volume
  IFEQ pt_track_periods_enabled
    move.w  d5,n_current_volume(a2) ;Clear new volume
  ENDC
  move.w  d5,8(a6)           ;AUDxVOL Clear volume
pt_NoteCutEnd
  rts
  ENDM


PT2_EFFECT_NOTE_DELAY MACRO
  CNOP 0,4
pt_NoteDelay
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: x-blanks
  cmp.w   pt_Counter(a3),d0  ;blanks = ticks ?
  bne.s   pt_NoteDelayEnd    ;No -> skip
  move.w  (a2),d0            ;Get note period from pattern position
  and.w   d6,d0              ;Only 12 bits note period
  beq.s   pt_NoteDelayEnd    ;If no note period -> skip
  move.w  n_dmabit(a2),d0    ;Get audio channel DMA bit
  or.w    d0,pt_RtnDMACONtemp(a3) ;Set effect "Retrig Note" or "Note Delay" for audio channel
  move.b  d5,n_rtnsetchandma(a2) ;Activate interrupt set routine
  IFEQ pt_track_volumes_enabled
    move.b  d5,n_note_trigger(a2) ;Set note trigger flag
  ENDC
  move.w  d0,_CUSTOM+DMACON  ;Audio channel DMA off
  move.l  n_start(a2),(a6)   ;AUDxLCH Set sample start
  move.w  n_length(a2),4(a6) ;AUDxLEN Set length
pt_NoteDelayEnd
  rts
  ENDM


PT2_EFFECT_PATTERN_DELAY MACRO
  CNOP 0,4
pt_PatternDelay
  moveq   #NIBBLE_MASK_LOW,d0
  and.b   n_cmdlo(a2),d0     ;Get command data: x-notes
  tst.b   pt_PattDelayTime2(a3) ;Pattern delay time not zero ?
  bne.s   pt_PattDelayEnd    ;Yes -> skip
  addq.b  #1,d0              ;Decrement notes
  move.b  d0,pt_PattDelayTime(a3) ;Save new pattern delay time
pt_PattDelayEnd
  rts
  ENDM


PT2_EFFECT_INVERT_LOOP MACRO
  CNOP 0,4
pt_InvertLoop
  move.b  n_cmdlo(a2),d0     ;Get command data: x-speed
  moveq   #NIBBLE_MASK_LOW,d2
  and.b   n_glissinvert(a2),d2 ;Clear old speed
  lsl.b   #NIBBLE_SHIFT_BITS,d0 ;Move speed to upper nibble
  or.b    d0,d2              ;Set new speed
  move.b  d2,n_glissinvert(a2) ;Save new speed
  tst.b   d0                 ;speed = zero ?
  beq.s   pt_InvertEnd       ;Yes -> skip
pt_UpdateInvert
  moveq   #0,d0           ;Needed for word access
  move.b  n_glissinvert(a2),d0
  lsr.b   #NIBBLE_SHIFT_BITS,d0 ;Get speed
  beq.s   pt_InvertEnd       ;If zero -> skip
  lea     pt_InvertTable(pc),a1 ;Pointer to invert table
  move.b  (a1,d0.w),d0       ;Get invert value
  add.b   d0,n_invertoffset(a2) ;Decrease invert offset by invert value
  bpl.s   pt_InvertEnd       ;If >= zero -> skip
  move.l  n_wavestart(a2),a1 ;Get wavestart
  move.w  n_replen(a2),d0    ;Get repeat length
  MULUF.W 2,d0               ;*2 = length in bytes
  add.l   n_loopstart(a2),d0 ;Add loop start = repeat point
  addq.w  #1,a1              ;Next word in sample data
  move.b  d5,n_invertoffset(a2) ;Clear invert-offset
  cmp.l   d0,a1              ;Wavestart < repeat point ?
  blo.s   pt_InvertOk        ;Yes -> Skip
  move.l  n_loopstart(a2),a1 ;Get loop start
pt_InvertOk
  move.l  a1,n_wavestart(a2) ;Save new wavestart
  not.b   (a1)               ;Invert sample data byte bits
pt_InvertEnd
  rts
  ENDM


PT2_EFFECT_SET_SPEED MACRO
  CNOP 0,4
pt_SetSpeed
  IFEQ pt_ciatiming_enabled
    move.b  n_cmdlo(a2),d0   ;Get command data: xx-speed ($00-$1f ticks) / xx-tempo ($20-$ff BPM)
    beq.s   pt_StopReplay    ;If speed = zero -> skip
    cmp.b   #pt_maxticks,d0  ;speed > maximum ticks ?
    bhi.s   pt_SetTempo      ;Yes -> set tempo
    move.w  d0,pt_CurrSpeed(a3) ;Set new speed ticks
    move.w  d5,pt_Counter(a3) ;Set back ticks counter = tick #1
    rts
    CNOP 0,4
pt_SetTempo
    move.l  pt_125bpmrate(a3),d2 ;Get 125 BPM PAL/NTSC rate
    divu.w  d0,d2            ;/tempo = counter value
    move.b  d2,CIATALO(a5)   ;Set CIA-B timer A counter value low bits
    lsr.w   #BYTE_SHIFT_BITS,d2 ;Get counter value high bits
    move.b  d2,CIATAHI(a5)   ;Set CIA-B timer A counter value high bits
    rts
    CNOP 0,4
pt_StopReplay
    move.w  #INTF_EXTER,_CUSTOM+INTENA ;Stop replay routine by turning off level-6 interrupt
    rts
  ELSE
    move.b  n_cmdlo(a2),d0   ;Get command data: xx-speed ($00-$1f ticks)
    beq.s   pt_StopReplay    ;If speed = zero -> skip
    cmp.b   #pt_maxticks,d0  ;speed > maximum ticks ?
    bhi.s   pt_SetSpdEnd     ;Yes  -> skip
    move.w  d0,pt_CurrSpeed(a3) ;Set new speed ticks
    move.w  d5,pt_Counter(a3) ;Set back ticks counter = tick #1
pt_SetSpdEnd
    rts
    CNOP 0,4
pt_StopReplay
    move.w  #INTF_VERTB,_CUSTOM+INTENA ;Stop replay routine by turning off vertical blank interrupt
    rts
  ENDC
  ENDM

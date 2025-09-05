PT3_INIT_VARIABLES		MACRO
; Input
; \1 STRING:	"NOPOINTERS" are initialized
; Result
	IFC "","\1"
		lea	pt_auddata,a0
		move.l	a0,pt_Song(a3)
		IFEQ pt_split_module_enabled
			lea	pt_audsmps,a0
			move.l	a0,pt_Samples(a3)
		ENDC
	ENDC
	moveq	#TRUE,d0
	move.w	d0,pt_Counter(a3)
	move.w	#pt_defaultticks,pt_CurrSpeed(a3)
	move.w	d0,pt_DMACONtemp(a3)
	move.w	#DMAF_AUD0|DMAF_AUD1|DMAF_AUD2|DMAF_AUD3,pt_ActiveChannels(a3) ; all audio channels enabled
	move.l	d0,pt_Pattern(a3)
	move.w	d0,pt_PatternPosition(a3)
	move.w	d0,pt_SongPosition(a3)

; E9x "Retrig Note" or EDx "Note Delay"
	IFNE pt_usedefx&(pt_ecmdbitretrignote|pt_ecmdbitnotedelay)
		move.w d0,pt_RtnDMACONtemp(a3)
	ENDC
	moveq	#FALSE,d1
	IFEQ pt_music_fader_enabled
		move.w	d1,pt_music_fader_active(a3) ; deactivate volume fader
		move.w	#pt_fade_out_delay,pt_fade_out_delay_counter(a3)
		move.w	#pt_maxvol,pt_master_volume(a3)
	ENDC
	IFEQ pt_metronome_enabled
		move.b	#pt_metrospeedbits,pt_MetroSpeed(a3)
		move.b	#pt_metrochanbits,pt_MetroChannel(a3)
	ENDC
	move.b	d1,pt_SetAllChanDMAFlag(a3) ; deactivate routines
	move.b	d1,pt_InitAllChanLoopFlag(a3)

; Bxx "Position Jump" or Dxx "Pattern Break"
	IFNE pt_usedfx&(pt_cmdbitposjump|pt_cmdbitpattbreak)
		move.b	d0,pt_PBreakPosition(a3)
		move.b	d0,pt_PosJumpFlag(a3)
	ENDC

; E1x "Fine Portamento Up" or E2x "Fine Portamento Down"
	IFNE pt_usedefx&(pt_ecmdbitfineportup|pt_ecmdbitfineportdown)
		move.b	d0,pt_LowMask(a3)
	ENDC

; E6x "Jump to Loop"
	IFNE pt_usedefx&pt_ecmdbitjumptoloop
		move.b	d0,pt_PBreakFlag(a3)
	ENDC

; EEx" Pattern Delay"
	IFNE pt_usedefx&pt_ecmdbitpattdelay
		move.b	d0,pt_PattDelayTime(a3)
		move.b	d0,pt_PattDelayTime2(a3)
	ENDC
	ENDM


PT3_REPLAY			MACRO
; Input
; \1 LABEL:	subroutine for effect command 8 called at tick #1 (optional)
; Result
pt_PlayMusic
	movem.l	a5-a6,-(a7)
	moveq	#0,d5			; for all clear operations
	addq.w	#1,pt_Counter(a3)
	move.l	#pt_cmdpermask,d6
	move.w	pt_Counter(a3),d0
	ADDF.W	CIACRB,a5
	ADDF.W	AUD0LCH-DMACONR,a6
	cmp.w	pt_CurrSpeed(a3),d0	; ticks < speed ticks ?
	blo.s	pt_NoNewNote
	move.w	d5,pt_Counter(a3)	; restart ticks counter

; EEx "Pattern Delay"
	IFNE pt_usedefx&pt_ecmdbitpattdelay
		tst.b	pt_PattDelayTime2(a3)
		beq	pt_GetNewNote
	ELSE
		bra	pt_GetNewNote
	ENDC
	bsr.s	pt_NoNewAllChannels
	bra	pt_Dskip

	CNOP 0,4
pt_NoNewNote
	bsr.s	pt_NoNewAllChannels
	bra	pt_NoNewPositionYet

; Check all audio channel for effect commands at ticks #2..#speed ticks
	CNOP 0,4
pt_NoNewAllChannels
	lea	pt_audchan1temp(pc),a2
	bsr.s	pt_CheckEffects
	ADDF.W	16,a6			; next audio channel
	lea	pt_audchan2temp(pc),a2
	bsr.s	pt_CheckEffects
	ADDF.W	16,a6
	lea	pt_audchan3temp(pc),a2
	bsr.s	pt_CheckEffects
	ADDF.W	16,a6
	lea	pt_audchan4temp(pc),a2
	bsr.s	pt_CheckEffects

; E9x "Retrig Note" or EDx "Note Delay"
	IFNE pt_usedefx&(pt_ecmdbitretrignote|pt_ecmdbitnotedelay)
pt_RtnChkAllChannels
		tst.w	pt_RtnDMACONtemp(a3) ; "Retrig Note" or "Note Delay" ?
		beq.s	pt_NoRtnSetTimer
		moveq	#CIACRBF_START,d0
		or.b	d0,(a5)		; start DMA wait counter
pt_NoRtnSetTimer
	ENDC
	rts

; Update volume at ticks #2..#speedticks
	CNOP 0,4
pt_CheckEffects
	bsr.s	pt_CheckEffects2
	moveq	#0,d0
	move.b	n_volume(a2),d0
	IFEQ pt_music_fader_enabled
		move.w	pt_master_volume(a3),d2
		cmp.w	#pt_maxvol,d2
		beq.s	pt_DecVolSkip1
		mulu.w	d2,d0
		lsr.w	#6,d0
pt_DecVolSkip1
	ENDC
	IFEQ pt_mute_enabled
		move.w	d5,8(a6)	; AUDxVOL muted
	ELSE
		move.w	d0,8(a6)	; AUDxVOL
		IFEQ pt_track_volumes_enabled
			move.w	d0,n_currentvolume(a2)
		ENDC
	ENDC
	rts

; Check effect commands at ticks #2..#speed ticks
	CNOP 0,4
pt_CheckEffects2

; EFx "InvertLoop"
	IFNE pt_usedefx&pt_ecmdbitinvertloop
		bsr	pt_UpdateInvert
	ENDC
	move.w	n_cmd(a2),d0
	and.w	d6,d0
	beq	pt_CheckEffects2End
	lsr.w	#BYTE_SHIFT_BITS,d0	; adjust bits

; 0xy "Normal play" or "Arpeggio"	
	IFNE pt_usedfx&pt_cmdbitarpeggio
		beq.s	pt_Arpeggio
	ENDC

; 1xx "Portamento Up"
	IFNE pt_usedfx&pt_cmdbitportup
		cmp.b	#pt_cmdportup,d0
		beq	pt_PortamentoUp
	ENDC

; 2xx "PortamentoDown"
	IFNE pt_usedfx&pt_cmdbitportdown
		cmp.b	#pt_cmdportdown,d0
		beq	pt_PortamentoDown
	ENDC

; 3xx "Tone Portamento"
	IFNE pt_usedfx&pt_cmdbittoneport
		cmp.b	#pt_cmdtoneport,d0
		beq	pt_TonePortamento
	ENDC

; 4xy"Vibrato"
	IFNE pt_usedfx&pt_cmdbitvibrato
		cmp.b	#pt_cmdvibrato,d0
		beq	pt_Vibrato
	ENDC

; 5xy "Tone Portamento + Volume Slide"
	IFNE pt_usedfx&pt_cmdbittoneportvolslide
		cmp.b	#pt_cmdtoneportvolslide,d0
		beq	pt_TonePortaPlusVolSlide
	ENDC

; 6xy "Vibrato + Volume Slide"
	IFNE pt_usedfx&pt_cmdbitvibratovolslide
		cmp.b	#pt_cmdvibratovolslide,d0
		beq	pt_VibratoPlusVolSlide
	ENDC

; Exy "Extended commands"
	IFNE pt_usedfx&pt_cmdbitextended
		cmp.b	#pt_cmdextended,d0
		beq	pt_ExtCommands
	ENDC

pt_SetBack
	IFEQ pt_track_periods_enabled
		move.w	n_period(a2),d2
		move.w	d2,6(a6)	; AUDxPER
		move.w	d2,n_currentperiod(a2)
	ELSE
		move.w	n_period(a2),6(a6) ; AUDxPER
	ENDC

; 7xy "Tremolo"
	IFNE pt_usedfx&pt_cmdbittremolo
		cmp.b	#pt_cmdtremolo,d0
		beq	pt_Tremolo
	ENDC

; Axy "VolumeSlide"
	IFNE pt_usedfx&pt_cmdbitvolslide
		cmp.b	#pt_cmdvolslide,d0
		beq	pt_VolumeSlide
	ENDC

pt_CheckEffects2End
	rts

; 0xy "Normal play" or "Arpeggio"
	IFNE pt_usedfx&pt_cmdbitarpeggio
		PT3_EFFECT_ARPEGGIO
	ENDC
 
; 1xx "Portamento Up"
	IFNE pt_usedfx&pt_cmdbitportup
		PT3_EFFECT_PORTAMENTO_UP
	ELSE
		IFNE pt_usedefx&pt_ecmdbitfineportup
			PT3_EFFECT_PORTAMENTO_UP
		ENDC
	ENDC

; 2xx "Portamento Down"
	IFNE pt_usedfx&pt_cmdbitportdown
		PT3_EFFECT_PORTAMENTO_DOWN
	ELSE
		IFNE pt_usedefx&pt_ecmdbitfineportdown
			PT3_EFFECT_PORTAMENTO_DOWN
		ENDC
	ENDC

; 5xy "Tone Portamento + Volume Slide"
	IFNE pt_usedfx&pt_cmdbittoneportvolslide
		PT3_EFFECT_TONE_PORTA_VOL_SLIDE
	ENDC

; 3xx "Tone Portamento" or 5xy "Tone Portamento + Volume Slide"
	IFNE pt_usedfx&(pt_cmdbittoneport|pt_cmdbittoneportvolslide)
		PT3_EFFECT_TONE_PORTAMENTO
	ENDC
 
; 4xy "Vibrato" or 6xy "Vibrato + Volume Slide"
	IFNE pt_usedfx&(pt_cmdbitvibrato|pt_cmdbitvibratovolslide)
		PT3_EFFECT_VIBRATO
	ENDC

; 6xy "Vibrato + Volume Slide"
	IFNE pt_usedfx&pt_cmdbitvibratovolslide
		PT3_EFFECT_VIB_VOL_SLIDE
	ENDC

; Exy "Extended commands" at ticks #2..#speed
	IFNE pt_usedefx
		CNOP 0,4
pt_ExtCommands
		IFNE pt_usedefx&(pt_ecmdbitretrignote|pt_ecmdbitnotecut|pt_ecmdbitnotedelay)
			move.b	n_cmdlo(a2),d0
			lsr.b	#NIBBLE_SHIFT_BITS,d0 ; adjust bits
			cmp.b	#pt_ecmdkarplusstrong,d0
			ble	pt_ExtCommandsEnd
		ENDC

; E9x "Retrig Note"
		IFNE pt_usedefx&pt_ecmdbitretrignote
			cmp.b	#pt_ecmdretrignote,d0
			beq	pt_RetrigNote
		ENDC

; ECx "Note Cut"
		IFNE pt_usedefx&pt_ecmdbitnotecut
			cmp.b	#pt_ecmdnotecut,d0
			beq	pt_NoteCut
		ENDC

; EDx "Note Delay"
		IFNE pt_usedefx&pt_ecmdbitnotedelay
			cmp.b	#pt_ecmdnotedelay,d0
			beq	pt_NoteDelay
		ENDC

pt_ExtCommandsEnd
		rts
	ENDC


; 7xy "Tremolo"
	IFNE pt_usedfx&pt_cmdbittremolo
		PT3_EFFECT_TREMOLO
	ENDC
 

; 5xy "Tone Portamento + Volume Slide" or 6xy "Vibrato + Volume Slide" or Axy "Volume Slide"
	IFNE pt_usedfx&(pt_cmdbittoneport|pt_cmdbittoneportvolslide|pt_cmdbitvibratovolslide|pt_cmdbitvolslide)
		PT3_EFFECT_VOLUME_SLIDE
	ELSE
		IFNE pt_usedefx&pt_ecmdbitfinevolslideup
			PT3_EFFECT_VOLUME_SLIDE
		ELSE
			IFNE pt_usedefx&pt_ecmdbitfinevolslidedown
				PT3_EFFECT_VOLUME_SLIDE
			ENDC
		ENDC
	ENDC


; New note at tick #1
	CNOP 0,4
pt_GetNewNote
	move.l	pt_Song(a3),a0
	move.w	pt_SongPosition(a3),d0
	moveq	#0,d1
	move.b	(pt_sd_pattpos,a0,d0.w),d1 ; pattern number in song position table
	MULUF.W	pt_pattsize/4,d1,d2	; pattern offset
	add.w	pt_PatternPosition(a3),d1
	move.w	d5,pt_DMACONtemp(a3)	; clear DMA bits
	lea	pt_audchan1temp(pc),a2
	IFEQ pt_metronome_enabled
		moveq	#pt_metrochan1,d2
        ENDC
	bsr.s	pt_Plv2
	lea	pt_audchan2temp(pc),a2
	ADDF.W	16,a6			; next audio channel
	IFEQ pt_metronome_enabled
		moveq	#pt_metrochan2,d2
	ENDC
	bsr.s	pt_Plv2
	lea	pt_audchan3temp(pc),a2
	ADDF.W	16,a6
	IFEQ pt_metronome_enabled
		moveq	#pt_metrochan3,d2
	ENDC
	bsr.s	pt_Plv2
	lea	pt_audchan4temp(pc),a2
	ADDF.W	16,a6
	IFEQ pt_metronome_enabled
		moveq	#pt_metrochan4,d2
        ENDC
	bsr.s	pt_Plv2
	bra	pt_SetDMA

	IFEQ pt_metronome_enabled
; Input
; d2.l	Channel number [1..4]
; Result
		CNOP 0,4
pt_CheckMetronome
		cmp.b	pt_MetroChannel(a3),d2 ; channel number = metronome channel number ?
		bne.s	pt_ChkMetroEnd
		move.b	pt_MetroSpeed(a3),d2
		beq.s	pt_ChkMetroEnd
		moveq	#0,d0
		move.w	pt_PatternPosition(a3),d0
		lsr.w	#2,d0		; /(pt_pattposdata_size/4)
		divu.w	d2,d0		; pattern position / metronome speed
		swap	d0		; remainder
		tst.w	d0		; remainder = 0 ?
		bne.s	pt_ChkMetroEnd
		move.l	(a2),d0		; note data from pattern
		and.l	d6,d0		; clear note period and sample number of note data
		or.l	#pt_metronoteinfo,d0 ; play sample #31 at note period "C-3"
		move.l	d0,(a2)		; new note data
pt_ChkMetroEnd
		rts
	ENDC

	CNOP 0,4
pt_Plv2
	bsr.s	pt_PlayVoice
; Update volume
	moveq	#0,d0
	move.b	n_volume(a2),d0
	IFEQ pt_music_fader_enabled
		move.w	pt_master_volume(a3),d2
		cmp.w	#pt_maxvol,d2
		beq.s	pt_DecVolSkip2
		mulu.w	d2,d0
		lsr.w	#6,d0
pt_DecVolSkip2
	ENDC
	IFEQ pt_mute_enabled
		move.w	d5,8(a6)	; AUDxVOL muted
	ELSE
		move.w	d0,8(a6)	; AUDxVOL
		IFEQ pt_track_volumes_enabled
			move.w	d0,n_currentvolume(a2)
		ENDC
	ENDC
	rts

	CNOP 0,4
pt_PlayVoice
	tst.l	(a2)			; check current channel data in pattern
	bne.s	pt_PlvSkip
	IFEQ pt_track_periods_enabled
		move.w	n_period(a2),d2
		move.w	d2,6(a6)	; AUDxPER
		move.w	d2,n_currentperiod(a2)
	ELSE
		move.w	n_period(a2),6(a6) ; AUDxPER
	ENDC
pt_PlvSkip
	move.l	(pt_sd_patterndata,a0,d1.l*4),(a2) ; fetch note data
	IFEQ pt_metronome_enabled
		bsr.s	pt_CheckMetronome
	ENDC
	moveq	#0,d2
	MOVEF.B	NIBBLE_MASK_HIGH,d0
	move.b	n_cmd(a2),d2
	lsr.b	#NIBBLE_SHIFT_BITS,d2 nibble of sample number
	MOVEF.B	NIBBLE_MASK_HIGH,d0	
	and.b	(a2),d0 nibble of sample number
	addq.w	#pt_noteinfo_size/4,d1	; next channel data
	or.b	d0,d2			; sample number
	beq.s	pt_SetRegisters
	subq.w	#1,d2			; count starts at 0
	lea	pt_SampleStarts(pc),a1
	move.l	(a1,d2.w*4),a1		; sample data pointer
	move.l	a1,n_start(a2)
	MULUF.W	pt_sampleinfo_size/2,d2,d0
	movem.w	pt_sd_sampleinfo+pt_si_samplelength(a0,d2.w*2),d0/d2-d4 ; fetch length, finetune, volume, repeat point, repeat length
	move.w	d0,n_reallength(a2)
	move.w	d2,n_finetune(a2)	; finetune and volume
	cmp.w	#pt_oneshotlen,d4
	beq.s	pt_NoLoopSample
	move.w	d3,d0			; repeat point
	MULUF.W WORD_SIZE,d3,d2		; in bytes
	add.w	d4,d0			; repeat length
	add.l	d3,a1			; repeat point
pt_NoLoopSample
	move.w	d0,n_length(a2)
	move.w	d4,n_replen(a2)
	move.l	a1,n_loopstart(a2)
	move.l	a1,n_wavestart(a2)

pt_SetRegisters
	move.w	(a2),d3
	and.w	d6,d3			; note period ?
	beq	pt_CheckMoreEffects
	move.w	n_cmd(a2),d4
	and.w	#pt_ecmdmask,d4		; extra command ?
	beq.s	pt_SetPeriod

; E5x "Set Sample Finetune"
	IFNE pt_usedefx&pt_ecmdbitsetsamplefinetune
		cmp.w	#$0e50,d4	; E5 "Set Sample Finetune" ?
		beq	pt_DoSetSampleFinetune
	ENDC
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmd(a2),d0

; 3xx "Tone Portamento"
	IFNE pt_usedfx&pt_cmdbittoneport
		cmp.b	#pt_cmdtoneport,d0
		beq	pt_ChkTonePorta
	ENDC

; 5xy "Tone Portamento + VolumeSlide"
	IFNE pt_usedfx&pt_cmdbittoneportvolslide
		cmp.b	#pt_cmdtoneportvolslide,d0
		beq	pt_ChkTonePorta
	ENDC

; 9xx "Set Sample Offset"
	IFNE pt_usedfx&pt_cmdbitsetsampleoffset
		cmp.b	#pt_cmdsetsampleoffset,d0
		bne.s	pt_SetPeriod
		bsr	pt_SetSampleOffset
	ENDC

pt_SetPeriod
	lea	pt_PeriodTable(pc),a1
	moveq	#((pt_PeriodTableEnd-pt_PeriodTable)/WORD_SIZE)-1,d7 ; number of periods
pt_FtuLoop
	cmp.w	(a1)+,d3		; note period found ?
	dbhs	d7,pt_FtuLoop
pt_FtuFound
	moveq	#0,d0
	move.b	n_finetune(a2),d0
	lea	pt_FtuPeriodTableStarts(pc),a1
	move.l	(a1,d0.w*4),a1		; period table address
	moveq	#((pt_PeriodTableEnd-pt_PeriodTable)/WORD_SIZE)-1,d0
	sub.b	d7,d0			; number of periods - loop counter = offset in periods table
	move.w	(a1,d0.w*2),n_period(a2) ; note period from table

; EDx "Note Delay"
	IFNE pt_usedefx&pt_ecmdbitnotedelay
		cmp.w	#$0ed0,d4	; ED "Note Delay" ?
		beq	pt_CheckMoreEffects
	ENDC
	move.w	n_dmabit(a2),d0
	or.w	d0,pt_DMACONtemp(a3)
	move.w	d0,_CUSTOM+DMACON	; disable audio channel DMA

; 4xy "Vibrato"
	IFNE pt_usedfx&pt_cmdbitvibrato
		btst	#pt_vibnoretrigbit,n_wavecontrol(a2) ; vibratotype 4 - no retrig waveform ?
		bne.s	pt_VibNoC
		move.b	d5,n_vibratopos(a2) ; clear vibrato position
pt_VibNoC
	ENDC

; 7xy "Tremolo"
	IFNE pt_usedfx&pt_cmdbittremolo
		btst	#pt_trenoretrigbit,n_wavecontrol(a2) ; tremolotype 4 - no retrig waveform ?
		bne.s	pt_TreNoC
		move.b	d5,n_tremolopos(a2) ; clear tremolo position
pt_TreNoC
	ENDC
	move.w	n_length(a2),d3
	move.l	n_start(a2),d2
	bne.s	pt_sdmaskp
	move.l	audio_data(a3),d2	; dummy audio data
	move.l	d2,n_loopstart(a2)
	moveq	#pt_oneshotlen,d3
	move.w	d3,n_replen(a2)
pt_sdmaskp
	IFEQ pt_track_notes_played_enabled
		move.b	d5,n_notetrigger(a2)
	ENDC
	move.l	d2,(a6)			; AUDxLCH
	IFEQ pt_track_periods_enabled
		move.w	n_period(a2),d2
		move.w	d2,6(a6)	; AUDxPER
		move.w	d2,n_currentperiod(a2)
	ELSE
		move.w	n_period(a2),6(a6) ; AUDxPER
	ENDC
	move.w	d3,4(a6)		; AUDxLEN
	bra	pt_CheckMoreEffects

; E5x "Set Sample Finetune"
	IFNE pt_usedefx&pt_ecmdbitsetsamplefinetune
		CNOP 0,4
pt_DoSetSampleFinetune
		bsr	pt_SetSampleFinetune
		bra	pt_SetPeriod
	ENDC

; 3xx "Tone Portamento" or 5xy "Tone Portamento + Volume Slide"
	IFNE pt_usedfx&(pt_cmdbittoneport|pt_cmdbittoneportvolslide)
		CNOP 0,4
pt_ChkTonePorta
		bsr.s	pt_SetTonePorta
		bra	pt_CheckMoreEffects
	ENDC

; 3xx "Tone Portamento" or 5xy "Tone Portamento + Volume Slide"
	IFNE pt_usedfx&(pt_cmdbittoneport|pt_cmdbittoneportvolslide)
		CNOP 0,4
pt_SetTonePorta
		move.b	n_finetune(a2),d0
		lea	pt_FtuPeriodTableStarts(pc),a1
		move.l	(a1,d0.w*4),a1	; period table address
		move.l	a1,d2
		moveq	#((pt_PeriodTableEnd-pt_PeriodTable)/WORD_SIZE)-1,d7 ; number of periods
pt_StpLoop
		cmp.w	(a1)+,d3	; wanted note period ?
		dbhs	d7,pt_StpLoop
		bpl.s	pt_StpFound
		moveq	#1,d7		; penultimate note period in table
pt_StpFound
		moveq	#((pt_PeriodTableEnd-pt_PeriodTable)/WORD_SIZE)-1,d0 ; number of periods
		sub.b	d7,d0		; offset in period table
		move.l	d2,a1		; period table address
		moveq	#NIBBLE_SIGN_MASK,d2
		and.b	n_finetune(a2),d2 ; negative ?
		beq.s	pt_StpGoss
		tst.w	d0		; counter = 0 ?
		beq.s	pt_StpGoss
		subq.w	#1,d0
pt_StpGoss
		move.w	(a1,d0.w*2),d3	; note period
		move.w	d3,n_wantedperiod(a2)
		move.b	d5,n_toneportdirec(a2) ; clear tone port direction
		cmp.w	n_period(a2),d3	; wanted note period reached ?
		beq.s	pt_ClearTonePorta
		bgt.s	pt_StpEnd
		move.b	#1,n_toneportdirec(a2)
pt_StpEnd
		rts
		CNOP 0,4
pt_ClearTonePorta
		move.w	d5,n_wantedperiod(a2)
		IFEQ pt_track_notes_played_enabled
			move.b	d5,n_notetrigger(a2)
		ENDC
		rts
	ENDC

; Check more effect commands at tick #1
	CNOP 0,4
pt_CheckMoreEffects
	IFNE pt_usedfx&(pt_cmdbitnotused|pt_cmdbitsetsampleoffset|pt_cmdbitposjump|pt_cmdbitsetvolume|pt_cmdbitpattbreak|pt_cmdbitextended|pt_cmdbitsetspeed)
		moveq	#pt_cmdmask,d0
		and.b	n_cmd(a2),d0
		cmp.b	#pt_cmdnotused,d0

; 8xy "Not used/custom"
		IFEQ pt_usedfx&pt_cmdbitnotused
			ble	pt_ChkMoreEfxPerNop
		ELSE
			blt	pt_ChkMoreEfxPerNop
			beq	\1
		ENDC
	ENDC

; 9xx "Set Sample Offset"
	IFNE pt_usedfx&pt_cmdbitsetsampleoffset
		cmp.b	#pt_cmdsetsampleoffset,d0
		beq	pt_SetSampleOffset
	ENDC

; Bxx "Position Jump"
	IFNE pt_usedfx&pt_cmdbitposjump
		cmp.b	#pt_cmdposjump,d0
		beq	pt_PositionJump
	ENDC

; Cxx "Set Volume"
	IFNE pt_usedfx&pt_cmdbitsetvolume
		cmp.b	#pt_cmdsetvolume,d0
		beq	pt_SetVolume
	ENDC

; Dxx "Pattern Break"
	IFNE pt_usedfx&pt_cmdbitpattbreak
		cmp.b	#pt_cmdpattbreak,d0
		beq	pt_PatternBreak
	ENDC

; Exy "Extended commands"
	IFNE pt_usedfx&pt_cmdbitextended
		cmp.b	#pt_cmdextended,d0
		beq	pt_MoreExtCommands
	ENDC

; Fxx "Set Speed"
	IFNE pt_usedfx&pt_cmdbitsetspeed
		cmp.b	#pt_cmdsetspeed,d0
		beq	pt_SetSpeed
	ENDC

pt_ChkMoreEfxPerNop
	IFEQ pt_track_periods_enabled
		move.w	n_period(a2),d2
		move.w	d2,6(a6)	; AUDxPER
		move.w	d2,n_currentperiod(a2)
	ELSE
		move.w	n_period(a2),6(a6) ; AUDxPER
	ENDC
	rts

; 9xx "Set Sample Offset"
	IFNE pt_usedfx&pt_cmdbitsetsampleoffset
		PT3_EFFECT_SET_SAMPLE_OFFSET
	ENDC
 
; Bxx "Position Jump"
	IFNE pt_usedfx&pt_cmdbitposjump
		PT3_EFFECT_POSITION_JUMP
	ENDC
 
; Cxx "Set Volume"
	IFNE pt_usedfx&pt_cmdbitsetvolume
		PT3_EFFECT_SET_VOLUME
	ENDC
 
; Dxx "Pattern Break"
	IFNE pt_usedfx&pt_cmdbitpattbreak
		PT3_EFFECT_PATTERN_BREAK
	ENDC

; Check Exy "Extended commands" at tick #1
	CNOP 0,4
pt_MoreExtCommands
	IFNE pt_usedefx
		move.b	n_cmdlo(a2),d0
		lsr.b	#NIBBLE_SHIFT_BITS,d0 ; adjust bits
	ENDC

; E0x "Set Filter"
	IFNE pt_usedefx&pt_ecmdbitsetfilter
		beq	pt_SetFilter
	ENDC

; E1x "Fine Portamento Up"
	IFNE pt_usedefx&pt_ecmdbitfineportup
		cmp.b	#pt_ecmdfineportup,d0
		beq	pt_FinePortamentoUp
	ENDC

; E2x "Fine Portamento Down"
	IFNE pt_usedefx&pt_ecmdbitfineportdown
		cmp.b	#pt_ecmdfineportdown,d0
		beq	pt_FinePortamentoDown
	ENDC

; E3x "Set Glissando Control"
	IFNE pt_usedefx&pt_ecmdbitsetglisscontrol
		cmp.b	#pt_ecmdsetglisscontrol,d0
		beq	pt_SetGlissandoControl
	ENDC

; E4x "Set Vibrato Waveform"
	IFNE pt_usedefx&pt_ecmdbitsetvibwaveform
		cmp.b	#pt_ecmdsetvibwaveform,d0
		beq	pt_SetVibratoWaveform
	ENDC

; E5x "Set Sample Finetune"
	IFNE pt_usedefx&pt_ecmdbitsetsamplefinetune
		cmp.b	#pt_ecmdsetsamplefinetune,d0
		beq	pt_SetSampleFinetune
	ENDC

; E6x "Jump to Loop"
	IFNE pt_usedefx&pt_ecmdbitjumptoloop
		cmp.b	#pt_ecmdjumptoloop,d0
		beq	pt_JumpToLoop
	ENDC

; E7x "Set Tremolo Waveform"
	IFNE pt_usedefx&pt_ecmdbitsettrewaveform
		cmp.b	#pt_ecmdsettrewaveform,d0
		beq	pt_SetTremoloWaveform
	ENDC

; E8x "Karplus Strong"
	IFNE pt_usedefx&pt_ecmdbitkarplusstrong
		cmp.b	#pt_ecmdkarplusstrong,d0
		beq	pt_KarplusStrong
	ENDC

; E9x "Retrig Note"
	IFNE pt_usedefx&pt_ecmdbitretrignote
		cmp.b	#pt_ecmdretrignote,d0
		beq	pt_RetrigNote
	ENDC

; EAx "Fine Volume Slide Up"
	IFNE pt_usedefx&pt_ecmdbitfinevolslideup
		cmp.b	#pt_ecmdfinevolslideup,d0
		beq	pt_FineVolumeSlideUp
	ENDC

; EBx "Fine Volume Slide Down"
	IFNE pt_usedefx&pt_ecmdbitfinevolslidedown
		cmp.b	#pt_ecmdfinevolslidedown,d0
		beq	pt_FineVolumeSlideDown
	ENDC

; ECx "Note Cut"
	IFNE pt_usedefx&pt_ecmdbitnotecut
		cmp.b	#pt_ecmdnotecut,d0
		beq	pt_NoteCut
	ENDC

; EDx "Note Delay"
	IFNE pt_usedefx&pt_ecmdbitnotedelay
		cmp.b	#pt_ecmdnotedelay,d0
		beq	pt_NoteDelay
	ENDC

; EEx "Pattern Delay"
	IFNE pt_usedefx&pt_ecmdbitpattdelay
		cmp.b	#pt_ecmdpattdelay,d0
		beq	pt_PatternDelay
	ENDC

; EFx "Invert Loop"
	IFNE pt_usedefx&pt_ecmdbitinvertloop
		cmp.b	#pt_ecmdinvertloop,d0
		beq	pt_InvertLoop
	ENDC
	rts

; E0x "Set Filter"
	IFNE pt_usedefx&pt_ecmdbitsetfilter
		PT3_EFFECT_SET_FILTER
	ENDC 

; E1x "Fine Portamento Up"
	IFNE pt_usedefx&pt_ecmdbitfineportup
		PT3_EFFECT_FINE_PORTAMENTO_UP
	ENDC 

; E2x "Fine Portamento Down"
	IFNE pt_usedefx&pt_ecmdbitfineportdown
		PT3_EFFECT_FINE_PORTAMENTO_DOWN
	ENDC 

; E3x "Set Glissando Control"
	IFNE pt_usedefx&pt_ecmdbitsetglisscontrol
		PT3_EFFECT_SET_GLISS_CONTROL
	ENDC
 
; E4x "Set Vibrato Waveform"
	IFNE pt_usedefx&pt_ecmdbitsetvibwaveform
		PT3_EFFECT_SET_VIB_WAVEFORM
	ENDC 

; E5x "Set Sample Finetune"
	IFNE pt_usedefx&pt_ecmdbitsetsamplefinetune
		PT3_EFFECT_SET_SAMPLE_FINETUNE
	ENDC 

; E6x "Jump to Loop"
	IFNE pt_usedefx&pt_ecmdbitjumptoloop
		PT3_EFFECT_JUMP_TO_LOOP
	ENDC 

; E7x "Set Tremolo Waveform"
	IFNE pt_usedefx&pt_ecmdbitsettrewaveform
		PT3_EFFECT_SET_TRE_WAVEFORM
	ENDC 

; E80 "Karplus Strong"
	IFNE pt_usedefx&pt_ecmdbitkarplusstrong
		PT3_EFFECT_KARPLUS_STRONG
	ENDC

; E9x "Retrig Note" or EDx "Note Delay"
	IFNE pt_usedefx&(pt_ecmdbitretrignote|pt_ecmdbitnotedelay)
		PT3_EFFECT_RETRIG_NOTE
	ENDC 

; EAx "Fine Volume Slide Up"
	IFNE pt_usedefx&pt_ecmdbitfinevolslideup
		PT3_EFFECT_FINE_VOL_SLIDE_UP
	ENDC 

; EBx "Fine Volume Slide Down"
	IFNE pt_usedefx&pt_ecmdbitfinevolslidedown
		PT3_EFFECT_FINE_VOL_SLIDE_DOWN
	ENDC 

; ECx "Note Cut"
	IFNE pt_usedefx&pt_ecmdbitnotecut
		PT3_EFFECT_NOTE_CUT
	ENDC 

; EDx "Note Delay"
	IFNE pt_usedefx&pt_ecmdbitnotedelay
		PT3_EFFECT_NOTE_DELAY
	ENDC 

; EEx "Pattern Delay"
	IFNE pt_usedefx&pt_ecmdbitpattdelay
		PT3_EFFECT_PATTERN_DELAY
	ENDC

; EFx "Invert Loop"
	IFNE pt_usedefx&pt_ecmdbitinvertloop
		PT3_EFFECT_INVERT_LOOP
	ENDC

; Fxx "Set Speed"
	IFNE pt_usedfx&pt_cmdbitsetspeed
		PT3_EFFECT_SET_SPEED
	ENDC

	CNOP 0,4
pt_SetDMA
	move.b	d5,pt_SetAllChanDMAFlag(a3) ; activate DMA interrupt routine
	moveq	#CIACRBF_START,d0
	or.b	d0,(a5)			; start DMA wait counter
pt_Dskip
	addq.w	#pt_pattposdata_size/4,pt_PatternPosition(a3) ; next pattern position

; EEx "Pattern Delay"
	IFNE pt_usedefx&pt_ecmdbitpattdelay
		move.b	pt_PattDelayTime(a3),d0
		beq.s	pt_DskipC
		move.b	d0,pt_PattDelayTime2(a3)
		move.b	d5,pt_PattDelayTime(a3)
pt_DskipC
		tst.b	pt_PattDelayTime2(a3)
		beq.s	pt_DskipA
		subq.b	#1,pt_PattDelayTime2(a3)
		beq.s	pt_DskipA
		subq.w	#pt_pattposdata_size/4,pt_PatternPosition(a3) ; previous pattern position
pt_DskipA
	ENDC

; E6x "Jump to Loop"
	IFNE pt_usedefx&pt_ecmdbitjumptoloop
		tst.b	pt_PBreakFlag(a3)
		beq.s	pt_Nnpysk
		move.b	d5,pt_PBreakFlag(a3)
		moveq	#0,d0
		move.b	pt_PBreakPosition(a3),d0
		move.b	d5,pt_PBreakPosition(a3)
		MULUF.W	pt_pattposdata_size/4,d0,d2
		move.w	d0,pt_PatternPosition(a3)
pt_Nnpysk
	ENDC
	cmp.w	#pt_pattsize/4,pt_PatternPosition(a3) ; end of pattern reached ?
	blo.s	pt_NoNewPositionYet
pt_NextPosition
	move.b	d5,pt_PosJumpFlag(a3)
	moveq	#0,d0
	move.b	pt_PBreakPosition(a3),d0
	move.b	d5,pt_PBreakPosition(a3)
	MULUF.W	pt_pattposdata_size/4,d0,d2 ; offset to pattern data
	move.w	d0,pt_PatternPosition(a3)
	move.w	pt_SongPosition(a3),d1
	addq.w	#1,d1			; next song position
	and.w	#pt_maxsongpos-1,d1	; remove overflow
	move.w	d1,pt_SongPosition(a3)
	cmp.b	pt_SongLength(a3),d1	; last song position reached ?
	blo.s	pt_NoNewPositionYet
	move.w	d5,pt_SongPosition(a3)
pt_NoNewPositionYet
	tst.b	pt_PosJumpFlag(a3)
	bne.s	pt_NextPosition
	movem.l	(a7)+,a5-a6
	rts
	ENDM


; 0xy "Normal play" or "Arpeggio"
PT3_EFFECT_ARPEGGIO		MACRO
; Input
; Result
	CNOP 0,4
pt_Arpeggio
	move.w	pt_Counter(a3),d0
pt_ArpDivLoop
	subq.w	#pt_ArpDiv,d0		; substract divisor from dividend
	bge.s	pt_ArpDivLoop		; until dividend < divisor
	addq.w	#pt_ArpDiv,d0		; adjust division remainder
	subq.w	#1,d0			; remainder = $0001: add 1st halftone at tick #2 ?
	beq.s	pt_Arpeggio1
	subq.w	#1,d0			; remainder = $0002: add 2nd halftone at tick #3 ?
	beq.s	pt_Arpeggio2
; 000 "Normal Play" 1st note
pt_Arpeggio0
	move.w	n_period(a2),d2		; play original note period at tick #1
pt_ArpeggioSet
	move.w	d2,6(a6)		; AUDxPER
	IFEQ pt_track_periods_enabled
		move.w	d2,n_currentperiod(a2)
	ENDC
	rts
; 0x0 "Arpeggio" 2nd note
	CNOP 0,4
pt_Arpeggio1
	move.b	n_cmdlo(a2),d0
	lsr.b	#NIBBLE_SHIFT_BITS,d0	; command data: x-first halftone
	bra.s	pt_ArpeggioFind
; 00y "Arpeggio" 3rd note
	CNOP 0,4
pt_Arpeggio2
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: y-second halftone
pt_ArpeggioFind
	move.w	n_period(a2),d2
	moveq	#0,d7
	move.b	n_finetune(a2),d7
	lea	pt_FtuPeriodTableStarts(pc),a1
	move.l	(a1,d7.w*4),a1		; period table address
	moveq	#((pt_PeriodTableEnd-pt_PeriodTable)/WORD_SIZE)-1,d7 ; number of periods
pt_ArpLoop
	cmp.w	(a1)+,d2		; note period >= table note period ?
	dbhs	d7,pt_ArpLoop
	bpl.s	pt_ArpFound
	rts
	CNOP 0,4
pt_ArpFound
	moveq	#((pt_PeriodTableEnd-pt_PeriodTable)/WORD_SIZE)-1,d3
	sub.b	d7,d3			; number of periods - loopcounter = offset in periods table
	add.b	d0,d3			; + 1st or 2nd halftone
	cmp.b	#(pt_PeriodTableEnd-pt_PeriodTable)/WORD_SIZE,d3
	blt.s	pt_ArpNoClip
	moveq	#0,d0			; clip 1st or 2nd halftone
pt_ArpNoClip
	move.w	-WORD_SIZE(a1,d0.w*2),d2 ; original note period + 1st or 2nd halftone offset
	bra.s	pt_ArpeggioSet
	ENDM


; 1xx "Portamento Up"	
PT3_EFFECT_PORTAMENTO_UP	MACRO
; Input
; Result
	CNOP 0,4
pt_PortamentoUp
	move.b	n_cmdlo(a2),d0		; command data: xx-upspeed
	move.w	n_period(a2),d2
	IFNE pt_usedefx&pt_ecmdbitfineportup
		and.b	pt_LowMask(a3),d0 ; use 4 or 8 bits of upspeed
	ENDC
	sub.w	d0,d2			; note period - upspeed
	IFNE pt_usedefx&pt_ecmdbitfineportup
		move.b	d6,pt_LowMask(a3) ; set back low mask to $ff
	ENDC
	cmp.w	#pt_portminper,d2
	bpl.s	pt_PortaUpSkip
	moveq	#pt_portminper,d2
pt_PortaUpSkip
	move.w	d2,6(a6)		; AUDxPER
	move.w	d2,n_period(a2)
	IFEQ pt_track_periods_enabled
		move.w	d2,n_currentperiod(a2)
	ENDC
pt_PortaUpEnd
	rts
	ENDM


; 2xx "Portamento Down"
PT3_EFFECT_PORTAMENTO_DOWN	MACRO
; Input
; Result
	CNOP 0,4
pt_PortamentoDown
	move.b	n_cmdlo(a2),d0		; command data: xx-downspeed
	move.w	n_period(a2),d2
	IFNE pt_usedefx&pt_ecmdbitfineportdown
		and.b	pt_LowMask(a3),d0 ; use 4 or 8 bits of upspeed
	ENDC
	add.w	d0,d2			; note period + downspeed
	IFNE pt_usedefx&pt_ecmdbitfineportdown
		move.b	d6,pt_LowMask(a3) ; set back low mask to $ff
	ENDC
	cmp.w	#pt_portmaxper,d2
	bmi.s	pt_PortaDownSkip
	move.w	#pt_portmaxper,d2
pt_PortaDownSkip
	move.w	d2,6(a6)		; AUDxPER
	move.w	d2,n_period(a2)
	IFEQ pt_track_periods_enabled
		move.w	d2,n_currentperiod(a2)
	ENDC
pt_PortaDownEnd
	rts
	ENDM


; 3xx "Tone Portamento"
PT3_EFFECT_TONE_PORTAMENTO MACRO
; Input
; Result
	CNOP 0,4
pt_TonePortamento
	move.b	n_cmdlo(a2),d0		; command data: xx-up/down speed
	beq.s	pt_TonePortaNoChange
	move.b	d0,n_toneportspeed(a2)
	move.b	d5,n_cmdlo(a2)		; clear command data
pt_TonePortaNoChange
	move.w	n_wantedperiod(a2),d2
	beq.s	pt_TonePortaEnd
	move.w	n_period(a2),d3
	move.b	n_toneportspeed(a2),d0
	tst.b	n_toneportdirec(a2)	; check tone portamento direction
	bne.s	pt_TonePortaUp
pt_TonePortaDown
	add.w	d0,d3			; note period + down speed
	cmp.w	d3,d2			; wanted note period reached ?
	bgt.s	pt_TonePortaSetPer
	move.w	d2,d3			; note period = wanted note period
	IFEQ pt_track_notes_played_enabled
		move.b	d5,n_notetrigger(a2)
	ENDC
	moveq	#0,d2			; clear wanted note period
	bra.s	pt_TonePortaSetPer
	CNOP 0,4
pt_TonePortaUp
	sub.w	d0,d3			; note period - up speed
	cmp.w	d3,d2			; wanted note period reached ?
	blt.s	pt_TonePortaSetPer
	move.w	d2,d3			; note period = wanted note period
	IFEQ pt_track_notes_played_enabled
		move.b	d5,n_notetrigger(a2)
	ENDC
	moveq	#0,d2			; clear wanted note period
pt_TonePortaSetPer
	move.w	d2,n_wantedperiod(a2)
	moveq	#NIBBLE_MASK_LOW,d0
	move.w	d3,n_period(a2)
	and.b	n_glissinvert(a2),d0	; glissando state
	beq.s	pt_GlissSkip
	move.b	n_finetune(a2),d0
	lea	pt_FtuPeriodTableStarts(pc),a1
	move.l	(a1,d0.w*4),a1		; period table address
	moveq	#((pt_PeriodTableEnd-pt_PeriodTable)/2)-1,d7 ; number of periods
pt_GlissLoop
	cmp.w	(a1)+,d3		; note period >= table note period ?
	dbhs	d7,pt_GlissLoop
	bpl.s	pt_GlissFound
	subq.w	#LONGWORD_SIZE,a1	; penultimate period
pt_GlissFound
	move.w	-WORD_SIZE(a1),d3	; note period from period table
pt_GlissSkip
	move.w	d3,6(a6)		; AUDxPER
	IFEQ pt_track_periods_enabled
		move.w	d3,n_currentperiod(a2)
	ENDC
pt_TonePortaEnd
	rts
	ENDM



; 4xy "Vibrato"
PT3_EFFECT_VIBRATO		MACRO
; Input
; Result
	CNOP 0,4
pt_Vibrato
	move.b	n_cmdlo(a2),d0		; command data: x-speed y-depth
	beq.s	pt_Vibrato2
	move.b	n_vibratocmd(a2),d2	; vibrato command data
	and.b	#NIBBLE_MASK_LOW,d0	; y-depth
	beq.s	pt_VibSkip
	and.b	#NIBBLE_MASK_HIGH,d2	; clear old vibrato depth
	or.b	d0,d2			; new depth in vibrato command data
pt_VibSkip
	MOVEF.B	NIBBLE_MASK_HIGH,d0
	and.b	n_cmdlo(a2),d0		; command data: x-speed
	beq.s	pt_VibSkip2
	and.b	#NIBBLE_MASK_LOW,d2	; clear old speed
	or.b	d0,d2			; new speed in vibrato command data
pt_VibSkip2
	move.b	d2,n_vibratocmd(a2)
pt_Vibrato2
	lea	pt_VibTreSineTable(pc),a1
	move.b	n_vibratopos(a2),d0
	lsr.b	#2,d0
	moveq	#pt_wavetypemask,d2
	and.w	#$001f,d0		; remove position overflow
	and.b	n_wavecontrol(a2),d2	; vibrato waveform type
	beq.s	pt_VibSine
	MULUF.B	8,d0
	subq.b	#1,d2			; vibrato waveform 1-ramp down ?
	beq.s	pt_VibRampdown
pt_VibSquare
	MOVEF.W	255,d2			; square amplitude
	bra.s	pt_VibSet
	CNOP 0,4
pt_VibRampdown
	tst.b	n_vibratopos(a2)	; vibrato position positive ?
	bpl.s	pt_VibRampdown2
	MOVEF.W	255,d2			; rampdown amplitude
	sub.b	d0,d2			; reduce amplitude
	bra.s	pt_VibSet
	CNOP 0,4
pt_VibRampdown2
	move.b	d0,d2			; rampdown amplitude
	bra.s	pt_VibSet
	CNOP 0,4
pt_VibSine
	move.b	(a1,d0.w),d2		; sine amplitude
pt_VibSet
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_vibratocmd(a2),d0	; depth
	mulu.w	d0,d2			; depth * amplitude
	move.w	n_period(a2),d0
	lsr.w	#7,d2			; period amplitude = (depth * amplitude) / 128
	tst.b	n_vibratopos(a2)	; vibrato position negative ?
	bmi.s	pt_VibratoNeg
	add.w	d2,d0			; note period + period amplitude
	bra.s	pt_Vibrato3
	CNOP 0,4
pt_VibratoNeg
	sub.w	d2,d0			; note period - period amplitude
pt_Vibrato3
	move.w	d0,6(a6)		; AUDxPER
	IFEQ pt_track_periods_enabled
		move.w	d0,n_currentperiod(a2)
	ENDC
	move.b	n_vibratocmd(a2),d2	; vibrato command data
	lsr.b	#2,d2
	and.b	#$3c,d2			; remove vibrato position overflow
	add.b	d2,n_vibratopos(a2)	; next vibrato position
	rts
	ENDM


; 5xy "Tone Portamento + VolumeSlide"
PT3_EFFECT_TONE_PORTA_VOL_SLIDE	MACRO
; Input
; Result
	CNOP 0,4
pt_TonePortaPlusVolSlide
	bsr.s	pt_TonePortaNoChange
	bra	pt_VolumeSlide
	ENDM


; 6xy "Vibrato + Volume Slide"
PT3_EFFECT_VIB_VOL_SLIDE	MACRO
; Input
; Result
	CNOP 0,4
pt_VibratoPlusVolSlide
	bsr	pt_Vibrato2
	bra	pt_VolumeSlide
	ENDM


; 7xy "Tremolo"
PT3_EFFECT_TREMOLO		MACRO
; Input
; Result
	CNOP 0,4
pt_Tremolo
	move.b	n_cmdlo(a2),d0		; command data: x-speed y-depth
	beq.s	pt_Tremolo2
	move.b	n_tremolocmd(a2),d2	; tremolo command data
	and.b	#NIBBLE_MASK_LOW,d0	; y-depth
	beq.s	pt_TreSkip
	and.b	#NIBBLE_MASK_HIGH,d2	; clear old tremolo depth
	or.b	d0,d2			; new depth in tremolo command data
pt_TreSkip
	MOVEF.B	NIBBLE_MASK_HIGH,d0
	and.b	n_cmdlo(a2),d0		; command data: x-speed
	beq.s	pt_TreSkip2
	and.b	#NIBBLE_MASK_LOW,d2	; clear old speed
	or.b	d0,d2			; new tremolo speed in command data
pt_TreSkip2
	move.b	d2,n_tremolocmd(a2)
pt_Tremolo2
	lea	pt_VibTreSineTable(pc),a1
	move.b	n_tremolopos(a2),d0
	lsr.b	#2,d0
	move.b	n_wavecontrol(a2),d2	; tremolo waveform
	lsr.b	#NIBBLE_SHIFT_BITS,d2	; adjust bits
	and.w	#$001f,d0		; remove tremolo position overflow
	and.w	#pt_wavetypemask,d2	; tremolo waveform type
	beq.s	pt_TreSine
	MULUF.B	8,d0
	subq.b	#1,d2			; tremolo waveform 1-ramp down ?
	beq.s	pt_TreRampdown
pt_TreSquare
	MOVEF.W	255,d2			; square amplitude
	bra.s	pt_TreSet
	CNOP 0,4
pt_TreRampdown
	tst.b	n_tremolopos(a2)	; tremolo position positive ?
	bpl.s	pt_TreRampdown2
	MOVEF.W	255,d2			; rampdown amplitude
	sub.b	d0,d2			; reduce rampdown amplitude
	bra.s	pt_TreSet
	CNOP 0,4
pt_TreRampdown2
	move.b	d0,d2			; rampdown amplitude
	bra.s	pt_TreSet
	CNOP 0,4
pt_TreSine
	move.b	(a1,d0.w),d2		; sine amplitude
pt_TreSet
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_tremolocmd(a2),d0	; depth
	mulu.w	d0,d2			; depth * amplitude
	move.b	n_volume(a2),d0
	lsr.w	#6,d2			; volume amplitude = (depth * amplitude) / 64
	tst.b	n_tremolopos(a2)	; tremolo position negative ?
	bmi.s	pt_TremoloNeg
	add.w	d2,d0			; volume + volume amplitude
	bra.s	pt_Tremolo3
	CNOP 0,4
pt_TremoloNeg
	sub.w	d2,d0			; volume - volume amplitude
pt_Tremolo3
	bpl.s	pt_TremoloSkip
	moveq	#pt_minvol,d0
pt_TremoloSkip
	cmp.w	#pt_maxvol,d0
	bls.s	pt_TremoloOk
	moveq	#pt_maxvol,d0
pt_TremoloOk
	IFEQ pt_music_fader_enabled
		move.w	pt_master_volume(a3),d2
		cmp.w	#pt_maxvol,d2
		beq.s	pt_DecVolSkip3
		mulu.w	d2,d0
		lsr.w	#6,d0
pt_DecVolSkip3
	ENDC
	IFEQ pt_mute_enabled
		move.w	d5,8(a6)	; AUDxVOL muted
	ELSE
		move.w	d0,8(a6)	; AUDxVOL
		IFEQ pt_track_volumes_enabled
			move.w	d0,n_currentvolume(a2)
		ENDC
	ENDC
	move.b	n_tremolocmd(a2),d2	; tremolo command data
	lsr.b	#2,d2
	and.b	#$3c,d2			; remove tremolo position overflow
	add.b	d2,n_tremolopos(a2)	; next tremolo position
	addq.w	#LONGWORD_SIZE,a7	; skip update volume subroutine
	rts
	ENDM


; Axy "Volume Slide" 
PT3_EFFECT_VOLUME_SLIDE		MACRO
; Input
; Result
	CNOP 0,4
pt_VolumeSlide
	move.b	n_cmdlo(a2),d0
	lsr.b	#NIBBLE_SHIFT_BITS,d0	; command data: x-upspeed
	beq.s	pt_VolSlideDown
; Ax0 "Volume Slide Up"
pt_VolSlideUp
	moveq	#0,d2
	move.b	n_volume(a2),d2
	add.b	d0,d2			; volume + upspeed
	cmp.b	#pt_maxvol,d2
	bls.s	pt_VsuSkip
	moveq	#pt_maxvol,d2
pt_VsuSkip
	move.b	d2,n_volume(a2)
	IFEQ pt_track_volumes_enabled
		move.w	d2,n_currentvolume(a2)
	ENDC
pt_VSUEnd
	rts
; A0y "Volume Slide Down"
	CNOP 0,4
pt_VolSlideDown
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: y-downspeed
	moveq	#0,d2
	move.b	n_volume(a2),d2	;Get volume
	sub.b	d0,d2			; volume - downspeed
	bpl.s	pt_VsdSkip
	moveq	#pt_minvol,d2
pt_VsdSkip
	move.b	d2,n_volume(a2)
	IFEQ pt_track_volumes_enabled
		move.w	d2,n_currentvolume(a2)
	ENDC
pt_VsdEnd
	rts
	ENDM


; 9xx "Set Sample Offset"
PT3_EFFECT_SET_SAMPLE_OFFSET MACRO
; Input
; Result
	CNOP 0,4
pt_SetSampleOffset
	move.b	n_cmdlo(a2),d0		; command data: xx-sample offset
	beq.s	pt_SetSoNoNew
	move.b	d0,n_sampleoffset(a2)
pt_SetSoNoNew
	move.b	n_sampleoffset(a2),d0
	MULUF.W	128,d0,d2
	cmp.w	n_length(a2),d0		; >= length ?
	bge.s	pt_SetSoSkip
	sub.w	d0,n_length(a2)		; length - offset
	MULUF.W	WORD_SIZE,d0,d2		; offset in bytes
	add.l	d0,n_start(a2)		; sample start + offset
	rts
	CNOP 0,4
pt_SetSoSkip
	move.w	#pt_oneshotlen,n_length(a2)
	rts
	ENDM


; Bxx "Position Jump"
PT3_EFFECT_POSITION_JUMP	MACRO
; Input
; Result
	CNOP 0,4
pt_PositionJump
	move.b	n_cmdlo(a2),d0		; command data: xx-song position
	move.b	d5,pt_PBreakPosition(a3)
	subq.b	#1,d0
	move.w	d0,pt_SongPosition(a3)
	move.b	d6,pt_PosJumpFlag(a3)
	rts
	ENDM


; Cxx "Set Volume" 
PT3_EFFECT_SET_VOLUME		MACRO
; Input
; Result
	CNOP 0,4
pt_SetVolume
	move.b	n_cmdlo(a2),d0		; command data: xx-volume
	cmp.b	#pt_maxvol,d0
	bls.s	pt_MaxVolOk
	moveq	#pt_maxvol,d0
pt_MaxVolOk
	move.b	d0,n_volume(a2)
	rts
	ENDM


; Dxx "Pattern Break"
PT3_EFFECT_PATTERN_BREAK	MACRO
; Input
; Result
	CNOP 0,4
pt_PatternBreak
	move.b	n_cmdlo(a2),d0		; command data: xx-break position (decimal)
	moveq	#NIBBLE_MASK_LOW,d2
	and.b	d0,d2		 nibble: digits 0..9
	lsr.b	#NIBBLE_SHIFT_BITS,d0	; adjust bits
	MULUF.B	10,d0,d7 nibble:  digits 10..60
	add.b	d2,d0			; decimal number
	cmp.b	#pt_maxpattpos-1,d0	; break position > last position in pattern ?
	bhi.s	pt_PB2
	move.b	d0,pt_PBreakPosition(a3)
	move.b	d6,pt_PosJumpFlag(a3)
	rts
	CNOP 0,4
pt_PB2
	move.b	d5,pt_PBreakPosition(a3)
	move.b	d6,pt_PosJumpFlag(a3)
	rts
	ENDM


; E0x "Set Filter"
PT3_EFFECT_SET_FILTER		MACRO
; Input
; Result
	CNOP 0,4
pt_SetFilter
	moveq	#1,d0
	and.b	n_cmdlo(a2),d0		; command data: filter state [0-on, 1-off]
	bne.s	pt_FilterOff
pt_FilterOn
	MOVEF.B	(~CIAF_LED),d0
	and.b	d0,(a4)			; turn filter on
	rts
	CNOP 0,4
pt_FilterOff
	moveq	#CIAF_LED,d0
	or.b	d0,(a4)			; turn filter off
	rts
	ENDM


; E1x "Fine Portamento Up"
PT3_EFFECT_FINE_PORTAMENTO_UP	MACRO
; Input
; Result
	CNOP 0,4
pt_FinePortamentoUp
	moveq	#NIBBLE_MASK_LOW,d0
	move.b	d0,pt_LowMask(a3)
	bra	pt_PortamentoUp
	ENDM


; E2x "Fine Portamento Down"
PT3_EFFECT_FINE_PORTAMENTO_DOWN MACRO
; Input
; Result
	CNOP 0,4
pt_FinePortamentoDown
	moveq	#NIBBLE_MASK_LOW,d0
	move.b	d0,pt_LowMask(a3)
	bra	pt_PortamentoDown
	ENDM


; E3x "Set Glissando Control"
PT3_EFFECT_SET_GLISS_CONTROL	MACRO
; Input
; Result
	CNOP 0,4
pt_SetGlissandoControl
	MOVEF.B	NIBBLE_MASK_HIGH,d2
	and.b	n_glissinvert(a2),d2	; clear old glissando state
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: glissando state 0-off, 1-on
	or.b	d0,d2			; set new glissando state
	move.b	d2,n_glissinvert(a2)
	rts
	ENDM


; E4x "Set Vibrato Waveform"
PT3_EFFECT_SET_VIB_WAVEFORM	MACRO
; Vibrato waveform types
;	0 - sine (default)
;	4   (without retrigger)
;	1 - ramp down
;	5   (without retrigger)
;	2 - square
;	6   (without retrigger)
; Input
; Result
	CNOP 0,4
pt_SetVibratoWaveform
	MOVEF.B	NIBBLE_MASK_HIGH,d2
	and.b	n_wavecontrol(a2),d2	; clear old vibrato waveform
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: vibrato waveform
	or.b	d0,d2			; set new vibrato waveform
	move.b	d2,n_wavecontrol(a2)
	rts
	ENDM


; E5x "Set Sample Finetune"
PT3_EFFECT_SET_SAMPLE_FINETUNE	MACRO
; Input
; Result
	CNOP 0,4
pt_SetSampleFinetune
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: new finetune value
	move.b	d0,n_finetune(a2)
	rts
	ENDM


; E6x "Jump to Loop"
PT3_EFFECT_JUMP_TO_LOOP		MACRO
; Input
; Result
	CNOP 0,4
pt_JumpToLoop
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: x-times
	beq.s	pt_SetLoop
	tst.b	n_loopcount(a2)
	beq.s	pt_JmpLoopCnt
	subq.b	#1,n_loopcount(a2)
	beq.s	pt_JmpLoopEnd
pt_JmpLoop
	move.b	n_pattpos(a2),pt_PBreakPosition(a3)
	move.b	d6,pt_PBreakFlag(a3)
pt_JmpLoopEnd
	rts
	CNOP 0,4
pt_JmpLoopCnt
	move.b	d0,n_loopcount(a2)
	bra.s	pt_JmpLoop
	CNOP 0,4
pt_SetLoop
	move.w	pt_PatternPosition(a3),d0
	lsr.w	#2,d0
	move.b	d0,n_pattpos(a2)
	rts
	ENDM


; E7x "Set Tremolo Waveform"	
PT3_EFFECT_SET_TRE_WAVEFORM MACRO
; Tremolo waveform types
;	0 - sine (default)
;	4   (without retrigger)
;	1 - ramp down
;	5   (without retrigger)
;	2 - square
;	6   (without retrigger)
; Input
; Result
	CNOP 0,4
pt_SetTremoloWaveform
	move.b	n_cmdlo(a2),d0		; command data: tremolo waveform
	moveq	#NIBBLE_MASK_LOW,d2
	and.b	n_wavecontrol(a2),d2	; clear old tremolo waveform
	lsl.b	#NIBBLE_SHIFT_BITS,d0	; adjust bits
	or.b	d0,d2			; set new tremolo waveform
	move.b	d2,n_wavecontrol(a2)
	rts
	ENDM


; E80 "Karplus Strong"
PT3_EFFECT_KARPLUS_STRONG	MACRO
; Input
; Result
	CNOP 0,4
pt_KarplusStrong
	move.w	n_replen(a2),d7
	subq.w	#1,d7			; loop ends at false
	move.l	a0,-(a7)
	MULUF.W	WORD_SIZE,d7,d0		; repeat length in bytes
	move.l	n_loopstart(a2),a0
	move.l	a0,a1
	and.w	#pt_maxloopcount,d7	; remove overflow
pt_KarpLoop
	move.b	(a1),d0			; sample byte from loop
	ext.w	d0
	move.b	1(a1),d2		; next sample byte
	ext.w	d2
	add.w	d0,d2
	lsr.w	#1,d2
	move.b	d2,(a1)+		; interpolated sample byte
	dbf	d7,pt_KarpLoop
	move.b	(a1),d0			; last sample byte
	ext.w	d0
	move.b	(a0),d2			; 1st sample byte
	ext.w	d2
	move.l	(a7)+,a0
	add.w	d0,d2
	lsr.w	#1,d2
	move.b	d2,(a1)			; interpolated sample byte
	rts
	ENDM


; E9x "Retrig Note"
PT3_EFFECT_RETRIG_NOTE		MACRO
; Input
; Result
	CNOP 0,4
pt_RetrigNote
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: x-blanks
	beq.s	pt_RtnEnd
	move.w	pt_Counter(a3),d2
	bne.s	pt_RtnSkip
	move.w	(a2),d7			; note data from pattern position
	and.w	d6,d7			; note period
	bne.s	pt_RtnEnd
pt_RtnSkip
	sub.w	d0,d2			; substract divisor from dividend
	bge.s	pt_RtnSkip		; until dividend < divisor
	add.w	d0,d2			; adjust division remainder
	bne.s	pt_RtnEnd
	move.w	n_dmabit(a2),d0
	move.w	d0,_CUSTOM+DMACON	; disable audio channel DMA
	IFNE pt_usedefx&(pt_ecmdbitretrignote|pt_ecmdbitnotedelay)
		or.w	d0,pt_RtnDMACONtemp(a3)
		move.b	d5,n_rtnsetchandma(a2)	; activate routine
	ENDC
	IFEQ pt_track_notes_played_enabled
		move.b	d5,n_notetrigger(a2)
	ENDC
	move.l	n_start(a2),(a6)	; AUDxLCH
	move.w	n_length(a2),4(a6)	; AUDxLEN
pt_RtnEnd
	rts
	ENDM


; EAx "Fine Volume Slide Up"
PT3_EFFECT_FINE_VOL_SLIDE_UP	MACRO
; Input
; Result
	CNOP 0,4
pt_FineVolumeSlideUp
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: y-downspeed
	bra	pt_VolSlideUp
	ENDM


; EBx "Fine Volume Slide Down"
PT3_EFFECT_FINE_VOL_SLIDE_DOWN	MACRO
; Input
; Result
	CNOP 0,4
pt_FineVolumeSlideDown
	bra	pt_VolSlideDown
	ENDM


; ECx "Note Cut"
PT3_EFFECT_NOTE_CUT		MACRO
; Input
; Result
	CNOP 0,4
pt_NoteCut
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: x-blanks
	cmp.w	pt_Counter(a3),d0	; blanks = ticks ?
	bne.s	pt_NoteCutEnd
	move.b	d5,n_volume(a2)
pt_NoteCutEnd
	rts
	ENDM


; EDx "Note Delay"
PT3_EFFECT_NOTE_DELAY		MACRO
; Input
; Result
	CNOP 0,4
pt_NoteDelay
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: x-blanks
	cmp.w	pt_Counter(a3),d0	; blanks = ticks ?
	bne.s	pt_NoteDelayEnd
	move.w	(a2),d0			; note period from pattern position
	and.w	d6,d0			; note period
	beq.s	pt_NoteDelayEnd
	move.w	n_dmabit(a2),d0
	move.w	d0,_CUSTOM+DMACON	; disable audio channel DMA
	or.w	d0,pt_RtnDMACONtemp(a3)
	move.b	d5,n_rtnsetchandma(a2)	; activate routine
	IFEQ pt_track_notes_played_enabled
		move.b	d5,n_notetrigger(a2) ; set note trigger flag
	ENDC
	move.l	n_start(a2),(a6)	; AUDxLCH
	move.w	n_length(a2),4(a6)	; AUDxLEN
pt_NoteDelayEnd
	rts
	ENDM


; EEx "Pattern Delay"
PT3_EFFECT_PATTERN_DELAY	MACRO
; Input
; Result
	CNOP 0,4
pt_PatternDelay
	moveq	#NIBBLE_MASK_LOW,d0
	and.b	n_cmdlo(a2),d0		; command data: x-notes
	tst.b	pt_PattDelayTime2(a3)
	bne.s	pt_PattDelayEnd
	addq.b	#1,d0
	move.b	d0,pt_PattDelayTime(a3)
pt_PattDelayEnd
	rts
	ENDM


; EFx "Invert Loop"
PT3_EFFECT_INVERT_LOOP		MACRO
; Input
; Result
	CNOP 0,4
pt_InvertLoop
	move.b	n_cmdlo(a2),d0		; command data: x-speed
	moveq	#NIBBLE_MASK_LOW,d2
	and.b	n_glissinvert(a2),d2	; clear old speed
	lsl.b	#NIBBLE_SHIFT_BITS,d0	; adjust bits
	or.b	d0,d2			; new speed
	move.b	d2,n_glissinvert(a2)
	tst.b	d0			; speed = 0 ?
	beq.s	pt_InvertEnd
pt_UpdateInvert
	moveq	#0,d0
	move.b	n_glissinvert(a2),d0
	lsr.b	#NIBBLE_SHIFT_BITS,d0	; speed
	beq.s	pt_InvertEnd
	lea	pt_InvertTable(pc),a1
	move.b	(a1,d0.w),d0		; invert value
	add.b	d0,n_invertoffset(a2)	; decrease invert offset by invert value
	bpl.s	pt_InvertEnd
	move.l	n_wavestart(a2),a1
	move.w	n_replen(a2),d0
	MULUF.W	WORD_SIZE,d0		; length in bytes
	add.l	n_loopstart(a2),d0	; add loop start = repeat point
	addq.w	#BYTE_SIZE,a1		; next sample byte
	move.b	d5,n_invertoffset(a2)	; clear invert-offset
	cmp.l	d0,a1			; wavestart < repeat point ?
	blo.s	pt_InvertOk
	move.l	n_loopstart(a2),a1
pt_InvertOk
	move.l	a1,n_wavestart(a2)
	not.b	(a1)			; invert sample data byte
pt_InvertEnd
	rts
	ENDM


; Fxx "Set Speed"
PT3_EFFECT_SET_SPEED		MACRO
; Input
; Result
	CNOP 0,4
pt_SetSpeed
	IFEQ pt_ciatiming_enabled
		move.b	n_cmdlo(a2),d0	; command data: xx-speed [$00-$1f ticks, $20-$ff BPM]
		beq.s	pt_StopReplay
		cmp.b	#pt_maxticks,d0
		bhi.s	pt_SetTempo
		move.w	d0,pt_CurrSpeed(a3)
		move.w	d5,pt_Counter(a3) ; restart ticks counter
		rts
		CNOP 0,4
pt_SetTempo
		move.l	pt_125bpmrate(a3),d2
		divu.w	d0,d2		; /tempo = counter value
		move.b	d2,CIATALO-CIACRB(a5)
		lsr.w	#BYTE_SHIFT_BITS,d2 ; adjust bits
		move.b	d2,CIATAHI-CIACRB(a5)
		rts
		CNOP 0,4
pt_StopReplay
		move.w	#INTF_EXTER,_CUSTOM+INTENA ; stop replay routine by turning off level-6 interrupt
		rts
	ELSE
		move.b	n_cmdlo(a2),d0	; command data: xx-speed ($00-$1f ticks)
		beq.s	pt_StopReplay
		cmp.b	#pt_maxticks,d0
		bhi.s	pt_SetSpdEnd
		move.w	d0,pt_CurrSpeed(a3)
		move.w	d5,pt_Counter(a3) ; restart ticks counter = tick #1
pt_SetSpdEnd
		rts
		CNOP 0,4
pt_StopReplay
		move.w	#INTF_VERTB,_CUSTOM+INTENA ; stop replay routine by turning off vertical blank interrupt
		rts
	ENDC
	ENDM

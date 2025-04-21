PT_FADE_OUT_VOLUME		MACRO
; Input
; \1 STRING:	Label of additional variable set to TRUE if fader is finished (optional)
; \2 STRING:	"GLOBALVAR" if variables are pc relative (optional)
; Result
	CNOP 0,4
pt_music_fader
	IFC "GLOBALVAR","\2"
		move.w	pt_global_music_fader_active(pc),d0
	ELSE
		tst.w	pt_music_fader_active(a3)
	ENDC
	bne.s	pt_music_fader_quit
	IFD PROTRACKER_VERSION_2
		lea	pt_audchan1temp(pc),a0
		lea	AUD0VOL-DMACONR(a6),a1
		bsr.s	pt_decrease_channel_volume
		lea	pt_audchan2temp(pc),a0
		bsr.s	pt_decrease_channel_volume
		lea	pt_audchan3temp(pc),a0
		bsr.s	pt_decrease_channel_volume
		lea	pt_audchan4temp(pc),a0
		bsr.s	pt_decrease_channel_volume
	ENDC
	move.w	pt_fade_out_delay_counter(a3),d0
	subq.w	#1,d0
	bne.s	pt_music_fader_skip1
	move.w	pt_master_volume(a3),d1
	beq.s	pt_music_fader_skip2
	subq.w	#1,d1
	move.w	d1,pt_master_volume(a3)
	moveq	#pt_fade_out_delay,d0
pt_music_fader_skip1
	move.w	d0,pt_fade_out_delay_counter(a3)
pt_music_fader_quit
	rts
	CNOP 0,4
pt_music_fader_skip2
	IFC "GLOBALVAR","\2"
		lea	pt_global_music_fader_active(pc),a0
		move.w	#FALSE,(a0)
	ELSE
		move.w	#FALSE,pt_music_fader_active(a3)
	ENDC
	IFNC "","\1"
		IFC "GLOBALVAR","\2"
			lea	\1(pc),a0
			clr.w	(a0)	; set additional global variable
		ELSE
			clr.w	\1(a3)	; set additional variable
		ENDC
	ENDC
	bra.s	pt_music_fader_quit

	IFD PROTRACKER_VERSION_2
; Input
; a0.l	Pointer temporary audio data
; Result
		CNOP 0,4
pt_decrease_channel_volume
		moveq	#0,d0
		move.b	n_volume(a0),d0
		mulu.w	pt_master_volume(a3),d0
		lsr.w	#6,d0
		move.w	d0,(a1)		; AUDVOL
		ADDF.W	16,a1		; next audio channel
		rts
	ENDC
	ENDM


PT_DETECT_SYS_FREQUENCY		MACRO
; Input
; Result
	CNOP 0,4
pt_DetectSysFrequ
	move.l	_GfxBase(pc),a0
	move.w	gb_DisplayFlags(a0),d0
	move.l	#pt_pal125bpmrate,d1
	btst	#REALLY_PALn,d0		; crystal frequency = 50Hz ?
	bne.s	pt_DetectSysFrequSave
	move.l	#pt_ntsc125bpmrate,d1
pt_DetectSysFrequSave
	move.l	d1,pt_125BPMrate(a3)
	rts
	ENDM


PT_INIT_TIMERS			MACRO
; Input
; Result
	IFEQ pt_ciatiming_enabled
		move.l	pt_125bpmrate(a3),d0
		divu.w	#pt_defaultbpm,d0 ; ticks for replay routine execution
		move.b	d0,CIATALO(a5)
		lsr.w	#BYTE_SHIFT_BITS,d0
		move.b	d0,CIATAHI(a5)
		moveq	#ciab_cra_bits,d0
		move.b	d0,CIACRA(a5)
	ENDC
	moveq	#ciab_tb_time&BYTE_MASK,d0 ; DMA wait delay
	move.b	d0,CIATBLO(a5)
	moveq	#ciab_tb_time>>8,d0
	move.b	d0,CIATBHI(a5)
	moveq	#ciab_crb_bits,d0
	move.b	d0,CIACRB(a5)
	ENDM


PT_INIT_REGISTERS		MACRO
; Input
; Result
	CNOP 0,4
pt_InitRegisters
	moveq	#CIAF_LED,d0
	or.b	d0,CIAPRA(a4)		; turn sound filter off
	moveq	#0,d0
	move.w	d0,AUD0VOL-DMACONR(a6)	; clear volume for all channels
	move.w	d0,AUD1VOL-DMACONR(a6)
	move.w	d0,AUD2VOL-DMACONR(a6)
	move.w	d0,AUD3VOL-DMACONR(a6)
	IFD SYS_TAKEN_OVER
		move.w	#DMAF_AUD0+DMAF_AUD1+DMAF_AUD2+DMAF_AUD3,DMACON-DMACONR(a6) ; disable channels DMA
	ENDC
	rts
	ENDM


PT_INIT_AUDIO_TEMP_STRUCTURES	MACRO
; Input
; Result
	CNOP 0,4
pt_InitAudTempStrucs
	moveq	#FALSE,d1
	lea	pt_audchan1temp(pc),a0
	move.w	#DMAF_AUD0,n_dmabit(a0)
	IFEQ pt_track_notes_played_enabled
		move.b	d1,n_notetrigger(a0)
	ENDC
	move.b	d1,n_rtnsetchandma(a0)	; deactivate routines
	move.b	d1,n_rtninitchanloop(a0)

	lea	pt_audchan2temp(pc),a0
	move.w	#DMAF_AUD1,n_dmabit(a0)
	IFEQ pt_track_notes_played_enabled
		move.b	d1,n_notetrigger(a0)
	ENDC
	move.b	d1,n_rtnsetchandma(a0)
	move.b	d1,n_rtninitchanloop(a0)

	lea	pt_audchan3temp(pc),a0
	move.w	#DMAF_AUD2,n_dmabit(a0)
	IFEQ pt_track_notes_played_enabled
		move.b	d1,n_notetrigger(a0)
	ENDC
	move.b	d1,n_rtnsetchandma(a0)
	move.b	d1,n_rtninitchanloop(a0)

	lea	pt_audchan4temp(pc),a0
	move.w	#DMAF_AUD3,n_dmabit(a0)
	IFEQ pt_track_notes_played_enabled
		move.b	d1,n_notetrigger(a0)
	ENDC
	move.b	d1,n_rtnsetchandma(a0)
	move.b	d1,n_rtninitchanloop(a0)
	rts
	ENDM


PT_EXAMINE_SONG_STRUCTURE	MACRO
; Input
; Result
	CNOP 0,4
pt_ExamineSongStruc
	moveq	#0,d0		 	; first pattern number (count starts at 0)
	moveq	#0,d1			; counter highest pattern number
	move.l	pt_SongDataPointer(a3),a0
	move.b	pt_sd_numofpatt(a0),pt_SongLength(a3)
	lea	pt_sd_pattpos(a0),a1	; pointer table with pattern positions in song
	MOVEF.W pt_maxsongpos-1,d7
pt_InitLoop
	move.b	(a1)+,d0		; patterm number from song position table
	cmp.b	d1,d0
	ble.s	pt_InitSkip
	move.l	d0,d1		 	; save higher pattern number
pt_InitSkip
	dbf	d7,pt_InitLoop
	IFNE pt_split_module_enabled
		addq.w	#1,d1
	ENDC
	ADDF.W	pt_sd_sampleinfo,a0	; pointer 1st sample info structure
	IFNE pt_split_module_enabled
		MULUF.W	pt_pattsize/8,d1,d0 ; end of last pattern
	ENDC
	moveq	#0,d2
	moveq	#pt_oneshotlen,d3 	; length in words
	IFNE pt_split_module_enabled
		lea	pt_sd_patterndata-pt_sd_id(a1,d1.w*8),a2 ; pointer first sample data in module
	ELSE
		move.l	pt_SamplesDataPointer(a3),a2
	ENDC
	lea	pt_SampleStarts(pc),a1
	moveq	#pt_sampleinfo_size,d1
	moveq	#pt_samplesnum-1,d7
pt_InitLoop2
	move.l	a2,(a1)+		; pointer sample data
	move.w	pt_si_samplelength(a0),d0
	beq.s	pt_InitSkip2
	MULUF.W	WORD_SIZE,d0,d4		; sample length in bytes
	move.w	d2,(a2)		 	; clear first word in sample data
	add.l	d0,a2		 	; next sample data
	move.w	pt_si_repeatlength(a0),d0 ; Fasttracker module with repeat length 0 ?
	bne.s	pt_InitSkip2
	move.w	d3,pt_si_repeatlength(a0) ; repeat length 1 for Protracker compability
pt_InitSkip2
	add.l	d1,a0		 	; next sample info structure
	dbf	d7,pt_InitLoop2
	rts
	ENDM


PT_INIT_FINETUNE_TABLE_STARTS	MACRO
; Input
; Result
	CNOP 0,4
pt_InitFtuPeriodTableStarts
	moveq	#pt_PeriodTableEnd-pt_PeriodTable,d0 ; period table length in bytes
	lea	pt_PeriodTable(pc),a0
	lea	pt_FtuPeriodTableStarts(pc),a1
	moveq	#pt_finetunenum-1,d7
pt_InitFtuPeriodTableStartsLoop
	move.l	a0,(a1)+		; period table pointer
	add.l	d0,a0		 	; next period table pointer
	dbf	d7,pt_InitFtuPeriodTableStartsLoop
	rts
	ENDM


PT_TIMER_INTERRUPT_SERVER	MACRO
; Input
; Result

; E9 "Retrig Note" or ED "Note Delay"
	IFNE pt_usedefx&(pt_ecmdbitretrignote+pt_ecmdbitnotedelay)
		tst.w	pt_RtnDMACONtemp(a3) ; any retrig/delay fx for a channel ?
		beq.s	pt_RtnChannelsSkip
		move.b	pt_audchan1temp+n_rtnsetchandma(pc),d0
		beq	pt_RtnSetChan1DMA
		move.b	pt_audchan1temp+n_rtninitchanloop(pc),d0
		beq	pt_RtnInitChan1Loop
		move.b	pt_audchan2temp+n_rtnsetchandma(pc),d0
		beq	pt_RtnSetChan2DMA
		move.b	pt_audchan2temp+n_rtninitchanloop(pc),d0
		beq	pt_RtnInitChan2Loop
		move.b	pt_audchan3temp+n_rtnsetchandma(pc),d0
		beq	pt_RtnSetChan3DMA
		move.b	pt_audchan3temp+n_rtninitchanloop(pc),d0
		beq	pt_RtnInitChan3Loop
		move.b	pt_audchan4temp+n_rtnsetchandma(pc),d0
		beq	pt_RtnSetChan4DMA
		move.b	pt_audchan4temp+n_rtninitchanloop(pc),d0
		beq	pt_RtnInitChan4Loop
pt_RtnChannelsSkip
	ENDC
	tst.b	pt_SetAllChanDMAFlag(a3)
	beq	pt_SetAllChanDMA
	tst.b	pt_InitAllChanLoopFlag(a3)
	beq	pt_initAllChanLoop
	rts


; E9 "Retrig Note" or ED "Note Delay"
	IFNE pt_usedefx&(pt_ecmdbitretrignote+pt_ecmdbitnotedelay)
		CNOP 0,4
pt_RtnSetChan1DMA
		lea	pt_audchan1temp(pc),a0
		moveq   #DMAF_AUD0,d0
		bra	pt_RtnSetChanDMA

		CNOP 0,4
pt_RtnInitChan1Loop
		lea	pt_audchan1temp(pc),a0
		move.b	#FALSE,n_rtninitchanloop(a0) ; deactivate routine
		ADDF.W	n_period,a0
		move.w	(a0)+,AUD0PER-DMACONR(a6)
		move.l	(a0)+,AUD0LCH-DMACONR(a6)
		moveq	#~DMAF_AUD0,d0
		move.w	(a0),AUD0LEN-DMACONR(a6)
		bra	pt_RtnChkNextChan


		CNOP 0,4
pt_RtnSetChan2DMA
		lea	pt_audchan2temp(pc),a0
		moveq   #DMAF_AUD1,d0
		bra	pt_RtnSetChanDMA

		CNOP 0,4
pt_RtnInitChan2Loop
		lea	pt_audchan2temp(pc),a0
		move.b	#FALSE,n_rtninitchanloop(a0) ; deactivate routine
		ADDF.W	n_period,a0
		move.w	(a0)+,AUD1PER-DMACONR(a6)
		move.l	(a0)+,AUD1LCH-DMACONR(a6)
		moveq	#~DMAF_AUD1,d0
		move.w	(a0),AUD1LEN-DMACONR(a6)
		bra	pt_RtnChkNextChan


		CNOP 0,4
pt_RtnSetChan3DMA
		lea	pt_audchan3temp(pc),a0
		moveq   #DMAF_AUD2,d0
		bra.s	pt_RtnSetChanDMA

		CNOP 0,4
pt_RtnInitChan3Loop
		lea	pt_audchan3temp(pc),a0
		move.b	#FALSE,n_rtninitchanloop(a0) ; deactivate routine
		ADDF.W	n_period,a0
		move.w	(a0)+,AUD2PER-DMACONR(a6)
		move.l	(a0)+,AUD2LCH-DMACONR(a6)
		moveq	#~DMAF_AUD2,d0
		move.w	(a0),AUD2LEN-DMACONR(a6)
		bra.s	pt_RtnChkNextChan


		CNOP 0,4
pt_RtnSetChan4DMA
		lea	pt_audchan4temp(pc),a0
		moveq   #DMAF_AUD3,d0
		bra.s	pt_RtnSetChanDMA

		CNOP 0,4
pt_RtnInitChan4Loop
		lea	pt_audchan4temp(pc),a0
		move.b	#FALSE,n_rtninitchanloop(a0) ; deactivate routine
		ADDF.W	n_period,a0
		move.w	(a0)+,AUD3PER-DMACONR(a6)
		move.l	(a0)+,AUD3LCH-DMACONR(a6)
		moveq	#~DMAF_AUD3,d0
		move.w	(a0),AUD3LEN-DMACONR(a6)
		bra.s	pt_RtnChkNextChan


; Input
; a0.l	Pointer temporary audio data
; d0.w	DMACON bit audio channel [0,2,4,8]
; Result
		CNOP 0,4
pt_RtnSetChanDMA
		move.b	#FALSE,n_rtnsetchandma(a0) ; deactivate routine
		or.w	#DMAF_SETCLR,d0
		move.w	d0,DMACON-DMACONR(a6)
		clr.b	n_rtninitchanloop(a0) ; activate follow up routine
		addq.b	#CIACRBF_START,CIACRB(a5) ; start DMA delay counter
		rts


; Input
; d0.w	Mask for Retrig DMACONtemp
; Result
		CNOP 0,4
pt_RtnChkNextChan
		and.w	d0,pt_RtnDMACONtemp(a3) ; other channel DMA bits set ("Retrig Note" or "Note Delay") ?
		bne.s	pt_RtnChkNextChanSkip
		tst.b	pt_SetAllChanDMAFlag(a3)
		bne.s	pt_RtnChkNextChanQuit
pt_RtnChkNextChanSkip
		addq.b	#CIACRBF_START,CIACRB(a5) ; start DMA delay counter
pt_RtnChkNextChanQuit
		rts
	ENDC

	CNOP 0,4
pt_InitAllChanLoop
	move.l	pt_audchan1temp+n_loopstart(pc),AUD0LCH-DMACONR(a6)
	move.w	pt_audchan1temp+n_replen(pc),AUD0LEN-DMACONR(a6)
	move.l	pt_audchan2temp+n_loopstart(pc),AUD1LCH-DMACONR(a6)
	move.w	pt_audchan2temp+n_replen(pc),AUD1LEN-DMACONR(a6)
	move.l	pt_audchan3temp+n_loopstart(pc),AUD2LCH-DMACONR(a6)
	move.w	pt_audchan3temp+n_replen(pc),AUD2LEN-DMACONR(a6)
	move.l	pt_audchan4temp+n_loopstart(pc),AUD3LCH-DMACONR(a6)
	move.w	pt_audchan4temp+n_replen(pc),AUD3LEN-DMACONR(a6)
	move.b	#FALSE,pt_InitAllChanLoopFlag(a3) ; deactivate routine
	rts

	CNOP 0,4
pt_SetAllChanDMA
	move.w	pt_DMACONtemp(a3),d0
	move.b	#FALSE,pt_SetAllChanDMAFlag(a3) ; deactivate routine
	or.w	#DMAF_SETCLR,d0
	move.w	d0,DMACON-DMACONR(a6)
	clr.b	pt_InitAllChanLoopFlag(a3) ; activate follow up routine
	addq.b	#CIACRBF_START,CIACRB(a5) ; start DMA delay counter
	rts
	ENDM

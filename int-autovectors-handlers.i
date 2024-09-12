; Datum:        06.09.2024
; Version:      2.1

; ** Level-1-Interrupt-Handler **
	IFNE intena_bits&(INTF_TBE|INTF_DSKBLK|INTF_SOFTINT)
		CNOP 0,4
level_1_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A-Base
		move.l	#_CUSTOM+DMACONR,a6
		moveq	#intena_bits&(INTF_TBE|INTF_DSKBLK|INTF_SOFTINT),d0
		and.w	INTREQR-DMACONR(a6),d0

		IFNE intena_bits&INTF_TBE
			btst	#INTB_TBE,d0 ; TBE-Interrupt ?
			bne.s	TBE_int_handler
		ENDC
rt_level_1_int1
		IFNE intena_bits&INTF_DSKBLK
			btst	#INTB_DSKBLK,d0	; DSKBLK-Interrupt ?
			bne.s	DSKBLK_int_handler
		ENDC
rt_level_1_int2
		IFNE intena_bits&INTF_SOFTINT
			btst	#INTB_SOFTINT,d0 ; SOFTINT-Interrupt ?
			bne.s	SOFTINT_int_handler
		ENDC
rt_level_1_int3
		move.w	d0,INTREQ-DMACONR(a6) ; Alle Level-1-Interrupts löschen
		movem.l	(a7)+,d0-d7/a0-a6
		nop
		rte

; * Ausgabepuffer des seriellen Ports leer *
		IFNE intena_bits&INTF_TBE
			CNOP 0,4
TBE_int_handler
			move.l	d0,-(a7)
			bsr	TBE_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_1_int1
		ENDC

; * Disk-DMA beendet *
		IFNE intena_bits&INTF_DSKBLK
			CNOP 0,4
DSKBLK_int_handler
			move.l	d0,-(a7)
			bsr	DSKBLK_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_1_int2
		ENDC

; * Software-Interrupt *
		IFNE intena_bits&INTF_SOFTINT
			CNOP 0,4
SOFTINT_int_handler
			move.l	d0,-(a7)
			bsr	SOFTINT_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_1_int3
		ENDC

	ENDC


; ** Level-2-Interrupt-Handler **
	IFNE intena_bits&INTF_PORTS
		CNOP 0,4
level_2_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A-Base
		move.l	#_CUSTOM+DMACONR,a6
		moveq	#INTF_PORTS,d0
		and.w	INTREQR-DMACONR(a6),d0 ; Interrupts ausmaskieren
		moveq	#ciaa_icr_bits&(~CIAICRF_SETCLR),d1
		and.b	CIAICR(a4),d1	; CIA-A-Interrupts ?
		beq.s	PORTS_int_handler
		IFNE ciaa_icr_bits&CIAICRF_TA
			btst	#CIAICRB_TA,d1 ; CIA-A-TA-Interrupt ?
			bne.s	ciaa_ta_int_handler
		ENDC
rt_level_2_int1
		IFNE ciaa_icr_bits&CIAICRF_TB
			btst	#CIAICRB_TB,d1 ; CIA-A-TB-Interrupt ?
			bne.s	ciaa_tb_int_handler
		ENDC
rt_level_2_int2
		IFNE ciaa_icr_bits&CIAICRF_ALRM
			btst	#CIAICRB_ALRM,d1 ; CIA-A-ALRM-Interrupt ?
			bne.s	CIAA_ALRM_int_handler
		ENDC
rt_level_2_int3
		IFNE ciaa_icr_bits&CIAICRF_SP
			btst	#CIAICRB_SP,d1 ; CIA-A-SP-Interrupt ?
			bne.s	CIAA_SP_int_handler
		ENDC
rt_level_2_int4
		IFNE ciaa_icr_bits&CIAICRF_FLG
			btst	#CIAICRB_FLG,d1 ; CIA-A-FLG-Interrupt ?
			bne.s	CIAA_FLG_int_handler
		ENDC
rt_level_2_int5
		move.w	d0,INTREQ-DMACONR(a6) ; Level-2-Interrupt löschen
		movem.l	(a7)+,d0-d7/a0-a6
		nop
		rte

; * Externer Level-2-Interrupt *
		IFNE intena_bits&INTF_PORTS
			CNOP 0,4
PORTS_int_handler
			movem.l	d0-d1,-(a7)
			bsr	PORTS_int_server
			movem.l (a7)+,d0-d1
			bra.s	rt_level_2_int5
		ENDC

; * Unterlauf Timer A *
		IFNE ciaa_icr_bits&CIAICRF_TA
			CNOP 0,4
ciaa_ta_int_handler
			movem.l	d0-d1,-(a7)
			bsr	ciaa_ta_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_2_int1
		ENDC

; * Unterlauf Timer B *
		IFNE ciaa_icr_bits&CIAICRF_TB
			CNOP 0,4
ciaa_tb_int_handler
			movem.l	d0-d1,-(a7)
			bsr	ciaa_tb_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_2_int2
		ENDC

; * Alarm-Interrupt *
		IFNE ciaa_icr_bits&CIAICRF_ALRM
			CNOP 0,4
CIAA_ALRM_int_handler
			movem.l	d0-d1,-(a7)
			bsr	CIAA_ALRM_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_2_int3
		ENDC

; * Serieller-Port-Interrupt *
		IFNE ciaa_icr_bits&CIAICRF_SP
			CNOP 0,4
CIAA_SP_int_handler
			movem.l	d0-d1,-(a7)
			bsr	CIAA_SP_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_2_int4
		ENDC

; * Flag-Interrupt *
		IFNE ciaa_icr_bits&CIAICRF_FLG
			CNOP 0,4
CIAA_FLG_int_handler
			movem.l	d0-d1,-(a7)
			bsr	CIAA_FLG_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_2_int5
		ENDC

	ENDC


; ** Level-3-Interrupt-Handler **
	IFNE intena_bits&(INTF_COPER|INTF_VERTB|INTF_BLIT)
		CNOP 0,4
level_3_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A-Base
		move.l	#_CUSTOM+DMACONR,a6
		moveq	#intena_bits&(INTF_COPER|INTF_VERTB|INTF_BLIT),d0
		and.w	INTREQR-DMACONR(a6),d0 ;Interrupts holen
		IFNE intena_bits&INTF_COPER
			btst	#INTB_COPER,d0 ; COPER-Interrupt ?
			bne.s	COPPER_int_handler
		ENDC
rt_level_3_int1
		IFNE intena_bits&INTF_VERTB
			btst	#INTB_VERTB,d0 ; VERTB-Interrupt ?
			bne.s	VERTB_int_handler
		ENDC
rt_level_3_int2
		IFNE intena_bits&INTF_BLIT
			btst	#INTB_BLIT,d0 ; BLIT-Interrupt ?
			bne.s	BLIT_int_handler
		ENDC
rt_level_3_int3
		move.w	d0,INTREQ-DMACONR(a6) ; Alle Level-3-Interrupts löschen
		movem.l (a7)+,d0-d7/a0-a6
		nop
		rte

; * Copper hat Interrupt erzeugt *
		IFNE intena_bits&INTF_COPER
			CNOP 0,4
COPPER_int_handler
			move.l	d0,-(a7)
			bsr	COPER_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_3_int1
		ENDC

; * Beginn der vertikalen Austastlücke *
		IFNE intena_bits&INTF_VERTB
			CNOP 0,4
VERTB_int_handler
			move.l	d0,-(a7)
			bsr	VERTB_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_3_int2
		ENDC

; * Blitteroperation beendet *
		IFNE intena_bits&INTF_BLIT
			CNOP 0,4
BLIT_int_handler
			move.l	d0,-(a7)
			bsr	BLIT_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_3_int3
		ENDC

	ENDC


; ** Level-4-Interrupt-Handler **
	IFNE intena_bits&(INTF_AUD0|INTF_AUD1|INTF_AUD2|INTF_AUD3)
		CNOP 0,4
level_4_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A-Base
		move.l	#_CUSTOM+DMACONR,a6
		move.w	INTREQR-DMACONR(a6),d0 ;Interrupts holen
		and.w	 #intena_bits&(INTF_AUD0|INTF_AUD1|INTF_AUD2|INTF_AUD3),d0
		IFNE intena_bits&INTF_AUD0
			btst	#INTB_AUD0,d0 ; AUD0-Interrupt ?
			bne.s	AUD0_int_handler
		ENDC
rt_level_4_int1
		IFNE intena_bits&INTF_AUD1
			btst	#INTB_AUD1,d0 ; AUD1-Interrupt ?
			bne.s	AUD1_int_handler
		ENDC
rt_level_4_int2
		IFNE intena_bits&INTF_AUD2
			btst	#INTB_AUD2,d0 ; AUD2-Interrupt ?
			bne.s	AUD2_int_handler
		ENDC
rt_level_4_int3
		IFNE intena_bits&INTF_AUD3
			btst	#INTB_AUD3,d0 ; AUD3-Interrupt ?
			bne.s	AUD3_int_handler
		ENDC
rt_level_4_int4
		move.w	d0,INTREQ-DMACONR(a6) ; Alle Level-4-Interrupts löschen
		movem.l	(a7)+,d0-d7/a0-a6
		nop
		rte

; * Audiokanal 0 ist fertig mit Datenausgabe *
		IFNE intena_bits&INTF_AUD0
			CNOP 0,4
AUD0_int_handler
			move.l	d0,-(a7)
			bsr	AUD0_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_4_int1
		ENDC

; * Audiokanal 1 ist fertig mit Datenausgabe *
		IFNE intena_bits&INTF_AUD1
			CNOP 0,4
AUD1_int_handler
			move.l	d0,-(a7)
			bsr	AUD1_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_4_int2
		ENDC

; * Audiokanal 2 ist fertig mit Datenausgabe *
		IFNE intena_bits&INTF_AUD2
			CNOP 0,4
AUD2_int_handler
			move.l	d0,-(a7)
			bsr	AUD2_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_4_int3
		ENDC

; * Audiokanal 3 ist fertig mit Datenausgabe *
		IFNE intena_bits&INTF_AUD3
			CNOP 0,4
AUD3_int_handler
			move.l	d0,-(a7)
			bsr	AUD3_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_4_int4
		ENDC

	ENDC


; ** Level-5-Interrupt-Handler **
	IFNE intena_bits&(INTF_RBF|INTF_DSKSYNC)
		CNOP 0,4
level_5_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A-Base
		move.l	#_CUSTOM+DMACONR,a6
		move.w	INTREQR-DMACONR(a6),d0 ; Interrupts holen
		and.w	#intena_bits&(INTF_RBF|INTF_DSKSYNC),d0
		IFNE intena_bits&INTF_RBF
			btst	#INTB_RBF,d0 ; RBF-Interrupt ?
			bne.s	RBF_int_handler
		ENDC
rt_level_5_int1
		IFNE intena_bits&INTF_DSKSYNC
			btst	#INTB_DSKSYNC,d0 ; DSKSYN-Interrupt ?
			bne.s	DSKSYNC_int_handler
		ENDC
rt_level_5_int2
		move.w	d0,INTREQ-DMACONR(a6) ; Alle Level-5-Interrupts löschen
		movem.l	(a7)+,d0-d7/a0-a6
		nop
		rte

; * Serieller Port ist voll *
		IFNE intena_bits&INTF_RBF
			CNOP 0,4
RBF_int_handler
			move.l	d0,-(a7)
			bsr	RBF_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_5_int1
		ENDC

; * Disk-Synchronisationswert erkannt *
		IFNE intena_bits&INTF_DSKSYNC
			CNOP 0,4
DSKSYNC_int_handler
			move.l	d0,-(a7)
			bsr	DSKSYNC_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_5_int2
		ENDC

	ENDC


; ** Level-6-Interrupt-Handler **
	IFNE intena_bits&INTF_EXTER
		CNOP 0,4
level_6_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A-Base
		move.l	#_CUSTOM+DMACONR,a6
		move.w	INTREQR-DMACONR(a6),d0 ; Interrupts holen
		and.w	#INTF_EXTER,d0
		moveq	#ciab_icr_bits&(~CIAICRF_SETCLR),d1
		and.b	CIAICR(a5),d1	; CIA-B-Interrupts ?
		beq.s	EXTER_int_handler
		IFNE ciab_icr_bits&CIAICRF_TA
			btst	#CIAICRB_TA,d1 ; CIA-B-TA-Interrupt ?
			bne.s	ciab_ta_int_handler
		ENDC
rt_level_6_int1
		IFNE ciab_icr_bits&CIAICRF_TB
			btst	#CIAICRB_TB,d1 ; CIA-B-TB-Interrupt ?
			bne.s	ciab_tb_int_handler
		ENDC
rt_level_6_int2
		IFNE ciab_icr_bits&CIAICRF_ALRM
			btst	#CIAICRB_ALRM,d1 ; CIA-B-ALRM-Interrupt ?
			bne.s	CIAB_ALRM_int_handler
		ENDC
rt_level_6_int3
		IFNE ciab_icr_bits&CIAICRF_SP
			btst	#CIAICRB_SP,d1 ; CIA-B-SP-Interrupt ?
			bne.s	CIAB_SP_int_handler
		ENDC
rt_level_6_int4
		IFNE ciab_icr_bits&CIAICRF_FLG
			btst	#CIAICRB_FLG,d1 ; CIA-B-FLG-Interrupt ?
			bne.s	CIAB_FLG_int_handler
		ENDC
rt_level_6_int5
		move.w	d0,INTREQ-DMACONR(a6) ; Level-6-Interrupt löschen
		movem.l (a7)+,d0-d7/a0-a6
		nop
		rte

; * Externer Level-6-Interrupt *
		IFNE intena_bits&INTF_EXTER
			CNOP 0,4
EXTER_int_handler
			movem.l	d0-d1,-(a7)
			bsr	EXTER_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_6_int5
		ENDC

; * Unterlauf Timer A *
		IFNE ciab_icr_bits&CIAICRF_TA
			CNOP 0,4
ciab_ta_int_handler
			movem.l	d0-d1,-(a7)
			bsr	ciab_ta_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_6_int1
		ENDC

; * Unterlauf Timer B *
		IFNE ciab_icr_bits&CIAICRF_TB
			CNOP 0,4
ciab_tb_int_handler
			movem.l	d0-d1,-(a7)
			bsr	ciab_tb_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_6_int2
		ENDC

; * Alarm-Interrupt *
		IFNE ciab_icr_bits&CIAICRF_ALRM
			CNOP 0,4
CIAB_ALRM_int_handler
			movem.l	d0-d1,-(a7)
			bsr	CIAB_ALRM_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_6_int3
		ENDC

; * Serieller-Port-Interrupt *
		IFNE ciab_icr_bits&CIAICRF_SP
			CNOP 0,4
CIAB_SP_int_handler
			movem.l	d0-d1,-(a7)
			bsr	CIAB_SP_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_6_int4
		ENDC

; * Flag-Interrupt *
		IFNE ciab_icr_bits&CIAICRF_FLG
			CNOP 0,4
CIAB_FLG_int_handler
			movem.l	d0-d1,-(a7)
			bsr	CIAB_FLG_int_server
			movem.l	(a7)+,d0-d1
			bra.s	rt_level_6_int5
		ENDC

	ENDC


; ** Level-7-Interrupt-Handler **
	CNOP 0,4
level_7_int_handler
	movem.l	d0-d7/a0-a6,-(a7)
	lea	variables(pc),a3
	move.l	#_CIAB,a5
	lea	_CIAA-_CIAB(a5),a4 ; CIA-A-Base
	move.l	#_CUSTOM+DMACONR,a6
	bsr	NMI_int_server
	movem.l	(a7)+,d0-d7/a0-a6
	nop
	rte

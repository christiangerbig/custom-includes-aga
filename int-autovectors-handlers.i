	IFNE intena_bits&(INTF_TBE|INTF_DSKBLK|INTF_SOFTINT)
		CNOP 0,4
level_1_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A base
		move.l	#_CUSTOM+DMACONR,a6
		moveq	#intena_bits&(INTF_TBE|INTF_DSKBLK|INTF_SOFTINT),d0
		and.w	INTREQR-DMACONR(a6),d0
		IFNE intena_bits&INTF_TBE
			btst	#INTB_TBE,d0
			beq.s	level_1_int_handler_skip1
			move.l	d0,-(a7)
			bsr	tbe_int_server
			move.l	(a7)+,d0
level_1_int_handler_skip1
		ENDC
		IFNE intena_bits&INTF_DSKBLK
			btst	#INTB_DSKBLK,d0
			beq.s	level_1_int_handler_skip2
			move.l	d0,-(a7)
			bsr	dskblk_int_server
			move.l	(a7)+,d0
level_1_int_handler_skip2
		ENDC
		IFNE intena_bits&INTF_SOFTINT
			btst	#INTB_SOFTINT,d0
			beq.s	level_1_int_handler_skip3
			move.l	d0,-(a7)
			bsr	softint_int_server
			move.l	(a7)+,d0
level_1_int_handler_skip3
		ENDC
		move.w	d0,INTREQ-DMACONR(a6) ; clear level1 interrupts
		movem.l	(a7)+,d0-d7/a0-a6
		nop
		rte
	ENDC


	IFNE intena_bits&INTF_PORTS
		CNOP 0,4
level_2_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A base
		move.l	#_CUSTOM+DMACONR,a6
		moveq	#INTF_PORTS,d0
		and.w	INTREQR-DMACONR(a6),d0
		IFNE ciaa_icr_bits&(CIAICRF_TA|CIAICRF_TB|CIAICRB_ALRM|CIAICRB_SP|CIAICRB_FLG)
			moveq	#ciaa_icr_bits&(~CIAICRF_SETCLR),d1
			and.b	CIAICR(a4),d1	; any CIA-A interrupts ?
			bne.s	level_2_int_handler_skip1
                ENDC
		movem.l	d0-d1,-(a7)
		bsr	ports_int_server
		movem.l (a7)+,d0-d1
level_2_int_handler_quit
		move.w	d0,INTREQ-DMACONR(a6) ; clear level2 interrupts
		movem.l	(a7)+,d0-d7/a0-a6
		nop
		rte
		IFNE ciaa_icr_bits&(CIAICRF_TA|CIAICRF_TB|CIAICRB_ALRM|CIAICRB_SP|CIAICRB_FLG)
			CNOP 0,4
level_2_int_handler_skip1
			IFNE ciaa_icr_bits&CIAICRF_TA
				btst	#CIAICRB_TA,d1
				beq.s	level_2_int_handler_skip2
				movem.l	d0-d1,-(a7)
				bsr	ciaa_ta_int_server
				movem.l	(a7)+,d0-d1
level_2_int_handler_skip2
			ENDC
			IFNE ciaa_icr_bits&CIAICRF_TB
				btst	#CIAICRB_TB,d1
				beq.s	level_2_int_handler_skip3
				movem.l	d0-d1,-(a7)
				bsr	ciaa_tb_int_server
				movem.l	(a7)+,d0-d1
level_2_int_handler_skip3
			ENDC
			IFNE ciaa_icr_bits&CIAICRF_ALRM
				btst	#CIAICRB_ALRM,d1
				beq.s	level_2_int_handler_skip4
				movem.l	d0-d1,-(a7)
				bsr	ciaa_alrm_int_server
				movem.l	(a7)+,d0-d1
level_2_int_handler_skip4
			ENDC
			IFNE ciaa_icr_bits&CIAICRF_SP
				btst	#CIAICRB_SP,d1
				beq.s	level_2_int_handler_skip5
				movem.l	d0-d1,-(a7)
				bsr	ciaa_sp_int_server
				movem.l	(a7)+,d0-d1
level_2_int_handler_skip5
			ENDC
			IFNE ciaa_icr_bits&CIAICRF_FLG
				btst	#CIAICRB_FLG,d1
				beq.s	level_2_int_handler_skip6
				movem.l	d0-d1,-(a7)
				bsr	ciaa_flg_int_server
				movem.l	(a7)+,d0-d1
level_2_int_handler_skip6
			ENDC
			bra.s	level_2_int_handler_quit
		ENDC
	ENDC


	IFNE intena_bits&(INTF_COPER|INTF_VERTB|INTF_BLIT)
		CNOP 0,4
level_3_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A base
		move.l	#_CUSTOM+DMACONR,a6
		moveq	#intena_bits&(INTF_COPER|INTF_VERTB|INTF_BLIT),d0
		and.w	INTREQR-DMACONR(a6),d0
		IFNE intena_bits&INTF_COPER
			btst	#INTB_COPER,d0
			beq.s	level_3_int_handler_skip1
			move.l	d0,-(a7)
			bsr	coper_int_server
			move.l	(a7)+,d0
level_3_int_handler_skip1
		ENDC
		IFNE intena_bits&INTF_VERTB
			btst	#INTB_VERTB,d0
			beq.s	level_3_int_handler_skip2
			move.l	d0,-(a7)
			bsr	vertb_int_server
			move.l	(a7)+,d0
level_3_int_handler_skip2
		ENDC
		IFNE intena_bits&INTF_BLIT
			btst	#INTB_BLIT,d0
			beq.s	level_3_int_handler_skip3
			move.l	d0,-(a7)
			bsr	blit_int_server
			move.l	(a7)+,d0
level_3_int_handler_skip3
		ENDC
		move.w	d0,INTREQ-DMACONR(a6) ; clear level3 interrupts
		movem.l (a7)+,d0-d7/a0-a6
		nop
		rte
	ENDC


	IFNE intena_bits&(INTF_AUD0|INTF_AUD1|INTF_AUD2|INTF_AUD3)
		CNOP 0,4
level_4_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A base
		move.l	#_CUSTOM+DMACONR,a6
		move.w	INTREQR-DMACONR(a6),d0
		and.w	#intena_bits&(INTF_AUD0|INTF_AUD1|INTF_AUD2|INTF_AUD3),d0
		IFNE intena_bits&INTF_AUD0
			btst	#INTB_AUD0,d0
			beq.s	level_4_int_handler_skip1
			move.l	d0,-(a7)
			bsr	aud0_int_server
			move.l	(a7)+,d0
level_4_int_handler_skip1
		ENDC
		IFNE intena_bits&INTF_AUD1
			btst	#INTB_AUD1,d0
			beq.s	level_4_int_handler_skip2
			move.l	d0,-(a7)
			bsr	aud1_int_server
			move.l	(a7)+,d0
level_4_int_handler_skip2
		ENDC
		IFNE intena_bits&INTF_AUD2
			btst	#INTB_AUD2,d0
			beq.s	level_4_int_handler_skip3
			move.l	d0,-(a7)
			bsr	aud2_int_server
			move.l	(a7)+,d0
level_4_int_handler_skip3
		ENDC
		IFNE intena_bits&INTF_AUD3
			btst	#INTB_AUD3,d0
			beq.s	level_4_int_handler_skip4
			move.l	d0,-(a7)
			bsr	aud3_int_server
			move.l	(a7)+,d0
			bra.s	rt_level_4_int4
level_4_int_handler_skip4
		ENDC
		move.w	d0,INTREQ-DMACONR(a6) ; clear level4 interrupts
		movem.l	(a7)+,d0-d7/a0-a6
		nop
		rte
	ENDC


	IFNE intena_bits&(INTF_RBF|INTF_DSKSYNC)
		CNOP 0,4
level_5_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A base
		move.l	#_CUSTOM+DMACONR,a6
		move.w	INTREQR-DMACONR(a6),d0
		and.w	#intena_bits&(INTF_RBF|INTF_DSKSYNC),d0
		IFNE intena_bits&INTF_RBF
			btst	#INTB_RBF,d0
			beq.s	level_5_int_handler_skip1
			move.l	d0,-(a7)
			bsr	rbf_int_server
			move.l	(a7)+,d0
level_5_int_handler_skip1
		ENDC
		IFNE intena_bits&INTF_DSKSYNC
			btst	#INTB_DSKSYNC,d0
			beq.s	level_5_int_handler_skip2
			move.l	d0,-(a7)
			bsr	dsksync_int_server
			move.l	(a7)+,d0
level_5_int_handler_skip2
		ENDC
		move.w	d0,INTREQ-DMACONR(a6) ; clear level5 interrupts
		movem.l	(a7)+,d0-d7/a0-a6
		nop
		rte
	ENDC


	IFNE intena_bits&INTF_EXTER
		CNOP 0,4
level_6_int_handler
		movem.l	d0-d7/a0-a6,-(a7)
		lea	variables(pc),a3
		move.l	#_CIAB,a5
		lea	_CIAA-_CIAB(a5),a4 ; CIA-A base
		move.l	#_CUSTOM+DMACONR,a6
		move.w	INTREQR-DMACONR(a6),d0
		and.w	#INTF_EXTER,d0
		IFNE ciab_icr_bits&(CIAICRF_TA|CIAICRF_TB|CIAICRF_ALRM|CIAICRF_SP|CIAICRF_FLG)
			moveq	#ciab_icr_bits&(~CIAICRF_SETCLR),d1
			and.b	CIAICR(a5),d1 ; any CIA-B interrupts ?
			bne.s	level_6_int_handler_skip1
		ENDC
		movem.l	d0-d1,-(a7)
		bsr	exter_int_server
		movem.l	(a7)+,d0-d1
level_6_int_handler_quit
		move.w	d0,INTREQ-DMACONR(a6) ; clear level6 interrupts
		movem.l (a7)+,d0-d7/a0-a6
		nop
		rte
		IFNE ciab_icr_bits&(CIAICRF_TA|CIAICRF_TB|CIAICRF_ALRM|CIAICRF_SP|CIAICRF_FLG)
			CNOP 0,4
level_6_int_handler_skip1
			IFNE ciab_icr_bits&CIAICRF_TA
				btst	#CIAICRB_TA,d1
				beq.s	level_6_int_handler_skip2
				movem.l	d0-d1,-(a7)
				bsr	ciab_ta_int_server
				movem.l	(a7)+,d0-d1
level_6_int_handler_skip2
			ENDC
			IFNE ciab_icr_bits&CIAICRF_TB
				btst	#CIAICRB_TB,d1
				beq.s	level_6_int_handler_skip3
				movem.l	d0-d1,-(a7)
				bsr	ciab_tb_int_server
				movem.l	(a7)+,d0-d1
level_6_int_handler_skip3
			ENDC
			IFNE ciab_icr_bits&CIAICRF_ALRM
				btst	#CIAICRB_ALRM,d1
				beq.s	level_6_int_handler_skip4
				movem.l	d0-d1,-(a7)
				bsr	ciab_alrm_int_server
				movem.l	(a7)+,d0-d1
level_6_int_handler_skip4
			ENDC
			IFNE ciab_icr_bits&CIAICRF_SP
				btst	#CIAICRB_SP,d1
				beq.s	level_6_int_handler_skip5
				movem.l	d0-d1,-(a7)
				bsr	ciab_sp_int_server
				movem.l	(a7)+,d0-d1
level_6_int_handler_skip5
			ENDC
			IFNE ciab_icr_bits&CIAICRF_FLG
				btst	#CIAICRB_FLG,d1
				beq.s	level_6_int_handler_skip6
				movem.l	d0-d1,-(a7)
				bsr	ciab_flg_int_server
				movem.l	(a7)+,d0-d1
level_6_int_handler_skip6
			ENDC
              	bra.s	level_6_int_handler_quit
		ENDC
	ENDC


	CNOP 0,4
level_7_int_handler
	movem.l	d0-d7/a0-a6,-(a7)
	lea	variables(pc),a3
	move.l	#_CIAB,a5
	lea	_CIAA-_CIAB(a5),a4	; CIA-A base
	move.l	#_CUSTOM+DMACONR,a6
	bsr	nmi_int_server
	movem.l	(a7)+,d0-d7/a0-a6
	nop
	rte

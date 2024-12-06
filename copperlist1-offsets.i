	IFD diwstrt_bits
cl1_DIWSTRT			RS.L 1
	ENDC
	IFD diwstop_bits
cl1_DIWSTOP			RS.L 1
	ENDC
	IFD ddfstrt_bits
cl1_DDFSTRT			RS.L 1
	ENDC
	IFD ddfstop_bits
cl1_DDFSTOP			RS.L 1
	ENDC
cl1_BPLCON0			RS.L 1
	IFD bplcon1_bits
cl1_BPLCON1			RS.L 1
	ENDC
	IFD bplcon2_bits
cl1_BPLCON2			RS.L 1
	ENDC
cl1_BPLCON3_1			RS.L 1
	IFNE pf_depth
cl1_BPL1MOD			RS.L 1
	ENDC
	IFGT pf_depth-1
cl1_BPL2MOD			RS.L 1
	ENDC
	IFEQ (pf_depth+spr_depth)
		IFD diwstrt_bits
cl1_BPLCON4			RS.L 1
		ENDC
	ELSE
cl1_BPLCON4			RS.L 1
	ENDC
	IFD diwhigh_bits
cl1_DIWHIGH			RS.L 1
	ENDC
	IFD fmode_bits
cl1_FMODE			RS.L 1
	ENDC

	IFNE dma_bits&DMAF_SPRITE
cl1_SPR0PTH			RS.L 1
cl1_SPR0PTL			RS.L 1
cl1_SPR1PTH			RS.L 1
cl1_SPR1PTL			RS.L 1
cl1_SPR2PTH			RS.L 1
cl1_SPR2PTL			RS.L 1
cl1_SPR3PTH			RS.L 1
cl1_SPR3PTL			RS.L 1
cl1_SPR4PTH			RS.L 1
cl1_SPR4PTL			RS.L 1
cl1_SPR5PTH			RS.L 1
cl1_SPR5PTL			RS.L 1
cl1_SPR6PTH			RS.L 1
cl1_SPR6PTL			RS.L 1
cl1_SPR7PTH			RS.L 1
cl1_SPR7PTL			RS.L 1
	ENDC

COLOR_PALETTE_HIGH		MACRO
; \1:	color number base in 32 steps 0/32/../224
; \2: 	playfield palette number 1..8
; \3:	sprite palette number $00/$22/$44,$66,$88,$aa,$cc,$ee
; \4: 	sprite palette number $11/$33/$55,$77,$99,$bb,$dd,$ff
	IFGE pf_colors_number-(1+\1)	; number of playfield colors >= 1
		IFGT \2-1	 	; playfield palette number > 1
cl1_BPLCON3_high\2		RS.L 1
		ENDC
cl1_COLOR00_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(2+\1)	; number of playfield colors >= 2
cl1_COLOR01_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(3+\1)	; number of playfield colors >= 3
cl1_COLOR02_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(4+\1)	; number of playfield colors >= 4
cl1_COLOR03_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(5+\1)	; number of playfield colors >= 5
cl1_COLOR04_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(6+\1)	; number of playfield colors >= 6
cl1_COLOR05_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(7+\1)	; number of playfield colors >= 7
cl1_COLOR06_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(8+\1)	; number of playfield colors >= 8
cl1_COLOR07_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(9+\1)	; number of playfield colors >= 9
cl1_COLOR08_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(10+\1)	; number of playfield colors >= 10
cl1_COLOR09_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(11+\1)	; number of playfield colors >= 11
cl1_COLOR10_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(12+\1)	; number of playfield colors >= 12
cl1_COLOR11_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(13+\1)	; number of playfield colors >= 13
cl1_COLOR12_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(14+\1)	; number of playfield colors >= 14
cl1_COLOR13_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(15+\1)	; number of playfield colors >= 15
cl1_COLOR14_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(16+\1)	; number of playfield colors >= 16
cl1_COLOR15_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(17+\1)	; number of playfield colors >= 17
cl1_COLOR16_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(18+\1)	; number of playfield colors >= 18
cl1_COLOR17_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(19+\1)	; number of playfield colors >= 19
cl1_COLOR18_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(20+\1)	; number of playfield colors >= 20
cl1_COLOR19_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(21+\1)	; number of playfield colors >= 21
cl1_COLOR20_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(22+\1)	; number of playfield colors >= 22
cl1_COLOR21_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(23+\1)	; number of playfield colors >= 23
cl1_COLOR22_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(24+\1)	; number of playfield colors >= 24
cl1_COLOR23_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(25+\1)	; number of playfield colors >= 25
cl1_COLOR24_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(26+\1)	; number of playfield colors >= 26
cl1_COLOR25_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(27+\1)	; number of playfield colors >= 27
cl1_COLOR26_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(28+\1)	; number of playfield colors >= 28
cl1_COLOR27_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(29+\1)	; number of playfield colors >= 29
cl1_COLOR28_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(30+\1)	; number of playfield colors >= 30
cl1_COLOR29_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(31+\1)	; number of playfield colors >= 31
cl1_COLOR30_high\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(32+\1)	; number of playfield colors >= 32
cl1_COLOR31_high\2		RS.L 1
	ENDC
	IFNE spr_colors_number		; number of sprite colors > 0
		IFEQ ((bplcon4_bits&$000f)-(\3&$000f)) & ((bplcon4_bits&$00f0)-(\3&$00f0)) ; sprite color table
	 		IFLT pf_colors_number-(16+\1) ; number of playfield colors < 16
	 	 		IFGT \2-1 ; playfield palette number > 1
cl1_BPLCON3_high\2		RS.L 1
	 	 		ENDC
cl1_COLOR00_high\2		RS.L 1
cl1_COLOR01_high\2		RS.L 1
cl1_COLOR02_high\2		RS.L 1
cl1_COLOR03_high\2		RS.L 1
cl1_COLOR04_high\2		RS.L 1
cl1_COLOR05_high\2		RS.L 1
cl1_COLOR06_high\2		RS.L 1
cl1_COLOR07_high\2		RS.L 1
cl1_COLOR08_high\2		RS.L 1
cl1_COLOR09_high\2		RS.L 1
cl1_COLOR10_high\2		RS.L 1
cl1_COLOR11_high\2		RS.L 1
cl1_COLOR12_high\2		RS.L 1
cl1_COLOR13_high\2		RS.L 1
cl1_COLOR14_high\2		RS.L 1
cl1_COLOR15_high\2		RS.L 1
			ENDC
		ENDC
		IFEQ ((bplcon4_bits&$000f)-(\4&$000f)) & ((bplcon4_bits&$00f0)-(\4&$00f0)) ; sprite color table 1
			IFLT pf_colors_number-(32+\1) ; number of playfield colors < 32
	 			IFGT \2-1 ; playfield palette number > 1
	 				IFLT pf_colors_number-(1+\1) ; number of playfield colors < 1
cl1_BPLCON3_high\2		RS.L 1
	 				ENDC
	 			ENDC
cl1_COLOR16_high\2		RS.L 1
cl1_COLOR17_high\2		RS.L 1
cl1_COLOR18_high\2		RS.L 1
cl1_COLOR19_high\2		RS.L 1
cl1_COLOR20_high\2		RS.L 1
cl1_COLOR21_high\2		RS.L 1
cl1_COLOR22_high\2		RS.L 1
cl1_COLOR23_high\2		RS.L 1
cl1_COLOR24_high\2		RS.L 1
cl1_COLOR25_high\2		RS.L 1
cl1_COLOR26_high\2		RS.L 1
cl1_COLOR27_high\2		RS.L 1
cl1_COLOR28_high\2		RS.L 1
cl1_COLOR29_high\2		RS.L 1
cl1_COLOR30_high\2		RS.L 1
cl1_COLOR31_high\2		RS.L 1
	 		ENDC
		ENDC
	ENDC
	ENDM

	COLOR_PALETTE_HIGH 0,1,$0000,$0011
	COLOR_PALETTE_HIGH 32,2,$0022,$0033
	COLOR_PALETTE_HIGH 64,3,$0044,$0055
	COLOR_PALETTE_HIGH 96,4,$0066,$0077
	COLOR_PALETTE_HIGH 128,5,$0088,$0099
	COLOR_PALETTE_HIGH 160,6,$00aa,$00bb
	COLOR_PALETTE_HIGH 192,7,$00cc,$00dd
	COLOR_PALETTE_HIGH 224,8,$00ee,$00ff

COLOR_PALETTE_LOW		MACRO
; \1:	color number base in 32steps 0/32/../224
; \2:	playfield palette number 1..8
; \3:	sprite palette number $00/$22/$44,$66,$88,$aa,$cc,$ee
; \4:	sprite palette number $11/$33/$55,$77,$99,$bb,$dd,$ff
	IFGE pf_colors_number-(1+\1)	; number of playfield colors >= 1
cl1_BPLCON3_low\2		RS.L 1
cl1_COLOR00_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(2+\1)	; number of playfield colors >= 2
cl1_COLOR01_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(3+\1)	; number of playfield colors >= 3
cl1_COLOR02_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(4+\1)	; number of playfield colors >= 4
cl1_COLOR03_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(5+\1)	; number of playfield colors >= 5
cl1_COLOR04_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(6+\1)	; number of playfield colors >= 6
cl1_COLOR05_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(7+\1)	; number of playfield colors >= 7
cl1_COLOR06_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(8+\1)	; number of playfield colors >= 8
cl1_COLOR07_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(9+\1)	; number of playfield colors >= 9
cl1_COLOR08_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(10+\1)	; number of playfield colors >= 10
cl1_COLOR09_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(11+\1)	; number of playfield colors >= 11
cl1_COLOR10_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(12+\1)	; number of playfield colors >= 12
cl1_COLOR11_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(13+\1)	; number of playfield colors >= 13
cl1_COLOR12_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(14+\1)	; number of playfield colors >= 14
cl1_COLOR13_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(15+\1)	; number of playfield colors >= 15
cl1_COLOR14_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(16+\1)	; number of playfield colors >= 16
cl1_COLOR15_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(17+\1)	; number of playfield colors >= 17
cl1_COLOR16_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(18+\1)	; number of playfield colors >= 18
cl1_COLOR17_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(19+\1)	; number of playfield colors >= 19
cl1_COLOR18_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(20+\1)	; number of playfield colors >= 20
cl1_COLOR19_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(21+\1)	; number of playfield colors >= 21
cl1_COLOR20_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(22+\1)	; number of playfield colors >= 22
cl1_COLOR21_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(23+\1)	; number of playfield colors >= 23
cl1_COLOR22_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(24+\1)	; number of playfield colors >= 24
cl1_COLOR23_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(25+\1)	; number of playfield colors >= 25
cl1_COLOR24_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(26+\1)	; number of playfield colors >= 26
cl1_COLOR25_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(27+\1)	; number of playfield colors >= 27
cl1_COLOR26_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(28+\1)	; number of playfield colors >= 28
cl1_COLOR27_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(29+\1)	; number of playfield colors >= 29
cl1_COLOR28_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(30+\1)	; number of playfield colors >= 30
cl1_COLOR29_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(31+\1)	; number of playfield colors >= 31
cl1_COLOR30_low\2		RS.L 1
	ENDC
	IFGE pf_colors_number-(32+\1)	; number of playfield colors >= 32
cl1_COLOR31_low\2		RS.L 1
	ENDC
	IFNE spr_colors_number		; number of sprite colors > 0
		IFEQ ((bplcon4_bits&$000f)-(\3&$000f)) & ((bplcon4_bits&$00f0)-(\3&$00f0)) ; sprite color table
	 		IFLT pf_colors_number-(16+\1) ; number of playfield colors < 16
cl1_BPLCON3_low\2		RS.L 1
cl1_COLOR00_low\2		RS.L 1
cl1_COLOR01_low\2		RS.L 1
cl1_COLOR02_low\2		RS.L 1
cl1_COLOR03_low\2		RS.L 1
cl1_COLOR04_low\2		RS.L 1
cl1_COLOR05_low\2		RS.L 1
cl1_COLOR06_low\2		RS.L 1
cl1_COLOR07_low\2		RS.L 1
cl1_COLOR08_low\2		RS.L 1
cl1_COLOR09_low\2		RS.L 1
cl1_COLOR10_low\2		RS.L 1
cl1_COLOR11_low\2		RS.L 1
cl1_COLOR12_low\2		RS.L 1
cl1_COLOR13_low\2		RS.L 1
cl1_COLOR14_low\2		RS.L 1
cl1_COLOR15_low\2		RS.L 1
	 		ENDC
		ENDC
		IFEQ ((bplcon4_bits&$000f)-(\4&$000f)) & ((bplcon4_bits&$00f0)-(\4&$00f0)) ; sprite color table 1
	 		IFLT pf_colors_number-(32+\1) ; number of playfield colors < 32
	 	 		IFLT pf_colors_number-(1+\1) ; number of playfield colors < 1
cl1_BPLCON3_low\2		RS.L 1
	 	 		ENDC
cl1_COLOR16_low\2		RS.L 1
cl1_COLOR17_low\2		RS.L 1
cl1_COLOR18_low\2		RS.L 1
cl1_COLOR19_low\2		RS.L 1
cl1_COLOR20_low\2		RS.L 1
cl1_COLOR21_low\2		RS.L 1
cl1_COLOR22_low\2		RS.L 1
cl1_COLOR23_low\2		RS.L 1
cl1_COLOR24_low\2		RS.L 1
cl1_COLOR25_low\2		RS.L 1
cl1_COLOR26_low\2		RS.L 1
cl1_COLOR27_low\2		RS.L 1
cl1_COLOR28_low\2		RS.L 1
cl1_COLOR29_low\2		RS.L 1
cl1_COLOR30_low\2		RS.L 1
cl1_COLOR31_low\2		RS.L 1
	 		ENDC
		ENDC
	ENDC
	ENDM

	COLOR_PALETTE_LOW 0,1,$0000,$0011
	COLOR_PALETTE_LOW 32,2,$0022,$0033
	COLOR_PALETTE_LOW 64,3,$0044,$0055
	COLOR_PALETTE_LOW 96,4,$0066,$0077
	COLOR_PALETTE_LOW 128,5,$0088,$0099
	COLOR_PALETTE_LOW 160,6,$00aa,$00bb
	COLOR_PALETTE_LOW 192,7,$00cc,$00dd
	COLOR_PALETTE_LOW 224,8,$00ee,$00ff

	IFGE pf_depth-1
cl1_BPL1PTH			RS.L 1
cl1_BPL1PTL			RS.L 1
	ENDC

	IFGE pf_depth-2
cl1_BPL2PTH			RS.L 1
cl1_BPL2PTL			RS.L 1
	ENDC

	IFGE pf_depth-3
cl1_BPL3PTH			RS.L 1
cl1_BPL3PTL			RS.L 1
	ENDC

	IFGE pf_depth-4
cl1_BPL4PTH			RS.L 1
cl1_BPL4PTL			RS.L 1
	ENDC

	IFGE pf_depth-5
cl1_BPL5PTH			RS.L 1
cl1_BPL5PTL			RS.L 1
	ENDC

	IFGE pf_depth-6
cl1_BPL6PTH			RS.L 1
cl1_BPL6PTL			RS.L 1
	ENDC

	IFGE pf_depth-7
cl1_BPL7PTH			RS.L 1
cl1_BPL7PTL			RS.L 1
	ENDC

	IFGE pf_depth-8
cl1_BPL8PTH			RS.L 1
cl1_BPL8PTL			RS.L 1
	ENDC

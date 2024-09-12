; Datum:	05.09.2024
; Version:	4.3

; ** Struktur, die alle Registeroffsets der 1. Copperliste enthält **

	IFD diwstrt_bits
cl2_DIWSTRT			RS.L 1
	ENDC
	IFD diwstop_bits
cl2_DIWSTOP			RS.L 1
	ENDC
	IFD ddfstrt_bits
cl2_DDFSTRT			RS.L 1
	ENDC
	IFD ddfstop_bits
cl2_DDFSTOP			RS.L 1
	ENDC
cl2_BPLCON0			RS.L 1
	IFD bplcon1_bits
cl2_BPLCON1			RS.L 1
	ENDC
	IFD bplcon2_bits
cl2_BPLCON2			RS.L 1
	ENDC
cl2_BPLCON3_1			RS.L 1
	IFNE pf_depth
cl2_BPL1MOD			RS.L 1
	ENDC
	IFGT pf_depth-1
cl2_BPL2MOD			RS.L 1
	ENDC
	IFEQ (pf_depth+spr_depth)
		IFD diwstrt_bits
cl2_BPLCON4			RS.L 1
		ENDC
	ELSE
cl2_BPLCON4			RS.L 1
	ENDC
	IFD diwhigh_bits
cl2_DIWHIGH			RS.L 1
	ENDC
	IFD fmode_bits
cl2_FMODE			RS.L 1
	ENDC

	IFNE dma_bits&DMAF_SPRITE
cl2_SPR0PTH			RS.L 1
cl2_SPR0PTL			RS.L 1
cl2_SPR1PTH			RS.L 1
cl2_SPR1PTL			RS.L 1
cl2_SPR2PTH			RS.L 1
cl2_SPR2PTL			RS.L 1
cl2_SPR3PTH			RS.L 1
cl2_SPR3PTL			RS.L 1
cl2_SPR4PTH			RS.L 1
cl2_SPR4PTL			RS.L 1
cl2_SPR5PTH			RS.L 1
cl2_SPR5PTL			RS.L 1
cl2_SPR6PTH			RS.L 1
cl2_SPR6PTL			RS.L 1
cl2_SPR7PTH			RS.L 1
cl2_SPR7PTL			RS.L 1
	ENDC

; ** High-Farbwerte der 1. Palette **

COLOR_PALETTE_HIGH MACRO
; \1: Farbnummer-Basis in 32er-Schritten 0/32/../224
; \2: PF-Palettennummer 1..8
; \3: Sprite-Palettennummer $00/$22/$44,$66,$88,$aa,$cc,$ee
; \4: Sprite-Palettennummer $11/$33/$55,$77,$99,$bb,$dd,$ff
	IFGE pf_colors_number-(1+\1)	; Anzahl Playfield-Farben >= 1
		IFGT \2-1	 	; PF-Palettennummer > 1
cl2_BPLCON3_high\2 RS.L 1
		ENDC
cl2_COLOR00_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(2+\1)	; Anzahl Playfield-Farben >= 2
cl2_COLOR01_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(3+\1)	; Anzahl Playfield-Farben >= 3
cl2_COLOR02_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(4+\1)	; Anzahl Playfield-Farben >= 4
cl2_COLOR03_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(5+\1)	; Anzahl Playfield-Farben >= 5
cl2_COLOR04_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(6+\1)	; Anzahl Playfield-Farben >= 6
cl2_COLOR05_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(7+\1)	; Anzahl Playfield-Farben >= 7
cl2_COLOR06_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(8+\1)	; Anzahl Playfield-Farben >= 8
cl2_COLOR07_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(9+\1)	; Anzahl Playfield-Farben >= 9
cl2_COLOR08_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(10+\1)	; Anzahl Playfield-Farben >= 10
cl2_COLOR09_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(11+\1)	; Anzahl Playfield-Farben >= 11
cl2_COLOR10_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(12+\1)	; Anzahl Playfield-Farben >= 12
cl2_COLOR11_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(13+\1)	; Anzahl Playfield-Farben >= 13
cl2_COLOR12_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(14+\1)	; Anzahl Playfield-Farben >= 14
cl2_COLOR13_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(15+\1)	; Anzahl Playfield-Farben >= 15
cl2_COLOR14_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(16+\1)	; Anzahl Playfield-Farben >= 16
cl2_COLOR15_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(17+\1)	; Anzahl Playfield-Farben >= 17
cl2_COLOR16_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(18+\1)	; Anzahl Playfield-Farben >= 18
cl2_COLOR17_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(19+\1)	; Anzahl Playfield-Farben >= 19
cl2_COLOR18_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(20+\1)	; Anzahl Playfield-Farben >= 20
cl2_COLOR19_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(21+\1)	; Anzahl Playfield-Farben >= 21
cl2_COLOR20_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(22+\1)	; Anzahl Playfield-Farben >= 22
cl2_COLOR21_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(23+\1)	; Anzahl Playfield-Farben >= 23
cl2_COLOR22_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(24+\1)	; Anzahl Playfield-Farben >= 24
cl2_COLOR23_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(25+\1)	; Anzahl Playfield-Farben >= 25
cl2_COLOR24_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(26+\1)	; Anzahl Playfield-Farben >= 26
cl2_COLOR25_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(27+\1)	; Anzahl Playfield-Farben >= 27
cl2_COLOR26_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(28+\1)	; Anzahl Playfield-Farben >= 28
cl2_COLOR27_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(29+\1)	; Anzahl Playfield-Farben >= 29
cl2_COLOR28_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(30+\1)	; Anzahl Playfield-Farben >= 30
cl2_COLOR29_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(31+\1)	; Anzahl Playfield-Farben >= 31
cl2_COLOR30_high\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(32+\1)	; Anzahl Playfield-Farben >= 32
cl2_COLOR31_high\2 RS.L 1
	ENDC
	IFNE spr_colors_number		; Anzahl SPR-Farben > 0
		IFEQ ((bplcon4_bits&$000f)-(\3&$000f)) & ((bplcon4_bits&$00f0)-(\3&$00f0)) ; Sprite-Colortable
	 		IFLT pf_colors_number-(16+\1) ; Anzahl Playfield-Farben < 16
	 	 		IFGT \2-1 ; Playfiels-Palettennummer > 1
cl2_BPLCON3_high\2		RS.L 1
	 	 		ENDC
cl2_COLOR00_high\2		RS.L 1
cl2_COLOR01_high\2		RS.L 1
cl2_COLOR02_high\2		RS.L 1
cl2_COLOR03_high\2		RS.L 1
cl2_COLOR04_high\2		RS.L 1
cl2_COLOR05_high\2		RS.L 1
cl2_COLOR06_high\2		RS.L 1
cl2_COLOR07_high\2		RS.L 1
cl2_COLOR08_high\2		RS.L 1
cl2_COLOR09_high\2		RS.L 1
cl2_COLOR10_high\2		RS.L 1
cl2_COLOR11_high\2		RS.L 1
cl2_COLOR12_high\2		RS.L 1
cl2_COLOR13_high\2		RS.L 1
cl2_COLOR14_high\2		RS.L 1
cl2_COLOR15_high\2		RS.L 1
			ENDC
		ENDC
		IFEQ ((bplcon4_bits&$000f)-(\4&$000f)) & ((bplcon4_bits&$00f0)-(\4&$00f0)) ; Sprite-Colortable 1
			IFLT pf_colors_number-(32+\1) ; Anzahl Playfield-Farben < 32
	 			IFGT \2-1 ; Playfield-Palettennummer > 1
	 				IFLT pf_colors_number-(1+\1) ; Anzahl Playfield-Farben < 1
cl2_BPLCON3_high\2 RS.L 1
	 				ENDC
	 			ENDC
cl2_COLOR16_high\2		RS.L 1
cl2_COLOR17_high\2		RS.L 1
cl2_COLOR18_high\2		RS.L 1
cl2_COLOR19_high\2		RS.L 1
cl2_COLOR20_high\2		RS.L 1
cl2_COLOR21_high\2		RS.L 1
cl2_COLOR22_high\2		RS.L 1
cl2_COLOR23_high\2		RS.L 1
cl2_COLOR24_high\2		RS.L 1
cl2_COLOR25_high\2		RS.L 1
cl2_COLOR26_high\2		RS.L 1
cl2_COLOR27_high\2		RS.L 1
cl2_COLOR28_high\2		RS.L 1
cl2_COLOR29_high\2		RS.L 1
cl2_COLOR30_high\2		RS.L 1
cl2_COLOR31_high\2		RS.L 1
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


; ** Low-Farbwerte der 1. Palette **

COLOR_PALETTE_LOW MACRO
; \1: Farbnummer-Basis in 32er-Schritten 0/32/../224
; \2: PF-Palettennummer 1..8
; \3: Sprite-Palettennummer $00/$22/$44,$66,$88,$aa,$cc,$ee
; \4: Sprite-Palettennummer $11/$33/$55,$77,$99,$bb,$dd,$ff
	IFGE pf_colors_number-(1+\1)	; Anzahl Playfield-Farben >= 1
cl2_BPLCON3_low\2 RS.L 1
cl2_COLOR00_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(2+\1)	; Anzahl Playfield-Farben >= 2
cl2_COLOR01_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(3+\1)	; Anzahl Playfield-Farben >= 3
cl2_COLOR02_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(4+\1)	; Anzahl Playfield-Farben >= 4
cl2_COLOR03_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(5+\1)	; Anzahl Playfield-Farben >= 5
cl2_COLOR04_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(6+\1)	; Anzahl Playfield-Farben >= 6
cl2_COLOR05_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(7+\1)	; Anzahl Playfield-Farben >= 7
cl2_COLOR06_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(8+\1)	; Anzahl Playfield-Farben >= 8
cl2_COLOR07_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(9+\1)	; Anzahl Playfield-Farben >= 9
cl2_COLOR08_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(10+\1)	; Anzahl Playfield-Farben >= 10
cl2_COLOR09_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(11+\1)	; Anzahl Playfield-Farben >= 11
cl2_COLOR10_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(12+\1)	; Anzahl Playfield-Farben >= 12
cl2_COLOR11_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(13+\1)	; Anzahl Playfield-Farben >= 13
cl2_COLOR12_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(14+\1)	; Anzahl Playfield-Farben >= 14
cl2_COLOR13_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(15+\1)	; Anzahl Playfield-Farben >= 15
cl2_COLOR14_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(16+\1)	; Anzahl Playfield-Farben >= 16
cl2_COLOR15_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(17+\1)	; Anzahl Playfield-Farben >= 17
cl2_COLOR16_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(18+\1)	; Anzahl Playfield-Farben >= 18
cl2_COLOR17_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(19+\1)	; Anzahl Playfield-Farben >= 19
cl2_COLOR18_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(20+\1)	; Anzahl Playfield-Farben >= 20
cl2_COLOR19_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(21+\1)	; Anzahl Playfield-Farben >= 21
cl2_COLOR20_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(22+\1)	; Anzahl Playfield-Farben >= 22
cl2_COLOR21_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(23+\1)	; Anzahl Playfield-Farben >= 23
cl2_COLOR22_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(24+\1)	; Anzahl Playfield-Farben >= 24
cl2_COLOR23_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(25+\1)	; Anzahl Playfield-Farben >= 25
cl2_COLOR24_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(26+\1)	; Anzahl Playfield-Farben >= 26
cl2_COLOR25_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(27+\1)	; Anzahl Playfield-Farben >= 27
cl2_COLOR26_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(28+\1)	; Anzahl Playfield-Farben >= 28
cl2_COLOR27_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(29+\1)	; Anzahl Playfield-Farben >= 29
cl2_COLOR28_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(30+\1)	; Anzahl Playfield-Farben >= 30
cl2_COLOR29_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(31+\1)	; Anzahl Playfield-Farben >= 31
cl2_COLOR30_low\2 RS.L 1
	ENDC
	IFGE pf_colors_number-(32+\1)	; Anzahl Playfield-Farben >= 32
cl2_COLOR31_low\2 RS.L 1
	ENDC
	IFNE spr_colors_number		; Anzahl Sprite-Farben > 0
		IFEQ ((bplcon4_bits&$000f)-(\3&$000f)) & ((bplcon4_bits&$00f0)-(\3&$00f0)) ; Sprite-Colortable
	 		IFLT pf_colors_number-(16+\1) ; Anzahl Playfield-Farben < 16
cl2_BPLCON3_low\2	RS.L 1
cl2_COLOR00_low\2	RS.L 1
cl2_COLOR01_low\2	RS.L 1
cl2_COLOR02_low\2	RS.L 1
cl2_COLOR03_low\2	RS.L 1
cl2_COLOR04_low\2	RS.L 1
cl2_COLOR05_low\2	RS.L 1
cl2_COLOR06_low\2	RS.L 1
cl2_COLOR07_low\2	RS.L 1
cl2_COLOR08_low\2	RS.L 1
cl2_COLOR09_low\2	RS.L 1
cl2_COLOR10_low\2	RS.L 1
cl2_COLOR11_low\2	RS.L 1
cl2_COLOR12_low\2	RS.L 1
cl2_COLOR13_low\2	RS.L 1
cl2_COLOR14_low\2	RS.L 1
cl2_COLOR15_low\2	RS.L 1
	 		ENDC
		ENDC
		IFEQ ((bplcon4_bits&$000f)-(\4&$000f)) & ((bplcon4_bits&$00f0)-(\4&$00f0)) ;SPR-Colortable 1
	 		IFLT pf_colors_number-(32+\1) ;Anzahl Playfield-Farben < 32
	 	 		IFLT pf_colors_number-(1+\1) ;Anzahl Playfield-Farben < 1
cl2_BPLCON3_low\2 RS.L 1
	 	 		ENDC
cl2_COLOR16_low\2 RS.L 1
cl2_COLOR17_low\2 RS.L 1
cl2_COLOR18_low\2 RS.L 1
cl2_COLOR19_low\2 RS.L 1
cl2_COLOR20_low\2 RS.L 1
cl2_COLOR21_low\2 RS.L 1
cl2_COLOR22_low\2 RS.L 1
cl2_COLOR23_low\2 RS.L 1
cl2_COLOR24_low\2 RS.L 1
cl2_COLOR25_low\2 RS.L 1
cl2_COLOR26_low\2 RS.L 1
cl2_COLOR27_low\2 RS.L 1
cl2_COLOR28_low\2 RS.L 1
cl2_COLOR29_low\2 RS.L 1
cl2_COLOR30_low\2 RS.L 1
cl2_COLOR31_low\2 RS.L 1
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
cl2_BPL1PTH			RS.L 1	; 1 Bitplane
cl2_BPL1PTL			RS.L 1
	ENDC

	IFGE pf_depth-2
cl2_BPL2PTH			RS.L 1	; 2 bitplanes
cl2_BPL2PTL			RS.L 1
	ENDC

	IFGE pf_depth-3
cl2_BPL3PTH			RS.L 1	; 3 Bitplanes
cl2_BPL3PTL			RS.L 1
	ENDC

	IFGE pf_depth-4
cl2_BPL4PTH			RS.L 1	; 4 Bitplanes
cl2_BPL4PTL			RS.L 1
	ENDC

	IFGE pf_depth-5
cl2_BPL5PTH			RS.L 1	; 5 Bitplanes
cl2_BPL5PTL			RS.L 1
	ENDC

	IFGE pf_depth-6
cl2_BPL6PTH			RS.L 1	; 6 Bitplanes
cl2_BPL6PTL			RS.L 1
	ENDC

	IFGE pf_depth-7
cl2_BPL7PTH			RS.L 1	; 7 Bitplanes
cl2_BPL7PTL			RS.L 1
	ENDC

	IFGE pf_depth-8
cl2_BPL8PTH			RS.L 1	; 8 Bitplanes
cl2_BPL8PTL			RS.L 1
	ENDC

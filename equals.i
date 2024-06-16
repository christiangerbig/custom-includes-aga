; Includedatei: "normsource-includes/equals.i"
; Datum:        19.02.2023
; Version:      5.6

; ** Konstanten **
; ----------------

; **** Main ****
TRUE                                EQU 0
FALSE                               EQU -1
FALSEB                              EQU $ff
FALSEW                              EQU $ffff
FALSEL                              EQU $ffffffff

BYTESIZE                            EQU 1
WORDSIZE                            EQU 2
LONGWORDSIZE                        EQU 4
QUADWORDSIZE                        EQU 8

NIBBLESHIFTBITS                     EQU 4
NIBBLESHIFT                         EQU 16
NIBBLEMASKLO                        EQU $0f
NIBBLEMASKHI                        EQU $f0
NIBBLESIGNMASK                      EQU $8
NIBBLESIGNBIT                       EQU 3

BYTESHIFTBITS                       EQU 8
BYTEMASK                            EQU $ff
BYTESIGNMASK                        EQU $80
BYTESIGNBIT                         EQU 7

WORDMASK                            EQU $ffff
WORDSIGNMASK                        EQU $8000
WORDSIGNBIT                         EQU 15

ALIGN64KB                           EQU $ffff

PALFPS                              EQU 50
NTSCFPS                             EQU 60
                                      
PALCLOCKCONSTANT                    EQU 3524210
NTSCCLOCKCONSTANT                   EQU 3492064

ASCII_CTRL_A                        EQU 1
ASCII_CTRL_C                        EQU 3
ASCII_CTRL_D                        EQU 4
ASCII_CTRL_F                        EQU 6
ASCII_CTRL_M                        EQU 13
ASCII_CTRL_N                        EQU 14
ASCII_CTRL_P                        EQU 16
ASCII_CTRL_S                        EQU 19
ASCII_CTRL_W                        EQU 23


; **** Workbench-Fader ****
wbf_colors_number_max               EQU 256
wbfi_fader_speed                    EQU 6
wbfo_fader_speed                    EQU 6

; **** OS ****
delay_time1                         EQU 50*1 ;1s bei 50 Ticks/Sekunde
delay_time2                         EQU 50*3 ;3s bei 50 Ticks/Sekunde

OS_VERSION_AGA                      EQU 39

Exec_Base                           EQU $0004

AFF_68060                           EQU $80
AFB_68060                           EQU 7

_LVOResetBattClock          	    EQU -6
_LVOReadBattClock           	    EQU -12
_LVOWriteBattClock          	    EQU -18

; **** Custom_Errors ****
custom_error_number                 EQU 46

NO_CUSTOM_ERROR                     EQU 0

GRAPHICS_LIBRARY_COULD_NOT_OPEN     EQU 1

KICKSTART_VERSION_NOT_FOUND         EQU 2
CPU_020_NOT_FOUND                   EQU 3
CHIPSET_NO_AGA_PAL                  EQU 4

CPU_030_REQUIRED                    EQU 5
CPU_040_REQUIRED                    EQU 5
CPU_060_REQUIRED                    EQU 5
FAST_MEMORY_REQUIRED                EQU 6

INTUITION_LIBRARY_COULD_NOT_OPEN    EQU 7

CIAA_RESOURCE_COULD_NOT_OPEN        EQU 8
CIAB_RESOURCE_COULD_NOT_OPEN        EQU 9

TIMER_DEVICE_COULD_NOT_OPEN         EQU 10

CL1_CONSTRUCTION1_NO_MEMORY         EQU 11
CL1_CONSTRUCTION2_NO_MEMORY         EQU 12
CL1_DISPLAY_NO_MEMORY               EQU 13

CL2_CONSTRUCTION1_NO_MEMORY         EQU 14
CL2_CONSTRUCTION2_NO_MEMORY         EQU 15
CL2_DISPLAY_NO_MEMORY               EQU 16

PF1_CONSTRUCTION1_NO_MEMORY         EQU 17
PF1_CONSTRUCTION1_NOT_INTERLEAVED   EQU 18
PF1_CONSTRUCTION2_NO_MEMORY         EQU 19
PF1_CONSTRUCTION2_NOT_INTERLEAVED   EQU 20
PF1_DISPLAY_NO_MEMORY               EQU 21
PF1_DISPLAY_NOT_INTERLEAVED         EQU 22

PF2_CONSTRUCTION1_NO_MEMORY         EQU 23
PF2_CONSTRUCTION1_NOT_INTERLEAVED   EQU 24
PF2_CONSTRUCTION2_NO_MEMORY         EQU 25
PF2_CONSTRUCTION2_NOT_INTERLEAVED   EQU 26
PF2_DISPLAY_NO_MEMORY               EQU 27
PF2_DISPLAY_NOT_INTERLEAVED         EQU 28

EXTRA_PLAYFIELD_NO_MEMORY           EQU 29
EXTRA_PLAYFIELD_NOT_INTERLEAVED     EQU 30

SPR_CONSTRUCTION_NO_MEMORY          EQU 31
SPR_CONSTRUCTION_NOT_INTERLEAVED    EQU 32

SPR_DISPLAY_NO_MEMORY               EQU 33
SPR_DISPLAY_NOT_INTERLEAVED         EQU 34

AUDIO_MEMORY_NO_MEMORY              EQU 35

DISK_MEMORY_NO_MEMORY               EQU 36

EXTRA_MEMORY_NO_MEMORY              EQU 37

CHIP_MEMORY_NO_MEMORY               EQU 38

CUSTOM_MEMORY_NO_MEMORY             EQU 39

EXCEPTION_VECTORS_NO_MEMORY         EQU 40

ACTIVE_SCREEN_NOT_FOUND             EQU 41
VIEWPORT_MONITOR_ID_NOT_FOUND       EQU 42

SCREEN_COLOR_TABLE_NO_MEMORY        EQU 43
SCREEN_COULD_NOT_OPEN               EQU 44
SCREEN_DISPLAY_MODE_NOT_AVAILABLE   EQU 45

WORKBENCH_FADE_NO_MEMORY            EQU 46

; **** Chipset ****
_CUSTOM                             EQU $dff000

DSKPTH                              EQU DSKPT
DSKPTL                              EQU DSKPT+2

COP1LCH                             EQU COP1LC
COP1LCL                             EQU COP1LC+2
COP2LCH                             EQU COP2LC
COP2LCL                             EQU COP2LC+2

BLTCPTH                             EQU BLTCPT
BLTCPTL                             EQU BLTCPT+2
BLTBPTH                             EQU BLTBPT
BLTBPTL                             EQU BLTBPT+2
BLTAPTH                             EQU BLTAPT
BLTAPTL                             EQU BLTAPT+2
BLTDPTH                             EQU BLTDPT
BLTDPTL                             EQU BLTDPT+2

AUD0LCH                             EQU AUD0
AUD0LCL                             EQU AUD0+2
AUD0LEN                             EQU AUD0+4
AUD0PER                             EQU AUD0+6
AUD0VOL                             EQU AUD0+8

AUD1LCH                             EQU AUD1
AUD1LCL                             EQU AUD1+2
AUD1LEN                             EQU AUD1+4
AUD1PER                             EQU AUD1+6
AUD1VOL                             EQU AUD1+8

AUD2LCH                             EQU AUD2
AUD2LCL                             EQU AUD2+2
AUD2LEN                             EQU AUD2+4
AUD2PER                             EQU AUD2+6
AUD2VOL                             EQU AUD2+8

AUD3LCH                             EQU AUD3
AUD3LCL                             EQU AUD3+2
AUD3LEN                             EQU AUD3+4
AUD3PER                             EQU AUD3+6
AUD3VOL                             EQU AUD3+8

BPL1PTH                             EQU BPLPT
BPL1PTL                             EQU BPLPT+2
BPL2PTH                             EQU BPLPT+4
BPL2PTL                             EQU BPLPT+6
BPL3PTH                             EQU BPLPT+8
BPL3PTL                             EQU BPLPT+10
BPL4PTH                             EQU BPLPT+12
BPL4PTL                             EQU BPLPT+14
BPL5PTH                             EQU BPLPT+16
BPL5PTL                             EQU BPLPT+18
BPL6PTH                             EQU BPLPT+20
BPL6PTL                             EQU BPLPT+22
BPL7PTH                             EQU BPLPT+24
BPL7PTL                             EQU BPLPT+26
BPL8PTH                             EQU BPLPT+28
BPL8PTL                             EQU BPLPT+30

BPL1DAT                             EQU BPLDAT
BPL2DAT                             EQU BPLDAT+2
BPL3DAT                             EQU BPLDAT+4
BPL4DAT                             EQU BPLDAT+6
BPL5DAT                             EQU BPLDAT+8
BPL6DAT                             EQU BPLDAT+10
BPL7DAT                             EQU BPLDAT+12
BPL8DAT                             EQU BPLDAT+14

SPR0PTH                             EQU SPRPT
SPR0PTL                             EQU SPRPT+2
SPR1PTH                             EQU SPRPT+4
SPR1PTL                             EQU SPRPT+6
SPR2PTH                             EQU SPRPT+8
SPR2PTL                             EQU SPRPT+10
SPR3PTH                             EQU SPRPT+12
SPR3PTL                             EQU SPRPT+14
SPR4PTH                             EQU SPRPT+16
SPR4PTL                             EQU SPRPT+18
SPR5PTH                             EQU SPRPT+20
SPR5PTL                             EQU SPRPT+22
SPR6PTH                             EQU SPRPT+24
SPR6PTL                             EQU SPRPT+26
SPR7PTH                             EQU SPRPT+28
SPR7PTL                             EQU SPRPT+30
SPR0POS                             EQU $140
SPR0CTL                             EQU $142
SPR0DATA                            EQU $144
SPR0DATB                            EQU $146
SPR1POS                             EQU $148
SPR1CTL                             EQU $14a
SPR1DATA                            EQU $14c
SPR1DATB                            EQU $14e
SPR2POS                             EQU $150
SPR2CTL                             EQU $152
SPR2DATA                            EQU $154
SPR2DATB                            EQU $156
SPR3POS                             EQU $158
SPR3CTL                             EQU $15a
SPR3DATA                            EQU $15c
SPR3DATB                            EQU $15e
SPR4POS                             EQU $160
SPR4CTL                             EQU $162
SPR4DATA                            EQU $164
SPR4DATB                            EQU $166
SPR5POS                             EQU $168
SPR5CTL                             EQU $16a
SPR5DATA                            EQU $16c
SPR5DATB                            EQU $16e
SPR6POS                             EQU $170
SPR6CTL                             EQU $172
SPR6DATA                            EQU $174
SPR6DATB                            EQU $176
SPR7POS                             EQU $178
SPR7CTL                             EQU $17a
SPR7DATA                            EQU $17c
SPR7DATB                            EQU $17e

COLOR00                             EQU COLOR
COLOR01                             EQU COLOR+2
COLOR02                             EQU COLOR+4
COLOR03                             EQU COLOR+6
COLOR04                             EQU COLOR+8
COLOR05                             EQU COLOR+10
COLOR06                             EQU COLOR+12
COLOR07                             EQU COLOR+14
COLOR08                             EQU COLOR+16
COLOR09                             EQU COLOR+18
COLOR10                             EQU COLOR+20
COLOR11                             EQU COLOR+22
COLOR12                             EQU COLOR+24
COLOR13                             EQU COLOR+26
COLOR14                             EQU COLOR+28
COLOR15                             EQU COLOR+30
COLOR16                             EQU COLOR+32
COLOR17                             EQU COLOR+34
COLOR18                             EQU COLOR+36
COLOR19                             EQU COLOR+38
COLOR20                             EQU COLOR+40
COLOR21                             EQU COLOR+42
COLOR22                             EQU COLOR+44
COLOR23                             EQU COLOR+46
COLOR24                             EQU COLOR+48
COLOR25                             EQU COLOR+50
COLOR26                             EQU COLOR+52
COLOR27                             EQU COLOR+54
COLOR28                             EQU COLOR+56
COLOR29                             EQU COLOR+58
COLOR30                             EQU COLOR+60
COLOR31                             EQU COLOR+62

NOOP                                EQU $1fe

JOY0DATF_Y7                         EQU $8000
JOY0DATF_Y6                         EQU $4000
JOY0DATF_Y5                         EQU $2000
JOY0DATF_Y4                         EQU $1000
JOY0DATF_Y3                         EQU $0800
JOY0DATF_Y2                         EQU $0400
JOY0DATF_Y1                         EQU $0200
JOY0DATF_Y0                         EQU $0100
JOY0DATF_X7                         EQU $0080
JOY0DATF_X6                         EQU $0040
JOY0DATF_X5                         EQU $0020
JOY0DATF_X4                         EQU $0010
JOY0DATF_X3                         EQU $0008
JOY0DATF_X2                         EQU $0004
JOY0DATF_X1                         EQU $0002
JOY0DATF_X0                         EQU $0001

JOY0DATB_Y7                         EQU 15
JOY0DATB_Y6                         EQU 14
JOY0DATB_Y5                         EQU 13
JOY0DATB_Y4                         EQU 12
JOY0DATB_Y3                         EQU 11
JOY0DATB_Y2                         EQU 10
JOY0DATB_Y1                         EQU 9
JOY0DATB_Y0                         EQU 8
JOY0DATB_X7                         EQU 7
JOY0DATB_X6                         EQU 6
JOY0DATB_X5                         EQU 5
JOY0DATB_X4                         EQU 4
JOY0DATB_X3                         EQU 3
JOY0DATB_X2                         EQU 2
JOY0DATB_X1                         EQU 1
JOY0DATB_X0                         EQU 0

JOY1DATF_Y7                         EQU $8000
JOY1DATF_Y6                         EQU $4000
JOY1DATF_Y5                         EQU $2000
JOY1DATF_Y4                         EQU $1000
JOY1DATF_Y3                         EQU $0800
JOY1DATF_Y2                         EQU $0400
JOY1DATF_Y1                         EQU $0200
JOY1DATF_Y0                         EQU $0100
JOY1DATF_X7                         EQU $0080
JOY1DATF_X6                         EQU $0040
JOY1DATF_X5                         EQU $0020
JOY1DATF_X4                         EQU $0010
JOY1DATF_X3                         EQU $0008
JOY1DATF_X2                         EQU $0004
JOY1DATF_X1                         EQU $0002
JOY1DATF_X0                         EQU $0001

JOY1DATB_Y7                         EQU 15
JOY1DATB_Y6                         EQU 14
JOY1DATB_Y5                         EQU 13
JOY1DATB_Y4                         EQU 12
JOY1DATB_Y3                         EQU 11
JOY1DATB_Y2                         EQU 10
JOY1DATB_Y1                         EQU 9
JOY1DATB_Y0                         EQU 8
JOY1DATB_X7                         EQU 7
JOY1DATB_X6                         EQU 6
JOY1DATB_X5                         EQU 5
JOY1DATB_X4                         EQU 4
JOY1DATB_X3                         EQU 3
JOY1DATB_X2                         EQU 2
JOY1DATB_X1                         EQU 1
JOY1DATB_X0                         EQU 0

DSKLENF_DMAEN                       EQU $8000
DSKLENF_WRITE                       EQU $4000

POTINPF_OUTRY                       EQU $8000
POTINPF_DATRY                       EQU $4000
POTINPF_OUTRX                       EQU $2000
POTINPF_DATRX                       EQU $1000
POTINPF_OUTLY                       EQU $0800
POTINPF_DATLY                       EQU $0400
POTINPF_OUTLX                       EQU $0200
POTINPF_DATLX                       EQU $0100
POTINPF_START                       EQU $0001

POTINPB_OUTRY                       EQU 15
POTINPB_DATRY                       EQU 14
POTINPB_OUTRX                       EQU 13
POTINPB_DATRX                       EQU 12
POTINPB_OUTLY                       EQU 11
POTINPB_DATLY                       EQU 10
POTINPB_OUTLX                       EQU 9
POTINPB_DATLX                       EQU 8
POTINPB_START                       EQU 0

VPOSF_LOF                           EQU $8000
VPOSB_LOF                           EQU 15

COPCONF_CDANG                       EQU $0002
COPCONB_CDANG                       EQU 1

SERDATRF_OVRUN                      EQU $8000
SERDATRF_RBF                        EQU $4000
SERDATRF_TBE                        EQU $2000
SERDATRF_TSRE                       EQU $1000
SERDATRF_RXD                        EQU $0800
SERDATRF_STP                        EQU $0200
SERDATRF_DB8                        EQU $0100
SERDATRF_DB7                        EQU $0080
SERDATRF_DB6                        EQU $0040
SERDATRF_DB5                        EQU $0020
SERDATRF_DB4                        EQU $0010
SERDATRF_DB3                        EQU $0008
SERDATRF_DB2                        EQU $0004
SERDATRF_DB1                        EQU $0002
SERDATRF_DB0                        EQU $0001

SERDATRB_OVRUN                      EQU 15
SERDATRB_RBF                        EQU 14
SERDATRB_TBE                        EQU 13
SERDATRB_TSRE                       EQU 12
SERDATRB_RXD                        EQU 11
SERDATRB_STP                        EQU 9
SERDATRB_DB8                        EQU 8
SERDATRB_DB7                        EQU 7
SERDATRB_DB6                        EQU 6
SERDATRB_DB5                        EQU 5
SERDATRB_DB4                        EQU 4
SERDATRB_DB3                        EQU 3
SERDATRB_DB2                        EQU 2
SERDATRB_DB1                        EQU 1
SERDATRB_DB0                        EQU 0

BLTCON0F_ASH3                       EQU $8000
BLTCON0F_ASH2                       EQU $4000
BLTCON0F_ASH1                       EQU $2000
BLTCON0F_ASH0                       EQU $1000
BLTCON0F_USEA                       EQU $0800
BLTCON0F_USEB                       EQU $0400
BLTCON0F_USEC                       EQU $0200
BLTCON0F_USED                       EQU $0100
BLTCON0F_LF7                        EQU $0080
BLTCON0F_LF6                        EQU $0040
BLTCON0F_LF5                        EQU $0020
BLTCON0F_LF4                        EQU $0010
BLTCON0F_LF3                        EQU $0008
BLTCON0F_LF2                        EQU $0004
BLTCON0F_LF1                        EQU $0002
BLTCON0F_LF0                        EQU $0001

BLTCON0F_START3                     EQU $8000
BLTCON0F_START2                     EQU $4000
BLTCON0F_START1                     EQU $2000
BLTCON0F_START0                     EQU $1000

BLTCON1F_BSH3                       EQU $8000
BLTCON1F_BSH2                       EQU $4000
BLTCON1F_BSH1                       EQU $2000
BLTCON1F_BSH0                       EQU $1000
BLTCON1F_DOFF                       EQU $0080
BLTCON1F_EFE                        EQU $0010
BLTCON1F_IFE                        EQU $0008
BLTCON1F_FCI                        EQU $0004
BLTCON1F_DESC                       EQU $0002
BLTCON1F_LINE                       EQU $0001

BLTCON1F_TEXTURE3                   EQU $8000
BLTCON1F_TEXTURE2                   EQU $4000
BLTCON1F_TEXTURE1                   EQU $2000
BLTCON1F_TEXTURE0                   EQU $1000
BLTCON1F_SIGN                       EQU $0040
BLTCON1F_SUD                        EQU $0010
BLTCON1F_SUL                        EQU $0008
BLTCON1F_AUL                        EQU $0004
BLTCON1F_SING                       EQU $0002

DIWSTRTF_V7                         EQU $8000
DIWSTRTF_V6                         EQU $4000
DIWSTRTF_V5                         EQU $2000
DIWSTRTF_V4                         EQU $1000
DIWSTRTF_V3                         EQU $0800
DIWSTRTF_V2                         EQU $0400
DIWSTRTF_V1                         EQU $0200
DIWSTRTF_V0                         EQU $0100
DIWSTRTF_H7                         EQU $0080
DIWSTRTF_H6                         EQU $0040
DIWSTRTF_H5                         EQU $0020
DIWSTRTF_H4                         EQU $0010
DIWSTRTF_H3                         EQU $0008
DIWSTRTF_H2                         EQU $0004
DIWSTRTF_H1                         EQU $0002
DIWSTRTF_H0                         EQU $0001

DIWSTOPF_V7                         EQU $8000
DIWSTOPF_V6                         EQU $4000
DIWSTOPF_V5                         EQU $2000
DIWSTOPF_V4                         EQU $1000
DIWSTOPF_V3                         EQU $0800
DIWSTOPF_V2                         EQU $0400
DIWSTOPF_V1                         EQU $0200
DIWSTOPF_V0                         EQU $0100
DIWSTOPF_H7                         EQU $0080
DIWSTOPF_H6                         EQU $0040
DIWSTOPF_H5                         EQU $0020
DIWSTOPF_H4                         EQU $0010
DIWSTOPF_H3                         EQU $0008
DIWSTOPF_H2                         EQU $0004
DIWSTOPF_H1                         EQU $0002
DIWSTOPF_H0                         EQU $0001

CLXCONF_ENSP7                       EQU $8000
CLXCONF_ENSP5                       EQU $4000
CLXCONF_ENSP3                       EQU $2000
CLXCONF_ENSP1                       EQU $1000
CLXCONF_ENBP6                       EQU $0800
CLXCONF_ENBP5                       EQU $0400
CLXCONF_ENBP4                       EQU $0200
CLXCONF_ENBP3                       EQU $0100
CLXCONF_ENBP2                       EQU $0080
CLXCONF_ENBP1                       EQU $0040
CLXCONF_MVBP6                       EQU $0020
CLXCONF_MVBP5                       EQU $0010
CLXCONF_MVBP4                       EQU $0008
CLXCONF_MVBP3                       EQU $0004
CLXCONF_MVBP2                       EQU $0002
CLXCONF_MVBP1                       EQU $0001

BPLCON0F_HIRES                      EQU $8000
BPLCON0F_BPU2                       EQU $4000
BPLCON0F_BPU1                       EQU $2000
BPLCON0F_BPU0                       EQU $1000
BPLCON0F_HAM                        EQU $0800
BPLCON0F_DPF                        EQU $0400
BPLCON0F_COLOR                      EQU $0200
BPLCON0F_GAUD                       EQU $0100
BPLCON0F_UHRES                      EQU $0080
BPLCON0F_SHRES                      EQU $0040
BPLCON0F_BYPASS                     EQU $0020
BPLCON0F_BPU3                       EQU $0010
BPLCON0F_LPEN                       EQU $0008
BPLCON0F_LACE                       EQU $0004
BPLCON0F_ERSY                       EQU $0002
BPLCON0F_ECSENA                     EQU $0001

BPLCON1F_PF2H7                      EQU $8000
BPLCON1F_PF2H6                      EQU $4000
BPLCON1F_PF2H1                      EQU $2000
BPLCON1F_PF2H0                      EQU $1000
BPLCON1F_PF1H7                      EQU $0800
BPLCON1F_PF1H6                      EQU $0400
BPLCON1F_PF1H1                      EQU $0200
BPLCON1F_PF1H0                      EQU $0100
BPLCON1F_PF2H5                      EQU $0080
BPLCON1F_PF2H4                      EQU $0040
BPLCON1F_PF2H3                      EQU $0020
BPLCON1F_PF2H2                      EQU $0010
BPLCON1F_PF1H5                      EQU $0008
BPLCON1F_PF1H4                      EQU $0004
BPLCON1F_PF1H3                      EQU $0002
BPLCON1F_PF1H2                      EQU $0001

BPLCON2F_ZDBPSEL2                   EQU $4000
BPLCON2F_ZDBPSEL1                   EQU $2000
BPLCON2F_ZDBPSEL0                   EQU $1000
BPLCON2F_ZDBPEN                     EQU $0800
BPLCON2F_ZDCTEN                     EQU $0400
BPLCON2F_KILLEHB                    EQU $0200
BPLCON2F_RDRAM                      EQU $0100
BPLCON2F_SOGEN                      EQU $0080
BPLCON2F_PF2PRI                     EQU $0040
BPLCON2F_PF2P2                      EQU $0020
BPLCON2F_PF2P1                      EQU $0010
BPLCON2F_PF2P0                      EQU $0008
BPLCON2F_PF1P2                      EQU $0004
BPLCON2F_PF1P1                      EQU $0002
BPLCON2F_PF1P0                      EQU $0001

BPLCON3F_BANK2                      EQU $8000
BPLCON3F_BANK1                      EQU $4000
BPLCON3F_BANK0                      EQU $2000
BPLCON3F_PF2OF2                     EQU $1000
BPLCON3F_PF2OF1                     EQU $0800
BPLCON3F_PF2OF0                     EQU $0400
BPLCON3F_LOCT                       EQU $0200
BPLCON3F_SPRES1                     EQU $0080
BPLCON3F_SPRES0                     EQU $0040
BPLCON3F_BRDRBLNK                   EQU $0020
BPLCON3F_BRDNTRAN                   EQU $0010
BPLCON3F_ZDCLKEN                    EQU $0004
BPLCON3F_BRDSPRT                    EQU $0002
BPLCON3F_EXTBLKEN                   EQU $0001

BPLCON4F_BPLAM7                     EQU $8000
BPLCON4F_BPLAM6                     EQU $4000
BPLCON4F_BPLAM5                     EQU $2000
BPLCON4F_BPLAM4                     EQU $1000
BPLCON4F_BPLAM3                     EQU $0800
BPLCON4F_BPLAM2                     EQU $0400
BPLCON4F_BPLAM1                     EQU $0200
BPLCON4F_BPLAM0                     EQU $0100
BPLCON4F_ESPRM7                     EQU $0080
BPLCON4F_ESPRM6                     EQU $0040
BPLCON4F_ESPRM5                     EQU $0020
BPLCON4F_ESPRM4                     EQU $0010
BPLCON4F_OSPRM7                     EQU $0008
BPLCON4F_OSPRM6                     EQU $0004
BPLCON4F_OSPRM5                     EQU $0002
BPLCON4F_OSPRM4                     EQU $0001

CLXCON2F_ENBP8                      EQU $0080
CLXCON2F_ENBP7                      EQU $0040
CLXCON2F_MVBP8                      EQU $0002
CLXCON2F_MVBP7                      EQU $0001

SPRPOSF_SV7                         EQU $8000
SPRPOSF_SV6                         EQU $4000
SPRPOSF_SV5                         EQU $2000
SPRPOSF_SV4                         EQU $1000
SPRPOSF_SV3                         EQU $0800
SPRPOSF_SV2                         EQU $0400
SPRPOSF_SV1                         EQU $0200
SPRPOSF_SV0                         EQU $0100
SPRPOSF_SH10                        EQU $0080
SPRPOSF_SH9                         EQU $0040
SPRPOSF_SH8                         EQU $0020
SPRPOSF_SH7                         EQU $0010
SPRPOSF_SH6                         EQU $0008
SPRPOSF_SH5                         EQU $0004
SPRPOSF_SH4                         EQU $0002
SPRPOSF_SH3                         EQU $0001

SPRPOSB_SV7                         EQU 15
SPRPOSB_SV6                         EQU 14
SPRPOSB_SV5                         EQU 13
SPRPOSB_SV4                         EQU 12
SPRPOSB_SV3                         EQU 11
SPRPOSB_SV2                         EQU 10
SPRPOSB_SV1                         EQU 9
SPRPOSB_SV0                         EQU 8
SPRPOSB_SH10                        EQU 7
SPRPOSB_SH9                         EQU 6
SPRPOSB_SH8                         EQU 5
SPRPOSB_SH7                         EQU 4
SPRPOSB_SH6                         EQU 3
SPRPOSB_SH5                         EQU 2
SPRPOSB_SH4                         EQU 1
SPRPOSB_SH3                         EQU 0

SPRCTLF_EV7                         EQU $8000
SPRCTLF_EV6                         EQU $4000
SPRCTLF_EV5                         EQU $2000
SPRCTLF_EV4                         EQU $1000
SPRCTLF_EV3                         EQU $0800
SPRCTLF_EV2                         EQU $0400
SPRCTLF_EV1                         EQU $0200
SPRCTLF_EV0                         EQU $0100
SPRCTLF_ATT                         EQU $0080
SPRCTLF_SV9                         EQU $0040
SPRCTLF_EV9                         EQU $0020
SPRCTLF_SH1                         EQU $0010
SPRCTLF_SH0                         EQU $0008
SPRCTLF_SV8                         EQU $0004
SPRCTLF_EV8                         EQU $0002
SPRCTLF_SH2                         EQU $0001

SPRPOSB_EV7                         EQU 15
SPRCTLB_EV6                         EQU 14
SPRCTLB_EV5                         EQU 13
SPRCTLB_EV4                         EQU 12
SPRCTLB_EV3                         EQU 11
SPRCTLB_EV2                         EQU 10
SPRCTLB_EV1                         EQU 9
SPRCTLB_EV0                         EQU 8
SPRCTLB_ATT                         EQU 7
SPRCTLB_SV9                         EQU 6
SPRCTLB_EV9                         EQU 5
SPRCTLB_SH1                         EQU 4
SPRCTLB_SH0                         EQU 3
SPRCTLB_SV8                         EQU 2
SPRCTLB_EV8                         EQU 1
SPRCTLB_SH2                         EQU 0

HTOTALF_H8                          EQU $0080
HTOTALF_H7                          EQU $0040
HTOTALF_H6                          EQU $0020
HTOTALF_H5                          EQU $0010
HTOTALF_H4                          EQU $0008
HTOTALF_H3                          EQU $0004
HTOTALF_H2                          EQU $0002
HTOTALF_H1                          EQU $0001

HSSTOPF_H8                          EQU $0080
HSSTOPF_H7                          EQU $0040
HSSTOPF_H6                          EQU $0020
HSSTOPF_H5                          EQU $0010
HSSTOPF_H4                          EQU $0008
HSSTOPF_H3                          EQU $0004
HSSTOPF_H2                          EQU $0002
HSSTOPF_H1                          EQU $0001

HBSTRTF_H2                          EQU $0400
HBSTRTF_H1                          EQU $0200
HBSTRTF_H0                          EQU $0100
HBSTRTF_H10                         EQU $0080
HBSTRTF_H9                          EQU $0040
HBSTRTF_H8                          EQU $0020
HBSTRTF_H7                          EQU $0010
HBSTRTF_H6                          EQU $0008
HBSTRTF_H5                          EQU $0004
HBSTRTF_H4                          EQU $0002
HBSTRTF_H3                          EQU $0001

HBSTOPF_H2                          EQU $0400
HBSTOPF_H1                          EQU $0200
HBSTOPF_H0                          EQU $0100
HBSTOPF_H10                         EQU $0080
HBSTOPF_H9                          EQU $0040
HBSTOPF_H8                          EQU $0020
HBSTOPF_H7                          EQU $0010
HBSTOPF_H6                          EQU $0008
HBSTOPF_H5                          EQU $0004
HBSTOPF_H4                          EQU $0002
HBSTOPF_H3                          EQU $0001

HSSTRTF_H8                          EQU $0080
HSSTRTF_H7                          EQU $0040
HSSTRTF_H6                          EQU $0020
HSSTRTF_H5                          EQU $0010
HSSTRTF_H4                          EQU $0008
HSSTRTF_H3                          EQU $0004
HSSTRTF_H2                          EQU $0002
HSSTRTF_H1                          EQU $0001

DIWHIGHF_HSTOP10                    EQU $2000 ;AGA
DIWHIGHF_HSTOP8                     EQU $2000 ;ECS
DIWHIGHF_HSTOP1                     EQU $1000 ;AGA
DIWHIGHF_HSTOP0                     EQU $0800 ;AGA
DIWHIGHF_VSTOP10                    EQU $0400
DIWHIGHF_VSTOP9                     EQU $0200
DIWHIGHF_VSTOP8                     EQU $0100
DIWHIGHF_HSTART10                   EQU $0020 ;AGA
DIWHIGHF_HSTART8                    EQU $0020 ;ECS
DIWHIGHF_HSTART1                    EQU $0010 ;AGA
DIWHIGHF_HSTART0                    EQU $0008 ;AGA
DIWHIGHF_VSTART10                   EQU $0004
DIWHIGHF_VSTART9                    EQU $0002
DIWHIGHF_VSTART8                    EQU $0001

BEAMCON0F_HARDDIS                   EQU $4000
BEAMCON0F_LPENDIS                   EQU $2000
BEAMCON0F_VARVBEN                   EQU $1000
BEAMCON0F_LOLDIS                    EQU $0800
BEAMCON0F_CSCBEN                    EQU $0400
BEAMCON0F_VARVSYEN                  EQU $0200
BEAMCON0F_VARHSYEN                  EQU $0100
BEAMCON0F_VARBEAMEN                 EQU $0080
BEAMCON0F_DUAL                      EQU $0040
BEAMCON0F_PAL                       EQU $0020
BEAMCON0F_VARCSYEN                  EQU $0010
BEAMCON0F_BLANKEN                   EQU $0008
BEAMCON0F_CSYTRUE                   EQU $0004
BEAMCON0F_VSYTRUE                   EQU $0002
BEAMCON0F_HSYTRUE                   EQU $0001

FMODEF_SSCAN2                       EQU $8000
FMODEF_BSCAN2                       EQU $4000
FMODEF_SPAGEM                       EQU $0008
FMODEF_SPR32                        EQU $0004
FMODEF_BPAGEM                       EQU $0002
FMODEF_BPL32                        EQU $0001

; **** CIA ****
_CIAA                               EQU $bfe001
_CIAB                               EQU $bfd000

; **** CPU ****
SRF_T1                              EQU $8000
SRF_T0                              EQU $4000
SRF_S                               EQU $2000
SRF_M                               EQU $1000
SRF_I2                              EQU $0400
SRF_I1                              EQU $0200
SRF_I0                              EQU $0100
SRF_X                               EQU $0010
SRF_N                               EQU $0008
SRF_Z                               EQU $0004
SRF_V                               EQU $0002
SRF_C                               EQU $0001

CACR2F_WA                           EQU $2000
CACR2F_DBE                          EQU $1000
CACR2F_CD                           EQU $0800
CACR2F_CED                          EQU $0400
CACR2F_FD                           EQU $0200
CACR2F_ED                           EQU $0100
CACR2F_IBE                          EQU $0010
CACR2F_CI                           EQU $0008
CACR2F_CEI                          EQU $0004
CACR2F_FI                           EQU $0002
CACR2F_EI                           EQU $0001

CACR060F_EDC                        EQU $80000000
CACR060F_NAD                        EQU $40000000
CACR060F_ESB                        EQU $20000000
CACR060F_DPI                        EQU $10000000
CACR060F_FOC                        EQU $08000000
CACR060F_EBC                        EQU $00800000
CACR060F_CABC                       EQU $00400000
CACR060F_CUBC                       EQU $00200000
CACR060F_EIC                        EQU $00008000
CACR060F_NAI                        EQU $00004000
CACR060F_FIC                        EQU $00002000

CACR060B_EDC                        EQU 31
CACR060B_NAD                        EQU 30
CACR060B_ESB                        EQU 29
CACR060B_DPI                        EQU 28
CACR060B_FOC                        EQU 27
CACR060B_EBC                        EQU 23
CACR060B_CABC                       EQU 22
CACR060B_CUBC                       EQU 21
CACR060B_EIC                        EQU 15
CACR060B_NAI                        EQU 14
CACR060B_FIC                        EQU 13

; Tastatur
keyboard_keycode_I                  EQU $17
keyboard_keycode_A                  EQU $20
keyboard_keycode_G                  EQU $24
keyboard_keycode_M                  EQU $37
keyboard_keycode_SPACE_BAR          EQU $40
keyboard_keycode_RETURN             EQU $44
keyboard_keycode_ESC                EQU $45
keyboard_keycode_CURS_DOWN          EQU $4d
keyboard_keycode_CURS_RIGHT         EQU $4e
keyboard_keycode_CURS_LEFT          EQU $4f
keyboard_keycode_CURS_UP            EQU $4c
keyboard_keycode_F1                 EQU $50
keyboard_keycode_F2                 EQU $51
keyboard_keycode_F3                 EQU $52
keyboard_keycode_F4                 EQU $53
keyboard_keycode_F5                 EQU $54
keyboard_keycode_F6                 EQU $55
keyboard_keycode_F7                 EQU $56
keyboard_keycode_F8                 EQU $57
keyboard_keycode_F9                 EQU $58
keyboard_keycode_F10                EQU $59

; **** Display ****
color_clock_speed                   EQU 280
lores_pixel_speed                   EQU 140
hires_pixel_speed                   EQU 70
shires_pixel_speed                  EQU 35
pixel_per_line_min                  EQU 64
DMA_slot_period                     EQU color_clock_speed/lores_pixel_speed
CMOVE_slot_period                   EQU DMA_slot_period*4
CWAIT_slot_period                   EQU DMA_slot_period*6
cl_x_wrap                           EQU $1c0
cl_x_wrap_6_bitplanes_1x            EQU $1be
cl_x_wrap_7_bitplanes_1x            EQU $1b6
cl_x_wrap_7_bitplanes_2x            EQU $1b6
cl_y_wrap                           EQU $ff

HSTART_128_pixel_right_aligned      EQU $141
HSTART_128_pixel                    EQU $e1
HSTART_144_pixel_right_aligned      EQU $111
HSTART_144_pixel                    EQU $d9
HSTART_160_pixel_right_aligned      EQU $121
HSTART_160_pixel                    EQU $d1
HSTART_176_pixel_right_aligned      EQU $111
HSTART_176_pixel                    EQU $c9
HSTART_192_pixel_right_aligned      EQU $101
HSTART_192_pixel                    EQU $c1
HSTART_224_pixel_right_aligned      EQU $e1
HSTART_224_pixel                    EQU $b1
HSTART_240_pixel_right_aligned      EQU $d1
HSTART_240_pixel                    EQU $a9
HSTART_256_pixel_right_aligned      EQU $c1
HSTART_256_pixel                    EQU $a1
HSTART_320_pixel                    EQU $81
HSTART_352_pixel                    EQU $71
HSTART_overscan                     EQU $5b
HSTART_40_chunky_pixel              EQU $81
HSTART_44_chunky_pixel              EQU $67
HSTART_46_chunky_pixel              EQU $5b
HSTART_47_chunky_pixel              EQU $5b

HSTOP_64_pixel_left_aligned         EQU $c1
HSTOP_128_pixel_left_aligned        EQU $101
HSTOP_128_pixel                     EQU $161
HSTOP_144_pixel_left_aligned        EQU $111
HSTOP_144_pixel                     EQU $169
HSTOP_160_pixel_left_aligned        EQU $121
HSTOP_160_pixel                     EQU $171
HSTOP_176_pixel_left_aligned        EQU $131
HSTOP_176_pixel                     EQU $179
HSTOP_192_pixel_left_aligned        EQU $141
HSTOP_192_pixel                     EQU $181
HSTOP_224_pixel_left_aligned        EQU $161
HSTOP_224_pixel                     EQU $191
HSTOP_240_pixel_left_aligned        EQU $171
HSTOP_240_pixel                     EQU $199
HSTOP_256_pixel_left_aligned        EQU $181
HSTOP_256_pixel                     EQU $1a1
HSTOP_320_pixel                     EQU $1c1
HSTOP_352_pixel                     EQU $1d1
HSTOP_overscan                      EQU $1d3
HSTOP_40_chunky_pixel               EQU $1c1
HSTOP_44_chunky_pixel               EQU $1c7
HSTOP_46_chunky_pixel               EQU $1c7
HSTOP_47_chunky_pixel               EQU $1d3

VSTART_64_lines                     EQU $8c
VSTART_80_lines                     EQU $84
VSTART_128_lines                    EQU $6c
VSTART_144_lines                    EQU $64
VSTART_160_lines                    EQU $5c
VSTART_176_lines                    EQU $54
VSTART_192_lines                    EQU $4c
VSTART_200_lines                    EQU $48
VSTART_208_lines                    EQU $44
VSTART_224_lines                    EQU $3c
VSTART_240_lines                    EQU $34
VSTART_256_lines                    EQU $2c
VSTART_272_lines                    EQU $24
VSTART_overscan_PAL                 EQU $1d
VSTART_overscan_NTSC                EQU $15

VSTOP_64_lines                      EQU $cc
VSTOP_80_lines                      EQU $d4
VSTOP_128_lines                     EQU $ec
VSTOP_144_lines                     EQU $f4
VSTOP_160_lines                     EQU $fc
VSTOP_176_lines                     EQU $104
VSTOP_192_lines                     EQU $10c
VSTOP_NTSC                          EQU $f4
VSTOP_200_lines                     EQU $110
VSTOP_208_lines                     EQU $114
VSTOP_overscan_NTSC                 EQU $106
VSTOP_224_lines                     EQU $11c
VSTOP_240_lines                     EQU $124
VSTOP_256_lines                     EQU $12c
VSTOP_272_lines                     EQU $134
VSTOP_overscan_PAL                  EQU $138

HTOTAL_lores_15k                    EQU 320
HTOTAL_overscan_lores_15k           EQU 368
HTOTAL_hires_15k                    EQU 640
HTOTAL_overscan_hires_15k           EQU 736

VTOTAL_PAL                          EQU 256
VTOTAL_overscan_PAL                 EQU 283
VTOTAL_NTSC                         EQU 200
VTOTAL_overscan_NTSC                EQU 216

DDFSTART_32_pixel_right_aligned_2x  EQU $c8
DDFSTART_64_pixel_right_aligned_4x  EQU $b8
DDFSTART_128_pixel_right_aligned    EQU $98
DDFSTART_128_pixel_1x               EQU $68
DDFSTART_128_pixel_2x               EQU $58
DDFSTART_144_pixel_right_aligned_1x EQU $90
DDFSTART_160_pixel_1x               EQU $60
DDFSTART_160_pixel_2x               EQU $58
DDFSTART_192_pixel_right_aligned    EQU $70
DDFSTART_192_pixel_1x               EQU $58
DDFSTART_192_pixel_2x               EQU $58
DDFSTART_192_pixel_4x               EQU $58
DDFSTART_224_pixel_1x               EQU $48
DDFSTART_224_pixel_2x               EQU $48
DDFSTART_256_pixel_right_aligned    EQU $58
DDFSTART_256_pixel_1x               EQU $48
DDFSTART_256_pixel_2x               EQU $48
DDFSTART_512_pixel_right_aligned    EQU $58
DDFSTART_512_pixel_4x               EQU $48
DDFSTART_320_pixel                  EQU $38
DDFSTART_640_pixel_1x               EQU $3c
DDFSTART_640_pixel_2x               EQU $3c
DDFSTART_640_pixel_4x               EQU $38
DDFSTART_1280_pixel_4x              EQU $38
DDFSTART_overscan_16_pixel          EQU $30
DDFSTART_overscan_32_pixel          EQU $28
DDFSTART_overscan_48_pixel          EQU $20
DDFSTART_overscan_64_pixel          EQU $18

DDFSTOP_standard_min                EQU $40
DDFSTOP_32_pixel_left_aligned_2x    EQU $40
DDFSTOP_64_pixel_left_aligned_4x    EQU $40
DDFSTOP_128_pixel_left_aligned_1x   EQU $70
DDFSTOP_128_pixel_left_aligned_2x   EQU $58
DDFSTOP_128_pixel_left_aligned_4x   EQU $40
DDFSTOP_128_pixel_1x                EQU $90
DDFSTOP_128_pixel_2x                EQU $80
DDFSTOP_144_pixel_left_aligned_1x   EQU $78
DDFSTOP_160_pixel_1x                EQU $a8
DDFSTOP_160_pixel_2x                EQU $90
DDFSTOP_176_pixel_left_aligned_1x   EQU $88
DDFSTOP_192_pixel_left_aligned_1x   EQU $90
DDFSTOP_192_pixel_left_aligned_2x   EQU $88
DDFSTOP_192_pixel_left_aligned_4x   EQU $60
DDFSTOP_192_pixel_1x                EQU $b0
DDFSTOP_192_pixel_2x                EQU $a0
DDFSTOP_192_pixel_4x                EQU $80
DDFSTOP_224_pixel_1x                EQU $b8
DDFSTOP_224_pixel_2x                EQU $b8
DDFSTOP_256_pixel_left_aligned_1x   EQU $b0
DDFSTOP_256_pixel_left_aligned_2x   EQU $a0
DDFSTOP_256_pixel_left_aligned_4x   EQU $80
DDFSTOP_256_pixel_1x                EQU $c0
DDFSTOP_256_pixel_2x                EQU $a0
DDFSTOP_320_pixel_1x                EQU $d0
DDFSTOP_320_pixel_2x                EQU $c0
DDFSTOP_320_pixel_4x                EQU $a0
DDFSTOP_512_pixel_left_aligned_1x   EQU $b0
DDFSTOP_512_pixel_left_aligned_2x   EQU $a8
DDFSTOP_512_pixel_left_aligned_4x   EQU $a0
DDFSTOP_640_pixel_1x                EQU $d4
DDFSTOP_640_pixel_2x                EQU $d0
DDFSTOP_640_pixel_4x                EQU $c0
DDFSTOP_1280_pixel_4x               EQU $d0
DDFSTOP_overscan_16_pixel           EQU $d8
DDFSTOP_overscan_32_pixel           EQU $c8
DDFSTOP_overscan_64_pixel           EQU $c0
DDFSTOP_overscan_16_pixel_min       EQU $38
DDFSTOP_overscan_32_pixel_min       EQU $30
DDFSTOP_overscan_48_pixel_min       EQU $28
DDFSTOP_overscan_64_pixel_min       EQU $20

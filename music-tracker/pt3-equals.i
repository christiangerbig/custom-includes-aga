; **** PT3-Replay ****
pt_maxsongpos	 	 	EQU 128
pt_maxpattpos	 	 	EQU 64
pt_pattsize	 	 	EQU 1024
pt_chansnum	 	 	EQU 4
pt_samplesnum	 	 	EQU 31
pt_cmdpermask	 	 	EQU $0fff
pt_cmdmask	 	 	EQU $0f
pt_ecmdmask	 	 	EQU $0ff0

pt_defaultticks	 	 	EQU 6
pt_minticks	 	 	EQU 0
pt_maxticks	 	 	EQU 31
pt_defaultbpm	 	 	EQU 125
pt_minbpm	 	 	EQU 32
pt_maxbpm	 	 	EQU 255
pt_pal125bpmrate	 	EQU 1773447 ; = 0,709379 MHz * [(20000 µs * 125 BPM)]
pt_ntsc125bpmrate	 	EQU 1789773 ; = 0,715909 MHz * [(20000 µs * 125 BPM)]

pt_arpdiv	 	 	EQU 3
pt_periodsnum	 	 	EQU 36
pt_portminper	 	 	EQU 113 ; Note period "B-3"
pt_portmaxper	 	 	EQU 856 ; Note period "C-1"
pt_finetunenum	 	 	EQU 16
pt_minvol	 	 	EQU 0
pt_maxvol	 	 	EQU 64
pt_wavetypemask	 	 	EQU $03
pt_wavesine	 	 	EQU 0
pt_waverampdown	 	 	EQU 1
pt_wavesquare	 	 	EQU 2
pt_wavenoretrig	 	 	EQU 4
pt_vibnoretrigbit	 	EQU 2
pt_trenoretrigbit	 	EQU 6
pt_maxloopcount	 	 	EQU $7fff
pt_metronote	 	 	EQU 214 ; Note period "C-3"
pt_metrosamplenum	 	EQU 31
pt_metronoteinfo	 	EQU ((pt_metrosamplenum&NIBBLE_MASK_HIGH)<<24)+(pt_metronote<<16)+((pt_metrosamplenum&NIBBLE_MASK_LOW)<<8*NIBBLE_SHIFT)

pt_cmdarpeggio	 	 	EQU 0
pt_cmdportup	 	 	EQU 1
pt_cmdportdown	 	 	EQU 2
pt_cmdtoneport	 	 	EQU 3
pt_cmdvibrato	 	 	EQU 4
pt_cmdtoneportvolslide	 	EQU 5
pt_cmdvibratovolslide	 	EQU 6
pt_cmdtremolo	 	 	EQU 7
pt_cmdnotused	 	 	EQU 8
pt_cmdsetsampleoffset	 	EQU 9
pt_cmdvolslide	 	 	EQU $a
pt_cmdposjump	 	 	EQU $b
pt_cmdsetvolume	 	 	EQU $c
pt_cmdpattbreak	 	 	EQU $d
pt_cmdextended	 	 	EQU $e
pt_cmdsetspeed	 	 	EQU $f
pt_ecmdsetfilter	 	EQU 0
pt_ecmdfineportup	 	EQU 1
pt_ecmdfineportdown	 	EQU 2
pt_ecmdsetglisscontrol	 	EQU 3
pt_ecmdsetvibwaveform	 	EQU 4
pt_ecmdsetsamplefinetune	EQU 5
pt_ecmdjumptoloop	 	EQU 6
pt_ecmdsettrewaveform	 	EQU 7
pt_ecmdkarplusstrong	 	EQU 8
pt_ecmdretrignote	 	EQU 9
pt_ecmdfinevolslideup	 	EQU $a
pt_ecmdfinevolslidedown	 	EQU $b
pt_ecmdnotecut	 	 	EQU $c
pt_ecmdnotedelay	 	EQU $d
pt_ecmdpattdelay	 	EQU $e
pt_ecmdinvertloop	 	EQU $f

pt_cmdbitarpeggio	 	EQU %0000000000000001
pt_cmdbitportup	 	 	EQU %0000000000000010
pt_cmdbitportdown	 	EQU %0000000000000100
pt_cmdbittoneport	 	EQU %0000000000001000
pt_cmdbitvibrato	 	EQU %0000000000010000
pt_cmdbittoneportvolslide	EQU %0000000000100000
pt_cmdbitvibratovolslide	EQU %0000000001000000
pt_cmdbittremolo	 	EQU %0000000010000000
pt_cmdbitnotused	 	EQU %0000000100000000
pt_cmdbitsetsampleoffset	EQU %0000001000000000
pt_cmdbitvolslide	 	EQU %0000010000000000
pt_cmdbitposjump	 	EQU %0000100000000000
pt_cmdbitsetvolume	 	EQU %0001000000000000
pt_cmdbitpattbreak	 	EQU %0010000000000000
pt_cmdbitextended	 	EQU %0100000000000000
pt_cmdbitsetspeed	 	EQU %1000000000000000
pt_ecmdbitsetfilter	 	EQU %0000000000000001
pt_ecmdbitfineportup	 	EQU %0000000000000010
pt_ecmdbitfineportdown	 	EQU %0000000000000100
pt_ecmdbitsetglisscontrol	EQU %0000000000001000
pt_ecmdbitsetvibwaveform	EQU %0000000000010000
pt_ecmdbitsetsamplefinetune	EQU %0000000000100000
pt_ecmdbitjumptoloop	 	EQU %0000000001000000
pt_ecmdbitsettrewaveform	EQU %0000000010000000
pt_ecmdbitkarplusstrong	 	EQU %0000000100000000
pt_ecmdbitretrignote	 	EQU %0000001000000000
pt_ecmdbitfinevolslideup	EQU %0000010000000000
pt_ecmdbitfinevolslidedown	EQU %0000100000000000
pt_ecmdbitnotecut	 	EQU %0001000000000000
pt_ecmdbitnotedelay	 	EQU %0010000000000000
pt_ecmdbitpattdelay	 	EQU %0100000000000000
pt_ecmdbitinvertloop	 	EQU %1000000000000000

pt_allusedfx	 	 	EQU %1111111011111111
pt_allusedefx	 	 	EQU %1111111111111111

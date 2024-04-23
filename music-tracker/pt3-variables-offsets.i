pt_SongDataPointer         RS.L 1
  IFEQ pt_split_module
pt_SamplesDataPointer      RS.L 1
  ENDC
pt_125BPMrate              RS.L 1
pt_Counter                 RS.W 1
pt_CurrSpeed               RS.W 1
pt_DMACONtemp              RS.W 1
pt_ActiveChannels          RS.W 1
pt_PatternPointer          RS.L 1
pt_PatternPosition         RS.W 1
pt_SongPosition            RS.W 1
;--> E9 "Retrig Note" or ED "Note Delay" <--
  IFNE pt_usedefx&(pt_ecmdbitretrignote+pt_ecmdbitnotedelay)
pt_RtnDMACONtemp           RS.W 1
  ENDC
  IFEQ pt_music_fader
pt_fade_out_music_state    RS.W 1
pt_fade_out_delay_counter  RS.W 1
pt_master_volume           RS.W 1
  ENDC
  IFEQ pt_metronome
pt_MetroSpeed              RS.B 1
pt_MetroChannel            RS.B 1
  ENDC
pt_SongLength              RS.B 1
pt_SetAllChanDMAFlag       RS.B 1
pt_InitAllChanLoopDataFlag RS.B 1
pt_PBreakPosition          RS.B 1
pt_PosJumpFlag             RS.B 1
  IFNE pt_usedefx&(pt_ecmdfineportup+pt_ecmdfineportdown)
pt_LowMask                 RS.B 1
  ENDC
;--> E6 "Jump to Loop" <--
  IFNE pt_usedefx&pt_ecmdbitjumptoloop
pt_PBreakFlag              RS.B 1
  ENDC
;--> EE "Pattern Delay" <--
  IFNE pt_usedefx&pt_ecmdbitpattdelay
pt_PattDelayTime           RS.B 1
pt_PattDelayTime2          RS.B 1
  ENDC

; ** PT SampleInfo structure **
  RSRESET

pt_sampleinfo      RS.B 0

pt_si_samplename   RS.B 22   ;Sample's name padded with null bytes ,"#" at the beginning indicates a message
pt_si_samplelength RS.W 1    ;Sample length in words
pt_si_finetune     RS.B 1    ;Bits 7-4 not used, bits 3-0 finetune value as signed 4 bit number
pt_si_volume       RS.B 1    ;Bit 7 not used, bits 6-0 sample volume 0..64
pt_si_repeatpoint  RS.W 1    ;Start of sample repeat offset in words
pt_si_repeatlength RS.W 1    ;Length of sample repeat in words

pt_sampleinfo_size RS.B 0


; ** PT SongData structure **
  RSRESET

pt_songdata        RS.B 0

pt_sd_songname     RS.B 20   ;Song's name padded with null bytes
pt_sd_sampleinfo   RS.B pt_sampleinfo_size*pt_samplesnum ;Pointer to 1st sampleinfo, structure repeated for each sample 1-31
pt_sd_numofpatt    RS.B 1    ;Number of song positions 1..128
pt_sd_restartpos   RS.B 1    ;Restart position for Noisetracker and Startrekker not used by PT, set to 127
pt_sd_pattpos      RS.B 128  ;Pattern positions table 0..127
pt_sd_id           RS.B 4    ;"M.K." = (4 channels, 31 samples, 64 pattern positions) or "M!K!" (4 channels, 31 Samples, 100 patterns)
pt_sd_patterndata  RS.B 0    ;Pointer to 1st pattern, structure repeated for each pattern 1..64 times

pt_songdata_size   RS.B 0


; ** PT NoteInfo structure **
  RSRESET

pt_noteinfo      RS.B 0

pt_ni_note       RS.W 1      ;Bits 15-12 upper nibble of sample number, bits 11-0 note period
pt_ni_cmd        RS.B 1      ;Bits 7-4 lower nibble of sample number, bits 3-0 effect command number
pt_ni_cmdlo      RS.B 1      ;Bits 7-0 effect command data / bits 7-4 effect e-command number, bits 3-0 effect e-command data

pt_noteinfo_size RS.B 0


; ** PT PatternPositionData structure **
  RSRESET

pt_pattposdata       RS.B 0

pt_ppd_chan1noteinfo RS.B pt_noteinfo_size ;Note info for each audio channel 1..4 is stored successive
pt_ppd_chan2noteinfo RS.B pt_noteinfo_size
pt_ppd_chan3noteinfo RS.B pt_noteinfo_size
pt_ppd_chan4noteinfo RS.B pt_noteinfo_size

pt_pattposdata_size  RS.B 0


; ** PT PatternData structure **
  RSRESET

pt_patterndata      RS.B 0

pt_pd_data          RS.B pt_pattposdata_size*pt_maxpattpos ;Repeated 64 times (standard PT) or upto 100 times (PT 2.3a)

pt_patterndata_size RS.B 0

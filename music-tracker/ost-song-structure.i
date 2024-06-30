; ** OST SampleInfo structure **
  RSRESET

ost_sampleinfo      RS.B 0

ost_si_samplename   RS.B 22  ;Sample's name padded with null bytes
ost_si_samplelength RS.W 1   ;Sample length in words
ost_si_volume       RS.W 1   ;Bits 15-7 not used, bits 6-0 sample volume 0..64
ost_si_repeatpoint  RS.W 1   ;Start of sample repeat offset in bytes
ost_si_repeatlength RS.W 1   ;Length of sample repeat in words

ost_sampleinfo_size RS.B 0


; ** OST SongData structure **
  RSRESET

ost_songdata       RS.B 0

ost_sd_songname    RS.B 20   ;Song's name padded with null bytes
ost_sd_sampleinfo  RS.B ost_sampleinfo_size*ost_samplesnum ;Pointer to 1st sampleinfo, structure repeated for each sample 1-15
ost_sd_numofpatt   RS.B 1    ;Number of song positions 1..128
ost_sd_songspeed   RS.B 1    ;Default song speed 120 BPM is ignored
ost_sd_pattpos     RS.B 128  ;Pattern positions table 0..127
ost_sd_patterndata RS.B 0    ;Pointer to 1st pattern, structure repeated for each pattern 1..64 times

ost_songdata_size  RS.B 0


; ** OST NoteInfo structure **
  RSRESET

ost_noteinfo      RS.B 0

ost_ni_note       RS.W 1     ;Bits 15-12 not used, bits 11-0 noteperiod
ost_ni_cmd        RS.B 1     ;Bits 7-4 sample number, bits 3-0 effect command number
ost_ni_cmdlo      RS.B 1     ;Bits 7-0 effect command data

ost_noteinfo_size RS.B 0


; ** OST PatternPositionData structure **
  RSRESET

ost_pattposdata       RS.B 0

ost_ppd_chan1noteinfo RS.B ost_noteinfo_size ;Note info for each audio channel 1..4 is stored successive
ost_ppd_chan2noteinfo RS.B ost_noteinfo_size
ost_ppd_chan3noteinfo RS.B ost_noteinfo_size
ost_ppd_chan4noteinfo RS.B ost_noteinfo_size

ost_pattposdata_size  RS.B 0


; ** OST PatternData structure **
  RSRESET

ost_patterndata      RS.B 0

ost_pd_data          RS.B ost_pattposdata_size*ost_maxpattpos ;Repeated 64 times

ost_patterndata_size RS.B 0

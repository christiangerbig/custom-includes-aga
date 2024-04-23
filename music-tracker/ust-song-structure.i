; ** UST SampleInfo structure **
; ------------------------------
  RSRESET

ust_sampleinfo      RS.B 0

ust_si_samplename   RS.B 22  ;Sample's name padded with null bytes
ust_si_samplelength RS.W 1   ;Sample length in words
ust_si_volume       RS.W 1   ;Bits 15-7 not used, bits 6-0 sample volume 0..64
ust_si_repeatpoint  RS.W 1   ;Start of sample repeat offset in bytes
ust_si_repeatlength RS.W 1   ;Length of sample repeat in words

ust_sampleinfo_SIZE RS.B 0


; ** UST SongData structure **
; ----------------------------
  RSRESET

ust_songdata       RS.B 0

ust_sd_songname    RS.B 20   ;Song's name padded with null bytes
ust_sd_sampleinfo  RS.B ust_sampleinfo_SIZE*ust_samplesnum ;Pointer to 1st sampleinfo, structure repeated for each sample 1-15
ust_sd_numofpatt   RS.B 1    ;Number of song positions 1..128
ust_sd_songspeed   RS.B 1    ;Song speed 0..220 BPM, default 120 BPM
ust_sd_pattpos     RS.B 128  ;Pattern positions table 0..127
ust_sd_patterndata RS.B 0    ;Pointer to 1st pattern, structure repeated for each pattern 1..64 times

ust_songdata_SIZE  RS.B 0


; ** UST NoteInfo structure **
; ----------------------------
  RSRESET

ust_noteinfo      RS.B 0

ust_ni_note       RS.W 1     ;Bits 15-12 not used, bits 11-0 noteperiod
ust_ni_cmd        RS.B 1     ;Bits 7-4 sample number, bits 3-0 effect command number
ust_ni_cmdlo      RS.B 1     ;Bits 7-0 effect command data

ust_noteinfo_SIZE RS.B 0


; ** UST PatternPositionData structure **
; ---------------------------------------
  RSRESET

ust_pattposdata       RS.B 0

ust_ppd_chan1noteinfo RS.B ust_noteinfo_SIZE ;Note info for each audio channel 1..4 is stored successive
ust_ppd_chan2noteinfo RS.B ust_noteinfo_SIZE
ust_ppd_chan3noteinfo RS.B ust_noteinfo_SIZE
ust_ppd_chan4noteinfo RS.B ust_noteinfo_SIZE

ust_pattposdata_SIZE  RS.B 0


; ** UST PatternData structure **
; -------------------------------
  RSRESET

ust_patterndata      RS.B 0

ust_pd_data          RS.B ust_pattposdata_SIZE*ust_maxpattpos ;Repeated 64 times

ust_patterndata_SIZE RS.B 0

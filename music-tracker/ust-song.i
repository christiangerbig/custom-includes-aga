	RSRESET

ust_sampleinfo			RS.B 0

ust_si_samplename		RS.B 22	; name padded with null bytes
ust_si_samplelength		RS.W 1	; sample length in words
ust_si_volume			RS.W 1	; bits 0..6 sample volume [0..64]
ust_si_repeatpoint		RS.W 1	; start of sample repeat offset in bytes
ust_si_repeatlength		RS.W 1	; length of sample repeat in words

ust_sampleinfo_size		RS.B 0


	RSRESET

ust_songdata			RS.B 0

ust_sd_songname			RS.B 20	; song's name padded with null bytes
ust_sd_sampleinfo		RS.B ust_sampleinfo_size*ust_samplesnum ; 1st sampleinfo structure repeated 15 times
ust_sd_numofpatt		RS.B 1	; number of song positions [1..128]
ust_sd_songspeed		RS.B 1	; song speed [0..220] BPM, default 120 BPM
ust_sd_pattpos			RS.B 128 ; pattern positions table [0..127]
ust_sd_patterndata		RS.B 0	; 1st pattern structure, repeated for each pattern [1..64] times

ust_songdata_size		RS.B 0


	RSRESET

ust_noteinfo			RS.B 0

ust_ni_note			RS.W 1	; bits 0..11 noteperiod
ust_ni_cmd			RS.B 1	; bits 0..3 effect command number, bits 4-7 sample number
ust_ni_cmdlo			RS.B 1	; bits 0..7 effect command data

ust_noteinfo_size		RS.B 0


	RSRESET

ust_pattposdata			RS.B 0

ust_ppd_chan1noteinfo		RS.B ust_noteinfo_size ; note info for each audio channel [1..4] is stored successive
ust_ppd_chan2noteinfo		RS.B ust_noteinfo_size
ust_ppd_chan3noteinfo		RS.B ust_noteinfo_size
ust_ppd_chan4noteinfo		RS.B ust_noteinfo_size

ust_pattposdata_size		RS.B 0


	RSRESET

ust_patterndata			RS.B 0

ust_pd_data			RS.B ust_pattposdata_size*ust_maxpattpos ; repeated 64 times

ust_patterndata_size		RS.B 0

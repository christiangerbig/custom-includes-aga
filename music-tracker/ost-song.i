ost_songname_size		EQU 20
ost_samplename_size		EQU 22
ost_pattpos_size			EQU 128


	RSRESET

ost_sampleinfo			RS.B 0

ost_si_samplename		RS.B ost_samplename_size ; name padded with null bytes
ost_si_samplelength		RS.W 1	; sample length in words
ost_si_volume			RS.W 1	; bits 0..6 sample volume [0..64]
ost_si_repeatpoint		RS.W 1	; start of sample repeat offset in bytes
ost_si_repeatlength		RS.W 1	; length of sample repeat in words

ost_sampleinfo_size		RS.B 0


	RSRESET

ost_songdata			RS.B 0

ost_sd_songname			RS.B ost_songname_size ; name padded with null bytes
ost_sd_sampleinfo		RS.B ost_sampleinfo_size*ost_samplesnum ; 1st sampleinfo structure repeated 15 times
ost_sd_numofpatt		RS.B 1	; number of song positions [1..128]
ost_sd_songspeed		RS.B 1	; default song speed 120 BPM is ignored
ost_sd_pattpos			RS.B ost_pattpos_size ; pattern positions table
ost_sd_patterndata		RS.B 0	; 1st pattern structure, repeated for each pattern [1..64] times

ost_songdata_size		RS.B 0


	RSRESET

ost_noteinfo			RS.B 0

ost_ni_note			RS.W 1	; bits 0..11 noteperiod
ost_ni_cmd			RS.B 1	; bits 0..3 effect command number, bits 4-7 sample number
ost_ni_cmdlo			RS.B 1	; bits 0..7 effect command data

ost_noteinfo_size		RS.B 0


	RSRESET

ost_pattposdata			RS.B 0

ost_ppd_chan1noteinfo		RS.B ost_noteinfo_size ; note info for each audio channel [1..4] is stored successive
ost_ppd_chan2noteinfo		RS.B ost_noteinfo_size
ost_ppd_chan3noteinfo		RS.B ost_noteinfo_size
ost_ppd_chan4noteinfo		RS.B ost_noteinfo_size

ost_pattposdata_size		RS.B 0


	RSRESET

ost_patterndata			RS.B 0

ost_pd_data			RS.B ost_pattposdata_size*ost_maxpattpos ; repeated 64 times

ost_patterndata_size		RS.B 0

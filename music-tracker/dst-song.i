dst_songname_size		EQU 20
dst_samplename_size		EQU 22
dst_pattpos_size		EQU 128


	RSRESET

dst_sampleinfo			RS.B 0

dst_si_samplename		RS.B dst_samplename_size ; name padded with null bytes
dst_si_samplelength		RS.W 1	; length in words
dst_si_volume			RS.W 1	; bits 0..6 sample volume [0..64]
dst_si_repeatpoint		RS.W 1	; start of sample repeat offset in bytes
dst_si_repeatlength		RS.W 1	; length of sample repeat in words

dst_sampleinfo_size		RS.B 0


	RSRESET

dst_songdata			RS.B 0

dst_sd_songname			RS.B dst_songname_size ; name padded with null bytes
dst_sd_sampleinfo		RS.B dst_sampleinfo_size*dst_samplesnumber ; 1st sampleinfo structure repeated 15 times
dst_sd_numofpatt		RS.B 1	; number of song positions [1..128]
dst_sd_songspeed		RS.B 1	; song speed [0..220] BPM, default 120 BPM
dst_sd_pattpos			RS.B dst_pattpos_size ; pattern positions table
dst_sd_patterndata		RS.B 0	; 1st pattern structure repeated for each pattern [1..64] times

dst_songdata_size		RS.B 0


	RSRESET

dst_noteinfo			RS.B 0

dst_ni_note			RS.W 1	; bits 0..11 note period
dst_ni_cmd			RS.B 1	; bits 0..3 effect command number, bits 4-7 sample number
dst_ni_cmdlo			RS.B 1	; bits 0..7 effect command data

dst_noteinfo_size		RS.B 0


	RSRESET

dst_pattposdata			RS.B 0

dst_ppd_chan1noteinfo		RS.B dst_noteinfo_size ; note info for each audio channel [1..4] is stored successive
dst_ppd_chan2noteinfo		RS.B dst_noteinfo_size
dst_ppd_chan3noteinfo		RS.B dst_noteinfo_size
dst_ppd_chan4noteinfo		RS.B dst_noteinfo_size

dst_pattposdata_size		RS.B 0


	RSRESET

dst_patterndata			RS.B 0

dst_pd_data			RS.B dst_pattposdata_size*dst_maxpattpos ; repeated 64 times

dst_patterndata_size		RS.B 0

	RSRESET

pt_sampleinfo			RS.B 0

pt_si_samplename		RS.B 22	; name padded with null bytes, "#" at the beginning indicates a message
pt_si_samplelength		RS.W 1	; sample length in words
pt_si_finetune			RS.B 1	; bits 0..3 finetune value as signed 4 bit number
pt_si_volume			RS.B 1	; bits 0..6 sample volume [0..64]
pt_si_repeatpoint		RS.W 1	; start of sample repeat offset in words
pt_si_repeatlength		RS.W 1	; length of sample repeat in words

pt_sampleinfo_size		RS.B 0


	RSRESET

pt_songdata			RS.B 0

pt_sd_songname			RS.B 20	; name padded with null bytes
pt_sd_sampleinfo		RS.B pt_sampleinfo_size*pt_samplesnum ; 1st sampleinfo structure repeated 31 times
pt_sd_numofpatt			RS.B 1	; number of song positions [1..128]
pt_sd_restartpos		RS.B 1	; restart position for Noisetracker and Startrekker not used by Protracker, set to 127
pt_sd_pattpos			RS.B 128 ; pattern positions table [0..127]
pt_sd_id			RS.B 4	; string "M.K." = 4 channels, 31 samples, 64 pattern positions or string "M!K!" = 4 channels, 31 Samples, 100 patterns
pt_sd_patterndata		RS.B 0	; 1st pattern structure, repeated for each pattern [1..64] times

pt_songdata_size		RS.B 0


	RSRESET

pt_noteinfo			RS.B 0

pt_ni_note			RS.W 1	; bits 0..11 note period, bits 12-15 high nibble of sample number
pt_ni_cmd			RS.B 1	; bits 0..3 effect command number, bits 4-7 low nibble of sample number
pt_ni_cmdlo			RS.B 1	; bits 0..3 effect e-command data, bits 4-7 effect e-command number

pt_noteinfo_size		RS.B 0


	RSRESET

pt_pattposdata			RS.B 0

pt_ppd_chan1noteinfo		RS.B pt_noteinfo_size ; note info for each audio channel [1..4] is stored successive
pt_ppd_chan2noteinfo		RS.B pt_noteinfo_size
pt_ppd_chan3noteinfo		RS.B pt_noteinfo_size
pt_ppd_chan4noteinfo		RS.B pt_noteinfo_size

pt_pattposdata_size		RS.B 0


	RSRESET

pt_patterndata			RS.B 0

pt_pd_data			RS.B pt_pattposdata_size*pt_maxpattpos ; repeated 64 times (standard Protracker) or upto 100 times (PT 2.3a)

pt_patterndata_size		RS.B 0

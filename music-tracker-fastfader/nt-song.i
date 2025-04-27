	RSRESET

nt_sampleinfo			RS.B 0

nt_si_samplename		RS.B 22	; name padded with null bytes
nt_si_samplelength		RS.W 1	; length in bytes or words
nt_si_volume			RS.W 1	; bits 0-6 sample volume [0..64]
nt_si_repeatpoint		RS.W 1	; start of sample repeat offset in words
nt_si_repeatlength 		RS.W 1	; length of sample repeat in words

nt_sampleinfo_size		RS.B 0


	RSRESET

nt_songdata			RS.B 0

nt_sd_songname			RS.B 20	; name padded with null bytes
nt_sd_sampleinfo		RS.B nt_sampleinfo_size*nt_samplesnum ; pointer 1st sampleinfo structure repeated 31 times
nt_sd_numofpatt		 	RS.B 1	; number of song positions [1..128]
nt_sd_restartpos		RS.B 1	; song restart position in pattern positions table [0..126]
nt_sd_pattpos			RS.B 128 ; pattern positions table [0..127]
nt_sd_id			RS.B 4	; string "M.K." = 4 channels, 31 samples, 64 patterns
nt_sd_patterndata		RS.B 0	; pointer 1st pattern structure, repeated for each pattern [1..64] times

nt_songdata_size		RS.B 0


	RSRESET

nt_noteinfo			RS.B 0

nt_ni_note			RS.W 1	; bits 0-11 note period, bits 12-15 upper nibble of sample number
nt_ni_cmd			RS.B 1	; bits 4-7 lower nibble of sample number, bits 3-0 effect command number
nt_ni_cmdlo			RS.B 1	; bits 0-3 effect e-command data, bits 4-7 effect e-command number

nt_noteinfo_size		RS.B 0


	RSRESET

nt_pattposdata			RS.B 0

nt_ppd_chan1noteinfo		RS.B nt_noteinfo_size ; note info for each audio channel [1..4] is stored successive
nt_ppd_chan2noteinfo		RS.B nt_noteinfo_size
nt_ppd_chan3noteinfo		RS.B nt_noteinfo_size
nt_ppd_chan4noteinfo		RS.B nt_noteinfo_size

nt_pattposdata_size		RS.B 0


	RSRESET

nt_patterndata			RS.B 0

nt_pd_data			RS.B nt_pattposdata_size*nt_maxpattpos ; repeated 64 times (standard PT) or upto 100 times (PT 2.3a)

nt_patterndata_size		RS.B 0

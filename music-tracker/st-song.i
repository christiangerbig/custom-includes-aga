	RSRESET

st_sampleinfo			RS.B 0

st_si_samplename		RS.B 22	; name padded with null bytes
st_si_samplelength		RS.W 1	; length in bytes or words
st_si_volume			RS.W 1	; bits 0-6 sample volume [0..64]
st_si_repeatpoint		RS.W 1	; start of sample repeat offset in bytes
st_si_repeatlength		RS.W 1	; length of sample repeat in words

st_sampleinfo_size RS.B 0


	RSRESET

st_songdata			RS.B 0

st_sd_songname			RS.B 20	; name padded with null bytes
st_sd_sampleinfo		RS.B st_sampleinfo_size*st_samplesnum ; 1st sampleinfo structure repeated 31 times
st_sd_numofpatt			RS.B 1	; number of song positions 1..128
st_sd_songspeed			RS.B 1	; default songspeed 120 BPM is ignored
st_sd_pattpos			RS.B 128 ; pattern positions table 0..127
st_sd_id			RS.B 4	; string "M.K." = 4 channels, 31 samples, 64 patterns
st_sd_patterndata		RS.B 0  ; 1st pattern structure repeated for each pattern [1..64] times

st_songdata_size		RS.B 0


	RSRESET

st_noteinfo			RS.B 0

st_ni_note			RS.W 1	; bits 0-11 note period, bits 12-15 high nibble of sample number
st_ni_cmd			RS.B 1	; bits 0-3 effect command number, bits 4-7 low nibble of sample number
st_ni_cmdlo			RS.B 1	; bits 0-3 effect e-command data, bits 4-7 effect e-command number

st_noteinfo_size		RS.B 0


	RSRESET

st_pattposdata			RS.B 0

st_ppd_chan1noteinfo		RS.B st_noteinfo_size ; note info for each audio channel [1..4] is stored successive
st_ppd_chan2noteinfo		RS.B st_noteinfo_size
st_ppd_chan3noteinfo		RS.B st_noteinfo_size
st_ppd_chan4noteinfo		RS.B st_noteinfo_size

st_pattposdata_size		RS.B 0


	RSRESET

st_patterndata			RS.B 0

st_pd_data			RS.B st_pattposdata_size*st_maxpattpos ; repeated 64 times

st_patterndata_size		RS.B 0

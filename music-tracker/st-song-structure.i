; ** ST SampleInfo structure **
 	RSRESET

st_sampleinfo			RS.B 0

st_si_samplename		RS.B 22	; Name padded with null bytes
st_si_samplelength		RS.W 1	; Length in bytes or words
st_si_volume			RS.W 1 	; Bits 0-6 sample volume [0..64]
st_si_repeatpoint		RS.W 1	; Start of sample repeat offset in bytes
st_si_repeatlength		RS.W 1	; Length of sample repeat in words

st_sampleinfo_size RS.B 0


; ** ST SongData structure **
	RSRESET

st_songdata			RS.B 0

st_sd_songname			RS.B 20	; Name padded with null bytes
st_sd_sampleinfo		RS.B st_sampleinfo_size*st_samplesnum ; Pointer to 1st sampleinfo, structure repeated for each sample 1-31
st_sd_numofpatt			RS.B 1	; Number of song positions 1..128
st_sd_songspeed			RS.B 1	; Default songspeed 120 BPM is ignored
st_sd_pattpos			RS.B 128 ; Pattern positions table 0..127
st_sd_id			RS.B 4	; String "M.K." = 4 channels, 31 samples, 64 patterns
st_sd_patterndata		RS.B 0  ; Pointer to 1st pattern structure, repeated for each pattern [1..64] times

st_songdata_size		RS.B 0


; ** ST NoteInfo structure **
	RSRESET

st_noteinfo			RS.B 0

st_ni_note			RS.W 1	; Bits 0-11 note period, bits 12-15 upper nibble of sample number
st_ni_cmd			RS.B 1	; Bits 0-3 effect command number, bits 4-7 lower nibble of sample number
st_ni_cmdlo			RS.B 1	; Bits 0-3 effect e-command data, bits 4-7 effect e-command number

st_noteinfo_size		RS.B 0


; ** ST PatternPositionData structure **
				RSRESET

st_pattposdata			RS.B 0

st_ppd_chan1noteinfo		RS.B st_noteinfo_size ; Note info for each audio channel [1..4] is stored successive
st_ppd_chan2noteinfo		RS.B st_noteinfo_size
st_ppd_chan3noteinfo		RS.B st_noteinfo_size
st_ppd_chan4noteinfo		RS.B st_noteinfo_size

st_pattposdata_size		RS.B 0


; ** ST PatternData structure **
	RSRESET

st_patterndata			RS.B 0

st_pd_data			RS.B st_pattposdata_size*st_maxpattpos ; Repeated 64 times (standard Protracker) or upto 100 times (PT 2.3a)

st_patterndata_size		RS.B 0

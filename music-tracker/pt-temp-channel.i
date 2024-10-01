; ** Temporary audio channel structure **
	RSRESET

n_audchantemp			RS.B 0

n_note				RS.W 1
n_cmd				RS.B 1
n_cmdlo				RS.B 1
n_start				RS.L 1
n_length			RS.W 1
n_period			RS.W 1
n_loopstart			RS.L 1
n_replen			RS.W 1
n_finetune			RS.B 1
n_volume			RS.B 1
n_dmabit			RS.W 1
n_toneportdirec			RS.B 1
n_toneportspeed			RS.B 1
n_wantedperiod			RS.W 1
n_vibratocmd			RS.B 1
n_vibratopos			RS.B 1
n_tremolocmd			RS.B 1
n_tremolopos			RS.B 1
n_wavecontrol			RS.B 1
n_glissinvert			RS.B 1
n_sampleoffset			RS.B 1
n_pattpos			RS.B 1
n_loopcount			RS.B 1
n_invertoffset			RS.B 1
n_wavestart			RS.L 1
n_reallength			RS.W 1
n_rtnsetchandma			RS.B 1
n_rtninitchanloop		RS.B 1

	IFEQ pt_track_periods_enabled
		RS_ALIGN_LONGWORD
n_current_start			RS.L 1
n_current_length		RS.W 1
n_current_period		RS.W 1
n_current_volume		RS.W 1
n_chan_data_position		RS.W 1
	ENDC

	IFEQ pt_track_volumes_enabled
n_note_trigger			RS.B 1
	ENDC

n_audchantemp_size		RS.B 0

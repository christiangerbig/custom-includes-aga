	IFEQ pt_finetune_enabled
		CNOP 0,4
pt_FtuPeriodTableStarts
		DS.L pt_finetunenum
	ENDC

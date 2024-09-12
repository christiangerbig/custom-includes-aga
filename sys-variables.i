; Datum:	10.09.2024
; Version:	2.3

	CNOP 0,4
variables			DS.B variables_size

	CNOP 0,4
_SysBase			DC.L 0
	IFND SYS_TAKEN_OVER
_DOSBase			DC.L 0
	ENDC
_GfxBase			DC.L 0
	IFND SYS_TAKEN_OVER
_IntuitionBase			DC.L 0
_CIABase			DC.L 0
		CNOP 0,4
exception_vecs_save		DS.B exception_vectors_size

		IFD PASS_GLOBAL_REFERENCES
			CNOP 0,4
global_references_table		DS.B global_references_size
		ENDC
	ENDC

	IFNE pf_extra_number
		CNOP 0,4
pf_extra_attributes		DS.B pf_extra_attribute_size*pf_extra_number
	ENDC

	IFNE spr_number
		IFNE spr_x_size1
			CNOP 0,4
sprite_attributes1		DS.B sprite_attributes_size*spr_number
		ENDC
		IFNE spr_x_size2
			CNOP 0,4
sprite_attributes2		DS.B sprite_attributes_size*spr_number
		ENDC
	ENDC
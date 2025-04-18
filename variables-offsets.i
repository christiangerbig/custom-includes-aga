	RSRESET

	IFND SYS_TAKEN_OVER
shell_parameters		RS.L 1
shell_parameters_length		RS.L 1


		IFEQ workbench_start_enabled
workbench_message		RS.L 1
		ENDC

		IFEQ text_output_enabled
output_handle			RS.L 1
		ENDC

raw_handle			RS.L 1
raw_buffer			RS.B 1

cpu_flags			RS.W 1
fast_memory_available		RS.W 1

	ELSE
		IFD PASS_GLOBAL_REFERENCES
			RS_ALIGN_LONGWORD
global_references_table		RS.L 1
		ENDC
	ENDC

custom_error_code		RS.W 1
	RS_ALIGN_LONGWORD
dos_return_code			RS.L 1

	IFND SYS_TAKEN_OVER
active_screen			RS.L 1
screen_mode			RS.L 1
pal_screen			RS.L 1
invisible_window		RS.L 1
mouse_pointer_data		RS.L 1
old_sprite_resolution		RS.L 1

		IFEQ screen_fader_enabled
sf_screen_color_table		RS.L 1
sf_screen_color_cache		RS.L 1
sfi_rgb32_active		RS.W 1
sfo_rgb32_active		RS.W 1
		ENDC

		IFNE cl1_size3
old_cop1lc			RS.L 1
		ENDC
		IFNE cl2_size3
old_cop2lc			RS.L 1
		ENDC

		IFD SAVE_BEAMCON0
old_beamcon0			RS.L 1
		ENDC

old_vbr				RS.L 1
		IFD ALL_CACHES
old_cacr			RS.L 1
		ENDC
		IFD NO_060_STORE_BUFFER
			IFND ALL_CACHES
old_cacr			RS.L 1
			ENDC
		ENDC

old_dmacon			RS.W 1
old_intena			RS.W 1
old_adkcon			RS.W 1

old_ciaa_pra			RS.B 1
old_ciaa_talo			RS.B 1
old_ciaa_tahi			RS.B 1
old_ciaa_tblo			RS.B 1
old_ciaa_tbhi			RS.B 1
old_ciaa_icr			RS.B 1
old_ciaa_cra			RS.B 1
old_ciaa_crb			RS.B 1

old_ciab_prb			RS.B 1
old_ciab_talo			RS.B 1
old_ciab_tahi			RS.B 1
old_ciab_tblo			RS.B 1
old_ciab_tbhi			RS.B 1
old_ciab_icr			RS.B 1
old_ciab_cra			RS.B 1
old_ciab_crb			RS.B 1

		RS_ALIGN_LONGWORD
tod_time			RS.L 1

	ENDC

	IFNE cl1_size1
cl1_construction1		RS.L 1
	ENDC
	IFNE cl1_size2
cl1_construction2		RS.L 1
	ENDC
	IFNE cl1_size3
cl1_display			RS.L 1
	ENDC

	IFNE cl2_size1
cl2_construction1		RS.L 1
	ENDC
	IFNE cl2_size2
cl2_construction2		RS.L 1
	ENDC
	IFNE cl2_size3
cl2_display			RS.L 1
	ENDC

	IFNE pf1_depth1
pf1_bitmap1			RS.L 1
	ENDC
	IFNE pf1_depth2
pf1_bitmap2			RS.L 1
	ENDC
	IFNE pf1_depth3
pf1_bitmap3			RS.L 1
	ENDC
	IFNE pf1_depth1
pf1_construction1		RS.L 1
	ENDC
	IFNE pf1_depth2
pf1_construction2		RS.L 1
	ENDC
	IFNE pf1_depth3
pf1_display			RS.L 1
	ENDC

	IFNE pf2_depth1
pf2_bitmap1			RS.L 1
	ENDC
	IFNE pf2_depth2
pf2_bitmap2			RS.L 1
	ENDC
	IFNE pf2_depth3
pf2_bitmap3			RS.L 1
	ENDC
	IFNE pf2_depth1
pf2_construction1		RS.L 1
	ENDC
	IFNE pf2_depth2
pf2_construction2		RS.L 1
	ENDC
	IFNE pf2_depth3
pf2_display			RS.L 1
	ENDC

	IFNE pf_extra_number
		IFGE pf_extra_number-1
pf_extra_bitmap1		RS.L 1
		ENDC
		IFGE pf_extra_number-2
pf_extra_bitmap2		RS.L 1
		ENDC
		IFGE pf_extra_number-3
pf_extra_bitmap3		RS.L 1
		ENDC
		IFGE pf_extra_number-4
pf_extra_bitmap4		RS.L 1
		ENDC
		IFGE pf_extra_number-5
pf_extra_bitmap5		RS.L 1
		ENDC
		IFGE pf_extra_number-6
pf_extra_bitmap6		RS.L 1
		ENDC
		IFGE pf_extra_number-7
pf_extra_bitmap7		RS.L 1
		ENDC
		IFGE pf_extra_number-8
pf_extra_bitmap8		RS.L 1
		ENDC
		IFGE pf_extra_number-1
extra_pf1			RS.L 1
		ENDC
		IFGE pf_extra_number-2
extra_pf2			RS.L 1
		ENDC
		IFGE pf_extra_number-3
extra_pf3			RS.L 1
		ENDC
		IFGE pf_extra_number-4
extra_pf4			RS.L 1
		ENDC
		IFGE pf_extra_number-5
extra_pf5			RS.L 1
		ENDC
		IFGE pf_extra_number-6
extra_pf6			RS.L 1
		ENDC
		IFGE pf_extra_number-7
extra_pf7			RS.L 1
		ENDC
		IFGE pf_extra_number-8
extra_pf8			RS.L 1
		ENDC
	ENDC

	IFNE spr_x_size1
spr0_bitmap1			RS.L 1
spr1_bitmap1			RS.L 1
spr2_bitmap1			RS.L 1
spr3_bitmap1			RS.L 1
spr4_bitmap1			RS.L 1
spr5_bitmap1			RS.L 1
spr6_bitmap1			RS.L 1
spr7_bitmap1			RS.L 1
spr0_construction		RS.L 1
spr1_construction		RS.L 1
spr2_construction		RS.L 1
spr3_construction		RS.L 1
spr4_construction		RS.L 1
spr5_construction		RS.L 1
spr6_construction		RS.L 1
spr7_construction		RS.L 1
	ENDC

	IFNE spr_x_size2
spr0_bitmap2			RS.L 1
spr1_bitmap2			RS.L 1
spr2_bitmap2			RS.L 1
spr3_bitmap2			RS.L 1
spr4_bitmap2			RS.L 1
spr5_bitmap2			RS.L 1
spr6_bitmap2			RS.L 1
spr7_bitmap2			RS.L 1
spr0_display			RS.L 1
spr1_display			RS.L 1
spr2_display			RS.L 1
spr3_display			RS.L 1
spr4_display			RS.L 1
spr5_display			RS.L 1
spr6_display			RS.L 1
spr7_display			RS.L 1
	ENDC

	IFNE audio_memory_size
audio_data			RS.L 1
	ENDC

	IFNE disk_memory_size
disk_data			RS.L 1
	ENDC

	IFNE extra_memory_size
extra_memory			RS.L 1
	ENDC

	IFNE chip_memory_size
chip_memory			RS.L 1
	ENDC

	IFND SYS_TAKEN_OVER
exception_vectors_base		RS.L 1
	ENDC

	IFD MEASURE_RASTERTIME
rt_rasterlines_number		RS.L 1
	ENDC

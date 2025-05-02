	IFND SYS_TAKEN_OVER
error_text_kickstart
		DC.B "This programm needs at least kickstart 3.0 !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_kickstart_end
		EVEN

error_text_cpu_1
		DC.B "This programm needs a 68020 cpu or better !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_cpu_1_end
		EVEN

error_text_chip_memory1
		DC.B "This program needs at least 2 MB chip memory !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_chip_memory1_end
		EVEN

error_text_aga_chipset
		DC.B "No AGA chipset detected! Please run the shell command SetPatch before.",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_aga_chipset_end
		EVEN

error_text_config
		DC.B "No PAL machine detected! Please run the shell command SetPatch before.",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_config_end
		EVEN

		IFEQ requires_030_cpu
error_text_cpu_2
			DC.B "This programm needs a 68030 cpu or better !",ASCII_LINE_FEED,ASCII_LINE_FEED
			DC.B "Press any key.",ASCII_LINE_FEED
error_text_cpu_2_end
			EVEN
		ENDC
		IFEQ requires_040_cpu
error_text_cpu_2
			DC.B "This programm needs a 68040 cpu or better !",ASCII_LINE_FEED,ASCII_LINE_FEED
			DC.B "Press any key.",ASCII_LINE_FEED
error_text_cpu_2_end
			EVEN
		ENDC
		IFEQ requires_060_cpu
error_text_cpu_2
			DC.B "This programm needs a 68060 cpu or better !",ASCII_LINE_FEED,ASCII_LINE_FEED
			DC.B "Press any key.",ASCII_LINE_FEED
error_text_cpu_2_end
			EVEN
		ENDC

		IFEQ requires_fast_memory
error_text_fast_memory
			DC.B "This programm needs fast memory !",ASCII_LINE_FEED,ASCII_LINE_FEED
			DC.B "Press any key.",ASCII_LINE_FEED
error_text_fast_memory_end
			EVEN
		ENDC

error_text_ciaa_resource
		DC.B "Couldn't open ciaa.resource !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_ciaa_resource_end
		EVEN
error_text_ciab_resource
		DC.B "Couldn't open ciab.resource !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_ciab_resource_end
		EVEN

error_text_timer_device
		DC.B "Couldn't open timer device !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_timer_device_end
		EVEN

error_text_cl1_constr1
		DC.B "Couldn't allocate memory for first copperlist1-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_cl1_constr1_end
		EVEN
error_text_cl1_constr2
		DC.B "Couldn't allocate memory for second copperlist1-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_cl1_constr2_end
		EVEN
error_text_cl1_display
		DC.B "Couldn't allocate memory for third copperlist1-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_cl1_display_end
		EVEN

error_text_cl2_constr1
		DC.B "Couldn't allocate memory for first copperlist2-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_cl2_constr1_end
		EVEN
error_text_cl2_constr2
		DC.B "Couldn't allocate memory for second copperlist2-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_cl2_constr2_end
		EVEN
error_text_cl2_display
		DC.B "Couldn't allocate memory for third copperlist2-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_cl2_display_end
		EVEN

error_text_pf1_constr1_1
		DC.B "Couldn't allocate memory for first playfield1-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf1_constr1_1_end
		EVEN
error_text_pf1_constr1_2
		DC.B "Check of first playfieled1-buffer failed !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf1_constr1_2_end
		EVEN
error_text_pf1_constr2_1
		DC.B "Couldn't allocate memory for second playfield1-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf1_constr2_1_end
		EVEN
error_text_pf1_constr2_2
		DC.B "Check of second playfieled1-buffer failed !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf1_constr2_2_end
		EVEN
error_text_pf1_display_1
		DC.B "Couldn't allocate memory for third playfield1-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf1_display_1_end
		EVEN
error_text_pf1_display_2
		DC.B "Check of third playfield1-buffer failed !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf1_display_2_end
		EVEN

error_text_pf2_constr1_1
		DC.B "Couldn't allocate memory for first playfield2-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf2_constr1_1_end
		EVEN
error_text_pf2_constr1_2
		DC.B "Check of first playfield2-buffer failed !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf2_constr1_2_end
		EVEN
error_text_pf2_constr2_1
		DC.B "Couldn't allocate memory for second playfield2-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf2_constr2_1_end
		EVEN
error_text_pf2_constr2_2
		DC.B "Check of second playfield2-buffer failed !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf2_constr2_2_end
		EVEN
error_text_pf2_display_1
		DC.B "Couldn't allocate memory for third playfield2-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf2_display_1_end
		EVEN
error_text_pf2_display_2
		DC.B "Check of third playfield2-buffer failed !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf2_display_2_end
		EVEN

error_text_pf_extra_1
		DC.B "Couldn't allocate memory for extra playfield-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf_extra_1_end
		EVEN
error_text_pf_extra_2
		DC.B "Check of extra playfield-buffer failed !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_pf_extra_2_end
		EVEN

error_text_spr_constr_1
		DC.B "Couldn't allocate memory for first sprites-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_spr_constr_1_end
		EVEN
error_text_spr_constr_2
		DC.B "Check of first sprites-buffer failed !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_spr_constr_2_end
		EVEN
error_text_spr_display_1
		DC.B "Couldn't allocate memory for second sprites-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_spr_display_1_end
		EVEN
error_text_spr_display_2
		DC.B "Check of second sprites-buffer failed !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_spr_display_2_end
		EVEN

error_text_audio
		DC.B "Couldn't allocate memory for audio-buffer !",ASCII_LINE_FEED ,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_audio_end
		EVEN

error_text_disk
		DC.B "Couldn't allocate memory for disk-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_disk_end
		EVEN

error_text_extra_memory
		DC.B "Couldn't allocate extra memory !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_extra_memory_end
		EVEN

error_text_chip_memory2
		DC.B "Couldn't allocate chip memory !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_chip_memory2_end
		EVEN

error_text_custom_memory
		DC.B "Couldn't allocate custom memory !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_custom_memory_end
		EVEN

error_text_exception_vectors
		DC.B "Couldn't allocate memory for exception-vectors-buffer !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_exception_vectors_end
		EVEN

error_text_cleared_sprite
		DC.B "Couldn't allocate memory for cleared_sprite !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_cleared_sprite_end
		EVEN

error_text_active_screen
		DC.B "Couldn't find active Screen !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_active_screen_end
		EVEN
error_text_viewport
		DC.B "Couldn't get viewport monitor ID !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_viewport_end
		EVEN

		IFEQ screen_fader_enabled
error_text_screen_fader
			DC.B "Couldn't allocate memory for colors-buffers !",ASCII_LINE_FEED,ASCII_LINE_FEED
			DC.B "Press any key.",ASCII_LINE_FEED
error_text_screen_fader_end
			EVEN
		ELSE
error_text_screen1
			DC.B "Couldn't allocate memory for degrade screen color table !",ASCII_LINE_FEED,ASCII_LINE_FEED
			DC.B "Press any key.",ASCII_LINE_FEED
error_text_screen1_end
			EVEN
		ENDC
error_text_screen2
		DC.B "Couldn't open downgrade screen !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_screen2_end
		EVEN
error_text_screen3
		DC.B "Requested display mode for downgrade screen not available !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_screen3_end
		EVEN

error_text_window
		DC.B "Couldn't open invisible window !",ASCII_LINE_FEED,ASCII_LINE_FEED
		DC.B "Press any key.",ASCII_LINE_FEED
error_text_window_end
		EVEN
	ENDC

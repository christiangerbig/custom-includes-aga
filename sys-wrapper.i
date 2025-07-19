; Requirements
; 68020+
; AGA PAL
; 3.0+


; Global labels
;	SYS_TAKEN_OVER
;	PASS_RETURN_CODE
;	PASS_GLOBAL_REFERENCES
;	WRAPPER
;	CUSTOM_MEMORY_USED
;	SAVE_BEAMCON0
;	AGA_CHECK_BY_HARDWARE
;	ALL_CACHES
;	NO_060_STORE_BUFFER
;	TRAP0
;	TRAP1
;	TRAP2
;	SET_SECOND_COPPERLIST
;	MEASURE_RASTERTIME


	IFND SYS_TAKEN_OVER
		INCLUDE "cleared-pointer-data.i"

		INCLUDE "custom-error-entry.i"

		INCLUDE "taglists.i"
 	ENDC

	IFD PASS_GLOBAL_REFERENCES
		INCLUDE "global-references.i"
	ENDC


	movem.l d2-d7/a2-a6,-(a7)
	lea	variables(pc),a3	; base for all variables
	bsr	init_variables
	IFD SYS_TAKEN_OVER
		tst.l	dos_return_code(a3)
		bne	end_final
	ENDC
	bsr	init_structures

	IFD SYS_TAKEN_OVER
		IFD CUSTOM_MEMORY_USED
			bsr	init_custom_memory_table ; external routine
			bsr	extend_global_references_table ; external routine
		ENDC
	ELSE
		IFEQ workbench_start_enabled
			bsr	check_workbench_start
			move.l	d0,dos_return_code(a3)
			bne	end_final
		ENDC

		bsr	open_dos_library
		move.l	d0,dos_return_code(a3)
		bne	cleanup_workbench_message
		IFEQ text_output_enabled
			bsr	get_output
			move.l	d0,dos_return_code(a3)
			bne	cleanup_dos_library
  		ENDC
		bsr	open_graphics_library
		move.l	d0,dos_return_code(a3)
		bne	cleanup_dos_library
		bsr	open_intuition_library
		move.l	d0,dos_return_code(a3)
		bne	cleanup_graphics_library

		bsr	get_active_screen
		move.l	d0,active_screen(a3)
		bsr	check_system_props
		move.l	d0,dos_return_code(a3)
		bne	cleanup_error_message

		IFEQ requires_030_cpu
			bsr	check_cpu_requirements
			move.l	d0,dos_return_code(a3)
			bne	cleanup_error_message
		ENDC
		IFEQ requires_040_cpu
			bsr	check_cpu_requirements
			move.l	d0,dos_return_code(a3)
			bne	cleanup_error_message
		ENDC
		IFEQ requires_060_cpu
			bsr	check_cpu_requirements
			move.l	d0,dos_return_code(a3)
			bne	cleanup_error_message
		ENDC
		IFEQ requires_fast_memory
			bsr	check_memory_requirements
			move.l	d0,dos_return_code(a3)
			bne	cleanup_error_message
		ENDC
		IFEQ requires_multiscan_monitor
			bsr	do_monitor_request
			move.l	d0,dos_return_code(a3)
			bne	cleanup_error_message
		ENDC

		IFNE intena_bits&INTF_PORTS
			bsr	check_tcp_stack
			move.l	d0,dos_return_code(a3)
			bne	cleanup_error_message
		ENDC

		bsr	open_ciaa_resource
		move.l	d0,dos_return_code(a3)
		bne	cleanup_error_message
		bsr	open_ciab_resource
		move.l	d0,dos_return_code(a3)
		bne	cleanup_error_message

		bsr	open_timer_device
		move.l	d0,dos_return_code(a3)
		bne	cleanup_error_message
	ENDC

	IFNE cl1_size1
		bsr	alloc_cl1_memory1
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	IFNE cl1_size2
		bsr	alloc_cl1_memory2
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	IFNE cl1_size3
		bsr	alloc_cl1_memory3
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC

	IFNE cl2_size1
		bsr	alloc_cl2_memory1
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	IFNE cl2_size2
		bsr	alloc_cl2_memory2
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	IFNE cl2_size3
		bsr	alloc_cl2_memory3
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC

	IFNE pf1_x_size1
		bsr	alloc_pf1_memory1
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		bsr	check_pf1_memory1
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	IFNE pf1_x_size2
		bsr	alloc_pf1_memory2
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		bsr	check_pf1_memory2
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	IFNE pf1_x_size3
		bsr	alloc_pf1_memory3
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		bsr	check_pf1_memory3
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	
	IFNE pf2_x_size1
		bsr	alloc_pf2_memory1
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		bsr	check_pf2_memory1
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	IFNE pf2_x_size2
		bsr	alloc_pf2_memory2
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		bsr	check_pf2_memory2
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	IFNE pf2_x_size3
		bsr	alloc_pf2_memory3
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		bsr	check_pf2_memory3
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC

	IFNE pf_extra_number
		bsr	alloc_pf_extra_memory
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		bsr	check_pf_extra_memory
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC

	IFNE spr_number
		IFNE spr_x_size1
			bsr	alloc_sprite_memory1
			move.l	d0,dos_return_code(a3)
			bne	cleanup_all_memory
			bsr	check_sprite_memory1
			move.l	d0,dos_return_code(a3)
			bne	cleanup_all_memory
		ENDC
		IFNE spr_x_size2
			bsr	alloc_sprite_memory2
			move.l	d0,dos_return_code(a3)
			bne	cleanup_all_memory
			bsr	check_sprite_memory2
			move.l	d0,dos_return_code(a3)
			bne	cleanup_all_memory
		ENDC
	ENDC

	IFNE audio_memory_size
		bsr	alloc_audio_memory
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC

	IFNE disk_memory_size
		bsr	alloc_disk_memory
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC

	IFNE extra_memory_size
		bsr	alloc_extra_memory
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC

	IFNE chip_memory_size
		bsr	alloc_chip_memory
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
	ENDC
	
	IFD SYS_TAKEN_OVER
		IFD CUSTOM_MEMORY_USED
			bsr	alloc_custom_memory ; external routine
			move.l	d0,dos_return_code(a3)
			bne.s	cleanup_all_memory
		ENDC
	ELSE
		bsr	alloc_vectors_base_memory
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory

		bsr	alloc_mouse_pointer_data
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory

		IFEQ screen_fader_enabled
			bsr	sf_alloc_screen_color_table
			move.l	d0,dos_return_code(a3)
			bne     cleanup_all_memory
			bsr	sf_alloc_screen_color_cache
			move.l	d0,dos_return_code(a3)
			bne	cleanup_all_memory
		ENDC

		IFD PASS_GLOBAL_REFERENCES
			bsr	init_global_references_table
		ENDC
	ENDC

	bsr	init_main_variables	; external routine

	IFND SYS_TAKEN_OVER
		bsr	wait_drives_motor

		IFD SAVE_BEAMCON0
			bsr	save_beamcon0_register
		ENDC

		bsr	get_sprite_resolution
		bsr	get_first_window
		move.l	d0,first_window(a3)
		bsr	check_screen_mode
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory

		IFEQ screen_fader_enabled
			bsr	sf_get_screen_colors
			bsr	sf_copy_screen_color_table
			bsr	sf_fade_out_screen
		ENDC

		bsr	open_pal_screen
		move.l	d0,dos_return_code(a3)
		bne	cleanup_original_screen
		bsr	check_pal_screen_mode
		move.l	d0,dos_return_code(a3)
		bne	cleanup_original_screen
		bsr	open_invisible_window
		move.l	d0,dos_return_code(a3)
		bne	cleanup_pal_screen
		bsr	clear_mousepointer
		bsr	blank_display
		bsr	wait_monitor_switch

		bsr	enable_exclusive_blitter
		bsr	get_system_time

		bsr	disable_system

		IFD ALL_CACHES
			bsr	enable_all_caches
		ENDC

		IFD NO_060_STORE_BUFFER
			bsr	disable_store_buffer
		ENDC
		
		bsr	save_exception_vectors
	ENDC

	bsr	init_exception_vectors
	
	IFND SYS_TAKEN_OVER
		bsr	move_exception_vectors
	ENDC

	move.l	#_CIAB,a5
	lea	_CIAA-_CIAB(a5),a4	; CIA-A base
	move.l	#_CUSTOM+DMACONR,a6
	
	IFND SYS_TAKEN_OVER
		bsr	save_copperlist_pointers
		bsr	get_tod_time
		bsr	save_chips_registers
		bsr	clear_chips_registers1
		bsr	turn_off_drive_motors
	ENDC

	move.w	#dma_bits&(~(DMAF_SPRITE|DMAF_COPPER|DMAF_RASTER)),DMACON-DMACONR(a6) ; enable DMA and exclude sprite/copper/bitplane DMA
	bsr	init_main		; external routine
	bsr	start_own_display
	IFNE (intena_bits&(~INTF_SETCLR))|(ciaa_icr_bits&(~CIAICRF_SETCLR))|(ciab_icr_bits&(~CIAICRF_SETCLR))
		bsr	start_own_interrupts
	ENDC
	IFEQ ciaa_ta_continuous_enabled&ciaa_tb_continuous_enabled&ciab_ta_continuous_enabled&ciab_tb_continuous_enabled
		bsr	start_CIA_timers
	ENDC

	IFD SYS_TAKEN_OVER
		IFD PASS_RETURN_CODE
			move.l	dos_return_code(a3),d0
			move.w	custom_error_code(a3),d1
		ENDC
		IFD PASS_GLOBAL_REFERENCES
			move.l	global_references_table(a3),a0
		ENDC
	ELSE
		IFD PASS_RETURN_CODE
			move.l	dos_return_code(a3),d0
			move.w	custom_error_code(a3),d1
		ENDC
		IFD PASS_GLOBAL_REFERENCES
			lea	global_references_table(pc),a0
		ENDC
	ENDC

	bsr	main		; external routine

	IFD PASS_RETURN_CODE
		move.l	d0,dos_return_code(a3)
		move.w	d1,custom_error_code(a3)
	ENDC

	IFEQ ciaa_ta_continuous_enabled&ciaa_tb_continuous_enabled&ciab_ta_continuous_enabled&ciab_tb_continuous_enabled
		bsr	stop_cia_timers
	ENDC
	IFNE (intena_bits&(~INTF_SETCLR))|(ciaa_icr_bits&(~CIAICRF_SETCLR))|(ciab_icr_bits&(~CIAICRF_SETCLR))
		bsr	stop_own_interrupts
	ENDC
	bsr	stop_own_display

	IFND SYS_TAKEN_OVER
		bsr	clear_chips_registers2
		bsr	restore_chips_registers
		bsr	get_tod_duration

		bsr	restore_exception_vectors

		bsr	restore_vbr

		IFD ALL_CACHES
			bsr	restore_caches
		ENDC

		IFD NO_060_STORE_BUFFER
			bsr	restore_store_buffer
		ENDC

		bsr	enable_system

		bsr	update_system_time

		bsr	disable_exclusive_blitter

		bsr	restore_sprite_resolution
		bsr	wait_monitor_switch
		bsr	close_invisible_window
cleanup_pal_screen
		bsr	close_pal_screen

cleanup_original_screen
		bsr	activate_first_window

		IFEQ screen_fader_enabled
			bsr	sf_fade_in_screen
		ENDC

		IFEQ text_output_enabled
			bsr	print_formatted_text
		ENDC
	ENDC

cleanup_all_memory
	IFD SYS_TAKEN_OVER
		IFD CUSTOM_MEMORY_USED
			bsr	free_custom_memory ; external routine
		ENDC
	ELSE
		IFEQ screen_fader_enabled
			bsr	sf_free_screen_color_cache
			bsr	sf_free_screen_color_table
		ENDC

		bsr	free_mouse_pointer_data

		bsr	free_vectors_base_memory
	ENDC

	IFNE chip_memory_size
		bsr	free_chip_memory
	ENDC

	IFNE extra_memory_size
		bsr	free_extra_memory
	ENDC

	IFNE disk_memory_size
		bsr	free_disk_memory
	ENDC

	IFNE audio_memory_size
		bsr	free_audio_memory
	ENDC

	IFNE spr_x_size2
		bsr	free_sprite_memory2
	ENDC
	IFNE spr_x_size1
		bsr	free_sprite_memory1
	ENDC

	IFNE pf_extra_number
		bsr	free_pf_extra_memory
	ENDC

	IFNE pf2_x_size3
		bsr	free_pf2_memory3
	ENDC
	IFNE pf2_x_size2
		bsr	free_pf2_memory2
	ENDC
	IFNE pf2_x_size1
		bsr	free_pf2_memory1
	ENDC

	IFNE pf1_x_size3
		bsr	free_pf1_memory3
	ENDC
	IFNE pf1_x_size2
		bsr	free_pf1_memory2
	ENDC
	IFNE pf1_x_size1
		bsr	free_pf1_memory1
	ENDC

	IFNE cl2_size3
		bsr	free_cl2_memory3
	ENDC
	IFNE cl2_size2
		bsr	free_cl2_memory2
	ENDC
	IFNE cl2_size1
		bsr	free_cl2_memory1
	ENDC

	IFNE cl1_size3
		bsr	free_cl1_memory3
	ENDC
	IFNE cl1_size2
		bsr	free_cl1_memory2
	ENDC
	IFNE cl1_size1
		bsr	free_cl1_memory1
	ENDC

	IFND SYS_TAKEN_OVER
cleanup_timer_device
		bsr	close_timer_device

cleanup_error_message
		bsr	print_error_message
		move.l	d0,dos_return_code(a3)

cleanup_intuition_library
		bsr	close_intuition_library

cleanup_graphics_library
		bsr	close_graphics_library

cleanup_dos_library
		bsr	close_dos_library

cleanup_workbench_message
		IFEQ workbench_start_enabled
			bsr	reply_workbench_message
		ENDC
	ENDC

end_final
	IFD MEASURE_RASTERTIME
		move.l	rt_rasterlines_number(a3),d0
output_rasterlines_number
	ELSE
		move.l	dos_return_code(a3),d0
	ENDC

	IFD SYS_TAKEN_OVER
		IFD PASS_RETURN_CODE
			move.w	custom_error_code(a3),d1
		ENDC
		IFD PASS_GLOBAL_REFERENCES
			move.l	global_references_table(a3),a0
		ENDC
	ENDC

	movem.l (a7)+,d2-d7/a2-a6
	rts


; Input
; Result
	CNOP 0,4
init_variables
	IFD SYS_TAKEN_OVER
		IFD PASS_GLOBAL_REFERENCES
			move.l	a0,global_references_table(a3)
			lea	_SysBase(pc),a1
			move.l	(a0)+,(a1)
			lea	_GfxBase(pc),a1
			move.l	(a0),(a1)
		ENDC
		IFD WRAPPER
			moveq	#RETURN_OK,d2
			move.l	d2,dos_return_code(a3)
			move.w	#NO_CUSTOM_ERROR,custom_error_code(a3)
		ELSE
			IFD PASS_RETURN_CODE
				move.l	d0,dos_return_code(a3)
				move.w	d1,custom_error_code(a3)
			ENDC
		ENDC
	ELSE
		move.l	a0,shell_parameters(a3)
		move.l	d0,shell_parameters_length(a3)

		moveq	#TRUE,d0
		IFEQ workbench_start_enabled
			move.l	d0,workbench_message(a3)
		ENDC
		moveq	#FALSE,d1
		move.w	d1,fast_memory_available(a3)

		IFEQ screen_fader_enabled
			move.w	d0,sfi_rgb32_active(a3)
			move.w	d0,sfo_rgb32_active(a3)
		ENDC

		move.l	d0,exception_vectors_base(a3)

		moveq	#RETURN_OK,d2
		move.l	d2,dos_return_code(a3)
		move.w	#NO_CUSTOM_ERROR,custom_error_code(a3)

		lea	_SysBase(pc),a0
		move.l	exec_base.w,(a0)
	ENDC

	IFD MEASURE_RASTERTIME
		move.l	d0,rt_rasterlines_number(a3)
	ENDC
	rts


; Input
; Result
	CNOP 0,4
init_structures
	IFND SYS_TAKEN_OVER
		bsr	init_custom_error_table
		bsr	init_easy_request
		bsr	init_timer_io
		bsr	init_pal_screen_tags
		IFNE screen_fader_enabled
			bsr	init_pal_screen_color_table
		ENDC
		bsr	init_video_control_tags
		bsr	init_invisible_window_tags
	ENDC
	IFNE pf_extra_number
		bsr	init_pf_extra_structure
	ENDC

	IFNE spr_x_size1|spr_x_size2
		bsr	spr_init_structure
	ENDC
	rts


	IFND SYS_TAKEN_OVER
; Input
; Result
		CNOP 0,4
init_custom_error_table
		lea	custom_error_table(pc),a0
		INIT_CUSTOM_ERROR_ENTRY KICKSTART_VERSION_NOT_FOUND,error_text_kickstart,error_text_kickstart_end-error_text_kickstart
		INIT_CUSTOM_ERROR_ENTRY CPU_020_NOT_FOUND,error_text_cpu_1,error_text_cpu_1_end-error_text_cpu_1
		INIT_CUSTOM_ERROR_ENTRY CHIP_MEMORY_WRONG_SIZE,error_text_chip_memory1,error_text_chip_memory1_end-error_text_chip_memory1
		INIT_CUSTOM_ERROR_ENTRY AGA_CHIPSET_NOT_FOUND,error_text_aga_chipset,error_text_aga_chipset_end-error_text_aga_chipset
		INIT_CUSTOM_ERROR_ENTRY CONFIG_NO_PAL,error_text_config,error_text_config_end-error_text_config

		IFEQ requires_030_cpu
			INIT_CUSTOM_ERROR_ENTRY CPU_030_REQUIRED,error_text_cpu_2,error_text_cpu_2_end-error_text_cpu_2
		ENDC
		IFEQ requires_040_cpu
			INIT_CUSTOM_ERROR_ENTRY CPU_040_REQUIRED,error_text_cpu_2,error_text_cpu_2_end-error_text_cpu_2
		ENDC
		IFEQ requires_060_cpu
			INIT_CUSTOM_ERROR_ENTRY CPU_060_REQUIRED,error_text_cpu_2,error_text_cpu_2_end-error_text_cpu_2
		ENDC

		IFEQ requires_fast_memory
			INIT_CUSTOM_ERROR_ENTRY FAST_MEMORY_REQUIRED,error_text_fast_memory,error_text_fast_memory_end-error_text_fast_memory
		ENDC

		INIT_CUSTOM_ERROR_ENTRY CIAA_RESOURCE_COULD_NOT_OPEN,error_text_ciaa_resource,error_text_ciaa_resource_end-error_text_ciaa_resource
		INIT_CUSTOM_ERROR_ENTRY CIAB_RESOURCE_COULD_NOT_OPEN,error_text_ciab_resource,error_text_ciab_resource_end-error_text_ciaa_resource

		INIT_CUSTOM_ERROR_ENTRY TIMER_DEVICE_COULD_NOT_OPEN,error_text_timer_device,error_text_timer_device_end-error_text_timer_device

		INIT_CUSTOM_ERROR_ENTRY CL1_CONSTR1_NO_MEMORY-1,error_text_cl1_constr1,error_text_cl1_constr1_end-error_text_cl1_constr1
		INIT_CUSTOM_ERROR_ENTRY CL1_CONSTR2_NO_MEMORY-1,error_text_cl1_constr2,error_text_cl1_constr2_end-error_text_cl1_constr2
		INIT_CUSTOM_ERROR_ENTRY CL1_DISPLAY_NO_MEMORY-1,error_text_cl1_display,error_text_cl1_display_end-error_text_cl1_display

		INIT_CUSTOM_ERROR_ENTRY CL2_CONSTR1_NO_MEMORY,error_text_cl2_constr1,error_text_cl2_constr1_end-error_text_cl2_constr1
		INIT_CUSTOM_ERROR_ENTRY CL2_CONSTR2_NO_MEMORY,error_text_cl2_constr2,error_text_cl2_constr2_end-error_text_cl2_constr2
		INIT_CUSTOM_ERROR_ENTRY CL2_DISPLAY_NO_MEMORY,error_text_cl2_display,error_text_cl2_display_end-error_text_cl2_display

		INIT_CUSTOM_ERROR_ENTRY PF1_CONSTR1_NO_MEMORY,error_text_pf1_constr1_1,error_text_pf1_constr1_1_end-error_text_pf1_constr1_1
		INIT_CUSTOM_ERROR_ENTRY PF1_CONSTR1_NOT_INTERLEAVED,error_text_pf1_constr1_2,error_text_pf1_constr1_2_end-error_text_pf1_constr1_2
		INIT_CUSTOM_ERROR_ENTRY PF1_CONSTR2_NO_MEMORY,error_text_pf1_constr2_1,error_text_pf1_constr2_1_end-error_text_pf1_constr2_1
		INIT_CUSTOM_ERROR_ENTRY PF1_CONSTR2_NOT_INTERLEAVED,error_text_pf1_constr2_2,error_text_pf1_constr2_2_end-error_text_pf1_constr2_2
		INIT_CUSTOM_ERROR_ENTRY PF1_DISPLAY_NO_MEMORY,error_text_pf1_display_1,error_text_pf1_display_1_end-error_text_pf1_display_1
		INIT_CUSTOM_ERROR_ENTRY PF1_DISPLAY_NOT_INTERLEAVED,error_text_pf1_display_2,error_text_pf1_display_2_end-error_text_pf1_display_2

		INIT_CUSTOM_ERROR_ENTRY PF2_CONSTR1_NO_MEMORY,error_text_pf2_constr1_1,error_text_pf2_constr1_1_end-error_text_pf2_constr1_1
		INIT_CUSTOM_ERROR_ENTRY PF2_CONSTR1_NOT_INTERLEAVED-1,error_text_pf2_constr1_2,error_text_pf2_constr1_2_end-error_text_pf2_constr1_2
		INIT_CUSTOM_ERROR_ENTRY PF2_CONSTR2_NO_MEMORY,error_text_pf2_constr2_1,error_text_pf2_constr2_1_end-error_text_pf2_constr2_1
		INIT_CUSTOM_ERROR_ENTRY PF2_CONSTR2_NOT_INTERLEAVED-1,error_text_pf2_constr2_2,error_text_pf2_constr2_2_end-error_text_pf2_constr2_2
		INIT_CUSTOM_ERROR_ENTRY PF2_DISPLAY_NO_MEMORY,error_text_pf2_display_1,error_text_pf2_display_1_end-error_text_pf2_display_1
		INIT_CUSTOM_ERROR_ENTRY PF2_DISPLAY_NOT_INTERLEAVED,error_text_pf2_display_2,error_text_pf2_display_2_end-error_text_pf2_display_2

		INIT_CUSTOM_ERROR_ENTRY PF_EXTRA_NO_MEMORY,error_text_pf_extra_1,error_text_pf_extra_1_end-error_text_pf_extra_1
		INIT_CUSTOM_ERROR_ENTRY PF_EXTRA_NOT_INTERLEAVED,error_text_pf_extra_2,error_text_pf_extra_2_end-error_text_pf_extra_2

		INIT_CUSTOM_ERROR_ENTRY SPR_CONSTR_NO_MEMORY,error_text_spr_constr_1,error_text_spr_constr_1_end-error_text_spr_constr_1
		INIT_CUSTOM_ERROR_ENTRY SPR_CONSTR_NOT_INTERLEAVED,error_text_spr_constr_2,error_text_spr_constr_2_end-error_text_spr_constr_2
		INIT_CUSTOM_ERROR_ENTRY SPR_DISPLAY_NO_MEMORY,error_text_spr_display_1,error_text_spr_display_1_end-error_text_spr_display_1
		INIT_CUSTOM_ERROR_ENTRY SPR_DISPLAY_NOT_INTERLEAVED,error_text_spr_display_2,error_text_spr_display_2_end-error_text_spr_display_2

		INIT_CUSTOM_ERROR_ENTRY AUDIO_NO_MEMORY,error_text_audio,error_text_audio_end-error_text_audio

		INIT_CUSTOM_ERROR_ENTRY DISK_NO_MEMORY,error_text_disk,error_text_disk_end-error_text_disk

		INIT_CUSTOM_ERROR_ENTRY EXTRA_MEMORY_NO_MEMORY,error_text_extra_memory,error_text_extra_memory_end-error_text_extra_memory

		INIT_CUSTOM_ERROR_ENTRY CHIP_MEMORY_NO_MEMORY,error_text_chip_memory2,error_text_chip_memory2_end-error_text_chip_memory2

		INIT_CUSTOM_ERROR_ENTRY CUSTOM_MEMORY_NO_MEMORY,error_text_custom_memory,error_text_custom_memory_end-error_text_custom_memory

		INIT_CUSTOM_ERROR_ENTRY EXCEPTION_VECTORS_NO_MEMORY,error_text_exception_vectors,error_text_exception_vectors_end-error_text_exception_vectors

		INIT_CUSTOM_ERROR_ENTRY CLEARED_SPRITE_NO_MEMORY,error_text_cleared_sprite,error_text_cleared_sprite_end-error_text_cleared_sprite

		INIT_CUSTOM_ERROR_ENTRY VIEWPORT_MONITOR_ID_NOT_FOUND,error_text_viewport,error_text_viewport_end-error_text_viewport

		IFEQ screen_fader_enabled
			INIT_CUSTOM_ERROR_ENTRY SCREEN_FADER_NO_MEMORY,error_text_screen_fader,error_text_screen_fader_end-error_text_screen_fader
     		ELSE
			INIT_CUSTOM_ERROR_ENTRY SCREEN_NO_MEMORY,error_text_screen1,error_text_screen1_end-error_text_screen1
		ENDC

		INIT_CUSTOM_ERROR_ENTRY SCREEN_COULD_NOT_OPEN,error_text_screen2,error_text_screen2_end-error_text_screen2

		INIT_CUSTOM_ERROR_ENTRY SCREEN_MODE_NOT_AVAILABLE,error_text_screen3,error_text_screen3_end-error_text_screen3
		rts


; Input
; Result
		CNOP 0,4
init_easy_request
		IFEQ requires_multiscan_monitor
			lea	monitor_request(pc),a0
			moveq	#EasyStruct_sizeOF,d0
			move.l	d0,(a0)+
			moveq	#0,d0
			move.l	d0,(a0)+ ; no flags
			lea	monitor_request_title(pc),a1
			move.l	a1,(a0)+
			lea	monitor_request_text_body(pc),a1
			move.l	a1,(a0)+
			lea	monitor_request_text_gadgets(pc),a1
			move.l	a1,(a0)
		ENDC

		IFNE intena_bits&INTF_PORTS
			lea	tcp_stack_request(pc),a0
			moveq	#EasyStruct_sizeOF,d0
			move.l	d0,(a0)+
			moveq	#0,d0
			move.l	d0,(a0)+ ; no flags
			lea	tcp_stack_request_title(pc),a1
			move.l	a1,(a0)+
			lea	tcp_stack_request_text_body(pc),a1
			move.l	a1,(a0)+
			lea	tcp_stack_request_text_gadgets(pc),a1
			move.l	a1,(a0)
		ENDC
		rts


; Input
; Result
		CNOP 0,4
init_timer_io
		lea	timer_io(pc),a0
		moveq	#0,d0
		move.b	d0,LN_Type(a0)
		move.b	d0,LN_Pri(a0)
		move.l	d0,LN_Name(a0)
		move.l	d0,MN_ReplyPort(a0)
		rts


; Input
; Result
		CNOP 0,4
init_pal_screen_tags
		lea	pal_screen_tags(pc),a0
		move.l	#SA_Left,(a0)+
  		moveq	#pal_screen_left,d2
		move.l	d2,(a0)+
		move.l	#SA_Top,(a0)+
		moveq	#pal_screen_top,d2
		move.l	d2,(a0)+
		move.l	#SA_Width,(a0)+
		moveq	#pal_screen_x_size,d2
		move.l	d2,(a0)+
		move.l	#SA_Height,(a0)+
		moveq	#pal_screen_y_size,d2
		move.l	d2,(a0)+
		move.l	#SA_Depth,(a0)+
		moveq	#pal_screen_depth,d2
		move.l	d2,(a0)+
		move.l	#SA_DisplayID,(a0)+
		IFEQ requires_multiscan_monitor
			move.l	#VGA_MONITOR_ID|VGAPRODUCT_KEY,(a0)+
		ELSE
			move.l	#PAL_MONITOR_ID|LORES_KEY,(a0)+
		ENDC
		move.l	#SA_DetailPen,(a0)+
		moveq	#0,d0
		move.l	d0,(a0)+
		move.l	#SA_BlockPen,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_Title,(a0)+
		lea	pal_screen_name(pc),a1
		move.l	a1,(a0)+
		move.l	#SA_Colors32,(a0)+
		IFEQ screen_fader_enabled
                	sub.l	a1,a1	; will be initialized later
		ELSE
			lea	pal_screen_rgb32_colors(pc),a1
		ENDC
		move.l	a1,(a0)+
		move.l	#SA_VideoControl,(a0)+
		lea	video_control_tags(pc),a1
		move.l	#VTAG_SPRITERESN_SET,vctl_VTAG_SPRITERESN+ti_Tag(a1)
		move.l	#SPRITERESN_140NS,vctl_VTAG_SPRITERESN+ti_Data(a1)
		move.l	a1,(a0)+
		move.l	#SA_Font,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_SysFont,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_Type,(a0)+
		move.l	#CUSTOMSCREEN,(a0)+
		move.l	#SA_Behind,(a0)+	
		moveq	#BOOL_FALSE,d2
		move.l	d2,(a0)+
		move.l	#SA_Quiet,(a0)+
		move.l	d2,(a0)+
		move.l	#SA_ShowTitle,(a0)+
		move.l	d2,(a0)+
		move.l	#SA_AutoScroll,(a0)+
		move.l	d2,(a0)+
		move.l	#SA_Draggable,(a0)+
		move.l	d2,(a0)+
		move.l	#SA_Interleaved,(a0)+
		move.l	d2,(a0)+
		moveq	#TAG_DONE,d2
		move.l	d2,(a0)
		rts


		IFNE screen_fader_enabled
; Input
; Result
			CNOP 0,4
init_pal_screen_color_table
			lea	pal_screen_rgb32_colors(pc),a0
			move.w	#pal_screen_colors_number,(a0)+
			moveq	#0,d0
			move.w	d0,(a0)+	; start with COLOR00
			lea     pf1_rgb8_color_table(pc),a1
			moveq	#0,d1
			move.b	1(a1),d1	; COLOR00 R8
			lsl.w	#8,d1
			move.b	BYTE_SIZE(a1),d1 ; COLOR00 R8
			swap	d1
			move.b	1(a1),d1	; COLOR00 R8
			lsl.w	#8,d1
			move.b	BYTE_SIZE(a1),d1 ; COLOR00 R8
			moveq	#0,d2
			move.b	2(a1),d2	; COLOR00 G8
			lsl.w	#8,d2
			move.b	WORD_SIZE(a1),d2 ; COLOR00 G8
			swap	d2
			move.b	WORD_SIZE(a1),d2 ; COLOR00 G8
			lsl.w	#8,d2
			move.b	2(a1),d2	; COLOR00 G8
			moveq	#0,d3
			move.b	3(a1),d3	; COLOR00 B8
			lsl.w	#8,d3
			move.b	3(a1),d3	; COLOR00 B8
			swap	d3
			move.b	3(a1),d3	; COLOR00 B8
			lsl.w	#8,d3
			move.b	3(a1),d3	; COLOR00 B8
			MOVEF.W	pal_screen_colors_number-1,d7
init_pal_screen_color_table_loop
			move.l	d1,(a0)+	; R32
			move.l	d2,(a0)+	; G32
			move.l	d3,(a0)+	; B32
			dbf	d7,init_pal_screen_color_table_loop
			move.l	d0,(a0)		; end of list
			rts
		ENDC


; Input
; Result
		CNOP 0,4
init_video_control_tags
		lea	video_control_tags(pc),a0
		moveq	#TAG_DONE,d2
		move.l	d2,vctl_TAG_DONE(a0)
		rts


; Input
; Result
		CNOP 0,4
init_invisible_window_tags
		lea	invisible_window_tags(pc),a0
		move.l	#WA_Left,(a0)+
		moveq	#invisible_window_left,d2
		move.l	d2,(a0)+
		move.l	#WA_Top,(a0)+
		moveq	#invisible_window_top,d2
		move.l	d2,(a0)+
		move.l	#WA_Width,(a0)+
		moveq	#invisible_window_x_size,d2
		move.l	d2,(a0)+
		move.l	#WA_Height,(a0)+
		moveq	#invisible_window_y_size,d2
		move.l	d2,(a0)+
		move.l	#WA_DetailPen,(a0)+
		moveq	#0,d0
		move.l	d0,(a0)+
		move.l	#WA_BlockPen,(a0)+
		move.l	d0,(a0)+
		move.l	#WA_IDCMP,(a0)+
		move.l	d0,(a0)+
		move.l	#WA_Title,(a0)+
		lea	invisible_window_name(pc),a1
		move.l	a1,(a0)+
		move.l	#WA_CustomScreen,(a0)+
		move.l	d0,(a0)+	; will be initialized later
		move.l	#WA_MinWidth,(a0)+
		moveq	#invisible_window_x_size,d2
		move.l	d2,(a0)+
		move.l	#WA_MinHeight,(a0)+
		moveq	#invisible_window_y_size,d2
		move.l	d2,(a0)+
		move.l	#WA_MaxWidth,(a0)+
		moveq	#invisible_window_x_size,d2
		move.l	d2,(a0)+
		move.l	#WA_MaxHeight,(a0)+
		moveq	#invisible_window_y_size,d2
		move.l	d2,(a0)+
		move.l	#WA_AutoAdjust,(a0)+
		moveq	#BOOL_TRUE,d2
		move.l	d2,(a0)+
		move.l	#WA_Flags,(a0)+
		move.l	#WFLG_BACKDROP|WFLG_BORDERLESS|WFLG_ACTIVATE,(a0)+
		moveq	#TAG_DONE,d2
		move.l	d2,(a0)
		rts
	ENDC


	IFNE pf_extra_number
; Input
; Result
		CNOP 0,4
init_pf_extra_structure
		lea	pf_extra_attributes(pc),a0
		IFGE pf_extra_number-1
			move.l	#extra_pf1_x_size,(a0)+
			move.l	#extra_pf1_y_size,(a0)+
			moveq	#extra_pf1_depth,d0
			IFEQ pf_extra_number-1
				move.l	d0,(a0)
			ELSE
				move.l	d0,(a0)+
			ENDC
		ENDC
		IFGE pf_extra_number-2
			move.l	#extra_pf2_x_size,(a0)+
			move.l	#extra_pf2_y_size,(a0)+
			moveq	#extra_pf2_depth,d0
			IFEQ pf_extra_number-2
				move.l	d0,(a0)
			ELSE
				move.l	d0,(a0)+
			ENDC
		ENDC
		IFGE pf_extra_number-3
			move.l	#extra_pf3_x_size,(a0)+
			move.l	#extra_pf3_y_size,(a0)+
			moveq	#extra_pf3_depth,d0
			IFEQ pf_extra_number-3
				move.l	d0,(a0)
			ELSE
				move.l	d0,(a0)+
			ENDC
		ENDC
		IFGE pf_extra_number-4
			move.l	#extra_pf4_x_size,(a0)+
			move.l	#extra_pf4_y_size,(a0)+
			moveq	#extra_pf4_depth,d0
			IFEQ pf_extra_number-4
				move.l	d0,(a0)
			ELSE
				move.l	d0,(a0)+
			ENDC
		ENDC
		IFGE pf_extra_number-5
			move.l	#extra_pf5_x_size,(a0)+
			move.l	#extra_pf5_y_size,(a0)+
			moveq	#extra_pf5_depth,d0
			IFEQ pf_extra_number-5
				move.l	d0,(a0)
			ELSE
				move.l	d0,(a0)+
			ENDC
		ENDC
		IFGE pf_extra_number-6
			move.l	#extra_pf6_x_size,(a0)+
			move.l	#extra_pf6_y_size,(a0)+
			moveq	#extra_pf6_depth,d0
			IFEQ pf_extra_number-6
				move.l	d0,(a0)
			ELSE
				move.l	d0,(a0)+
			ENDC
		ENDC
		IFGE pf_extra_number-7
			move.l	#extra_pf7_x_size,(a0)+
			move.l	#extra_pf7_y_size,(a0)+
			moveq	#extra_pf7_depth,d0
			IFEQ pf_extra_number-7
				move.l	d0,(a0)
			ELSE
				move.l	d0,(a0)+
			ENDC
		ENDC
		IFGE pf_extra_number-8
			move.l	#extra_pf8_x_size,(a0)+
			move.l	#extra_pf8_y_size,(a0)+
			moveq	#extra_pf8_depth,d0
			IFEQ pf_extra_number-8
				move.l	d0,(a0)
			ELSE
				move.l	d0,(a0)+
			ENDC
		ENDC
		rts
	ENDC

	IFNE spr_x_size1|spr_x_size2
; Input
; Result
		CNOP 0,4
spr_init_structure
		IFNE spr_x_size1
			lea	sprite_attributes1(pc),a0
			moveq	#spr0_x_size1,d0
			move.l	d0,(a0)+
			move.l	#spr0_y_size1,(a0)+
			moveq	#spr_depth,d1
			move.l	d1,(a0)+

			moveq	#spr1_x_size1,d0
			move.l	d0,(a0)+
			move.l	#spr1_y_size1,(a0)+
			move.l	d1,(a0)+

			moveq	#spr2_x_size1,d0
			move.l	d0,(a0)+
			move.l	#spr2_y_size1,(a0)+
			move.l	d1,(a0)+

			moveq	#spr3_x_size1,d0
			move.l	d0,(a0)+
			move.l	#spr3_y_size1,(a0)+
			move.l	d1,(a0)+

			moveq	#spr4_x_size1,d0
			move.l	d0,(a0)+
			move.l	#spr4_y_size1,(a0)+
			move.l	d1,(a0)+

			moveq	#spr5_x_size1,d0
			move.l	d0,(a0)+
			move.l	#spr5_y_size1,(a0)+
			move.l	d1,(a0)+

			moveq	#spr6_x_size1,d0
			move.l	d0,(a0)+
			move.l	#spr6_y_size1,(a0)+
			move.l	d1,(a0)+

			moveq	#spr7_x_size1,d0
			move.l	d0,(a0)+
			move.l	#spr7_y_size1,(a0)+
			move.l	d1,(a0)
		ENDC
		IFNE spr_x_size2
			lea	sprite_attributes2(pc),a0
			moveq	#spr0_x_size2,d0
			move.l	d0,(a0)+
			move.l	#spr0_y_size2,(a0)+
			moveq	#spr_depth,d1
			move.l	d1,(a0)+

			moveq	#spr1_x_size2,d0
			move.l	d0,(a0)+
			move.l	#spr1_y_size2,(a0)+
			move.l	d1,(a0)+

			moveq	#spr2_x_size2,d0
			move.l	d0,(a0)+
			move.l	#spr2_y_size2,(a0)+
			move.l	d1,(a0)+

			moveq	#spr3_x_size2,d0
			move.l	d0,(a0)+
			move.l	#spr3_y_size2,(a0)+
			move.l	d1,(a0)+

			moveq	#spr4_x_size2,d0
			move.l	d0,(a0)+
			move.l	#spr4_y_size2,(a0)+
			move.l	d1,(a0)+

			moveq	#spr5_x_size2,d0
			move.l	d0,(a0)+
			move.l	#spr5_y_size2,(a0)+
			move.l	d1,(a0)+

			moveq	#spr6_x_size2,d0
			move.l	d0,(a0)+
			move.l	#spr6_y_size2,(a0)+
			move.l	d1,(a0)+

			moveq	#spr7_x_size2,d0
			move.l	d0,(a0)+
			move.l	#spr7_y_size2,(a0)+
			move.l	d1,(a0)
		ENDC
		rts
	ENDC


	IFND SYS_TAKEN_OVER
		IFEQ workbench_start_enabled
; Input
; Result
; d0.l	Return code
			CNOP 0,4
check_workbench_start
			sub.l	a1,a1	; own task
			CALLEXEC FindTask
			tst.l	d0
			bne.s	check_workbench_start_skip1
			moveq	#RETURN_FAIL,d0
check_workbench_start_quit
			rts
			CNOP 0,4
check_workbench_start_skip1
			move.l	d0,a2
			tst.l	pr_CLI(a2)
			beq.s	check_workbench_start_skip2
check_workbench_start_ok
			moveq	#RETURN_OK,d0
			bra.s	check_workbench_start_quit
			CNOP 0,4
check_workbench_start_skip2
			lea	pr_MsgPort(a2),a0
			CALLLIBS WaitPort
			lea	pr_MsgPort(a2),a0
			CALLLIBS GetMsg
			move.l	d0,workbench_message(a3)
			bra.s	check_workbench_start_ok
		ENDC
	

; Input
; Result
; d0.l	Return code
		CNOP 0,4
open_dos_library
		lea	dos_name(pc),a1
		moveq	#ANY_LIBRARY_VERSION,d0
		CALLEXEC OpenLibrary
		lea	_DOSBase(pc),a0
		move.l	d0,(a0)
		bne.s	open_dos_library_ok
		moveq	#RETURN_FAIL,d0
open_dos_library_quit
		rts
		CNOP 0,4
open_dos_library_ok
		moveq	#RETURN_OK,d0
		bra.s	open_dos_library_quit


		IFEQ text_output_enabled
; Input
; Result
; d0.l	Return code/error code
			CNOP 0,4
get_output
			CALLDOS Output
			move.l	d0,output_handle(a3)
			bne.s   get_output_ok
			CALLLIBS IoErr
get_output_quit
			rts			
			CNOP 0,4
get_output_ok
			moveq	#RETURN_OK,d0
			bra.s	get_output_quit
		ENDC


; Input
; Result
; d0.l	Return code
		CNOP 0,4
open_graphics_library
		lea	graphics_name(pc),a1
		moveq	#ANY_LIBRARY_VERSION,d0
		CALLEXEC OpenLibrary
		lea	_GfxBase(pc),a0
		move.l	d0,(a0)
		bne.s	open_graphics_library_ok
		moveq	#RETURN_FAIL,d0
open_graphics_library_quit
		rts
		CNOP 0,4
open_graphics_library_ok
		moveq	#RETURN_OK,d0
		bra.s	open_graphics_library_quit


; Input
; Result
; d0.l	Return code	
		CNOP 0,4
open_intuition_library
		lea	intuition_name(pc),a1
		moveq	#ANY_LIBRARY_VERSION,d0
		CALLEXEC OpenLibrary
		lea	_IntuitionBase(pc),a0
		move.l	d0,(a0)
		bne.s	open_intuition_library_ok
		moveq	#RETURN_FAIL,d0
open_intuition_library_quit		
		rts
		CNOP 0,4
open_intuition_library_ok
		moveq	#RETURN_OK,d0
		bra.s	open_intuition_library_quit


; Input
; Result
; d0.l	pointer screen structure active screen
	CNOP 0,4
get_active_screen
		moveq	#0,d0		; all locks
		CALLINT LockIBase
		move.l	d0,a0
		move.l	ib_ActiveScreen(a6),a2
		CALLLIBS UnlockIBase
		move.l	a2,d0
		rts


; Input
; Result
; d0.l	Return code	
		CNOP 0,4
check_system_props
		move.l	_SysBase(pc),a6
		cmp.w	#OS3_VERSION,Lib_Version(a6)
		bge.s	check_system_props_skip1
		move.w	#KICKSTART_VERSION_NOT_FOUND,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_system_props_quit
		rts
		CNOP 0,4
check_system_props_skip1
		move.w	AttnFlags(a6),d0
		move.w	d0,cpu_flags(a3)
		and.w	#AFF_68020,d0
		bne.s	check_system_props_skip2
		move.w	#CPU_020_NOT_FOUND,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		bra.s	check_system_props_quit
		CNOP 0,4
check_system_props_skip2
		move.l	MaxLocMem(a6),d0
		cmp.l	#CHIP_MEMORY_MIN,d0
		bge.s	check_system_props_skip3
		move.w	#CHIP_MEMORY_WRONG_SIZE,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		bra.s	check_system_props_quit
		CNOP 0,4
check_system_props_skip3
		move.l	_GfxBase(pc),a1
		IFD DEF_AGA_CHECK_BY_HARDWARE
			move.l	#_CUSTOM+DENISEID,a0
			move.w	-(DENISEID-VPOSR)(a0),d0
			and.w	#$7e00,d0
			cmp.w	#$22<<8,d0 ; PAL Alice revision 2 ?
			beq.s	check_system_props_skip4
			cmp.w	#$23<<8,d0 ; PAL Alice revision 3 & 4 ?
			beq.s	check_system_props_skip4
			move.w	#AGA_CHIPSET_NOT_FOUND,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			bra.s	check_system_props_quit
			CNOP 0,4
check_system_props_skip4
			move.w	(a0),d0 ; Lisa ID
			moveq	#32-1,d7
check_system_props_loop
			move.w	(a0),d1	; Lisa ID
			cmp.b	d0,d1
			bne.s	check_system_props_skip5
			dbf	d7,check_system_props_loop
			or.b	#$f0,d0	; 0th revision level
			cmp.b	#$f8,d0	; Lisa ID ?
			beq.s	check_pal
check_system_props_skip5
			move.w	#AGA_CHIPSET_NOT_FOUND,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			bra.s	check_system_props_quit
		ELSE
			move.b	gb_ChipRevBits0(a1),d0
			btst	#GFXB_AA_ALICE,d0
			bne.s	check_system_props_skip4
			move.w	#AGA_CHIPSET_NOT_FOUND,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			bra.s	check_system_props_quit
			CNOP 0,4
check_system_props_skip4
			btst	#GFXB_AA_LISA,d0
			bne.s	check_system_props_skip6
			move.w	#AGA_CHIPSET_NOT_FOUND,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			bra.s	check_system_props_quit
		ENDC
		CNOP 0,4
check_system_props_skip6
		btst	#REALLY_PALn,gb_DisplayFlags+BYTE_SIZE(a1)
		bne.s	check_system_props_skip7
		move.w	#CONFIG_NO_PAL,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		bra.s	check_system_props_quit
		CNOP 0,4
check_system_props_skip7
		moveq	#MEMF_FAST,d1
		CALLLIBS AvailMem
		tst.l	d0
		beq.s	check_system_props_ok
		clr.w	fast_memory_available(a3)
check_system_props_ok
		moveq	#RETURN_OK,d0
		bra	check_system_props_quit


		IFEQ requires_030_cpu
; Input
; Result
; d0.l	Return code	
			CNOP 0,4
check_cpu_requirements
			btst	#AFB_68030,cpu_flags+BYTE_SIZE(a3)
			bne.s	check_cpu_requirements_ok
			move.w	#CPU_030_REQUIRED,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
check_cpu_requirements_quit
			rts
			CNOP 0,4
check_cpu_requirements_ok
			moveq	#RETURN_OK,d0
			bra.s	check_cpu_requirements_quit
		ENDC
		IFEQ requires_040_cpu
; Input
; Result
; d0.l	Return code	
			CNOP 0,4
check_cpu_requirements
			btst	#AFB_68040,cpu_flags+BYTE_SIZE(a3)
			bne.s	check_cpu_requirements_ok
			move.w	#CPU_040_REQUIRED,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
check_cpu_requirements_quit
			rts
			CNOP 0,4
check_cpu_requirements_ok
			moveq	#RETURN_OK,d0
			bra.s	check_cpu_requirements_quit
		ENDC
		IFEQ requires_060_cpu
; Input
; Result
; d0.l	Return code	
			CNOP 0,4
check_cpu_requirements
			tst.b	cpu_flags+BYTE_SIZE(a3)
			bmi.s	check_cpu_requirements_ok
			move.w	#CPU_060_REQUIRED,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
check_cpu_requirements_quit
			rts
			CNOP 0,4
check_cpu_requirements_ok
			moveq	#RETURN_OK,d0
			bra.s	check_cpu_requirements_quit
		ENDC


		IFEQ requires_fast_memory
; Input
; Result
; d0.l	Return code	
			CNOP 0,4
check_memory_requirements
			tst.w	fast_memory_available(a3)
			beq.s	check_memory_requirements_ok
			move.w	#FAST_MEMORY_REQUIRED,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
check_memory_requirements_quit
			rts
			CNOP 0,4
check_memory_requirements_ok
			moveq	#RETURN_OK,d0
			bra.s	check_memory_requirements_quit
		ENDC


		IFEQ requires_multiscan_monitor
; Input
; Result
; d0.l	Return code	
			CNOP 0,4
do_monitor_request
			sub.l	a0,a0	; requester on workbench/public screen
			lea	monitor_request(pc),a1
			move.l	a0,a2	; no IDCMP flags
			move.l	a3,-(a7)
			move.l	a0,a3	; no arguments list
			CALLINT EasyRequestArgs
			move.l	(a7)+,a3
			CMPF.L	BOOL_FALSE,d0 ; gadget "Quit" clicked ?
			bne.s	do_monitor_request_ok
			moveq	#RETURN_FAIL,d0
do_monitor_request_quit
			rts
			CNOP 0,4
do_monitor_request_ok
			moveq	#RETURN_OK,d0
			bra.s	do_monitor_request_quit
		ENDC


		IFNE intena_bits&INTF_PORTS
; Input
; Result
; d0.l	Return code	
			CNOP 0,4
check_tcp_stack
			CALLEXEC Forbid
			lea	LibList(a6),a0
			lea	bsdsocket_name(pc),a1
			CALLLIBS FindName
			tst.l	d0
			beq.s	check_tcp_stack_skip1
			move.l	d0,a0
			tst.w	LIB_OPENCNT(a0)
			bne.s	check_tcp_stack_skip2
check_tcp_stack_skip1
			CALLLIBS Permit
check_tcp_stack_ok
			moveq	#RETURN_OK,d0
check_tcp_stack_quit
			rts
			CNOP 0,4
check_tcp_stack_skip2
			CALLLIBS Permit
			sub.l	a0,a0	; requester on workbench/public screen
			lea	tcp_stack_request(pc),a1
			move.l	a0,a2	; no IDCMP flags
			move.l	a3,-(a7)
			move.l	a0,a3	; no arguments list
			CALLINT EasyRequestArgs
			move.l	(a7)+,a3
			CMPF.L	BOOL_FALSE,d0 ; gadget "Quit" clicked ?
			bne.s	check_tcp_stack_ok
			moveq	#RETURN_FAIL,d0
			bra.s	check_tcp_stack_quit
		ENDC


; Input
; Result
; d0.l	Return code	
		CNOP 0,4
open_ciaa_resource
		lea	CIAA_name(pc),a1
		CALLEXEC OpenResource
		lea	_CIABase(pc),a0
		move.l	d0,(a0)
		bne.s	open_ciaa_resource_skip
		move.w	#CIAA_RESOURCE_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
open_ciaa_resource_quit
		rts
		CNOP 0,4
open_ciaa_resource_skip
		moveq	#0,d0		; no mask
		CALLCIA AbleICR
		move.b	d0,old_ciaa_icr(a3)
		moveq	#RETURN_OK,d0
		bra.s	open_ciaa_resource_quit


; Input
; Result
; d0.l	Return code
		CNOP 0,4
open_ciab_resource	
		lea	CIAB_name(pc),a1
		CALLEXEC OpenResource
		lea	_CIABase(pc),a0
		move.l	d0,(a0)
		bne.s	open_ciab_resource_skip
		move.w	#CIAB_RESOURCE_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
open_ciab_resource_quit
		rts
		CNOP 0,4
open_ciab_resource_skip
		moveq	#0,d0		; no mask
		CALLCIA AbleICR
		move.b	d0,old_ciab_icr(a3)
		moveq	#RETURN_OK,d0
		bra.s	open_ciab_resource_quit


; Input
; Result
; d0.l	Return code	
		CNOP 0,4
open_timer_device
		lea	timer_device_name(pc),a0
		lea	timer_io(pc),a1
		moveq	#UNIT_MICROHZ,d0
		moveq	#0,d1		; no flags
		CALLEXEC OpenDevice
		tst.l	d0
		beq.s	open_timer_device_ok
		move.w	#TIMER_DEVICE_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
open_timer_device_quit		
		rts
		CNOP 0,4
open_timer_device_ok
		moveq	#RETURN_OK,d0
		bra.s	open_timer_device_quit	
	ENDC


	IFNE cl1_size1
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_cl1_memory1
		MOVEF.L	cl1_size1,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl1_construction1(a3)
		bne.s	alloc_cl1_memory1_ok
		move.w	#CL1_CONSTR1_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_cl1_memory1_quit
		rts
		CNOP 0,4
alloc_cl1_memory1_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_cl1_memory1_quit	
	ENDC
	IFNE cl1_size2
; Input
; Result
; d0.l	Return code/Error code
		CNOP 0,4
alloc_cl1_memory2
		MOVEF.L	cl1_size2,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl1_construction2(a3)
		bne.s	alloc_cl1_memory2_ok
		move.w	#CL1_CONSTR2_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_cl1_memory2_quit
		rts
		CNOP 0,4
alloc_cl1_memory2_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_cl1_memory2_quit
	ENDC
	IFNE cl1_size3
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_cl1_memory3
		MOVEF.L	cl1_size3,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl1_display(a3)
		bne.s	alloc_cl1_memory3_ok
		move.w	#CL1_DISPLAY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_cl1_memory3_quit
		rts
		CNOP 0,4
alloc_cl1_memory3_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_cl1_memory3_quit
	ENDC


	IFNE cl2_size1
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_cl2_memory1
		MOVEF.L	cl2_size1,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl2_construction1(a3)
		bne.s	alloc_cl2_memory1_ok
		move.w	#CL2_CONSTR1_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_cl2_memory1_quit
		rts
		CNOP 0,4
alloc_cl2_memory1_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_cl2_memory1_quit
	ENDC
	IFNE cl2_size2
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_cl2_memory2
		MOVEF.L	cl2_size2,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl2_construction2(a3)
		bne.s	alloc_cl2_memory2_ok
		move.w	#CL2_CONSTR2_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_cl2_memory2_quit
		rts
		CNOP 0,4
alloc_cl2_memory2_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_cl2_memory2_quit
	ENDC
	IFNE cl2_size3
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_cl2_memory3
		MOVEF.L	cl2_size3,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl2_display(a3)
		bne.s	alloc_cl2_memory3_ok
		move.w	#CL2_DISPLAY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_cl2_memory3_quit
		rts
		CNOP 0,4
alloc_cl2_memory3_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_cl2_memory3_quit
	ENDC


	IFNE pf1_x_size1
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_pf1_memory1
		MOVEF.L	pf1_x_size1,d0
		MOVEF.L	pf1_y_size1,d1
		moveq	#pf1_depth1,d2
		bsr	do_alloc_bitmap_memory
		move.l	d0,pf1_bitmap1(a3)
		bne.s	alloc_pf1_memory1_ok
		move.w	#PF1_CONSTR1_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_pf1_memory1_quit
		rts
		CNOP 0,4
alloc_pf1_memory1_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf1_construction1(a3) ; offset 1st bitplane
		moveq	#RETURN_OK,d0
		bra.s	alloc_pf1_memory1_quit
; Input
; Result
; d0.l	Return code	
		CNOP 0,4
check_pf1_memory1
		move.l	pf1_bitmap1(a3),a0
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s	check_pf1_memory1_fail
		moveq	#pf1_depth1-1,d1
		beq.s	check_pf1_memory1_ok
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_pf1_memory1_ok
check_pf1_memory1_fail
		move.w	#PF1_CONSTR1_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_pf1_memory1_quit
		rts
		CNOP 0,4
check_pf1_memory1_ok
		moveq	#RETURN_OK,d0
		bra.s	check_pf1_memory1_quit
	ENDC
	IFNE pf1_x_size2
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_pf1_memory2
		MOVEF.L	pf1_x_size2,d0
		MOVEF.L	pf1_y_size2,d1
		moveq	#pf1_depth2,d2
		bsr	do_alloc_bitmap_memory
		move.l	d0,pf1_bitmap2(a3)
		bne.s	alloc_pf1_memory2_ok
		move.w	#PF1_CONSTR2_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_pf1_memory2_quit
		rts
		CNOP 0,4
alloc_pf1_memory2_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf1_construction2(a3) ; offset 1st bitplane
		moveq	#RETURN_OK,d0
		bra.s	alloc_pf1_memory2_quit
; Input
; Result
; d0.l	Return code	
		CNOP 0,4
check_pf1_memory2
		move.l	pf1_bitmap2(a3),a0
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s	check_pf1_memory2_fail
		moveq	#pf1_depth2-1,d1
		beq.s	check_pf1_memory2_ok
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_pf1_memory2_ok
check_pf1_memory2_fail
		move.w	#PF1_CONSTR2_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_pf1_memory2_quit
		rts
		CNOP 0,4
check_pf1_memory2_ok
		moveq	#RETURN_OK,d0
		bra.s	check_pf1_memory2_quit
	ENDC
	IFNE pf1_x_size3
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_pf1_memory3
		MOVEF.L	pf1_x_size3,d0
		MOVEF.L	pf1_y_size3,d1
		moveq	#pf1_depth3,d2
		bsr	do_alloc_bitmap_memory
		move.l	d0,pf1_bitmap3(a3)
		bne.s	alloc_pf1_memory3_ok
		move.w	#PF1_DISPLAY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_pf1_memory3_quit
		rts
		CNOP 0,4
alloc_pf1_memory3_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf1_display(a3) ; offset 1st bitplane
		moveq	#RETURN_OK,d0
		bra.s	alloc_pf1_memory3_quit
; Input
; Result
; d0.l	Return code	
		CNOP 0,4
check_pf1_memory3
		move.l	pf1_bitmap3(a3),a0
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s	check_pf1_memory3_fail
		moveq	#pf1_depth3-1,d1
		beq.s	check_pf1_memory3_ok
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_pf1_memory3_ok
check_pf1_memory3_fail
		move.w	#PF1_DISPLAY_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_pf1_memory3_quit
		rts
		CNOP 0,4
check_pf1_memory3_ok
		moveq	#RETURN_OK,d0
		bra.s	check_pf1_memory3_quit
	ENDC


	IFNE pf2_x_size1
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_pf2_memory1
		MOVEF.L	pf2_x_size1,d0
		MOVEF.L	pf2_y_size1,d1
		moveq	#pf2_depth1,d2
		bsr	do_alloc_bitmap_memory
		move.l	d0,pf2_bitmap1(a3)
		bne.s	alloc_pf2_memory1_ok
		move.w	#PF2_CONSTR1_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_pf2_memory1_quit		
		rts
		CNOP 0,4
alloc_pf2_memory1_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf2_construction1(a3) ; offset 1st bitplane
		moveq	#RETURN_OK,d0
		bra.s	alloc_pf2_memory1_quit
; Input
; Result
; d0.l	Return code	
		CNOP 0,4
check_pf2_memory1
		move.l	pf2_bitmap1(a3),a0
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s	check_pf2_memory1_fail
		moveq	#pf2_depth1-1,d1
		beq.s	check_pf2_memory1_ok
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_pf2_memory1_ok
check_pf2_memory1_fail
		move.w	#PF2_CONSTR1_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_pf2_memory1_quit
		rts
		CNOP 0,4
check_pf2_memory1_ok
		moveq	#RETURN_OK,d0
		bra.s	check_pf2_memory1_quit
	ENDC
	IFNE pf2_x_size2
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_pf2_memory2
		MOVEF.L	pf2_x_size2,d0
		MOVEF.L	pf2_y_size2,d1
		moveq	#pf2_depth2,d2
		bsr	do_alloc_bitmap_memory
		move.l	d0,pf2_bitmap2(a3)
		bne.s	alloc_pf2_memory2_ok
		move.w	#PF2_CONSTR2_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_pf2_memory2_quit
		rts
		CNOP 0,4
alloc_pf2_memory2_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf2_construction2(a3) ; offset 1st bitplane
		moveq	#RETURN_OK,d0
		bra.s	alloc_pf2_memory2_quit
; Input
; Result
; d0.l	Return code	
		CNOP 0,4
check_pf2_memory2
		move.l	pf2_bitmap2(a3),a0
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s	check_pf2_memory2_fail
		moveq	#pf2_depth2-1,d1
		beq.s	check_pf2_memory2_ok
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_pf2_memory2_ok
check_pf2_memory2_fail
		move.w	#PF2_CONSTR2_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_pf2_memory2_quit
		rts
		CNOP 0,4
check_pf2_memory2_ok
		moveq	#RETURN_OK,d0
		bra.s	check_pf2_memory2_quit
	ENDC
	IFNE pf2_x_size3
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_pf2_memory3
		MOVEF.L	pf2_x_size3,d0
		MOVEF.L	pf2_y_size3,d1
		moveq	#pf2_depth3,d2
		bsr	do_alloc_bitmap_memory
		move.l	d0,pf2_bitmap3(a3)
		bne.s	alloc_pf2_memory3_ok
		move.w	#PF2_DISPLAY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_pf2_memory3_quit
		rts
		CNOP 0,4
alloc_pf2_memory3_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf2_display(a3) ; offset 1st bitplane
		moveq	#RETURN_OK,d0
		bra.s	alloc_pf2_memory3_quit
; Input
; Result
; d0.l	Return code	
		CNOP 0,4
check_pf2_memory3
		move.l	pf2_bitmap3(a3),a0
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s	check_pf2_memory3_fail
		moveq	#pf2_depth3-1,d1
		beq.s	check_pf2_memory3_ok
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_pf2_memory3_ok
check_pf2_memory3_fail
		move.w	#PF2_DISPLAY_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_pf2_memory3_quit
		rts
		CNOP 0,4
check_pf2_memory3_ok
		moveq	#RETURN_OK,d0
		bra.s	check_pf2_memory3_quit
	ENDC


	IFNE pf_extra_number
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_pf_extra_memory
		lea	pf_extra_bitmap1(a3),a2
		lea	extra_pf1(a3),a4
		lea	pf_extra_attributes(pc),a5
		moveq	#pf_extra_number-1,d7
alloc_pf_extra_memory_loop
		move.l	(a5)+,d0	; width
		move.l	(a5)+,d1	; height
		move.l	(a5)+,d2	; depth
		bsr	do_alloc_bitmap_memory
		move.l	d0,(a2)+	; bitmap structure
		bne.s	alloc_pf_extra_memory_skip
		move.w	#PF_EXTRA_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_pf_extra_memory_quit
		rts
		CNOP 0,4
alloc_pf_extra_memory_skip
		addq.l	#bm_Planes,d0
		move.l	d0,(a4)+	; offset 1st bitplane
		dbf	d7,alloc_pf_extra_memory_loop
		moveq	#RETURN_OK,d0
		bra.s	alloc_pf_extra_memory_quit		

; Input
; Result
; d0.l	Return code	
		CNOP 0,4
check_pf_extra_memory
		lea	pf_extra_bitmap1(a3),a2
		lea	pf_extra_attributes(pc),a4
		moveq	#pf_extra_number-1,d7
check_pf_extra_memory_loop
		move.l	(a2)+,a0	; bitmap structure
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s	check_pf_extra_memory_fail
		cmp.l	#1,pf_extra_attribute_depth(a4) ; monoplane ?
		beq.s	check_pf_extra_memory_skip
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_pf_extra_memory_skip
check_pf_extra_memory_fail
		move.w	#PF_EXTRA_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_pf_extra_memory_quit		
		rts
		CNOP 0,4
check_pf_extra_memory_skip
		ADDF.W	pf_extra_attribute_size,a4 ; next entry
		dbf	d7,check_pf_extra_memory_loop
		moveq	#RETURN_OK,d0
		bra.s	check_pf_extra_memory_quit
	ENDC


	IFNE spr_x_size1
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_sprite_memory1
		lea	spr0_bitmap1(a3),a2
		lea	spr0_construction(a3),a4
		lea	sprite_attributes1(pc),a5
		moveq	#spr_number-1,d7
alloc_sprite_memory1_loop
		move.l	(a5)+,d0	; width
		move.l	(a5)+,d1	; height
		move.l	(a5)+,d2	; depth
		bsr	do_alloc_bitmap_memory
		move.l	d0,(a2)+	; bitmap structure
		bne.s	alloc_sprite_memory1_skip
		move.w	#SPR_CONSTR_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_sprite_memory1_quit
		rts
		CNOP 0,4
alloc_sprite_memory1_skip
		addq.l	#bm_Planes,d0
		move.l	d0,(a4)+	; offset 1st bitplane
		dbf	d7,alloc_sprite_memory1_loop
		moveq	#RETURN_OK,d0
		bra.s	alloc_sprite_memory1_quit


; Input
; Result
; d0.l	Return code	
		CNOP 0,4
check_sprite_memory1
		lea	spr0_bitmap1(a3),a2
		moveq	#spr_number-1,d7
check_sprite_memory1_loop
		move.l	(a2)+,a0	; bitmap structure
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s   check_sprite_memory1_fail
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_sprite_memory1_skip
check_sprite_memory1_fail
		move.w	#SPR_CONSTR_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_sprite_memory1_quit			
		rts
		CNOP 0,4
check_sprite_memory1_skip
		dbf	d7,check_sprite_memory1_loop
		moveq	#RETURN_OK,d0
		bra.s	check_sprite_memory1_quit
	ENDC


	IFNE spr_x_size2
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_sprite_memory2
		lea	spr0_bitmap2(a3),a2
		lea	spr0_display(a3),a4
		lea	sprite_attributes2(pc),a5
		moveq	#spr_number-1,d7
alloc_sprite_memory2_loop
		move.l	(a5)+,d0	; width
		move.l	(a5)+,d1	; height
		move.l	(a5)+,d2	; depth
		bsr	do_alloc_bitmap_memory
		move.l	d0,(a2)+	; bitmap structure
		bne.s	alloc_sprite_memory2_skip
		move.w	#SPR_DISPLAY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0		
alloc_sprite_memory2_quit		
		rts
		CNOP 0,4
alloc_sprite_memory2_skip
		addq.l	#bm_Planes,d0
		move.l	d0,(a4)+	; offset 1st bitplane
		dbf	d7,alloc_sprite_memory2_loop
		moveq	#RETURN_OK,d0
		bra.s	alloc_sprite_memory2_quit
; Input
; Result
; d0.l	Return code
		CNOP 0,4
check_sprite_memory2
		lea	spr0_bitmap2(a3),a2
		moveq	#spr_number-1,d7
check_sprite_memory2_loop
		move.l	(a2)+,a0	; bitmap structure
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s   check_sprite_memory2_fail
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_sprite_memory2_skip
check_sprite_memory2_fail
		move.w	#SPR_DISPLAY_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_sprite_memory2_quit			
		rts
		CNOP 0,4
check_sprite_memory2_skip
		dbf	d7,check_sprite_memory2_loop
		moveq	#RETURN_OK,d0
		bra.s	check_sprite_memory2_quit
	ENDC


	IFNE audio_memory_size
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_audio_memory
		MOVEF.L	audio_memory_size,d0
		bsr	do_alloc_chip_memory
		move.l	d0,audio_data(a3)
		bne.s	alloc_audio_memory_ok
		move.w	#AUDIO_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_audio_memory_quit
		rts
		CNOP 0,4
alloc_audio_memory_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_audio_memory_quit
	ENDC


	IFNE disk_memory_size
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_disk_memory
		MOVEF.L disk_memory_size,d0
		bsr	do_alloc_chip_memory
		move.l	d0,disk_data(a3)
		bne.s	alloc_disk_memory_ok
		move.w	#DISK_MEMORY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_disk_memory_quit
		rts
		CNOP 0,4
alloc_disk_memory_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_disk_memory_quit
	ENDC


	IFNE extra_memory_size
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_extra_memory
		MOVEF.L	extra_memory_size,d0
		bsr	do_alloc_memory
		move.l	d0,extra_memory(a3)
		bne.s	alloc_extra_memory_ok
		move.w	#EXTRA_MEMORY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_extra_memory_quit
		rts
		CNOP 0,4
alloc_extra_memory_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_extra_memory_quit
	ENDC


	IFNE chip_memory_size
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_chip_memory
		MOVEF.L	chip_memory_size,d0
		bsr	do_alloc_chip_memory
		move.l	d0,chip_memory(a3)
		bne.s	alloc_chip_memory_ok
		move.w	#CHIP_MEMORY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_chip_memory_quit
		rts
		CNOP 0,4
alloc_chip_memory_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_chip_memory_quit
	ENDC

	IFND SYS_TAKEN_OVER
; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_vectors_base_memory
		lea	read_vbr(pc),a5
		CALLEXEC Supervisor
		move.l	d0,old_vbr(a3)
		move.l	d0,a1
		CALLLIBS TypeOfMem
		and.b	#MEMF_FAST,d0
		bne.s	alloc_vectors_base_memory_ok
		tst.w	fast_memory_available(a3)
		bne.s	alloc_vectors_base_memory_ok
		move.l	#exception_vectors_size,d0
		bsr	do_alloc_fast_memory
		move.l	d0,exception_vectors_base(a3)
		bne.s	alloc_vectors_base_memory_ok
		move.w	#EXCEPTION_VECTORS_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_vectors_base_memory_quit
		rts
		CNOP 0,4
alloc_vectors_base_memory_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_vectors_base_memory_quit


; Input
; Result
; d0.l	Return code/error code
		CNOP 0,4
alloc_mouse_pointer_data
		moveq	#cleared_pointer_data_size,d0
		bsr	do_alloc_chip_memory
		move.l	d0,mouse_pointer_data(a3)
		bne.s	alloc_mouse_pointer_data_ok
		move.w	#CLEARED_SPRITE_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
alloc_mouse_pointer_data_quit
		rts
		CNOP 0,4
alloc_mouse_pointer_data_ok
		moveq	#RETURN_OK,d0
		bra.s	alloc_mouse_pointer_data_quit


		IFEQ screen_fader_enabled
; Input
; Result
; d0.l	Return code/error code
			CNOP 0,4
sf_alloc_screen_color_table
			MOVEF.L	sf_rgb32_colors_number*3*LONGWORD_SIZE,d0
			bsr	do_alloc_memory
			move.l	d0,sf_screen_color_table(a3)
			bne.s	sf_alloc_screen_color_table_ok
			move.w	#SCREEN_FADER_NO_MEMORY,custom_error_code(a3)
			moveq	#ERROR_NO_FREE_STORE,d0
sf_alloc_screen_color_table_quit
			rts
			CNOP 0,4
sf_alloc_screen_color_table_ok
			moveq	#RETURN_OK,d0
			bra.s	sf_alloc_screen_color_table_quit


; Input
; Result
; d0.l	Return code/error code
			CNOP 0,4
sf_alloc_screen_color_cache
			MOVEF.L	(1+(sf_rgb32_colors_number*3)+1)*LONGWORD_SIZE,d0
			bsr	do_alloc_memory
			move.l	d0,sf_screen_color_cache(a3) ; for LoadRGB32()
			bne.s	sf_alloc_screen_color_cache_ok
			move.w	#SCREEN_FADER_NO_MEMORY,custom_error_code(a3)
			moveq	#ERROR_NO_FREE_STORE,d0
sf_alloc_screen_color_cache_quit
			rts
			CNOP 0,4
sf_alloc_screen_color_cache_ok
			moveq	#RETURN_OK,d0
			bra.s	sf_alloc_screen_color_cache_quit
		ENDC


		IFD PASS_GLOBAL_REFERENCES
; Input
; Result
; d0.l	Return code/error code
			CNOP 0,4
init_global_references_table
			lea	global_references_table(pc),a0
			move.l	_SysBase(pc),(a0)
			move.l	_GfxBase(pc),gr_graphics_base(a0)
			rts
		ENDC


; Input
; Result
		CNOP 0,4
wait_drives_motor
		MOVEF.L	drives_motor_delay,d1
		CALLDOS Delay
		rts


		IFD SAVE_BEAMCON0
; Input
; Result
save_beamcon0_register
			CALLINT ViewAddress
			move.l	d0,a0
			CALLGRAF GfxLookUp
			move.l	d0,a0	; view extra structure
			move.l	ve_monitor(a0),a0
			move.w	ms_BeamCon0(a0),old_beamcon0(a3)
			rts
		ENDC
		

; Input
; Result
		CNOP 0,4
get_sprite_resolution
		move.l	active_screen(a3),d0
		beq.s	get_sprite_resolution_quit
		move.l	d0,a0
		move.l  sc_ViewPort+vp_ColorMap(a0),a0
		lea	video_control_tags(pc),a1
		move.l	#VTAG_SPRITERESN_GET,vctl_VTAG_SPRITERESN+ti_Tag(a1)
		move.l	a1,a2
		clr.l	vctl_VTAG_SPRITERESN+ti_Data(a1)
		CALLGRAF VideoControl
		move.l  vctl_VTAG_SPRITERESN+ti_Data(a2),old_sprite_resolution(a3)
get_sprite_resolution_quit
		rts


; Input
; Result
; d0.l	Window structure first window
		CNOP 0,4
get_first_window
		move.l	active_screen(a3),d0
		bne.s	get_first_window_skip
get_first_window_quit
		rts
		CNOP 0,4
get_first_window_skip
		move.l	d0,a0
		move.l	sc_FirstWindow(a0),d0
		bra.s	get_first_window_quit


; Input
; Result
; d0.l	Return code
		CNOP 0,4
check_screen_mode
		move.l	active_screen(a3),d0
		beq.s	check_screen_mode_ok
		move.l	d0,a0
		ADDF.W	sc_ViewPort,a0
		CALLGRAF GetVPModeID
		cmp.l	#INVALID_ID,d0
		bne.s	check_screen_mode_skip
		move.w	#VIEWPORT_MONITOR_ID_NOT_FOUND,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_screen_mode_quit
		rts
		CNOP 0,4
check_screen_mode_skip
		and.l	#MONITOR_ID_MASK,d0	; without resolution
		move.l	d0,screen_mode(a3)
check_screen_mode_ok
		moveq	#RETURN_OK,d0
		bra.s	check_screen_mode_quit


		IFEQ screen_fader_enabled
; Input
; Result
			CNOP 0,4
sf_get_screen_colors
			move.l	active_screen(a3),d0
			bne.s	sf_get_screen_colors_skip
sf_get_screen_colors_quit
			rts
			CNOP 0,4
sf_get_screen_colors_skip
			move.l	d0,a0
			move.l	sc_ViewPort+vp_ColorMap(a0),a0
			move.l	sf_screen_color_table(a3),a1 ; RGB32 values
			moveq	#0,d0	; start at COLOR00
			MOVEF.L	sf_rgb32_colors_number,d1
			CALLGRAF GetRGB32
			bra.s	sf_get_screen_colors_quit


; Input
; Result
	CNOP 0,4
sf_copy_screen_color_table
			move.l	sf_screen_color_table(a3),a0 ; source
			move.l	sf_screen_color_cache(a3),a1 ; destination
			move.w	#sf_rgb32_colors_number,(a1)+ ; header
			moveq	#0,d0
			move.w	d0,(a1)+ ; start at COLOR00
			MOVEF.W	sf_rgb32_colors_number-1,d7
sf_copy_screen_color_table_loop
			move.l	(a0)+,(a1)+ ; R32
			move.l	(a0)+,(a1)+ ; G32
			move.l	(a0)+,(a1)+ ; B32
			dbf	d7,sf_copy_screen_color_table_loop
			move.l	d0,(a1)	; end of list
			rts


; Input
; Result
			CNOP 0,4
sf_fade_out_screen
			CALLGRAF WaitTOF
			bsr.s	rgb32_screen_fader_out
			bsr	sf_rgb32_set_new_colors
			tst.w	sfo_rgb32_active(a3)
			beq.s	sf_fade_out_screen
			rts


; Input
; Result
      CNOP 0,4
rgb32_screen_fader_out
			MOVEF.W	sf_rgb32_colors_number*3,d6 ; RGB counter
			move.l	sf_screen_color_cache(a3),a0 ; source colors
			addq.w  #LONGWORD_SIZE,a0	; skip header 
			move.l	pf1_rgb8_color_table(pc),a1 ; destination COLOR00
			move.w  #sfo_fader_speed,a4 ; increase/decrease RGB values
			MOVEF.W sf_rgb32_colors_number-1,d7
rgb32_screen_fader_out_loop
			moveq   #0,d0
			move.b  (a0),d0	; source R8
			move.l  a1,d3
			swap    d3	; destination R8
			moveq   #0,d1
			move.b  LONGWORD_SIZE(a0),d1 ; source G8
			move.w  a1,d4
			lsr.w   #8,d4	; destination G8
			moveq   #0,d2
			move.b  QUADWORD_SIZE(a0),d2 ; source B8
			move.w  a1,d5
			and.w	#$00ff,d5 ; destination B8

			cmp.w	d3,d0
			bgt.s	sfo_rgb32_decrease_red
			blt.s	sfo_rgb32_increase_red
sfo_rgb32_matched_red
			subq.w	#1,d6	; destination R32 reached
sfo_rgb32_check_green
			cmp.w	d4,d1
			bgt.s	sfo_rgb32_decrease_green
			blt.s	sfo_rgb32_increase_green
sfo_rgb32_matched_green
			subq.w	#1,d6	; destination G32 reached
sfo_rgb32_check_blue
			cmp.w	d5,d2
			bgt.s	sfo_rgb32_decrease_blue
			blt.s	sfo_rgb32_increase_blue
sfo_rgb32_matched_blue
			subq.w	#1,d6	; destination B32 reached
sfo_set_rgb32
			move.b	d0,(a0)+ ; R8
			move.b	d0,(a0)+ ; R8
			move.b	d0,(a0)+ ; R8
			move.b	d0,(a0)+ ; R8
			move.b	d1,(a0)+ ; G8
			move.b	d1,(a0)+ ; G8
			move.b	d1,(a0)+ ; G8
			move.b	d1,(a0)+ ; G8
			move.b	d2,(a0)+ ; B8
			move.b	d2,(a0)+ ; B8
			move.b	d2,(a0)+ ; B8
			move.b	d2,(a0)+ ; B8
			dbf	d7,rgb32_screen_fader_out_loop
			tst.w   d6	; fading finished ?
			bne.s   sfo_rgb32_quit
			move.w  #FALSE,sfo_rgb32_active(a3)
sfo_rgb32_quit
			rts
			CNOP 0,4
sfo_rgb32_decrease_red
			sub.w	a4,d0	; decrement R8
			cmp.w	d3,d0	; destination R8 ?
			bgt.s	sfo_rgb32_check_green
			move.w	d3,d0
			bra.s	sfo_rgb32_matched_red
			CNOP 0,4
sfo_rgb32_increase_red
			add.w	a4,d0	; increment R8
			cmp.w	d3,d0	; destination R8 ?
			blt.s	sfo_rgb32_check_green
			move.w	d3,d0
			bra.s	sfo_rgb32_matched_red
			CNOP 0,4
sfo_rgb32_decrease_green
			sub.w	a4,d1	; decrement G8
			cmp.w	d4,d1	; destination G8 ?
			bgt.s	sfo_rgb32_check_blue
			move.w	d4,d1
			bra.s	sfo_rgb32_matched_green
			CNOP 0,4
sfo_rgb32_increase_green
			add.w	a4,d1	; increment G8
			cmp.w	d4,d1	; destination G8 ?
			blt.s	sfo_rgb32_check_blue
			move.w	d4,d1
			bra.s	sfo_rgb32_matched_green
			CNOP 0,4
sfo_rgb32_decrease_blue
			sub.w	a4,d2	; decrement B8
			cmp.w	d5,d2	; destination B8 ?
			bgt.s	sfo_set_rgb32
			move.w	d5,d2
			bra.s	sfo_rgb32_matched_blue
			CNOP 0,4
sfo_rgb32_increase_blue
			add.w	a4,d2	; increment B8
			cmp.w	d5,d2	; destination B8 ?
			blt.s	sfo_set_rgb32
			move.w	d5,d2
			bra.s	sfo_rgb32_matched_blue


; Input
; Result
			CNOP 0,4
sf_rgb32_set_new_colors
			move.l	active_screen(a3),d0
			bne.s   sf_rgb32_set_new_colors_skip
sf_rgb32_set_new_colors_quit
			rts
			CNOP 0,4
sf_rgb32_set_new_colors_skip
			move.l	d0,a0
			ADDF.W	sc_ViewPort,a0
			move.l	sf_screen_color_cache(a3),a1
			CALLGRAF LoadRGB32
			bra.s	sf_rgb32_set_new_colors_quit
		ENDC


; Input
; Result
; d0.l	Return code
		CNOP 0,4
open_pal_screen
		lea	pal_screen_tags(pc),a1
		IFEQ screen_fader_enabled
			move.l	sf_screen_color_cache(a3),sctl_SA_Colors32+ti_Data(a1)
		ENDC
		sub.l	a0,a0		; no NewScreen structure
		CALLINT OpenScreenTagList
		move.l	d0,pal_screen(a3)
		bne.s	open_pal_screen_ok
		move.w	#SCREEN_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
open_pal_screen_quit		
		rts
		CNOP 0,4
open_pal_screen_ok
		moveq	#RETURN_OK,d0
		bra.s	open_pal_screen_quit


; Input
; Result
; d0.l	Return code
		CNOP 0,4
check_pal_screen_mode
		move.l	pal_screen(a3),a0
		ADDF.W	sc_ViewPort,a0
		CALLGRAF GetVPModeID
		IFEQ requires_multiscan_monitor
			cmp.l	#VGA_MONITOR_ID|VGAPRODUCT_KEY,d0
		ELSE
			cmp.l	#PAL_MONITOR_ID|LORES_KEY,d0
		ENDC
		beq.s	check_pal_screen_mode_ok
		move.w	#SCREEN_MODE_NOT_AVAILABLE,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
check_pal_screen_mode_quit		
		rts
		CNOP 0,4
check_pal_screen_mode_ok
		moveq	#RETURN_OK,d0
		bra.s	check_pal_screen_mode_quit

; Input
; Result
; d0.l	Return code
		CNOP 0,4
open_invisible_window
		lea	invisible_window_tags(pc),a1
		move.l	pal_screen(a3),wtl_WA_CustomScreen+ti_Data(a1)
		sub.l	a0,a0		; no NewWindow structure
		CALLINT OpenWindowTagList
		move.l	d0,invisible_window(a3)
		bne.s	open_invisible_window_ok
		move.w	#WINDOW_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
open_invisible_window_quit
		rts
		CNOP 0,4
open_invisible_window_ok
		moveq	#RETURN_OK,d0
		bra.s	open_invisible_window_quit


; Input
; Result
	CNOP 0,4
clear_mousepointer
		move.l	invisible_window(a3),a0
		move.l	mouse_pointer_data(a3),a1
		moveq	#cleared_sprite_y_size,d0
		moveq	#cleared_sprite_x_size,d1
		moveq	#cleared_sprite_x_offset,d2
		moveq	#cleared_sprite_y_offset,d3
		CALLINT SetPointer
		rts


; Input
; Result
		CNOP 0,4
blank_display
		sub.l	a1,a1			; no view
		CALLGRAF LoadView
		CALLLIBS WaitTOF
		CALLLIBS WaitTOF		; interlace screens with two copperlists
		tst.l	gb_ActiView(a6)		; did a different view appear ?
		bne.s	blank_display
		rts


; Input
; Result
		CNOP 0,4
wait_monitor_switch
		move.l	screen_mode(a3),d0
		beq.s	wait_monitor_switch_quit
		cmp.l	#DEFAULT_MONITOR_ID,d0
		beq.s	wait_monitor_switch_quit
		cmp.l	#PAL_MONITOR_ID,d0
		bne.s	wait_monitor_switch_skip
wait_monitor_switch_quit
		rts
		CNOP 0,4
wait_monitor_switch_skip
		MOVEF.L	monitor_switch_delay,d1
		CALLDOS Delay
		bra.s	wait_monitor_switch_quit


; Input
; Result
		CNOP 0,4
enable_exclusive_blitter
		CALLGRAF OwnBlitter
		CALLLIBS WaitBlit
		rts


; Input
; Result
		CNOP 0,4
get_system_time
		lea	timer_io(pc),a1
		move.w	#TR_GETSYSTIME,IO_command(a1)
		CALLEXEC DoIO
		rts


; Input
; Result
		CNOP 0,4
disable_system
		CALLEXEC Disable
		rts


		IFD ALL_CACHES
; Input
; Result
			CNOP 0,4
enable_all_caches
			move.l	#CACRF_EnableI|CACRF_IBE|CACRF_EnableD|CACRF_DBE|CACRF_WriteAllocate|CACRF_EnableE|CACRF_CopyBack,d0 ; enable all caches
			move.l	#CACRF_EnableI|CACRF_FreezeI|CACRF_ClearI|CACRF_IBE|CACRF_EnableD|CACRF_FreezeD|CACRF_ClearD|CACRF_DBE|CACRF_WriteAllocate|CACRF_EnableE|CACRF_CopyBack,d1 ; Alle Bits ändern
			CALLEXEC CacheControl
			move.l	d0,old_cacr(a3)
			rts
		ENDC


		IFD NO_060_STORE_BUFFER
; Input
; Result
			CNOP 0,4
disable_store_buffer
			DISABLE_060_STORE_BUFFER
		ENDC
	

; Input
; Result
		CNOP 0,4
save_exception_vectors
		move.l	old_vbr(a3),a0	; source
		lea	exception_vecs_save(pc),a1 ; destination
		MOVEF.W	(exception_vectors_size/LONGWORD_SIZE)-1,d7 ; number of vectors
copy_exception_vectors_loop
		move.l	(a0)+,(a1)+
		dbf	d7,copy_exception_vectors_loop
		rts
	ENDC


; Input
; Result
	CNOP 0,4
init_exception_vectors
	IFNE intena_bits&(~INTF_SETCLR)
		lea	read_vbr(pc),a5
		CALLEXEC Supervisor
		move.l	d0,a0
	ENDC

	IFNE intena_bits&(INTF_TBE|INTF_DSKBLK|INTF_SOFTINT)
		lea	level_1_int_handler(pc),a1
		move.l	a1,LEVEL_1_AUTOVECTOR(a0)
	ENDC
	IFNE intena_bits&INTF_PORTS
		lea	level_2_int_handler(pc),a1
		move.l	a1,LEVEL_2_AUTOVECTOR(a0)
	ENDC
	IFNE intena_bits&(INTF_COPER|INTF_VERTB|INTF_BLIT)
		lea	level_3_int_handler(pc),a1
		move.l	a1,LEVEL_3_AUTOVECTOR(a0)
	ENDC
	IFNE intena_bits&(INTF_AUD0|INTF_AUD1|INTF_AUD2|INTF_AUD3)
		lea	level_4_int_handler(pc),a1
		move.l	a1,LEVEL_4_AUTOVECTOR(a0)
	ENDC
	IFNE intena_bits&(INTF_RBF|INTF_DSKSYNC)
		lea	level_5_int_handler(pc),a1
		move.l	a1,LEVEL_5_AUTOVECTOR(a0)
	ENDC
	IFNE intena_bits&INTF_EXTER
		lea	level_6_int_handler(pc),a1
		move.l	a1,LEVEL_6_AUTOVECTOR(a0)
	ENDC
	IFND SYS_TAKEN_OVER
		lea	level_7_int_handler(pc),a1
		move.l	a1,LEVEL_7_AUTOVECTOR(a0)
	ENDC

	IFD TRAP0
		lea	trap_0_handler(pc),a1
		move.l	a1,TRAP_0_VECTOR(a0)
	ENDC
	IFD TRAP1
		lea	trap_1_handler(pc),a1
		move.l	a1,TRAP_1_VECTOR(a0)
	ENDC
	IFD TRAP2
		lea	trap_2_handler(pc),a1
		move.l	a1,TRAP_2_VECTOR(a0)
	ENDC
	CALLEXEC CacheClearU
	rts


	IFND SYS_TAKEN_OVER
; Input
; Result
		CNOP 0,4
move_exception_vectors
		move.l	exception_vectors_base(a3),d0
		beq.s	move_exception_vectors_quit
		move.l	d0,a1		; destination
		move.l	old_vbr(a3),a0	; source
		MOVEF.W	(exception_vectors_size/LONGWORD_SIZE)-1,d7 ; number of vectors
move_exception_vectors_loop
		move.l	(a0)+,(a1)+
		dbf	d7,move_exception_vectors_loop
		CALLEXEC CacheClearU
		move.l	exception_vectors_base(a3),d0
		lea	write_vbr(pc),a5
		CALLLIBS Supervisor
move_exception_vectors_quit
		rts
	

; Input
; Result
save_copperlist_pointers
		move.l	_GfxBase(pc),a0
		IFNE cl1_size3
			move.l	gb_Copinit(a0),old_cop1lc(a3)
		ENDC
		IFNE cl2_size3
			move.l	gb_LOFlist(a0),old_cop2lc(a3) ; OS generally sets LOF bit
		ENDC
		rts


; Input
; Result
		CNOP 0,4
get_tod_time
		moveq	#0,d0
		move.b	CIATODHI(a4),d0	; TOD-clock bits 16..23
		swap	d0		; adjust bits
		move.b	CIATODMID(a4),d0 ; TOD-clock bits 8..15
		lsl.w	#8,d0		; adjust bits
		move.b	CIATODLOW(a4),d0 ; TOD-clock bits 0..7
		move.l	d0,tod_time(a3)
		rts


; Input
; Result
		CNOP 0,4
save_chips_registers
		move.w	(a6),old_dmacon(a3)
		move.w	INTENAR-DMACONR(a6),old_intena(a3)
		move.w	ADKCONR-DMACONR(a6),old_adkcon(a3)
	
		move.b	CIAPRA(a4),old_ciaa_pra(a3)
		move.b	CIACRA(a4),d0
		move.b	d0,old_ciaa_cra(a3)
		and.b	#~CIACRAF_START,d0 ; stop timer a
		or.b	#CIACRAF_LOAD,d0
		move.b	d0,CIACRA(a4)
		nop
		move.b	CIATALO(a4),old_ciaa_talo(a3)
		move.b	CIATAHI(a4),old_ciaa_tahi(a3)
	
		move.b	CIACRB(a4),d0
		move.b	d0,old_ciaa_crb(a3)
		and.b	#(~(CIACRBF_ALARM&(~CIACRBF_START)))&$ff,d0 ; stop timer b
		or.b	#CIACRBF_LOAD,d0
		move.b	d0,CIACRB(a4)
		nop
		move.b	CIATBLO(a4),old_ciaa_tblo(a3)
		move.b	CIATBHI(a4),old_ciaa_tbhi(a3)
		
		move.b	CIAPRB(a5),old_ciab_prb(a3)
		move.b	CIACRA(a5),d0
		move.b	d0,old_ciaa_cra(a3)
		and.b	#~CIACRAF_START,d0 ; stop timer a
		or.b	#CIACRAF_LOAD,d0
		move.b	d0,CIACRA(a5)
		nop
		move.b	CIATALO(a5),old_ciab_talo(a3)
		move.b	CIATAHI(a5),old_ciab_tahi(a3)
	
		move.b	CIACRB(a5),d0
		move.b	d0,old_ciab_crb(a3)
		and.b	#(~(CIACRBF_ALARM&(~CIACRBF_START)))&$ff,d0 ; stop timer b
		or.b	#CIACRBF_LOAD,d0 ; load counter
		move.b	d0,CIACRB(a5)
		nop
		move.b	CIATBLO(a5),old_ciab_tblo(a3)
		move.b	CIATBHI(a5),old_ciab_tbhi(a3)
		rts


; Input
; Result
		CNOP 0,4
clear_chips_registers1
		move.w	#$7fff,d0
		move.w	d0,DMACON-DMACONR(a6) ; disable DMA
		move.w	d0,INTENA-DMACONR(a6) ; disable interrupts
		move.w	d0,INTREQ-DMACONR(a6) ; clear interrupts
		move.w	d0,ADKCON-DMACONR(a6)
	
		moveq	#$7f,d0
		move.b	d0,CIAICR(a4)	; disable cia interrupts
		move.b	d0,CIAICR(a5)
		move.b	CIAICR(a4),d0	; clear cia interrupts
		move.b	CIAICR(a5),d0

		moveq	#0,d0
		move.w	d0,JOYTEST-DMACONR(a6) ; reset mouse/joystick position
		rts


; Input
; Result
		CNOP 0,4
turn_off_drive_motors
		move.b	CIAPRB(a5),d0
		moveq	#CIAF_DSKSEL0|CIAF_DSKSEL1|CIAF_DSKSEL2|CIAF_DSKSEL3,d1
		or.b	d1,d0
		move.b	d0,CIAPRB(a5)	; deactivate all drives
		or.b	#CIAF_DSKMOTOR,d0
		move.b	d0,CIAPRB(a5)	; motor off
		eor.b	d1,d0
		move.b	d0,CIAPRB(a5)	; motor off for all drives
		or.b	d1,d0
		move.b	d0,CIAPRB(a5)	; deactivate all drives
		rts
	ENDC


; Input
; Result
	CNOP 0,4
start_own_display
	bsr	wait_vbi
	bsr	wait_vbi
	moveq	#copcon_bits,d0
	move.w	d0,COPCON-DMACONR(a6)
	IFNE cl2_size3
		IFD SET_SECOND_COPPERLIST
			move.l	cl2_display(a3),COP2LC-DMACONR(a6)
		ENDC
	ENDC
	IFNE cl1_size3
		move.l	cl1_display(a3),COP1LC-DMACONR(a6)
		moveq	#0,d0
		move.w	d0,COPJMP1-DMACONR(a6)
	ENDC
	move.w	#dma_bits&(DMAF_SPRITE|DMAF_COPPER|DMAF_RASTER|DMAF_SETCLR),DMACON-DMACONR(a6) ; enable sprite/copper/bitplane DMA
	rts


	IFNE (intena_bits&(~INTF_SETCLR))|(ciaa_icr_bits&(~CIAICRF_SETCLR))|(ciab_icr_bits&(~CIAICRF_SETCLR))
; Input
; Result
		CNOP 0,4
start_own_interrupts
		IFNE intena_bits&(~INTF_SETCLR)
			move.w	#intena_bits,INTENA-DMACONR(a6)
		ENDC
		IFNE ciaa_icr_bits&(~CIAICRF_SETCLR)
			MOVEF.B	ciaa_icr_bits,d0
			move.b	d0,CIAICR(a4) ; enable CIA-A interrupts
		ENDC
		IFNE ciab_icr_bits&(~CIAICRF_SETCLR)
			MOVEF.B	ciab_icr_bits,d0
			move.b	d0,CIAICR(a5) ; enable CIA-B interrupts
		ENDC
		rts
	ENDC


	IFEQ ciaa_ta_continuous_enabled&ciaa_tb_continuous_enabled&ciab_ta_continuous_enabled&ciab_tb_continuous_enabled
; Input
; Result
		CNOP 0,4
start_cia_timers
		IFEQ ciaa_ta_continuous_enabled
			moveq	#CIACRAF_START,d0
			or.b	d0,CIACRA(a4)
		ENDC
		IFEQ ciaa_tb_continuous_enabled
			moveq	#CIACRBF_START,d0
			or.b	d0,CIACRB(a4)
		ENDC

		IFEQ ciab_ta_continuous_enabled
			moveq	#CIACRAF_START,d0
			or.b	d0,CIACRA(a5)
		ENDC
		IFEQ ciab_tb_continuous_enabled
			moveq	#CIACRBF_START,d0
			or.b	d0,CIACRB(a5)
		ENDC
		rts
	ENDC


	IFEQ ciaa_ta_continuous_enabled&ciaa_tb_continuous_enabled&ciab_ta_continuous_enabled&ciab_tb_continuous_enabled
; Input
; Result
		CNOP 0,4
stop_CIA_timers
		IFNE ciaa_ta_time
			moveq	#~CIACRAF_START,d0
			and.b	d0,CIACRA(a4) ; stop timer a
		ENDC
		IFNE ciaa_tb_time
			moveq	#~CIACRBF_START,d0
			and.b	d0,CIACRB(a4) ; stop timer b
		ENDC

		IFNE ciab_ta_time
			moveq	#~CIACRAF_START,d0
			and.b	d0,CIACRA(a5) ; stop timer a
		ENDC
		IFNE ciab_tb_time
			moveq	#~CIACRBF_START,d0
			and.b	d0,CIACRB(a5) ; stop timer b
		ENDC
		rts
	ENDC


	IFNE (intena_bits&(~INTF_SETCLR))|(ciaa_icr_bits&(~CIAICRF_SETCLR))|(ciab_icr_bits&(~CIAICRF_SETCLR))
; Input
; Result
		CNOP 0,4
stop_own_interrupts
		IFNE intena_bits&(~INTF_SETCLR)
			IFD SYS_TAKEN_OVER
				move.w	#intena_bits&(~INTF_SETCLR),INTENA-DMACONR(a6) ; disable interrupts
			ELSE
				move.w	#INTF_INTEN,INTENA-DMACONR(a6) ; disable interrupts
			ENDC
		ENDC
		rts
	ENDC


; Input
; Result
	CNOP 0,4
stop_own_display
	IFNE copcon_bits&COPCONF_CDANG
		moveq	#0,d0
		move.w	d0,COPCON-DMACONR(a6) ; copper can not access blitter registers
	ENDC
	bsr	wait_beam_position	; external routine
	IFNE dma_bits&DMAF_BLITTER
		WAITBLIT
	ENDC
	IFD SYS_TAKEN_OVER
		move.w	#dma_bits&(~DMAF_SETCLR),DMACON-DMACONR(a6) ; disable all enabled DMA channels
	ELSE
		move.w	#DMAF_MASTER,DMACON-DMACONR(a6) ; disable DMA
	ENDC
	rts


	IFND SYS_TAKEN_OVER
; Input
; Result
		CNOP 0,4
clear_chips_registers2
		move.w	#$7fff,d0
		move.w	d0,DMACON-DMACONR(a6) ; disable DMA
		move.w	d0,INTENA-DMACONR(a6) ; disable interrupts
		move.w	d0,INTREQ-DMACONR(a6) ; clear interrupts
		move.w	d0,ADKCON-DMACONR(a6)
	
		moveq	#$7f,d0
		move.b	d0,CIAICR(a4)	; disable cia interrupts
		move.b	d0,CIAICR(a5)
		IFNE ciaa_icr_bits&(~CIAICRF_SETCLR)
			move.b	CIAICR(a4),d0 ; clear cia interrupts
		ENDC
		IFNE ciab_icr_bits&(~CIAICRF_SETCLR)
			move.b	CIAICR(a5),d0 ; clear cia interrupts
		ENDC

		moveq	#0,d0
		move.w	d0,AUD0VOL-DMACONR(a6) ; no volume for all channels
		move.w	d0,AUD1VOL-DMACONR(a6)
		move.w	d0,AUD2VOL-DMACONR(a6)
		move.w	d0,AUD3VOL-DMACONR(a6)
		rts


; Input
; Result
		CNOP 0,4
restore_chips_registers
		move.b	old_ciaa_pra(a3),CIAPRA(a4)
	
		move.b	old_ciaa_talo(a3),CIATALO(a4)
		nop
		move.b	old_ciaa_tahi(a3),CIATAHI(a4)
	
		move.b	old_ciaa_tblo(a3),CIATBLO(a4)
		nop
		move.b	old_ciaa_tbhi(a3),CIATBHI(a4)
	
		move.b	old_ciaa_icr(a3),d0
		or.b	#CIAICRF_SETCLR,d0
		move.b	d0,CIAICR(a4)
	
		move.b	old_ciaa_cra(a3),d0
		btst	#CIACRAB_RUNMODE,d0 ; continuous mode ?
		bne.s	restore_chips_registers_skip1
		or.b	#CIACRAF_START,d0
restore_chips_registers_skip1
		move.b	d0,CIACRA(a4)
	
		move.b	old_ciaa_crb(a3),d0
		btst	#CIACRBB_RUNMODE,d0 ; continuous mode ?
		bne.s	restore_chips_registers_skip2
		or.b	#CIACRBF_START,d0
restore_chips_registers_skip2
		move.b	d0,CIACRB(a4)
	
		move.b	old_ciab_prb(a3),CIAPRB(a5)
	
		move.b	old_ciab_talo(a3),CIATALO(a5)
		nop
		move.b	old_ciab_tahi(a3),CIATAHI(a5)
	
		move.b	old_ciab_tblo(a3),CIATBLO(a5)
		nop
		move.b	old_ciab_tbhi(a3),CIATBHI(a5)
	
		move.b	old_ciab_icr(a3),d0
		or.b		#CIAICRF_SETCLR,d0
		move.b	d0,CIAICR(a5)
	
		move.b	old_ciab_cra(a3),d0
		btst	#CIACRAB_RUNMODE,d0 ; continuous mode ?
		bne.s	restore_chips_registers_skip3
		or.b	#CIACRAF_START,d0
restore_chips_registers_skip3
		move.b	d0,CIACRA(a5)
	
		move.b	old_ciab_crb(a3),d0
		btst	#CIACRBB_RUNMODE,d0 ; continuous mode ?
		bne.s restore_chips_registers_skip4
		or.b	#CIACRBF_START,d0
restore_chips_registers_skip4
		move.b	d0,CIACRB(a5)

		IFD _SAVE_BEAMCON0
			move.w old_beamcon0(a3),BEAMCON0-DMACONR(a6)
		ENDC

		IFNE cl2_size3
			move.l	old_cop2lc(a3),COP2LC-DMACONR(a6)
		ENDC
		IFNE cl1_size3
			move.l	old_cop1lc(a3),COP1LC-DMACONR(a6)
			moveq	#0,d0
			move.w	d0,COPJMP1-DMACONR(a6)
		ENDC
	
		move.w	old_dmacon(a3),d0
		and.w	#~DMAF_RASTER,d0 ; disable bitplane DMA
		or.w	#DMAF_SETCLR,d0
		move.w	d0,DMACON-DMACONR(a6)
		move.w	old_intena(a3),d0
		or.w	#INTF_SETCLR,d0
		move.w	d0,INTENA-DMACONR(a6)
		move.w	old_adkcon(a3),d0
		or.w	#ADKF_SETCLR,d0
		move.w	d0,ADKCON-DMACONR(a6)
		rts
	

; Input
; Result
		CNOP 0,4
get_tod_duration	
		move.l	tod_time(a3),d0 ; program start time
		moveq	#0,d1
		move.b	CIATODHI(a4),d1	; TOD bits 16..23
		swap	d1		; adjust bits
		move.b	CIATODMID(a4),d1 ; TOD bits 8..15
		lsl.w	#8,d1		; adjust bits
		move.b	CIATODLOW(a4),d1 ; TOD bits 0..7
		cmp.l	d0,d1		; TOD overflow ?
		bge.s	get_tod_duration_skip1
		move.l	#TOD_MAX,d2
		sub.l	d0,d2
		add.l	d2,d1           ; adjust time
		bra.s	get_tod_duration_skip2
		CNOP 0,4
get_tod_duration_skip1
		sub.l	d0,d1		; no TOD overflow
get_tod_duration_skip2
		move.l	d1,tod_time(a3)
		rts


; Input
; Result
		CNOP 0,4
restore_exception_vectors
		lea	exception_vecs_save(pc),a0 ; source
		move.l	old_vbr(a3),a1	; destination
		MOVEF.W	(exception_vectors_size/LONGWORD_SIZE)-1,d7 ; number of vectors
restore_exception_vectors_loop
		move.l	(a0)+,(a1)+
		dbf	d7,restore_exception_vectors_loop
		CALLEXEC CacheClearU
		rts


; Input
; Result
		CNOP 0,4
restore_vbr
		move.l	old_vbr(a3),d0
		lea	write_VBR(pc),a5
		CALLEXEC Supervisor
		rts


		IFD ALL_CACHES
; Input
; Result
			CNOP 0,4
restore_caches
			move.l	old_cacr(a3),d0
			move.l	#CACRF_EnableI|CACRF_FreezeI|CACRF_ClearI|CACRF_IBE|CACRF_EnableD|CACRF_FreezeD|CACRF_ClearD|CACRF_DBE|CACRF_WriteAllocate|CACRF_EnableE|CACRF_CopyBack,d1 ; change all bits
			CALLEXEC CacheControl
			rts
		ENDC


		IFD NO_060_STORE_BUFFER
; Input
; Result
			CNOP 0,4
restore_store_buffer
			ENABLE_060_STORE_BUFFER
		ENDC


; Input
; Result
		CNOP 0,4
enable_system
		CALLEXEC Enable
		rts


; Input
; Result
		CNOP 0,4
update_system_time
		move.l	exec_base.w,a6
		move.l	tod_time(a3),d0 ; time the system was disabled
		moveq	#0,d1
		move.b	VBlankFrequency(a6),d1
		divu.w	d1,d0		; / vertical frequency (50Hz) = Unix seconds, remainder Unix microseconds
		lea	timer_io(pc),a1
		move.w	#TR_SETSYSTIME,IO_command(a1)
		move.l	d0,d1
		ext.l	d0
		swap	d1		; remainder
		add.l	d0,IO_size+TV_SECS(a1)
		mulu.w	#10000,d1	; convert to microseconds
		add.l	d1,IO_size+TV_MICRO(a1)
		CALLLIBS DoIO
		rts
	

; Input
; Result
		CNOP 0,4
disable_exclusive_blitter
		CALLGRAF DisownBlitter
		rts


; Input
; Result
		CNOP 0,4
restore_sprite_resolution
		move.l	pal_screen(a3),a2
		move.l	sc_ViewPort+vp_ColorMap(a2),a0
		lea	video_control_tags(pc),a1
		move.l	#VTAG_SPRITERESN_SET,vctl_VTAG_SPRITERESN+ti_Tag(a1)
		move.l	old_sprite_resolution(a3),vctl_VTAG_SPRITERESN+ti_Data(a1)
		CALLGRAF VideoControl
		move.l	a2,a0			; screen structure
		CALLINT MakeScreen
		CALLLIBS RethinkDisplay
		rts


; Input
; Result
	CNOP 0,4
close_invisible_window
		move.l	invisible_window(a3),a0
		CALLINT CloseWindow
		rts


; Input
; Result
		CNOP 0,4
close_pal_screen
		move.l	pal_screen(a3),a0
		CALLINT CloseScreen
		rts


; Input
; Result
		CNOP 0,4
activate_first_window
		move.l	first_window(a3),d0
		bne.s	activate_first_window_skip
activate_first_window_quit
		rts
		CNOP 0,4
activate_first_window_skip
		move.l	d0,a0
		CALLINT ActivateWindow
		bra.s	activate_first_window_quit


		IFEQ screen_fader_enabled
; Input
; Result
			CNOP 0,4
sf_fade_in_screen
			CALLGRAF WaitTOF
			bsr	rgb32_screen_fader_in
			bsr	sf_rgb32_set_new_colors
			tst.w	sfi_rgb32_active(a3)
			beq.s	sf_fade_in_screen
			rts


; Input
; Result
			CNOP 0,4	
rgb32_screen_fader_in
			MOVEF.W	sf_rgb32_colors_number*3,d6 ; RGB counter
			move.l	sf_screen_color_cache(a3),a0 ; source colors
			addq.w	#LONGWORD_SIZE,a0 ; skip offset
			move.l	sf_screen_color_table(a3),a1 ; destination colors
			move.w	#sfi_fader_speed,a4 ; increase/decrease RGB
			MOVEF.W	sf_rgb32_colors_number-1,d7
rgb32_screen_fader_in_loop
			moveq	#0,d0
			move.b	(a0),d0 ; R8
			moveq	#0,d1
			move.b	LONGWORD_SIZE(a0),d1 ; G8
			moveq	#0,d2
			move.b	QUADWORD_SIZE(a0),d2 ; B8
			moveq	#0,d3
			move.b	(a1),d3	; R8 destination
			moveq	#0,d4
			move.b	LONGWORD_SIZE(a1),d4 ; G8 destination
			moveq	#0,d5
			move.b	QUADWORD_SIZE(a1),d5 ; B8 destination

			cmp.w	d3,d0
			bgt.s	sfi_rgb32_decrease_red
			blt.s	sfi_rgb32_increase_red
sfi_rgb32_matched_red
			subq.w	#1,d6	; destination R8 reached
sfi_rgb32_check_green
			cmp.w	d4,d1
			bgt.s	sfi_rgb32_decrease_green
			blt.s	sfi_rgb32_increase_green
sfi_rgb32_matched_green
			subq.w	#1,d6	; destination G8 reached
sfi_rgb32_check_blue
			cmp.w	d5,d2
			bgt.s	sfi_rgb32_decrease_blue
			blt.s	sfi_rgb32_increase_blue
sfi_rgb32_matched_blue
			subq.w	#1,d6	; destination B8 reached

sfi_set_rgb32
			move.b	d0,(a0)+ ; R8
			move.b	d0,(a0)+ ; R8
			move.b	d0,(a0)+ ; R8
			move.b	d0,(a0)+ ; R8
			move.b	d1,(a0)+ ; G8
			move.b	d1,(a0)+ ; G8
			move.b	d1,(a0)+ ; G8
			move.b	d1,(a0)+ ; G8
			move.b	d2,(a0)+ ; B8
			move.b	d2,(a0)+ ; B8
			addq.w	#QUADWORD_SIZE,a1 ; next 32 bit tripple
			move.b	d2,(a0)+ ; B8
			addq.w	#LONGWORD_SIZE,a1
			move.b	d2,(a0)+ ; B8
			dbf	d7,rgb32_screen_fader_in_loop
			tst.w	d6	; fading-in finished ?
			bne.s	sfi_rgb32_quit
			move.w	#FALSE,sfi_rgb32_active(a3)
sfi_rgb32_quit
			rts
			CNOP 0,4
sfi_rgb32_decrease_red
			sub.w	a4,d0	; decrease R8
			cmp.w	d3,d0	; R8 destination ?
			bgt.s	sfi_rgb32_check_green
			move.w	d3,d0	; R8 destination
			bra.s	sfi_rgb32_matched_red
			CNOP 0,4
sfi_rgb32_increase_red
			add.w   a4,d0	; increase R8
			cmp.w   d3,d0	; R8 destination ?
			blt.s   sfi_rgb32_check_green
			move.w  d3,d0	; R8 destination
			bra.s   sfi_rgb32_matched_red
			CNOP 0,4
sfi_rgb32_decrease_green
			sub.w	a4,d1	; decrease G8
			cmp.w	d4,d1	; G8 destination ?
			bgt.s	sfi_rgb32_check_blue
			move.w	d4,d1	; G8 destination
			bra.s	sfi_rgb32_matched_green
			CNOP 0,4
sfi_rgb32_increase_green
			add.w	a4,d1	; increase G8
			cmp.w	d4,d1	; G8 destination ?
			blt.s	sfi_rgb32_check_blue
			move.w	d4,d1	; G8 destination
			bra.s	sfi_rgb32_matched_green
			CNOP 0,4
sfi_rgb32_decrease_blue
			sub.w	a4,d2	; decrease B8
			cmp.w	d5,d2	; B8 destination ?
			bgt.s	sfi_set_rgb32
			move.w	d5,d2	; B8 destination
			bra.s	sfi_rgb32_matched_blue
			CNOP 0,4
sfi_rgb32_increase_blue
			add.w	a4,d2	; increase B8
			cmp.w	d5,d2	; B8 destination ?
			blt.s	sfi_set_rgb32
			move.w	d5,d2	; B8 destination
			bra.s	sfi_rgb32_matched_blue
		ENDC


		IFEQ text_output_enabled
; Input
; Result
			CNOP 0,4
print_formatted_text

			lea	format_string(pc),a0
			lea	data_stream(pc),a1 ; data format string
			lea	put_ch_process(pc),a2 ; copy routine
			move.l	a3,-(a7)
			lea	put_ch_data(pc),a3 ; output string
			CALLEXEC RawDoFmt
			move.l	(a7)+,a3
			move.l	output_handle(a3),d1
			lea	put_ch_data(pc),a0 
			move.l	a0,d2	; text
			moveq	#-1,d3	; characters counter
print_formatted_text_loop
			addq.w	#1,d3
			tst.b	(a0)+	; nullbyte ?
			dbeq.s	print_formatted_text_loop
			CALLDOS Write
			rts
			CNOP 0,4
put_ch_process
			move.b	d0,(a3)+ ; write data into output string
			rts
		ENDC


; Input
; Result
		CNOP 0,4
free_vectors_base_memory
		move.l	exception_vectors_base(a3),d0
		bne.s   free_vectors_base_memory_skip
free_vectors_base_memory_quit
		rts
		CNOP 0,4
free_vectors_base_memory_skip
		move.l	d0,a1
		move.l	#exception_vectors_size,d0
		CALLEXEC FreeMem
		bra.s	free_vectors_base_memory_quit
	ENDC


	IFNE CHIP_memory_size
; Input
; Result
		CNOP 0,4
free_chip_memory
		move.l	chip_memory(a3),d0
		bne.s	free_chip_memory_skip
free_chip_memory_quit
		rts
		CNOP 0,4
free_chip_memory_skip
		move.l	d0,a1
		MOVEF.L	chip_memory_size,d0
		CALLEXEC FreeMem
		bra.s	free_chip_memory_quit
	ENDC


	IFNE extra_memory_size
; Input
; Result
		CNOP 0,4
free_extra_memory
		move.l	extra_memory(a3),d0
		bne.s	free_extra_memory_skip
free_extra_memory_quit
		rts
		CNOP 0,4
free_extra_memory_skip
		move.l	d0,a1
		MOVEF.L extra_memory_size,d0
		CALLEXEC FreeMem
		bra.s	free_extra_memory_quit
	ENDC


	IFNE disk_memory_size
; Input
; Result
		CNOP 0,4
free_disk_memory
		move.l	disk_data(a3),d0
		bne.s	free_disk_memory_skip
free_disk_memory_quit
		rts
		CNOP 0,4
free_disk_memory_skip
		move.l	d0,a1
		MOVEF.L	disk_memory_size,d0
		CALLEXEC FreeMem
		bra.s	free_disk_memory_quit
	ENDC


	IFNE audio_memory_size
; Input
; Result
		CNOP 0,4
free_audio_memory
		move.l	audio_data(a3),d0
		bne.s	free_audio_memory_skip
free_audio_memory_quit
		rts
		CNOP 0,4
free_audio_memory_skip
		move.l	d0,a1
		MOVEF.L	audio_memory_size,d0
		CALLEXEC FreeMem
		bra.s	free_audio_memory_quit
	ENDC


	IFNE spr_x_size2
; Input
; Result
		CNOP 0,4
free_sprite_memory2
		lea	spr0_bitmap2(a3),a2
		lea	sprite_attributes2(pc),a4
		moveq	#spr_number-1,d7
free_sprite_memory2_loop
		move.l	(a2)+,d0
		bne.s	free_sprite_memory2_skip
free_sprite_memory2_quit
		rts
		CNOP 0,4
free_sprite_memory2_skip
		move.l	d0,a0
		CALLGRAF FreeBitMap
		dbf	d7,free_sprite_memory2_loop
		bra.s	free_sprite_memory2_quit
	ENDC


	IFNE spr_x_size1
; Input
; Result
		CNOP 0,4
free_sprite_memory1
		lea	spr0_bitmap1(a3),a2
		moveq	#spr_number-1,d7
free_sprite_memory1_loop
		move.l	(a2)+,d0
		bne.s	free_sprite_memory1_skip
free_sprite_memory1_quit
		rts
		CNOP 0,4
free_sprite_memory1_skip
		move.l	d0,a0
		CALLGRAF FreeBitMap
		dbf	d7,free_sprite_memory1_loop
		bra.s	free_sprite_memory1_quit
	ENDC


	IFNE pf_extra_number
; Input
; Result
		CNOP 0,4
free_pf_extra_memory
		lea	pf_extra_bitmap1(a3),a2
		moveq	#pf_extra_number-1,d7
free_pf_extra_memory_loop
		move.l	(a2)+,d0
		bne.s	free_pf_extra_memory_skip
free_pf_extra_memory_quit
		rts
		CNOP 0,4
free_pf_extra_memory_skip
		move.l	d0,a0
		CALLGRAF FreeBitMap
		dbf	d7,free_pf_extra_memory_loop
		bra.s	free_pf_extra_memory_quit
	ENDC


	IFNE pf2_x_size3
; Input
; Result
		CNOP 0,4
free_pf2_memory3
		move.l	pf2_bitmap3(a3),d0
		bne.s	free_pf2_memory3_skip
free_pf2_memory3_quit
		rts
		CNOP 0,4
free_pf2_memory3_skip		
		move.l	d0,a0
		CALLGRAF FreeBitMap
		bra.s	free_pf2_memory3_quit
	ENDC
	IFNE pf2_x_size2
; Input
; Result
		CNOP 0,4
free_pf2_memory2
		move.l	pf2_bitmap2(a3),d0
		bne.s	free_pf2_memory2_skip
free_pf2_memory2_quit
		rts
		CNOP 0,4
free_pf2_memory2_skip		
		move.l	d0,a0
		CALLGRAF FreeBitMap
		bra.s	free_pf2_memory2_quit
	ENDC
	IFNE pf2_x_size1
; Input
; Result
		CNOP 0,4
free_pf2_memory1
		move.l	pf2_bitmap1(a3),d0
		bne.s	free_pf2_memory1_skip
free_pf2_memory1_quit
		rts
		CNOP 0,4
free_pf2_memory1_skip		
		move.l	d0,a0
		CALLGRAF FreeBitMap
		bra.s	free_pf2_memory1_quit
		rts
	ENDC


	IFNE pf1_x_size3
; Input
; Result
		CNOP 0,4
free_pf1_memory3
		move.l	pf1_bitmap3(a3),d0
		bne.s	free_pf1_memory3_skip
free_pf1_memory3_quit
		rts
		CNOP 0,4
free_pf1_memory3_skip		
		move.l	d0,a0
		CALLGRAF FreeBitMap
		bra.s	free_pf1_memory3_quit
	ENDC
	IFNE pf1_x_size2
; Input
; Result
		CNOP 0,4
free_pf1_memory2
		move.l	pf1_bitmap2(a3),d0
		bne.s	free_pf1_memory2_skip
free_pf1_memory2_quit
		rts
		CNOP 0,4
free_pf1_memory2_skip		
		move.l	d0,a0
		CALLGRAF FreeBitMap
		bra.s	free_pf1_memory2_quit
	ENDC
	IFNE pf1_x_size1
; Input
; Result
		CNOP 0,4
free_pf1_memory1
		move.l	pf1_bitmap1(a3),d0
		bne.s	free_pf1_memory1_skip
free_pf1_memory1_quit
		rts
		CNOP 0,4
free_pf1_memory1_skip		
		move.l	d0,a0
		CALLGRAF FreeBitMap
		bra.s	free_pf1_memory1_quit
	ENDC


	IFNE cl2_size3
; Input
; Result
		CNOP 0,4
free_cl2_memory3
		move.l	cl2_display(a3),d0
		bne.s	free_cl2_memory3_skip
free_cl2_memory3_quit
		rts
		CNOP 0,4
free_cl2_memory3_skip
		move.l	d0,a1
		MOVEF.L	cl2_size3,d0
		CALLEXEC FreeMem
		bra.s	free_cl2_memory3_quit
	ENDC
	IFNE cl2_size2
; Input
; Result
		CNOP 0,4
free_cl2_memory2
		move.l	cl2_construction2(a3),d0
		bne.s	free_cl2_memory2_skip
free_cl2_memory2_quit
		rts
		CNOP 0,4
free_cl2_memory2_skip
		move.l	d0,a1
		MOVEF.L	cl2_size2,d0
		CALLEXEC FreeMem
		bra.s	free_cl2_memory2_quit
	ENDC
	IFNE cl2_size1
; Input
; Result
		CNOP 0,4
free_cl2_memory1
		move.l	cl2_construction1(a3),d0
		bne.s	free_cl2_memory1_skip
		rts
free_cl2_memory1_quit
		CNOP 0,4
free_cl2_memory1_skip
		move.l	d0,a1
		MOVEF.L	cl2_size1,d0
		CALLEXEC FreeMem
		bra.s	free_cl2_memory2_quit
	ENDC


	IFNE cl1_size3
; Input
; Result
		CNOP 0,4
free_cl1_memory3
		move.l	cl1_display(a3),d0
		bne.s	free_cl1_memory3_skip
free_cl1_memory3_quit
		rts
		CNOP 0,4
free_cl1_memory3_skip
		move.l	d0,a1
		MOVEF.L	cl1_size3,d0
		CALLEXEC FreeMem
		bra.s	free_cl1_memory3_quit
	ENDC
	IFNE cl1_size2
; Input
; Result
		CNOP 0,4
free_cl1_memory2
		move.l	cl1_construction2(a3),d0
		bne.s	free_cl1_memory2_skip
free_cl1_memory2_quit
		rts
		CNOP 0,4
free_cl1_memory2_skip
		move.l	d0,a1
		MOVEF.L	cl1_size2,d0
		CALLEXEC FreeMem
		bra.s	free_cl1_memory2_quit
	ENDC
	IFNE cl1_size1
; Input
; Result
		CNOP 0,4
free_cl1_memory1
		move.l	cl1_construction1(a3),d0
		bne.s	free_cl1_memory1_skip
free_cl1_memory1_quit
		rts
		CNOP 0,4
free_cl1_memory1_skip
		move.l	d0,a1
		MOVEF.L	cl1_size1,d0
		CALLEXEC FreeMem
		bra.s	free_cl1_memory1_quit
	ENDC


	IFND SYS_TAKEN_OVER
		IFEQ screen_fader_enabled
; Input
; Result
			CNOP 0,4
sf_free_screen_color_cache
			move.l	sf_screen_color_cache(a3),d0
			bne.s	sf_free_screen_color_cache_skip
sf_free_screen_color_cache_quit
			rts
			CNOP 0,4
sf_free_screen_color_cache_skip
			move.l	d0,a1
			MOVEF.L	(1+(sf_rgb32_colors_number*3)+1)*LONGWORD_SIZE,d0
			CALLEXEC FreeMem
			bra.s	sf_free_screen_color_cache_quit


; Input
; Result
			CNOP 0,4
sf_free_screen_color_table
			move.l	sf_screen_color_table(a3),d0
			bne.s	sf_free_screen_color_table_skip
sf_free_screen_color_table_quit
			rts
			CNOP 0,4
sf_free_screen_color_table_skip
			move.l	d0,a1
			MOVEF.L	sf_rgb32_colors_number*3*LONGWORD_SIZE,d0
			CALLEXEC FreeMem
			bra.s	sf_free_screen_color_table_quit
		ENDC


; Input
; Result
		CNOP 0,4
free_mouse_pointer_data
		move.l	mouse_pointer_data(a3),d0
		bne.s	free_mouse_pointer_data_skip
free_mouse_pointer_data_quit
		rts
		CNOP 0,4
free_mouse_pointer_data_skip
		move.l	d0,a1
		moveq	#cleared_pointer_data_size,d0
		CALLEXEC FreeMem
		bra.s	free_mouse_pointer_data_quit


; Input
; Result
		CNOP 0,4
close_timer_device
		lea	timer_io(pc),a1
		CALLEXEC CloseDevice
		rts


; Input
; Result
		CNOP 0,4
close_intuition_library
		move.l	_IntuitionBase(pc),a1
		CALLEXEC CloseLibrary
		rts


; Input
; Result
		CNOP 0,4
close_graphics_library
		move.l	_GfxBase(pc),a1
		CALLEXEC CloseLibrary
		rts

	
; Input
; Result
		CNOP 0,4
print_error_message
		move.w	custom_error_code(a3),d4
		beq.s	print_error_message_ok
		CALLINT WBenchToFront
		lea	raw_name(pc),a0
		move.l	a0,d1
		move.l	#MODE_OLDFILE,d2
		CALLDOS Open
		move.l	d0,raw_handle(a3)
		bne.s	print_error_message_skip
		moveq	#RETURN_FAIL,d0
print_error_message_quit
		rts
		CNOP 0,4
print_error_message_skip
		subq.w	#1,d4		; count starts at 0
		MULUF.W	8,d4,d1
		lea	custom_error_table(pc),a0
		move.l	(a0,d4.w),d2	; error text
		move.l	LONGWORD_SIZE(a0,d4.w),d3 ; error text length
		move.l	d0,d1		; file handle
		CALLLIBS Write
		move.l	raw_handle(a3),d1
		lea	raw_buffer(a3),a0
		move.l	a0,d2		; buffer
		moveq	#1,d3		; read 1 character
		CALLLIBS Read
		move.l	raw_handle(a3),d1
		CALLLIBS Close
		bsr.s	original_screen_to_front
print_error_message_ok
		moveq	#RETURN_OK,d0
		bra.s	print_error_message_quit


; Input
; Result
		CNOP 0,4
original_screen_to_front
		move.l	active_screen(a3),d0
		bne.s	original_screen_to_front_skip
original_screen_to_front_quit
		rts
		CNOP 0,4
original_screen_to_front_skip
		move.l	d0,a4
		bsr.s	get_first_screen
		cmp.l	d0,a4
		beq.s	original_screen_to_front_quit
		move.l	a4,a0
		CALLINT ScreenToFront
		bra.s	original_screen_to_front_quit


; Input
; Result
; d0.l	Pointer screen structure 1st screen
		CNOP 0,4
get_first_screen
		moveq	#0,d0		; all locks
		CALLINT LockIBase
		move.l	d0,a0
		move.l	ib_FirstScreen(a6),a2
		CALLLIBS UnlockIBase
		move.l	a2,d0
		rts


; Input
; Result
		CNOP 0,4
close_dos_library
		move.l	_DOSBase(pc),a1
		CALLEXEC CloseLibrary
		rts


		IFEQ workbench_start_enabled
; Input
; Result
			CNOP 0,4
reply_workbench_message
			move.l	workbench_message(a3),d2
			bne.s	workbench_message_skip
reply_workbench_message_quit
			rts
			CNOP 0,4
workbench_message_skip
			CALLEXEC Forbid
			move.l	d2,a1
			CALLLIBS ReplyMsg
			CALLLIBS Permit
			bra.s	reply_workbench_message_quit
		ENDC
	ENDC

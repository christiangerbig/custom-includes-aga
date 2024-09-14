; Datum:	08.09.2024
; Version:	1.0

; Globale Labels

; SYS_TAKEN_OVER
; PASS_RETURN_CODE
; PASS_GLOBAL_REFERENCES
; WRAPPER

; CUSTOM_MEMORY_USED

; SAVE_BEAMCON0

; AGA_CHECK_BY_HARDWARE

; ALL_CACHES
; NO_060_STORE_BUFFER

; TRAP0
; TRAP1
; TRAP2

; SET_SECOND_COPPERLIST

; MEASURE_RASTERTIME


	IFND SYS_TAKEN_OVER
		INCLUDE "screen-colors.i"
	
		INCLUDE "sprite-pointer-data.i"

		INCLUDE "custom-error-entry.i"

		INCLUDE "taglists-offsets.i"
	ENDC

	IFD PASS_GLOBAL_REFERENCES
		INCLUDE "global-references-offsets.i"
	ENDC


WAITMOUSE			MACRO
wm
	move.w	$dff006,$dff180
	btst	#2,$dff016
	bne.s	wm
	ENDM


; ** Beginn **
	movem.l d2-d7/a2-a6,-(a7)
	lea	variables(pc),a3	; Basisadresse aller Variablen
	bsr	init_variables
	IFD SYS_TAKEN_OVER
		tst.l	dos_return_code(a3)
		bne	end_final
	ENDC
	bsr	init_structures

	IFD SYS_TAKEN_OVER
		IFD CUSTOM_MEMORY_USED
			bsr	init_custom_memory_table ; Wird von außen aufgerufen
			bsr	extend_global_references_table ; Wird von außen aufgerufen
		ENDC
	ELSE
		bsr	init_custom_error_table
		bsr	init_tag_lists

		IFEQ workbench_start_enabled
			bsr	check_workbench_start
			move.l	d0,dos_return_code(a3)
			bne	end_final
		ENDC

		bsr	open_dos_library
		move.l	d0,dos_return_code(a3)
		bne	cleanup_workbench_message
		bsr	get_output
		move.l	d0,dos_return_code(a3)
		bne	cleanup_dos_library
		bsr	open_graphics_library
		move.l	d0,dos_return_code(a3)
		bne	cleanup_dos_library
		bsr	check_system_properties
		move.l	d0,dos_return_code(a3)
		bne	cleanup_graphics_library
		bsr	open_intuition_library
		move.l	d0,dos_return_code(a3)
		bne	cleanup_graphics_library

		IFEQ requires_030_cpu
			bsr	check_cpu_requirements
			move.l	d0,dos_return_code(a3)
			bne	cleanup_intuition_library
		ENDC
		IFEQ requires_040_cpu
			bsr	check_cpu_requirements
			move.l	d0,dos_return_code(a3)
			bne	cleanup_intuition_library
		ENDC
		IFEQ requires_060_cpu
			bsr	check_cpu_requirements
			move.l	d0,dos_return_code(a3)
			bne	cleanup_intuition_library
		ENDC
		IFEQ requires_fast_memory
			bsr	check_memory_requirements
			move.l	d0,dos_return_code(a3)
			bne	cleanup_intuition_library
		ENDC
		IFEQ requires_multiscan_monitor
			bsr	do_monitor_request
			move.l	d0,dos_return_code(a3)
			bne	cleanup_intuition_library
		ENDC

		IFNE intena_bits&INTF_PORTS
			bsr	check_tcp_stack
			move.l	d0,dos_return_code(a3)
			bne	cleanup_intuition_library
		ENDC

		bsr	open_ciaa_resource
		move.l	d0,dos_return_code(a3)
		bne	cleanup_intuition_library
		bsr	open_ciab_resource
		move.l	d0,dos_return_code(a3)
		bne	cleanup_intuition_library

		bsr	open_timer_device
		move.l	d0,dos_return_code(a3)
		bne	cleanup_intuition_library
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
		bne	cleanup__all_memory
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
		bne.s	cleanup_all_memory
	ENDC
	
	IFD SYS_TAKEN_OVER
		IFD CUSTOM_MEMORY_USED
			bsr	alloc_custom_memory ; Wird von außen aufgerufen
			move.l	d0,dos_return_code(a3)
			bne.s	cleanup_all_memory
		ENDC
	ELSE
		bsr	alloc_vectors_base_memory
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory

		bsr	alloc_cleared_sprite_data
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

	bsr	init_own_variables	; wird von außen aufgerufen

	IFND SYS_TAKEN_OVER
		bsr	wait_drives_motor
		IFD SAVE_BEAMCON0
			bsr	save_beamcon0_register
		ENDC
		bsr	get_active_screen
		bsr	get_active_screen_mode
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		IFEQ screen_fader_enabled
			bsr	sf_get_active_screen_colors
			bsr	sf_copy_screen_color_table

			bsr	sf_fade_out_active_screen
		ENDC

		bsr	open_degrade_screen
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		bsr	check_degrade_screen_mode
		move.l	d0,dos_return_code(a3)
		bne	cleanup_all_memory
		bsr	get_sprite_resolution
		bsr	open_invisible_window
		move.l	d0,dos_return_code(a3)
		bne	cleanup_degrade_screen
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
	lea	_CIAA-_CIAB(a5),a4	; CIA-A-Base
	move.l	#_CUSTOM+DMACONR,a6
	
	IFND SYS_TAKEN_OVER
		bsr	save_copperlist_pointers
		bsr	get_tod_time
		bsr	save_chips_registers
		bsr	clear_chips_registers1
		bsr	turn_off_drive_motors
	ENDC

	move.w	#dma_bits&(~(DMAF_SPRITE|DMAF_COPPER|DMAF_RASTER)),DMACON-DMACONR(a6) ; DMA ausser Sprite/Copper/Bitplane-DMA an
	bsr	init_all		; wird von außen aufgerufen
	bsr	start_own_display
	IFNE (intena_bits-INTF_SETCLR)|(ciaa_icr_bits-CIAICRF_SETCLR)|(ciab_icr_bits-CIAICRF_SETCLR)
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

	bsr	main_routine		; wird von außen aufgerufen

	IFD PASS_RETURN_CODE
		move.l	d0,dos_return_code(a3)
		move.w	d1,custom_error_code(a3)
	ENDC

	IFEQ ciaa_ta_continuous_enabled&ciaa_tb_continuous_enabled&ciab_ta_continuous_enabled&ciab_tb_continuous_enabled
		bsr	stop_cia_timers
	ENDC
	IFNE (intena_bits-INTF_SETCLR)|(ciaa_icr_bits-CIAICRF_SETCLR)|(ciab_icr_bits-CIAICRF_SETCLR)
		bsr	stop_own_interrupts
	ENDC
	bsr	stop_own_display

	IFND SYS_TAKEN_OVER
		bsr	clear_chips_registers2
		bsr	restore_chips_registers
		bsr	get_tod_duration

		bsr	restore_vbr

		IFD ALL_CACHES
			bsr	restore_caches
		ENDC

		IFD NO_060_STORE_BUFFER
			bsr	restore_store_buffer
		ENDC
	
		bsr	restore_exception_vectors

		bsr	enable_system

		bsr	update_system_time

		bsr	disable_exclusive_blitter

cleanup_invisible_window
		bsr	close_invisible_window
cleanup_display
		bsr	restore_sprite_resolution
		bsr	wait_monitor_switch
cleanup_degrade_screen
		bsr	close_degrade_screen
cleanup_active_screen_colors
		bsr	check_active_screen_priority
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
			bsr	free_custom_memory ; Wird von außen aufgerufen
		ENDC
	ELSE
		IFEQ screen_fader_enabled
			bsr	sf_free_screen_color_cache
			bsr	sf_free_screen_color_table
		ENDC

		bsr	free_cleared_sprite_data

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

cleanup_intuition_library
		bsr	close_intuition_library

cleanup_graphics_library
		bsr	close_graphics_library

cleanup_dos_library
		bsr	print_error_message
		move.l	d0,dos_return_code(a3)
		bsr	close_dos_library

cleanup_workbench_message
		IFEQ workbench_start_enabled
			bsr		 reply_workbench_message
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
; d0.l	... Kein Rückgabewert	
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
		move.l	d0,(a3)		; Shell: Länge des Eingabestrings
		move.l	a0,shell_parameters_pointer(a3) ; Shell: Zeiger auf Eingabestring

		moveq	#TRUE,d0
		IFEQ workbench_start_enabled
			move.l	d0,workbench_message(a3)
		ENDC
		moveq	#FALSE,d1
		move.w	d1,fast_memory_available_enabled(a3)

		IFEQ screen_fader_enabled
			move.w	d0,sfi_active(a3)
			move.w	d0,sfo_active(a3)
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
; d0.l	... Kein Rückgabewert	
	CNOP 0,4
init_structures
	IFND SYS_TAKEN_OVER
		bsr	init_easy_request
		bsr	init_degrade_screen_colors
		bsr	init_timer_io
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
; d0.l	... Kein Rückgabewert	
		CNOP 0,4
init_custom_error_table
		lea	custom_error_table(pc),a0
		INIT_CUSTOM_ERROR_ENTRY GFX_LIBRARY_COULD_NOT_OPEN,error_text_gfx_library,error_text_gfx_library_end-error_text_gfx_library

		INIT_CUSTOM_ERROR_ENTRY KICKSTART_VERSION_NOT_FOUND,error_text_kickstart,error_text_kickstart_end-error_text_kickstart
		INIT_CUSTOM_ERROR_ENTRY CPU_020_NOT_FOUND,error_text_cpu_1,error_text_cpu_1_end-error_text_cpu_1
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

		INIT_CUSTOM_ERROR_ENTRY INTUI_LIBRARY_COULD_NOT_OPEN,error_text_intui_library,error_text_intui_library_end-error_text_intui_library

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

		INIT_CUSTOM_ERROR_ENTRY AUDIO_NO_MEMORY,error_text_audio_memory,error_text_audio_memory_end-error_text_audio_memory

		INIT_CUSTOM_ERROR_ENTRY DISK_NO_MEMORY,error_text_disk_memory,error_text_disk_memory_end-error_text_disk_memory

		INIT_CUSTOM_ERROR_ENTRY EXTRA_MEMORY_NO_MEMORY,error_text_extra_memory,error_text_extra_memory_end-error_text_extra_memory

		INIT_CUSTOM_ERROR_ENTRY CHIP_MEMORY_NO_MEMORY,error_text_chip_memory,error_text_chip_memory_end-error_text_chip_memory

		INIT_CUSTOM_ERROR_ENTRY CUSTOM_MEMORY_NO_MEMORY,error_text_custom_memory,error_text_custom_memory_end-error_text_custom_memory

		INIT_CUSTOM_ERROR_ENTRY EXCEPTION_VECTORS_NO_MEMORY,error_text_exception_vectors,error_text_exception_vectors_end-error_text_exception_vectors

		INIT_CUSTOM_ERROR_ENTRY CLEARED_SPRITE_NO_MEMORY,error_text_cleared_sprite,error_text_cleared_sprite_end-error_text_cleared_sprite

		INIT_CUSTOM_ERROR_ENTRY VIEWPORT_MONITOR_ID_NOT_FOUND,error_text_viewport,error_text_viewport_end-error_text_viewport

		INIT_CUSTOM_ERROR_ENTRY SCREEN_COULD_NOT_OPEN,error_text_screen,error_text_screen_end-error_text_screen

		INIT_CUSTOM_ERROR_ENTRY SCREEN_MODE_NOT_AVAILABLE,error_text_screen_display_mode,error_text_screen_display_mode_end-error_text_screen_display_mode

		IFEQ screen_fader_enabled
			INIT_CUSTOM_ERROR_ENTRY SCREEN_FADER_NO_MEMORY,error_text_screen_fader,error_text_screen_fader_end-error_text_screen_fader
		ENDC
		rts

; Input
; Result
; d0.l	... Kein Rückgabewert	
		CNOP 0,4
init_easy_request
		IFEQ requires_multiscan_monitor
			lea	monitor_request(pc),a0
			moveq	#EasyStruct_sizeOF,d0
			move.l	d0,(a0)+ ; Größe der Struktur
			moveq	#0,d0
			move.l	d0,(a0)+ ; Keine Flags
			lea	monitor_request_title(pc),a1
			move.l	a1,(a0)+ ; Zeiger auf Titeltext
			lea	monitor_request_text(pc),a1
			move.l	a1,(a0)+ ; Zeiger auf Text in Requester
			lea	monitor_request_gadgets_text(pc),a1
			move.l	a1,(a0)	; Zeiger auf Gadgettexte
		ENDC
		IFNE intena_bits&INTF_PORTS
			lea	tcp_request(pc),a0
			moveq	#EasyStruct_sizeOF,d0
			move.l	d0,(a0)+ ; Größe der Struktur
			moveq	#0,d0
			move.l	d0,(a0)+ ; Keine Flags
			lea	tcp_request_title(pc),a1
			move.l	a1,(a0)+ ; Zeiger auf Titeltext
			lea	tcp_request_text(pc),a1
			move.l	a1,(a0)+ ; Zeiger auf Text in Requester
			lea	tcp_request_gadgets_text(pc),a1
			move.l	a1,(a0)	; Zeiger auf Gadgettexte
		ENDC
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
init_degrade_screen_colors
		lea	degrade_screen_colors(pc),a0
		move.w	#degrade_screen_colors_number,(a0)+
		moveq	#0,d0
		move.w	d0,(a0)+	; Erste Farbe COLOR00
		lea     pf1_color_table(pc),a1
		moveq	#0,d1
		move.b	1(a1),d1	; 4x COLOR00 8-Bit Rotwert
		lsl.w	#8,d1
		move.b	1(a1),d1
		swap	d1
		move.b	1(a1),d1
		lsl.w	#8,d1
		move.b	1(a1),d1

		moveq	#0,d2
		move.b	2(a1),d2	; 4x COLOR00 8-Bit Grünwert
		lsl.w	#8,d2
		move.b	2(a1),d2
		swap	d2
		move.b	2(a1),d2
		lsl.w	#8,d2
		move.b	2(a1),d2

		moveq	#0,d3
		move.b	3(a1),d3	; 4x COLOR00 8-Bit Blauwert
		lsl.w	#8,d3
		move.b	3(a1),d3
		swap	d3
		move.b	3(a1),d3
		lsl.w	#8,d3
		move.b	3(a1),d3

		move.l	d1,(a0)+	; COLOR00 32-Bit Rotwert
		move.l	d2,(a0)+	; COLOR00 32-Bit Grünwert
		move.l	d3,(a0)+	; COLOR00 32-Bit Blauwert
		move.l	d1,(a0)+	; COLOR01 32-Bit Rotwert
		move.l	d2,(a0)+	; COLOR01 32-Bit Grünwert
		move.l	d3,(a0)+	; COLOR01 32-Bit Blauwert
		move.l	d0,(a0)		; Ende der Tabelle
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert	
		CNOP 0,4
init_timer_io
		lea	timer_io(pc),a0
		moveq	#0,d0
		move.b	d0,LN_Type(a0)	; Eintragstyp = Null
		move.b	d0,LN_Pri(a0)	; Priorität der Struktur = Null
		move.l	d0,LN_Name(a0)	; Keine Name der Struktur
		move.l	d0,MN_ReplyPort(a0) ; Kein Reply-Port
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert	
		CNOP 0,4
init_tag_lists
		bsr.s	init_degrade_screen_tags
		bsr	init_invisible_window_tags
		bra	init_video_control_tags


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
init_degrade_screen_tags
		lea	degrade_screen_tags(pc),a0
		move.l	#SA_Left,(a0)+
	     	moveq	#degrade_screen_left,d2
		move.l	d2,(a0)+
		move.l	#SA_Top,(a0)+
     		moveq	#degrade_screen_top,d2
		move.l	d2,(a0)+
		move.l	#SA_Width,(a0)+
		moveq	#degrade_screen_x_size,d2
		move.l	d2,(a0)+
		move.l	#SA_Height,(a0)+
		moveq	#degrade_screen_y_size,d2
		move.l	d2,(a0)+
		move.l	#SA_Depth,(a0)+
		moveq	#degrade_screen_depth,d2
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
		lea	degrade_screen_name(pc),a1
		move.l	a1,(a0)+
		move.l	#SA_Colors32,(a0)+
		lea	degrade_screen_colors(pc),a1
		move.l	a1,(a0)+
		move.l	#SA_Font,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_SysFont,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_Type,(a0)+
		move.l	#CUSTOMSCREEN,(a0)+
		move.l	#SA_Behind,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_Quiet,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_ShowTitle,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_AutoScroll,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_Draggable,(a0)+
		move.l	d0,(a0)+
		move.l	#SA_Interleaved,(a0)+
		move.l	d0,(a0)+
		moveq	#TAG_DONE,d2
		move.l	d2,(a0)
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
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
		move.l	d0,(a0)+		; Zeiger wird später initialisiert
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
		moveq	#FALSE,d2
		move.l	d2,(a0)+
		move.l	#WA_Flags,(a0)+
		move.l	#WFLG_BACKDROP|WFLG_BORDERLESS|WFLG_ACTIVATE,(a0)+
		moveq	#TAG_DONE,d2
		move.l	d2,(a0)
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
init_video_control_tags
		lea	video_control_tags+(ti_SIZEOF*1)(pc),a0
		moveq	#TAG_DONE,d2
		move.l	d2,(a0)
		rts

	ENDC


	IFNE pf_extra_number
; Input
; Result
; d0.l	... Kein Rückgabewert	
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
; d0.l	... Kein Rückgabewert	
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
; d0.l	... Rückgabewert: Return-Code	
			CNOP 0,4
check_workbench_start
			sub.l	a1,a1	; Nach dem eigenen Task suchen
			CALLEXEC FindTask
			tst.l	d0
			bne.s	check_workbench_start_skip1
			moveq	#RETURN_FAIL,d0
			rts
			CNOP 0,4
check_workbench_start_skip1
			move.l	d0,a2	; aktueller Task
			tst.l	pr_CLI(a2)
			beq.s	check_workbench_start_skip2
check_workbench_start_ok
			moveq	#RETURN_OK,d0
			rts
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
; d0.l	... Rückgabewert: Return-Code	
		CNOP 0,4
open_dos_library
		lea	dos_name(pc),a1
		moveq	#ANY_LIBRARY_VERSION,d0
		CALLEXEC OpenLibrary
		lea	_DOSBase(pc),a0
		move.l	d0,(a0)
		bne.s	open_dos_library_ok
		moveq	 #RETURN_FAIL,d0
		rts
		CNOP 0,4
open_dos_library_ok
		moveq	 #RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
get_output
		CALLDOS Output
		move.l	d0,output_handle(a3)
		bne.s   get_output_ok
		CALLLIBQ IoErr
		CNOP 0,4
get_output_ok
		moveq	#RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
		CNOP 0,4
open_graphics_library
		lea	graphics_name(pc),a1
		moveq	#ANY_LIBRARY_VERSION,d0
		CALLEXEC OpenLibrary
		lea	_GfxBase(pc),a0
		move.l	d0,(a0)
		bne.s	open_graphics_library_ok
		move.w	#GFX_LIBRARY_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
open_graphics_library_ok
		moveq	#RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
		CNOP 0,4
check_system_properties
		move.l	_SysBase(pc),a6
		cmp.w	#OS_VERSION_AGA,Lib_Version(a6)
		bge.s	check_cpu_type
		move.w	#KICKSTART_VERSION_NOT_FOUND,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
check_cpu_type
		move.w	AttnFlags(a6),d0
		move.w	d0,cpu_flags(a3)
		and.b	#AFF_68020,d0
		bne.s	check_chipset_type
		move.w	#CPU_020_NOT_FOUND,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
check_chipset_type
		move.l	_GfxBase(pc),a1
		IFD DEF_AGA_CHECK_BY_HARDWARE
			move.l	#_CUSTOM+DENISEID,a0
			move.w	-(DENISEID-VPOSR)(a0),d0
			and.w	#$7e00,d0
			cmp.w	#$22<<8,d0 ; PAL-Alice Revision 2 ?
			beq.s	check_lisa_id
			cmp.w	#$23<<8,d0 ; PAL-Alice Revision 3 & 4 ?
			beq.s	check_lisa_id
			move.w	#AGA_CHIPSET_NOT_FOUND,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			rts
			CNOP 0,4
check_lisa_id
			move.w	(a0),d0 ; ID
			moveq	 #32-1,d7
check_lisa_id_loop
			move.w	(a0),d1	; ID
			cmp.b	d0,d1
			bne.s	check_lisa_id_fail
			dbf	d7,check_lisa_id_loop
			or.b	#$f0,d0	; 0th revision level setzen
			cmp.b	#$f8,d0	; Lisa-ID ?
			beq.s	check_pal
check_lisa_id_fail
			move.w	#AGA_CHIPSET_NOT_FOUND,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			rts
		ELSE
			move.b	gb_ChipRevBits0(a1),d0
			btst	#GFXB_AA_ALICE,d0
			bne.s	check_lisa_type
			move.w	#AGA_CHIPSET_NOT_FOUND,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			rts
			CNOP 0,4
check_lisa_type
			btst	#GFXB_AA_LISA,d0
			bne.s	check_pal
			move.w	#AGA_CHIPSET_NOT_FOUND,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			rts
		ENDC
		CNOP 0,4
check_pal
		btst	#REALLY_PALn,gb_DisplayFlags+1(a1)
		bne.s	check_fast_memory
		move.w	#CONFIG_NO_PAL,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
check_fast_memory
		moveq	#MEMF_FAST,d1
		CALLLIBS AvailMem
		tst.l	d0
		beq.s	check_system_properties_ok
		clr.w	fast_memory_available_enabled(a3)
check_system_properties_ok
		moveq	#RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
		CNOP 0,4
open_intuition_library
		lea	intuition_name(pc),a1
		moveq	#OS_VERSION_AGA,d0
		CALLEXEC OpenLibrary
		lea	_IntuitionBase(pc),a0
		move.l	d0,(a0)
		bne.s	open_intuition_library_ok
		move.w	#INTUI_LIBRARY_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
open_intuition_library_ok
		moveq	#RETURN_OK,d0
		rts


		IFEQ requires_030_cpu
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
			CNOP 0,4
check_cpu_requirements
			btst	#AFB_68030,cpu_flags+1(a3)
			bne.s	check_cpu_requirements_ok
			move.w	#CPU_030_REQUIRED,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			rts
			CNOP 0,4
check_cpu_requirements_ok
			moveq	#RETURN_OK,d0
			rts
		ENDC
		IFEQ requires_040_cpu
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
			CNOP 0,4
check_cpu_requirements
			btst	#AFB_68040,cpu_flags+1(a3)
			bne.s	check_cpu_requirements_ok
			move.w	#CPU_040_REQUIRED,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			rts
			CNOP 0,4
check_cpu_requirements_ok
			moveq	#RETURN_OK,d0
			rts
		ENDC
		IFEQ requires_060_cpu
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
			CNOP 0,4
check_cpu_requirements
			tst.b	cpu_flags+1(a3)
			bmi.s	check_cpu_requirements_ok
			move.w	#CPU_060_REQUIRED,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			rts
			CNOP 0,4
check_cpu_requirements_ok
			moveq	#RETURN_OK,d0
			rts
		ENDC


		IFEQ requires_fast_memory
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
			CNOP 0,4
check_memory_requirements
			tst.w	fast_memory_available_enabled(a3)
			beq.s	check_memory_requirements_ok
			move.w	#FAST_MEMORY_REQUIRED,custom_error_code(a3)
			moveq	#RETURN_FAIL,d0
			rts
			CNOP 0,4
check_memory_requirements_ok
			moveq	#RETURN_OK,d0
			rts
		ENDC


		IFEQ requires_multiscan_monitor
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
			CNOP 0,4
do_monitor_request
			sub.l	a0,a0	; Requester erscheint auf Workbench/Public-Screen
			lea	monitor_request(pc),a1
			move.l	a0,a2	; Keine IDCMP-Flags
			move.l	a3,-(a7)
			move.l	a0,a3	; Keine Argumentenliste
			CALLINT EasyRequestArgs
			move.l	(a7)+,a3
			CMPF.L	0,d0	; Gadget "Quit" angeklickt ?
			bne.s	do_monitor_request_ok
			moveq	#RETURN_FAIL,d0
			rts
			CNOP 0,4
do_monitor_request_ok
			moveq	#RETURN_OK,d0
			rts
		ENDC


		IFNE intena_bits&INTF_PORTS
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
			CNOP 0,4
check_tcp_stack
			CALLEXEC Forbid
			lea	LibList(a6),a0
			lea	bsdsocket_name(pc),a1
			CALLLIBS FindName
			tst.l	d0
			beq.s	check_tcp_stack_skip
			move.l	d0,a0
			tst.w	LIB_OPENCNT(a0)
			bne.s	do_tcp_stack_request
check_tcp_stack_skip
			CALLLIBS Permit
			moveq	#RETURN_OK,d0
			rts
			CNOP 0,4
do_tcp_stack_request
			CALLLIBS Permit
			sub.l	a0,a0	; Requester auf WB/Public-Screen
			lea	tcp_request(pc),a1
			move.l	a0,a2	; Keine IDCMP-Flags
			move.l	a3,-(a7)
			move.l	a0,a3	; Keine Argumentenliste
			CALLINT EasyRequestArgs
			move.l	(a7)+,a3
			CMPF.L	0,d0	; Gadget "Quit" angeklickt ?
			bne.s	do_tcp_stack_request_ok
			moveq	#RETURN_FAIL,d0
			rts
			CNOP 0,4
do_tcp_stack_request_ok
			moveq	#RETURN_OK,d0
			rts
		ENDC


; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
		CNOP 0,4
open_ciaa_resource
		lea	CIAA_name(pc),a1
		CALLEXEC OpenResource
		lea	_CIABase(pc),a0
		move.l	d0,(a0)
		bne.s	open_ciaa_resource_save
		move.w	#CIAA_RESOURCE_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
open_ciaa_resource_save
		moveq	#0,d0		; keine Maske
		CALLCIA AbleICR
		move.b	d0,old_ciaa_icr(a3)
		moveq	#RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... Rückgabewert: Return-Code
		CNOP 0,4
open_ciab_resource	
		lea	CIAB_name(pc),a1
		CALLEXEC OpenResource
		lea	_CIABase(pc),a0
		move.l	d0,(a0)
		bne.s	open_ciab_resource_save
		move.w	#CIAB_RESOURCE_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
open_ciab_resource_save
		moveq	#0,d0		; keine Maske
		CALLCIA AbleICR
		move.b	d0,old_ciab_icr(a3)
		moveq	#RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
		CNOP 0,4
open_timer_device
		lea	timer_device_name(pc),a0
		lea	timer_io(pc),a1
		moveq	#UNIT_MICROHZ,d0
		moveq	#0,d1		; Keine Flags
		CALLEXEC OpenDevice
		tst.l	d0
		beq.s	open_timer_device_ok
		move.w	#TIMER_DEVICE_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
open_timer_device_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE cl1_size1
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_cl1_memory1
		MOVEF.L	cl1_size1,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl1_construction1(a3)
		bne.s	alloc_cl1_memory1_ok
		move.w	#CL1_CONSTR1_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_cl1_memory1_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC
	IFNE cl1_size2
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_cl1_memory2
		MOVEF.L	cl1_size2,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl1_construction2(a3)
		bne.s	alloc_cl1_memory2_ok
		move.w	#CL1_CONSTR2_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_cl1_memory2_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC
	IFNE cl1_size3
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_cl1_memory3
		MOVEF.L	cl1_size3,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl1_display(a3)
		bne.s	alloc_cl1_memory3_ok
		move.w	#CL1_DISPLAY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_cl1_memory3_ok
		moveq	 #RETURN_OK,d0
		rts
	ENDC


	IFNE cl2_size1
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code	
		CNOP 0,4
alloc_cl2_memory1
		MOVEF.L	cl2_size1,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl2_construction1(a3)
		bne.s	alloc_cl2_memory1_ok
		move.w	#CL2_CONSTR1_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_cl2_memory1_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC
	IFNE cl2_size2
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_cl2_memory2
		MOVEF.L	cl2_size2,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl2_construction2(a3)
		bne.s	alloc_cl2_memory2_ok
		move.w	#CL2_CONSTR2_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_cl2_memory2_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC
	IFNE cl2_size3
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_cl2_memory3
		MOVEF.L	cl2_size3,d0
		bsr	do_alloc_chip_memory
		move.l	d0,cl2_display(a3)
		bne.s	alloc_cl2_memory3_ok
		move.w	#CL2_DISPLAY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_cl2_memory3_ok
		moveq	 #RETURN_OK,d0
		rts
	ENDC


	IFNE pf1_x_size1
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
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
		rts
		CNOP 0,4
alloc_pf1_memory1_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf1_construction1(a3) ; Offset 1. Bitplanezeiger
		moveq	#RETURN_OK,d0
		rts
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
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
		rts
		CNOP 0,4
check_pf1_memory1_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC
	IFNE pf1_x_size2
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
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
		rts
		CNOP 0,4
alloc_pf1_memory2_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf1_construction2(a3) ; Offset 1. Bitplanezeiger
		moveq	#RETURN_OK,d0
		rts
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
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
		rts
		CNOP 0,4
check_pf1_memory2_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC
	IFNE pf1_x_size3
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
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
		rts
		CNOP 0,4
alloc_pf1_memory3_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf1_display(a3) ; Offset 1. Bitplanezeiger
		moveq	#RETURN_OK,d0
		rts
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
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
		rts
		CNOP 0,4
check_pf1_memory3_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE pf2_x_size1
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
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
		rts
		CNOP 0,4
alloc_pf2_memory1_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf2_construction1(a3) ; Offset 1. Bitplanezeiger
		moveq	#RETURN_OK,d0
		rts
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
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
		rts
		CNOP 0,4
check_pf2_memory1_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC
	IFNE pf2_x_size2
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
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
		rts
		CNOP 0,4
alloc_pf2_memory2_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf2_construction2(a3) ; Offset 1. Bitplanezeiger
		moveq	#RETURN_OK,d0
		rts
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
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
		rts
		CNOP 0,4
check_pf2_memory2_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC
	IFNE pf2_x_size3
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
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
		rts
		CNOP 0,4
alloc_pf2_memory3_ok
		addq.l	#bm_Planes,d0
		move.l	d0,pf2_display(a3) ; Offset 1. Bitplanezeiger
		moveq	#RETURN_OK,d0
		rts
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
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
		rts
		CNOP 0,4
check_pf2_memory3_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE pf_extra_number
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_pf_extra_memory
		lea	pf_extra_bitmap1(a3),a2
		lea	extra_pf1(a3),a4
		lea	pf_extra_attributes(pc),a5
		moveq	#pf_extra_number-1,d7
alloc_pf_extra_memory_loop
		move.l	(a5)+,d0	; Breite des Playfields
		move.l	(a5)+,d1	; Höhe des Playfields
		move.l	(a5)+,d2	; Anzahl der Bitplanes
		bsr	do_alloc_bitmap_memory
		move.l	d0,(a2)+	; Zeiger auf Bitmap-Struktur
		beq.s	alloc_pf_extra_memory_fail
		addq.l	#bm_Planes,d0
		move.l	d0,(a4)+	; Offset 1. Bitplanezeiger
		dbf	d7,alloc_pf_extra_memory_loop
		moveq	#RETURN_OK,d0
		rts
		CNOP 0,4
alloc_pf_extra_memory_fail
		move.w	#PF_EXTRA_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
		CNOP 0,4
check_pf_extra_memory
		lea	pf_extra_bitmap1(a3),a2
		lea	pf_extra_attributes(pc),a4
		moveq	#pf_extra_number-1,d7
check_pf_extra_memory_loop
		move.l	(a2)+,a0	; Zeiger auf Bitmap-Struktur
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s	check_pf_extra_memory_fail
		cmp.l	#1,pf_extra_attribute_depth(a4) ; Nur 1 Bitplane ?
		beq.s	check_pf_extra_memory_skip
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_pf_extra_memory_skip
check_pf_extra_memory_fail
		move.w	#PF_EXTRA_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
check_pf_extra_memory_skip
		ADDF.W	pf_extra_attribute_size,a4 ; nächster Eintrag
		dbf	d7,check_pf_extra_memory_loop
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE spr_x_size1
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_sprite_memory1
		lea	spr0_bitmap1(a3),a2
		lea	spr0_construction(a3),a4
		lea	sprite_attributes1(pc),a5
		moveq	#spr_number-1,d7 ; Anzahl der Hardware-Sprites [1..8]
alloc_sprite_memory1_loop
		move.l	(a5)+,d0	; Breite des Sprites
		move.l	(a5)+,d1	; Höhe des Sprites
		move.l	(a5)+,d2	; Anzahl der Bitplanes
		bsr	do_alloc_bitmap_memory
		move.l	d0,(a2)+	; Zeiger auf Sprite-Bitmap-Struktur
		beq.s	alloc_sprite_memory1_fail
		addq.l	#bm_Planes,d0
		move.l	d0,(a4)+	; Offset 1. Bitplanezeiger
		dbf	d7,alloc_sprite_memory1_loop
		moveq	#RETURN_OK,d0
		rts
		CNOP 0,4
alloc_sprite_memory1_fail
		move.w	#SPR_CONSTR_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
		CNOP 0,4
check_sprite_memory1
		lea	spr0_bitmap1(a3),a2
		moveq	#spr_number-1,d7 ; Anzahl der Hardware-Sprites [1..8]
check_sprite_memory1_loop
		move.l	(a2)+,a0	; Zeiger auf Sprite-Bitmap-Struktur
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s   check_sprite_memory1_fail
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_sprite_memory1_skip
check_sprite_memory1_fail
		move.w	#SPR_CONSTR_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0			 
		rts
		CNOP 0,4
check_sprite_memory1_skip
		dbf	d7,check_sprite_memory1_loop
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE spr_x_size2
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_sprite_memory2
		lea	spr0_bitmap2(a3),a2
		lea	spr0_display(a3),a4
		lea	sprite_attributes2(pc),a5
		moveq	#spr_number-1,d7 ; Anzahl der Hardware-Sprites [1..8]
alloc_sprite_memory2_loop
		move.l	(a5)+,d0	; Breite des Sprites
		move.l	(a5)+,d1	; Höhe des Sprites
		move.l	(a5)+,d2	; Anzahl der Bitplanes
		bsr	do_alloc_bitmap_memory
		move.l	d0,(a2)+	; Zeiger auf Sprite-Bitmap-Struktur
		beq.s	alloc_sprite_memory2_fail
		addq.l	#bm_Planes,d0
		move.l	d0,(a4)+	; Offset 1. Bitplanezeiger
		dbf	d7,alloc_sprite_memory2_loop
		moveq	#RETURN_OK,d0
		rts
		CNOP 0,4
alloc_sprite_memory2_fail
		move.w	#SPR_DISPLAY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
; Input
; Result
; d0.l	... Rückgabewert: Return-Code
		CNOP 0,4
check_sprite_memory2
		lea	spr0_bitmap2(a3),a2
		moveq	#spr_number-1,d7 ; Anzahl der Hardware-Sprites [1..8]
check_sprite_memory2_loop
		move.l	(a2)+,a0	; Zeiger auf Sprite-Bitmap-Struktur
		moveq	#BMA_FLAGS,d1
		CALLGRAF GetBitmapAttr
		btst	#BMB_DISPLAYABLE,d0
		beq.s   check_sprite_memory2_fail
		btst	#BMB_INTERLEAVED,d0
		bne.s	check_sprite_memory2_skip
check_sprite_memory2_fail
		move.w	#SPR_DISPLAY_NOT_INTERLEAVED,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0			 
		rts
		CNOP 0,4
check_sprite_memory2_skip
		dbf	d7,check_sprite_memory2_loop
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE audio_memory_size
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_audio_memory
		MOVEF.L	audio_memory_size,d0
		bsr	do_alloc_chip_memory
		move.l	d0,audio_data(a3)
		bne.s	alloc_audio_memory_ok
		move.w	#AUDIO_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_audio_memory_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE disk_memory_size
; Input
; Result
; d0.l	... Rückgabewert: Return-Code	
		CNOP 0,4
alloc_disk_memory
		MOVEF.L disk_memory_size,d0
		bsr	do_alloc_chip_memory
		move.l	d0,disk_data(a3)
		bne.s	alloc_disk_memory_ok
		move.w	#DISK_MEMORY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_disk_memory_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE extra_memory_size
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_extra_memory
		MOVEF.L	extra_memory_size,d0
		bsr	do_alloc_memory
		move.l	d0,extra_memory(a3)
		bne.s	alloc_extra_memory_ok
		move.w	#EXTRA_MEMORY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_extra_memory_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE chip_memory_size
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code	
		CNOP 0,4
alloc_chip_memory
		MOVEF.L	chip_memory_size,d0
		bsr	do_alloc_chip_memory
		move.l	d0,chip_memory(a3)
		bne.s	alloc_chip_memory_ok
		move.w	#CHIP_MEMORY_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_chip_memory_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC

	IFND SYS_TAKEN_OVER
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_vectors_base_memory
		lea	read_vbr(pc),a5
		CALLEXEC Supervisor
		move.l	d0,old_vbr(a3)
		move.l	d0,a1
		CALLLIBS TypeOfMem
		and.b	#MEMF_FAST,d0
		bne.s	alloc_vectors_base_memory_skip
		tst.w	fast_memory_available_enabled(a3)
		bne.s	alloc_vectors_base_memory_skip
		move.l	#exception_vectors_size,d0
		bsr	do_alloc_fast_memory
		move.l	d0,exception_vectors_base(a3)
		bne.s	alloc_vectors_base_memory_ok
		move.w	#EXCEPTION_VECTORS_NO_MEMORY,custom_error_code(a3)
		moveq	#ERROR_NO_FREE_STORE,d0
		rts
		CNOP 0,4
alloc_vectors_base_memory_skip
		move.l	old_vbr(a3),vbr_save(a3)
alloc_vectors_base_memory_ok
		moveq	#RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
		CNOP 0,4
alloc_cleared_sprite_data
	moveq	#sprite_pointer_data_size,d0
	MOVEF.L	MEMF_CLEAR|MEMF_CHIP|MEMF_PUBLIC|MEMF_REVERSE,d1
	CALLEXEC AllocMem
	move.l	d0,cleared_sprite_pointer_data(a3)
	bne.s	alloc_cleared_sprite_data_ok
	move.w	#CLEARED_SPRITE_NO_MEMORY,custom_error_code(a3)
	moveq	#ERROR_NO_FREE_STORE,d0
	rts
	CNOP 0,4
alloc_cleared_sprite_data_ok
	moveq	#RETURN_OK,d0
	rts


		IFEQ screen_fader_enabled
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
			CNOP 0,4
sf_alloc_screen_color_table
			MOVEF.L	sf_colors_number*3*LONGWORD_SIZE,d0
			bsr	do_alloc_memory
			move.l	d0,sf_screen_color_table(a3)
			bne.s	sf_alloc_screen_color_table_ok
			move.w	#SCREEN_FADER_NO_MEMORY,custom_error_code(a3)
			moveq	#ERROR_NO_FREE_STORE,d0
			rts
			CNOP 0,4
sf_alloc_screen_color_table_ok
			moveq	#RETURN_OK,d0
			rts


; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
	CNOP 0,4
sf_alloc_screen_color_cache
			MOVEF.L	(1+(sf_colors_number*3)+1)*LONGWORD_SIZE,d0
			bsr	do_alloc_memory
			move.l	d0,sf_screen_color_cache(a3)
			bne.s	sf_alloc_screen_color_cache_ok			lea	error_text8(pc),a0
			move.w	#SCREEN_FADER_NO_MEMORY,custom_error_code(a3)
			moveq	#ERROR_NO_FREE_STORE,d0
			rts
			CNOP 0,4
sf_alloc_screen_color_cache_ok
			moveq	#RETURN_OK,d0
			rts
		ENDC


		IFD PASS_GLOBAL_REFERENCES
; Input
; Result
; d0.l	... Rückgabewert: Return-Code/Error-Code
			CNOP 0,4
init_global_references_table
			lea	global_references_table(pc),a0
			move.l	_SysBase(pc),(a0)
			move.l	_GfxBase(pc),gr_graphics_base(a0)
			rts
		ENDC


; Input
; Result
; d0.l	... Kein Rückgabewert	
		CNOP 0,4
wait_drives_motor
		MOVEF.L	drives_motor_delay,d1
		CALLDOSQ Delay


		IFD SAVE_BEAMCON0
; Input
; Result
; d0.l	... Kein Rückgabewert
save_beamcon0_register
			CALLINT ViewAddress
			move.l	d0,a0
			CALLGRAF GfxLookUp
			move.l	d0,a0	; Zeiger auf ViewExtra-Struktur
			move.l	ve_monitor(a0),a0
			move.w	ms_BeamCon0(a0),old_beamcon0(a3)
			rts
		ENDC
		

; Input
; Result
; d0.l ... kein Rückgabewert
	CNOP 0,4
get_active_screen
		moveq	#0,d0		; Alle Locks
		CALLINT LockIBase
		move.l	d0,a0
		move.l	ib_ActiveScreen(a6),active_screen(a3)
		CALLLIBQ UnlockIBase


; Input
; Result
; d0.l	... Rückgabewert: Return-Code
		CNOP 0,4
get_active_screen_mode
		move.l	active_screen(a3),d0
		beq.s	get_active_screen_mode_ok
		move.l	d0,a0
		ADDF.W	sc_ViewPort,a0
		CALLGRAF GetVPModeID
		cmp.l	#INVALID_ID,d0
		bne.s	get_active_screen_mode_save
		move.w	#VIEWPORT_MONITOR_ID_NOT_FOUND,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
get_active_screen_mode_save
		and.l	#MONITOR_ID_MASK,d0	; Ohne Auflösung
		move.l	d0,active_screen_mode(a3)
get_active_screen_mode_ok
		moveq	#RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... kein Rückgabewert
	CNOP 0,4
get_sprite_resolution
		move.l	active_screen(a3),a0
		move.l  sc_ViewPort+vp_ColorMap(a0),a0
		lea	video_control_tags(pc),a1
		move.l	#VTAG_SPRITERESN_GET,vctl_VTAG_SPRITERESN+ti_tag(a1)
		clr.l	vctl_VTAG_SPRITERESN+ti_Data(a1)
		CALLGRAF VideoControl
		lea     video_control_tags(pc),a0
		move.l  vctl_VTAG_SPRITERESN+ti_Data(a0),old_sprite_resolution(a3)
		rts


		IFEQ screen_fader_enabled
; Input
; Result
; d0 ... keine Rückgabewert
			CNOP 0,4
sf_get_active_screen_colors
			move.l	active_screen(a3),d0
			beq.s	sf_get_active_screen_colors_skip
			move.l	d0,a0
			move.l	sc_ViewPort+vp_ColorMap(a0),a0
			move.l	sf_screen_color_table(a3),a1 ; 32-Bit RGB-Werte
			moveq	#0,d0	; Ab COLOR00
			MOVEF.L	sf_colors_number,d1 ; Alle 256 Farben
			CALLGRAFQ GetRGB32
			CNOP 0,4
sf_get_active_screen_colors_skip
			rts


; Input
; Result
; d0 ... keine Rückgabewert
	CNOP 0,4
sf_copy_screen_color_table
			move.l	sf_screen_color_table(a3),a0 ; Quelle 32-Bit RGB-Werte
			move.l	sf_screen_color_cache(a3),a1 ; Ziel 32-Bit RGB-Werte
			move.w	#sf_colors_number,(a1)+ ; Anzahl der Farben
			moveq	#0,d0
			move.w	d0,(a1)+ ; Ab COLOR00
			MOVEF.W	sf_colors_number-1,d7 ; Anzahl der Farbwerte
sf_copy_screen_color_table_loop
			move.l	(a0)+,(a1)+ ; 32-Bit-Rotwert
			move.l	(a0)+,(a1)+ ; 32-Bit-Grünwert
			move.l	(a0)+,(a1)+ ; 32-Bit-Blauwert
			dbf	d7,sf_copy_screen_color_table_loop
			move.l	d0,(a1)	; Listenende
			rts


; Input
; Result
; d0 ... keine Rückgabewert
	CNOP 0,4
sf_fade_out_active_screen
			CALLGRAF WaitTOF
			bsr.s	screen_fader_out
			bsr	sf_set_new_colors
			tst.w	sfo_active(a3)
			beq.s	sf_fade_out_active_screen
			rts


; Input
; Result
; d0 ... keine Rückgabewert
      CNOP 0,4
screen_fader_out
			MOVEF.W	sf_colors_number*3,d6 ; Zähler
			move.l	sf_screen_color_cache(a3),a0 ; Istwerte
			addq.w  #4,a0	; Offset überspringen
			move.l	pf1_color_table(pc),a1 ; Sollwert COLOR00
			move.w  #sfo_fader_speed,a4 ; Additions-/Subtraktionswert RGB-Werte
			MOVEF.W sf_colors_number-1,d7 ;Anzahl der Farbwerte
screen_fader_out_loop
			moveq   #0,d0
			move.b  (a0),d0	; 8-Bit Rot-Istwert
			move.l  a1,d3
			swap    d3	; 8-Bit Rot-Sollwert
			moveq   #0,d1
			move.b  4(a0),d1 ; 8-Bit Grün-Istwert
			move.w  a1,d4
			lsr.w   #8,d4	; 8-Bit Grün-Sollwert
			moveq   #0,d2
			move.b  8(a0),d2 ; 8-Bit Blau-Istwert
			move.w  a1,d5
			and.w	#$00ff,d5 ; 8-Bit Blau-Sollwert

			cmp.w	d3,d0
			bgt.s	sfo_decrease_red
			blt.s	sfo_increase_red
sfo_matched_red
			subq.w  #1,d6	; Ziel-Rotwert erreicht
sfo_check_green_byte
			cmp.w	d4,d1
			bgt.s	sfo_decrease_green
			blt.s	sfo_increase_green
sfo_matched_green
			subq.w  #1,d6	; Ziel-Grünwert erreicht
sfo_check_blue_byte
			cmp.w	d5,d2
			bgt.s	sfo_decrease_blue
			blt.s	sfo_increase_blue
sfo_matched_blue
			subq.w	#1,d6	; Ziel-Blauwert erreicht
sfo_set_rgb_bytes
			move.b	d0,(a0)+ ; 4x 8-Bit Rotwert in Cache schreiben
			move.b	d0,(a0)+
			move.b	d0,(a0)+
			move.b	d0,(a0)+
			move.b	d1,(a0)+ ; 4x 8-Bit Grünwert in Cache schreiben
			move.b	d1,(a0)+
			move.b	d1,(a0)+
			move.b	d1,(a0)+
			move.b	d2,(a0)+ ; 4x 8-Bit Blauwert in Cache schreiben
			move.b	d2,(a0)+
			move.b	d2,(a0)+
			move.b	d2,(a0)+
			dbf	d7,screen_fader_out_loop
			tst.w   d6	; Fertig mit ausblenden ?
			bne.s   sfo_flush_caches ; Nein -> verzweige
			move.w  #FALSE,sfo_active(a3) ; Fading-Out aus
sfo_flush_caches
			CALLEXECQ CacheClearU
			CNOP 0,4
sfo_decrease_red
			sub.w	a4,d0
			cmp.w	d3,d0
			bgt.s	sfo_check_green_byte
			move.w	d3,d0
			bra.s	sfo_matched_red
			CNOP 0,4
sfo_increase_red
			add.w	a4,d0
			cmp.w	d3,d0
			blt.s	sfo_check_green_byte
			move.w	d3,d0
			bra.s	sfo_matched_red
			CNOP 0,4
sfo_decrease_green
			sub.w	a4,d1
			cmp.w	d4,d1
			bgt.s	sfo_check_blue_byte
			move.w	d4,d1
			bra.s	sfo_matched_green
			CNOP 0,4
sfo_increase_green
			add.w	a4,d1
			cmp.w	d4,d1
			blt.s	sfo_check_blue_byte
			move.w	d4,d1
			bra.s	sfo_matched_green
			CNOP 0,4
sfo_decrease_blue
			sub.w	a4,d2
			cmp.w	d5,d2
			bgt.s	sfo_set_rgb_bytes
			move.w	d5,d2
			bra.s	sfo_matched_blue
			CNOP 0,4
sfo_increase_blue
			add.w	a4,d2
			cmp.w	d5,d2
			blt.s	sfo_set_rgb_bytes
			move.w	d5,d2
			bra.s	sfo_matched_blue


; Input
; Result
; d0 ... keine Rückgabewert
			CNOP 0,4
sf_set_new_colors
			move.l	active_screen(a3),d0
			bne.s   sf_set_new_colors_skip
			rts
			CNOP 0,4
sf_set_new_colors_skip
			move.l	d0,a0
			ADDF.W	sc_ViewPort,a0
			move.l	sf_screen_color_cache(a3),a1
			CALLGRAFQ LoadRGB32
		ENDC
	

; Input
; Result
; d0.l	... Rückgabewert: Return-Code
	CNOP 0,4
open_degrade_screen
		lea	degrade_screen_tags(pc),a1
		sub.l	a0,a0		; Keine NewScreen-Struktur
		CALLINT OpenScreenTagList
		move.l	d0,degrade_screen(a3)
		bne.s	open_degrade_screen_ok
		move.w	#SCREEN_COULD_NOT_OPEN,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
open_degrade_screen_ok
		moveq	#RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... Rückgabewert: Return-Code
		CNOP 0,4
check_degrade_screen_mode
		move.l	degrade_screen(a3),d0
		beq.s	check_degrade_screen_mode_ok
		move.l	d0,a0
		ADDF.W	sc_ViewPort,a0
		CALLGRAF GetVPModeID
		IFEQ requires_multiscan_monitor
			cmp.l	 #VGA_MONITOR_ID|VGAPRODUCT_KEY,d0
		ELSE
			cmp.l	 #PAL_MONITOR_ID|LORES_KEY,d0
		ENDC
		beq.s	check_degrade_screen_mode_ok
		move.w	#SCREEN_MODE_NOT_AVAILABLE,custom_error_code(a3)
		moveq	#RETURN_FAIL,d0
		rts
check_degrade_screen_mode_ok
		moveq	#RETURN_OK,d0
		rts

; Input
; Result
; d0.l	... Rückgabewert: Return-Code
	CNOP 0,4
open_invisible_window
	sub.l	a0,a0			; Keine NewWindow-Struktur
	lea	invisible_window_tags(pc),a1
	move.l	degrade_screen(a3),wtl_WA_CustomScreen+ti_data(a1)
	CALLINT OpenWindowTagList
	move.l	d0,invisible_window(a3)
	bne.s	open_invisible_window_ok
	move.w	#WINDOW_COULD_NOT_OPEN,custom_error_code(a3)
	moveq	#RETURN_FAIL,d0
	rts
	CNOP 0,4
open_invisible_window_ok
	moveq	#RETURN_OK,d0
	rts


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
clear_mousepointer
	move.l	invisible_window(a3),a0
	move.l	cleared_sprite_pointer_data(a3),a1
	moveq	#cleared_sprite_y_size,d0
	moveq	#cleared_sprite_x_size,d1
	moveq	#cleared_sprite_x_offset,d2
	moveq	#cleared_sprite_y_offset,d3
	CALLINTQ SetPointer


; Input
; Result
; d0	... Kein Rückgabewert
		CNOP 0,4
blank_display
		sub.l	a1,a1			; View auf ECS-Werte zurücksetzen
		CALLGRAF LoadView
		CALLLIBS WaitTOF		; Warten bis Änderung sichtbar ist
		CALLLIBS WaitTOF		; Warten bis Interlace-Screens mit 2 Copperlisten auch voll geändert sind
		tst.l	gb_ActiView(a6)		; Erschien zwischenzeitlich ein anderer View ?
		bne.s	blank_display	; Ja -> neuer Versuch
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
wait_monitor_switch
		move.l	active_screen_mode(a3),d0
		beq.s	wait_monitor_switch_quit
		cmp.l	#DEFAULT_MONITOR_ID,d0
		beq.s	wait_monitor_switch_quit
		cmp.l	#PAL_MONITOR_ID,d0
		bne.s	do_wait_monitor_switch
wait_monitor_switch_quit
		rts
		CNOP 0,4
do_wait_monitor_switch
		MOVEF.L	monitor_switch_delay,d1
		CALLDOSQ Delay


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
enable_exclusive_blitter
		CALLGRAF OwnBlitter
		CALLLIBQ WaitBlit


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
get_system_time
		lea	timer_io(pc),a1
		move.w	#TR_GETSYSTIME,IO_command(a1)
		CALLEXECQ DoIO


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
disable_system
		CALLEXECQ Disable


		IFD ALL_CACHES
; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4
enable_all_caches
			move.l	#CACRF_EnableI|CACRF_IBE|CACRF_EnableD|CACRF_DBE|CACRF_WriteAllocate|CACRF_EnableE|CACRF_CopyBack,d0 ; Alle Caches einschalten
			move.l	#CACRF_EnableI|CACRF_FreezeI|CACRF_ClearI|CACRF_IBE|CACRF_EnableD|CACRF_FreezeD|CACRF_ClearD|CACRF_DBE|CACRF_WriteAllocate|CACRF_EnableE|CACRF_CopyBack,d1 ; Alle Bits ändern
			CALLEXEC CacheControl
			move.l	d0,old_cacr(a3)
			rts
		ENDC


		IFD NO_060_STORE_BUFFER
; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4
disable_store_buffer
			DISABLE_060_STORE_BUFFER
		ENDC
	

; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
save_exception_vectors
		move.l	old_vbr(a3),a0	; Quelle = Reset (Initial SSP)
		lea	exception_vecs_save(pc),a1 ; Ziel
		MOVEF.W	(exception_vectors_size/LONGWORD_SIZE)-1,d7 ; Anzahl der Vektoren
copy_exception_vectors_loop
		move.l	(a0)+,(a1)+	; Vektor kopieren
		dbf	d7,copy_exception_vectors_loop
		rts
	ENDC


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
init_exception_vectors
	IFD SYS_TAKEN_OVER
		IFNE intena_bits&(~INTF_SETCLR)
			lea	read_vbr(pc),a5
			CALLEXEC Supervisor
			move.l	d0,a0
		ENDC
	ELSE
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
	CALLEXECQ CacheClearU


	IFND SYS_TAKEN_OVER
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
move_exception_vectors
		move.l	exception_vectors_base(a3),d0
		beq.s	move_exception_vectors_quit
		move.l	d0,a1		; Ziel = Fast-Memory
		move.l	old_vbr(a3),a0	; Quelle = Reset (Initial SSP)
		MOVEF.W	(exception_vectors_size/LONGWORD_SIZE)-1,d7 ; Anzahl der Vektoren
move_exception_vectors_loop
		move.l	(a0)+,(a1)+	; Vektoren kopieren
		dbf	d7,move_exception_vectors_loop
		CALLEXEC CacheClearU
		move.l	exception_vectors_base(a3),d0
		move.l	d0,vbr_save(a3)
		lea	write_vbr(pc),a5
		CALLLIBQ Supervisor
		CNOP 0,4
move_exception_vectors_quit
		rts
	

; Input
; Result
; d0.l	... Rückgabewert: Return-Code
save_copperlist_pointers
		move.l	_GfxBase(pc),a0
		IFNE cl1_size3
			move.l	gb_Copinit(a0),old_cop1lc(a3)
		ENDC
		IFNE cl2_size3
			move.l	gb_LOFlist(a0),old_cop2lc(a3) ; LOFlist, da OS das LOF-Bit bei non-Interlaced immer setzt!
		ENDC
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
get_tod_time
		moveq	#0,d0
		move.b	CIATODHI(a4),d0	; TOD-clock Bits 23-16
		swap	d0		; Bits in richtige Position bringen
		move.b	CIATODMID(a4),d0 ; TOD-clock Bits 15-8
		lsl.w	#8,d0		; Bits in richtige Position bringen
		move.b	CIATODLOW(a4),d0 ; TOD-clock Bits 7-0
		move.l	d0,tod_time(a3)
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
save_chips_registers
		move.w	(a6),old_dmacon(a3)
		move.w	INTENAR-DMACONR(a6),old_intena(a3)
		move.w	ADKCONR-DMACONR(a6),old_adkcon(a3)
	
		move.b	CIAPRA(a4),old_ciaa_pra(a3)
		move.b	CIACRA(a4),d0
		move.b	d0,old_ciaa_cra(a3)
		and.b	#~(CIACRAF_START),d0 ; Timer A stoppen
		or.b	#CIACRAF_LOAD,d0 ; Zählwert laden
		move.b	d0,CIACRA(a4)
		nop
		move.b	CIATALO(a4),old_ciaa_talo(a3)
		move.b	CIATAHI(a4),old_ciaa_tahi(a3)
	
		move.b	CIACRB(a4),d0
		move.b	d0,old_ciaa_crb(a3)
		and.b	#~(CIACRBF_ALARM-CIACRBF_START),d0 ; Timer B stoppen
		or.b	#CIACRBF_LOAD,d0 ; Zählwert laden
		move.b	d0,CIACRB(a4)
		nop
		move.b	CIATBLO(a4),old_ciaa_tblo(a3)
		move.b	CIATBHI(a4),old_ciaa_tbhi(a3)
		
		move.b	CIAPRB(a5),old_ciab_prb(a3)
		move.b	CIACRA(a5),d0
		move.b	d0,old_ciaa_cra(a3)
		and.b	#~(CIACRAF_START),d0 ; Timer A stoppen
		or.b	#CIACRAF_LOAD,d0 ; Zählwert laden
		move.b	d0,CIACRA(a5)
		nop
		move.b	CIATALO(a5),old_ciab_talo(a3)
		move.b	CIATAHI(a5),old_ciab_tahi(a3)
	
		move.b	CIACRB(a5),d0
		move.b	d0,old_ciab_crb(a3)
		and.b	#~(CIACRBF_ALARM-CIACRBF_START),d0 ;Timer B stoppen
		or.b	#CIACRBF_LOAD,d0 ;Zählwert laden
		move.b	d0,CIACRB(a5)
		nop
		move.b	CIATBLO(a5),old_ciab_tblo(a3)
		move.b	CIATBHI(a5),old_ciab_tbhi(a3)
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
clear_chips_registers1
		move.w	#$7fff,d0
		move.w	d0,DMACON-DMACONR(a6) ; DMA aus
		move.w	d0,INTENA-DMACONR(a6) ; Interrupts aus
		move.w	d0,INTREQ-DMACONR(a6) ; Interrupts löschen
		move.w	d0,ADKCON-DMACONR(a6) ; ADKCON löschen
	
		moveq	#$7f,d0
		move.b	d0,CIAICR(a4)	; CIA-A-Interrupts aus
		move.b	d0,CIAICR(a5)	; CIA-B-Interrupts aus
		move.b	CIAICR(a4),d0	; CIA-A-Interrupts löschen
		move.b	CIAICR(a5),d0	; CIA-B-Interrupts löschen

		moveq	#0,d0
		move.w	d0,JOYTEST-DMACONR(a6) ; Maus- und Joystickposition zurücksetzen
;		move.w	d0,FMODE-DMACONR(a6) ; Fetchmode Sprites & Bitplanes = 1x
;		move.l	d0,SPR0DATA-DMACONR(a6)	; Spritebitmaps löschen
;		move.l	d0,SPR1DATA-DMACONR(a6)
;		move.l	d0,SPR2DATA-DMACONR(a6)
;		move.l	d0,SPR3DATA-DMACONR(a6)
;		move.l	d0,SPR4DATA-DMACONR(a6)
;		move.l	d0,SPR5DATA-DMACONR(a6)
;		move.l	d0,SPR6DATA-DMACONR(a6)
;		move.l	d0,SPR7DATA-DMACONR(a6)
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
turn_off_drive_motors
		move.b	CIAPRB(a5),d0
		moveq	#CIAF_DSKSEL0|CIAF_DSKSEL1|CIAF_DSKSEL2|CIAF_DSKSEL3,d1
		or.b	d1,d0
		move.b	d0,CIAPRB(a5)	; df0: bis df3: deaktivieren
		tas	d0
		move.b	d0,CIAPRB(a5)	; Motor aus
		eor.b	d1,d0
		move.b	d0,CIAPRB(a5)	; df0: bis df3: aus
		or.b	d1,d0
		move.b	d0,CIAPRB(a5)	; df0: bis df3: deaktivieren
		rts
	ENDC


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
start_own_display
	bsr	wait_vbi
	bsr	wait_vbi
	moveq	#copcon_bits,d0		; Copper kann ggf. auf Blitteregister zurückgreifen
	move.w	d0,COPCON-DMACONR(a6)
	IFNE cl2_size3
		IFD SET_SECOND_COPPERLIST
			move.l	cl2_display(a3),COP2LC-DMACONR(a6)
		ENDC
	ENDC
	IFNE cl1_size3
		move.l	cl1_display(a3),COP1LC-DMACONR(a6)
		moveq	#0,d0
		move.w	d0,COPJMP1-DMACONR(a6) ; manuell starten
	ENDC
	move.w	#dma_bits&(DMAF_SPRITE|DMAF_COPPER|DMAF_RASTER|DMAF_SETCLR),DMACON-DMACONR(a6) ; Sprite/Copper/Bitplane-DMA an
	rts


	IFNE (intena_bits-INTF_SETCLR)|(ciaa_icr_bits-CIAICRF_SETCLR)|(ciab_icr_bits-CIAICRF_SETCLR)
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
start_own_interrupts
		IFNE intena_bits-INTF_SETCLR
			move.w	#intena_bits,INTENA-DMACONR(a6)
		ENDC
		IFNE ciaa_icr_bits-CIAICRF_SETCLR
			MOVEF.B	ciaa_icr_bits,d0
			move.b	d0,CIAICR(a4) ; CIA-A-Interrupts an
		ENDC
		IFNE ciab_icr_bits-CIAICRF_SETCLR
			MOVEF.B	ciab_icr_bits,d0
			move.b	d0,CIAICR(a5) ; CIA-B-Interrupts an
		ENDC
		rts
	ENDC


	IFEQ ciaa_ta_continuous_enabled&ciaa_tb_continuous_enabled&ciab_ta_continuous_enabled&ciab_tb_continuous_enabled
; Input
; Result
; d0.l	... Kein Rückgabewert
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
; d0.l	... Kein Rückgabewert
		CNOP 0,4
stop_CIA_timers
		IFNE ciaa_ta_time
			moveq	#~(CIACRAF_START),d0
			and.b	d0,CIACRA(a4) ; CIA-A-Timer-A stoppen
		ENDC
		IFNE ciaa_tb_time
			moveq	#~(CIACRBF_START),d0
			and.b	d0,CIACRB(a4) ; CIA-A-Timer-B stoppen
		ENDC
		IFNE ciab_ta_time
			moveq	#~(CIACRAF_START),d0
			and.b	d0,CIACRA(a5) ; CIA-B-Timer-A stoppen
		ENDC
		IFNE ciab_tb_time
			moveq	#~(CIACRBF_START),d0
			and.b	d0,CIACRB(a5) ; CIA-B-Timer-B stoppen
		ENDC
		rts
	ENDC


	IFNE (intena_bits-INTF_SETCLR)|(ciaa_icr_bits-CIAICRF_SETCLR)|(ciab_icr_bits-CIAICRF_SETCLR)
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
stop_own_interrupts
		IFNE intena_bits-INTF_SETCLR
			IFD SYS_TAKEN_OVER
				move.w	#intena_bits&(~INTF_SETCLR),INTENA-DMACONR(a6) ; Interrupts aus
			ELSE
				move.w	#INTF_INTEN,INTENA-DMACONR(a6) ; Interrupts aus
			ENDC
		ENDC
		rts
	ENDC


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
stop_own_display
	IFNE copcon_bits&COPCONF_CDANG
		moveq	#0,d0
		move.w	d0,COPCON-DMACONR(a6) ; Copper kann nicht auf Blitterregister zugreifen
	ENDC
	bsr	wait_beam_position	; wird von außen aufgerufen
	IFNE dma_bits&DMAF_BLITTER
		WAITBLIT
	ENDC
	IFD SYS_TAKEN_OVER
		move.w	#dma_bits&(~DMAF_SETCLR),DMACON-DMACONR(a6) ; DMA aus
	ELSE
		move.w	#DMAF_MASTER,DMACON-DMACONR(a6) ; DMA aus
	ENDC
	rts


	IFND SYS_TAKEN_OVER
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
clear_chips_registers2
		move.w	#$7fff,d0
		move.w	d0,DMACON-DMACONR(a6) ; DMA aus
		move.w	d0,INTENA-DMACONR(a6) ; Interrupts aus
		move.w	d0,INTREQ-DMACONR(a6) ; Interrupts löschen
		move.w	d0,ADKCON-DMACONR(a6) ; ADKCON löschen
	
		moveq	#$7f,d0
		move.b	d0,CIAICR(a4)	; CIA-A-Interrupts aus
		move.b	d0,CIAICR(a5)	; CIA-B-Interrupts aus
		IFNE ciaa_icr_bits-CIAICRF_SETCLR
			move.b	CIAICR(a4),d0 ; CIA-A-Interrupts löschen
		ENDC
		IFNE ciab_icr_bits-CIAICRF_SETCLR
			move.b	CIAICR(a5),d0 ; CIA-B-Interrupts löschen
		ENDC

		moveq	#0,d0
		move.w	d0,AUD0VOL-DMACONR(a6) ; Lautstärke aus
		move.w	d0,AUD1VOL-DMACONR(a6)
		move.w	d0,AUD2VOL-DMACONR(a6)
		move.w	d0,AUD3VOL-DMACONR(a6)
	
;		move.w	d0,FMODE-DMACONR(a6) ; Fetchmode Sprites & Bitplanes = 1x
;		move.l	d0,SPR0DATA-DMACONR(a6) ; Spritebitmaps manuell löschen
;		move.l	d0,SPR1DATA-DMACONR(a6)
;		move.l	d0,SPR2DATA-DMACONR(a6)
;		move.l	d0,SPR3DATA-DMACONR(a6)
;		move.l	d0,SPR4DATA-DMACONR(a6)
;		move.l	d0,SPR5DATA-DMACONR(a6)
;		move.l	d0,SPR6DATA-DMACONR(a6)
;		move.l	d0,SPR7DATA-DMACONR(a6)
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
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
		tas	d0		; Bit 7 ggf. setzen
		move.b	d0,CIAICR(a4)
	
		move.b	old_ciaa_cra(a3),d0
		btst	#CIACRAB_RUNMODE,d0 ; Continuous-Modus ?
		bne.s	restore_chips_registers_skip1
		or.b	#CIACRAF_START,d0
restore_chips_registers_skip1
		move.b	d0,CIACRA(a4)
	
		move.b	old_ciaa_crb(a3),d0
		btst	#CIACRBB_RUNMODE,d0 ;Continuous-Modus ?
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
		tas	d0		; Bit 7 ggf. setzen
		move.b	d0,CIAICR(a5)
	
		move.b	old_ciab_cra(a3),d0
		btst	#CIACRAB_RUNMODE,d0 ; Continuous-Modus ?
		bne.s	restore_chips_registers_skip3
		or.b	#CIACRAF_START,d0
restore_chips_registers_skip3
		move.b	d0,CIACRA(a5)
	
		move.b	old_ciab_crb(a3),d0
		btst	#CIACRBB_RUNMODE,d0 ; Continuous-Modus ?
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
		and.w	#~DMAF_RASTER,d0 ; Bitplane-DMA ggf. aus
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
; d0.l	... Kein Rückgabewert
		CNOP 0,4
get_tod_duration	
		move.l	tod_time(a3),d0 ; Zeit vor Programmstart
		moveq	#0,d1
		move.b	CIATODHI(a4),d1	; Bits 23-16
		swap	d1		; Bits in richtige Position bringen
		move.b	CIATODMID(a4),d1 ; Bits 15-8
		lsl.w	#8,d1		; Bits in richtige Position bringen
		move.b	CIATODLOW(a4),d1 ; Bits 7-0
		cmp.l	d0,d1		; TOD Überlauf ?
		bge.s	get_tod_duration_skip
		move.l	#$ffffff,d2	; Maximalwert
		sub.l	d0,d2		; Differenz bis zum Überlauf
		add.l	d2,d1		; zuzüglich Wert nach dem Überlauf
		bra.s	get_tod_duration_save
		CNOP 0,4
get_tod_duration_skip
		sub.l	d0,d1		; Normale Differenz
get_tod_duration_save
		move.l	d1,tod_time(a3)
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
restore_vbr
		move.l	old_vbr(a3),d0
		lea	write_VBR(pc),a5
		CALLEXECQ Supervisor


		IFD ALL_CACHES
; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4
restore_caches
			move.l	old_cacr(a3),d0
			move.l	#CACRF_EnableI|CACRF_FreezeI|CACRF_ClearI|CACRF_IBE|CACRF_EnableD|CACRF_FreezeD|CACRF_ClearD|CACRF_DBE|CACRF_WriteAllocate|CACRF_EnableE|CACRF_CopyBack,d1 ; Alle Bits ändern
			CALLEXECQ CacheControl
		ENDC


		IFD NO_060_STORE_BUFFER
; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4
restore_store_buffer
			ENABLE_060_STORE_BUFFER
		ENDC


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
restore_exception_vectors
		lea	exception_vecs_save(pc),a0 ; Quelle
		move.l	old_vbr(a3),a1	; Ziel = Reset (Initial SSP)
		MOVEF.W	(exception_vectors_size/LONGWORD_SIZE)-1,d7 ; Anzahl der Vektoren
restore_exception_vectors_loop
		move.l	(a0)+,(a1)+	; Vektor kopieren
		dbf	d7,restore_exception_vectors_loop
		CALLEXECQ CacheClearU


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
enable_system
		CALLEXECQ Enable


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
update_system_time
		move.l	exec_base.w,a6
		move.l	tod_time(a3),d0 ; Vergangene Zeit, als System ausgeschaltet war
		moveq	#0,d1
		move.b	VBlankFrequency(a6),d1
		divu.w	d1,d0		; / Vertikalfrequenz (50Hz) = Unix-Sekunden, Rest Unix-Microsekunden
		lea	timer_io(pc),a1
		move.w	#TR_SETSYSTIME,IO_command(a1)
		move.l	d0,d1
		ext.l	d0
		swap	d1		; Rest der Division
		add.l	d0,IO_size+TV_SECS(a1) ; Unix-Sekunden
		mulu.w	#10000,d1	; In Mikrosekunden
		add.l	d1,IO_size+TV_MICRO(a1) ; Unix-Mikrosekunden
		CALLLIBQ DoIO
	

; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
disable_exclusive_blitter
		CALLGRAFQ DisownBlitter


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
restore_sprite_resolution
		move.l	degrade_screen(a3),a2
		move.l	sc_ViewPort+vp_ColorMap(a2),a0
		lea	video_control_tags(pc),a1
		move.l	#VTAG_SPRITERESN_SET,vctl_VTAG_SPRITERESN+ti_tag(a1)
		move.l	old_sprite_resolution(a3),vctl_VTAG_SPRITERESN+ti_data(a1)
		CALLGRAF VideoControl
		move.l	a2,a0			; Zeiger auf Screen
		CALLINT MakeScreen
		CALLLIBQ RethinkDisplay


		IFEQ screen_fader_enabled
; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4
sf_fade_in_screen
			CALLGRAF WaitTOF
			bsr	screen_fader_in
			bsr	sf_set_new_colors
			tst.w	sfi_active(a3)
			beq.s	sf_fade_in_screen
			rts


; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4	
screen_fader_in
			MOVEF.W	sf_colors_number*3,d6; Zähler
			move.l	sf_screen_color_cache(a3),a0 ; Puffer für Farbwerte
			addq.w	#4,a0		; Offset überspringen
			move.w	#sfi_fader_speed,a4 ; Additions-/Subtraktionswert für RGB-Werte
			move.l	sf_screen_color_table(a3),a1 ; Sollwerte
			MOVEF.W	sf_colors_number-1,d7 ; Anzahl der Farben
screen_fader_in_loop
			moveq	#0,d0
			move.b	(a0),d0 ; 8-Bit Rot-Istwert
			moveq	#0,d1
			move.b	4(a0),d1 ; 8-Bit Grün-Istwert
			moveq	#0,d2
			move.b	8(a0),d2 ; 8-Bit Blau-Istwert
			moveq	#0,d3
			move.b	(a1),d3	 ; 8-Bit Rot-Sollwert
			moveq	#0,d4
			move.b	4(a1),d4 ; 8-Bit Grün-Sollwert
			moveq	#0,d5
			move.b	8(a1),d5 ; 8-Bit Blau-Sollwert

			cmp.w	d3,d0
			bgt.s	sfi_decrease_red
			blt.s	sfi_increase_red
sfi_matched_red
			subq.w	#1,d6 ; Ziel-Rotwert erreicht
sfi_check_green_byte
			cmp.w	d4,d1
			bgt.s	sfi_decrease_green
			blt.s	sfi_increase_green
sfi_matched_green
			subq.w	#1,d6 ; Ziel-Grünwert erreicht
sfi_check_blue_byte
			cmp.w	d5,d2
			bgt.s	sfi_decrease_blue
			blt.s	sfi_increase_blue
sfi_matched_blue
			subq.w	#1,d6 ; Ziel-Blauwert erreicht

sfi_set_rgb_bytes
			move.b	d0,(a0)+ ; 4x 8-Bit Rotwert in Cache schreiben
			move.b	d0,(a0)+
			move.b	d0,(a0)+
			move.b	d0,(a0)+
			move.b	d1,(a0)+ ; 4x 8-Bit Grünwert in Cache schreiben
			move.b	d1,(a0)+
			move.b	d1,(a0)+
			move.b	d1,(a0)+
			move.b	d2,(a0)+ ; 4x 8-Bit Blauwert in Cache schreiben
			move.b	d2,(a0)+
			addq.w	#8,a1	; nächstes 32-Bit-Tripple (4*3)
			move.b	d2,(a0)+
			addq.w	#4,a1
			move.b	d2,(a0)+
			dbf	d7,screen_fader_in_loop
			tst.w	d6	; Fertig mit ausblenden ?
			bne.s	sfi_flush_caches ; Nein -> verzweige
			move.w	#FALSE,sfi_active(a3) ; Fading-In aus
sfi_flush_caches
			CALLEXEC CacheClearU
			rts
			CNOP 0,4
sfi_decrease_red
			sub.w	a4,d0
			cmp.w	d3,d0
			bgt.s	sfi_check_green_byte
			move.w	d3,d0
			bra.s	sfi_matched_red
			CNOP 0,4
sfi_increase_red
			add.w   a4,d0
			cmp.w   d3,d0
			blt.s   sfi_check_green_byte
			move.w  d3,d0
			bra.s   sfi_matched_red
			CNOP 0,4
sfi_decrease_green
			sub.w	a4,d1
			cmp.w	d4,d1
			bgt.s	sfi_check_blue_byte
			move.w	d4,d1
			bra.s	sfi_matched_green
			CNOP 0,4
sfi_increase_green
			add.w	a4,d1
			cmp.w	d4,d1
			blt.s	sfi_check_blue_byte
			move.w	d4,d1
			bra.s	sfi_matched_green
			CNOP 0,4
sfi_decrease_blue
			sub.w	a4,d2
			cmp.w	d5,d2
			bgt.s	sfi_set_rgb_bytes
			move.w	d5,d2
			bra.s	sfi_matched_blue
			CNOP 0,4
sfi_increase_blue
			add.w	a4,d2
			cmp.w	d5,d2
			blt.s	sfi_set_rgb_bytes
			move.w	d5,d2
			bra.s	sfi_matched_blue
		ENDC


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
check_active_screen_priority
	tst.l	active_screen(a3)
	bne.s	get_first_screen
	rts
	CNOP 0,4
get_first_screen
	moveq	#0,d0			; alle Locks
	CALLINT LockIBase
	move.l	d0,a0
	move.l	ib_FirstScreen(a6),a2
	CALLLIBS UnLockIBase
	cmp.l	active_screen(a3),a2
	bne.s	active_screen_to_front
	rts
	CNOP 0,4
active_screen_to_front
	move.l	active_screen(a3),a0
	CALLLIBQ ScreenToFront


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
close_invisible_window
	move.l	invisible_window(a3),a0
	CALLINTQ CloseWindow


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
close_degrade_screen
		move.l	degrade_screen(a3),a0
		CALLINTQ CloseScreen

	
		IFEQ text_output_enabled
; ** formatierten Text ausgeben **
; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4
print_formatted_text
			lea	format_string(pc),a0
			lea	data_stream(pc),a1 ; Daten für den Format-String
			lea	put_ch_process(pc),a2 ; Zeiger auf Kopierroutine
			move.l	a3,-(a7)
			lea	put_ch_data(pc),a3 ; Zeiger auf Ausgabestring
			CALLEXEC RawDoFmt
			move.l	(a7)+,a3
			move.l	output_handle(a3),d1
			lea	put_ch_data(pc),a0 
			move.l	a0,d2	; Zeiger auf Text
			moveq	#-1,d3	; Zeichenzähler
print_formatted_text_loop
			addq.w	#1,d3
			tst.b	(a0)+	; Nullbyte ?
			dbeq.s	print_formatted_text_loop
			CALLLIBQ Write
			CNOP 0,4
put_ch_process
			move.b	d0,(a3)+ ; Daten in den Ausgabestring schreiben
			rts
		ENDC


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_vectors_base_memory
		move.l	exception_vectors_base(a3),d0
		bne.s   free_vectors_base_memory_skip
		rts
		CNOP 0,4
free_vectors_base_memory_skip
		move.l	d0,a1
		move.l	#exception_vectors_size,d0
		CALLEXECQ FreeMem
	ENDC


	IFNE CHIP_memory_size
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_chip_memory
		move.l	chip_memory(a3),d0
		bne.s	free_chip_memory_skip
		rts
		CNOP 0,4
free_chip_memory_skip
		move.l	d0,a1
		MOVEF.L	chip_memory_size,d0
		CALLEXECQ FreeMem
	ENDC


	IFNE extra_memory_size
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_extra_memory
		move.l	extra_memory(a3),d0
		bne.s	free_extra_memory_skip
		rts
		CNOP 0,4
free_extra_memory_skip
		move.l	d0,a1
		MOVEF.L extra_memory_size,d0
		CALLEXECQ FreeMem
	ENDC


	IFNE disk_memory_size
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_disk_memory
		move.l	disk_data(a3),d0
		beq.s	free_disk_memory_skip
		rts
		CNOP 0,4
free_disk_memory_skip
		move.l	d0,a1
		MOVEF.L	disk_memory_size,d0
		CALLEXECQ FreeMem
	ENDC


	IFNE audio_memory_size
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_audio_memory
		move.l	audio_data(a3),d0
		bne.s	free_audio_memory_skip
		rts
		CNOP 0,4
free_audio_memory_skip
		move.l	d0,a1
		MOVEF.L	audio_memory_size,d0
		CALLEXECQ FreeMem
	ENDC


	IFNE spr_x_size2
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_sprite_memory2
		lea	spr0_bitmap2(a3),a2
		moveq	#spr_number-1,d7 ; Anzahl der Hardware-Sprites [1..8]
free_sprite_memory2_loop
		move.l	(a2)+,d0
		beq.s	free_sprite_memory2_quit
		move.l	d0,a0
		CALLGRAF FreeBitMap
		dbf	d7,free_sprite_memory2_loop
free_sprite_memory2_quit
		rts
	ENDC


	IFNE spr_x_size1
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_sprite_memory1
		lea	spr0_bitmap1(a3),a2
		moveq	#spr_number-1,d7 ; Anzahl der Hardware-Sprites [1..8]
free_sprite_memory1_loop
		move.l	(a2)+,d0
		beq.s	free_sprite_memory1_quit
		move.l	d0,a0
		CALLGRAF FreeBitMap
		dbf	d7,free_sprite_memory1_loop
free_sprite_memory1_quit
		rts
	ENDC


	IFNE pf_extra_number
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_pf_extra_memory
		lea	pf_extra_bitmap1(a3),a2
		moveq	#pf_extra_number-1,d7
free_pf_extra_memory_loop
		move.l	(a2)+,d0
		beq.s	free_pf_extra_memory_quit
		move.l	d0,a0
		CALLGRAF FreeBitMap
		dbf	d7,free_pf_extra_memory_loop
free_pf_extra_memory_quit
		rts
	ENDC


	IFNE pf2_x_size3
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_pf2_memory3
		move.l	pf2_bitmap3(a3),d0
		beq.s	free_pf2_memory3_quit
		move.l	d0,a0
		CALLGRAFQ FreeBitMap
		CNOP 0,4
free_pf2_memory3_quit
		rts
	ENDC
	IFNE pf2_x_size2
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_pf2_memory2
		move.l	pf2_bitmap2(a3),d0
		beq.s	free_pf2_memory2_quit
		move.l	d0,a0
		CALLGRAFQ FreeBitMap
		CNOP 0,4
free_pf2_memory2_quit
		rts
	ENDC
	IFNE pf2_x_size1
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_pf2_memory1
		move.l	pf2_bitmap1(a3),d0
		beq.s	free_pf2_memory1_quit
		move.l	d0,a0
		CALLGRAFQ FreeBitMap
		CNOP 0,4
free_pf2_memory1_quit
		rts
	ENDC


	IFNE pf1_x_size3
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_pf1_memory3
		move.l	pf1_bitmap3(a3),d0
		beq.s	free_pf1_memory3_quit
		move.l	d0,a0
		CALLGRAFQ FreeBitMap
		CNOP 0,4
free_pf1_memory3_quit
		rts
	ENDC
	IFNE pf1_x_size2
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_pf1_memory2
		move.l	pf1_bitmap2(a3),d0
		beq.s	free_pf1_memory2_quit
		move.l	d0,a0
		CALLGRAFQ FreeBitMap
		CNOP 0,4
free_pf1_memory2_quit
		rts
	ENDC
	IFNE pf1_x_size1
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_pf1_memory1
		move.l	pf1_bitmap1(a3),d0
		beq.s	free_pf1_memory1_quit
		move.l	d0,a0
		CALLGRAFQ FreeBitMap
		CNOP 0,4
free_pf1_memory1_quit
		rts
	ENDC


	IFNE cl2_size3
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_cl2_memory3
		move.l	cl2_display(a3),d0
		bne.s	free_cl2_memory3_skip
		rts
		CNOP 0,4
free_cl2_memory3_skip
		move.l	d0,a1
		MOVEF.L	cl2_size3,d0
		CALLEXECQ FreeMem
	ENDC
	IFNE cl2_size2
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_cl2_memory2
		move.l	cl2_construction2(a3),d0
		bne.s	free_cl2_memory2_skip
		rts
		CNOP 0,4
free_cl2_memory2_skip
		move.l	d0,a1
		MOVEF.L	cl2_size2,d0
		CALLEXECQ FreeMem
	ENDC
	IFNE cl2_size1
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_cl2_memory1
		move.l	cl2_construction1(a3),d0
		bne.s	free_cl2_memory1_skip
		rts
		CNOP 0,4
free_cl2_memory1_skip
		move.l	d0,a1
		MOVEF.L	cl2_size1,d0
		CALLEXECQ FreeMem
	ENDC


	IFNE cl1_size3
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_cl1_memory3
		move.l	cl1_display(a3),d0
		bne.s	free_cl1_memory3_skip
		rts
		CNOP 0,4
free_cl1_memory3_skip
		move.l	d0,a1
		MOVEF.L	cl1_size3,d0
		CALLEXECQ FreeMem
	ENDC
	IFNE cl1_size2
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_cl1_memory2
		move.l	cl1_construction2(a3),d0
		bne.s	free_cl1_memory2_skip
		rts
		CNOP 0,4
free_cl1_memory2_skip
		move.l	d0,a1
		MOVEF.L	cl1_size2,d0
		CALLEXECQ FreeMem
	ENDC
	IFNE cl1_size1
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_cl1_memory1
		move.l	cl1_construction1(a3),d0
		bne.s	free_cl1_memory1_skip
		rts
		CNOP 0,4
free_cl1_memory1_skip
		move.l	d0,a1
		MOVEF.L	cl1_size1,d0
		CALLEXECQ FreeMem
	ENDC


	IFND SYS_TAKEN_OVER
		IFEQ screen_fader_enabled
; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4
sf_free_screen_color_cache
			move.l	sf_screen_color_cache(a3),d0
			bne.s	sf_free_screen_color_cache_skip
			rts
			CNOP 0,4
sf_free_screen_color_cache_skip
			move.l	d0,a1
			MOVEF.L	(1+(sf_colors_number*3)+1)*LONGWORD_SIZE,d0
			CALLEXECQ FreeMem


; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4
sf_free_screen_color_table
			move.l	sf_screen_color_table(a3),d0
			bne.s	sf_free_screen_color_table_skip
			rts
			CNOP 0,4
sf_free_screen_color_table_skip
			move.l	d0,a1
			MOVEF.L	sf_colors_number*3*LONGWORD_SIZE,d0
			CALLEXECQ FreeMem
		ENDC


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
free_cleared_sprite_data
	move.l	cleared_sprite_pointer_data(a3),d0
	bne.s	free_cleared_sprite_data_skip
	rts
	CNOP 0,4
free_cleared_sprite_data_skip
	move.l	d0,a1
	moveq	#sprite_pointer_data_size,d0
	CALLEXECQ FreeMem


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
close_timer_device
		lea	timer_io(pc),a1
		CALLEXECQ CloseDevice


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
close_intuition_library
		move.l	_IntuitionBase(pc),a1
		CALLEXECQ CloseLibrary


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
close_graphics_library
		move.l	_GfxBase(pc),a1
		CALLEXECQ CloseLibrary

	
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
print_error_message
		move.w	custom_error_code(a3),d4
		beq.s	print_error_message_quit
		CALLINT WBenchToFront
		lea	raw_name(pc),a0
		move.l	a0,d1
		move.l	#MODE_OLDFILE,d2 ; Modus: Alt (Muß sein!)
		CALLDOS Open
		move.l	d0,raw_handle(a3)
		bne.s	print_error_message_skip
		moveq	#RETURN_FAIL,d0
		rts
		CNOP 0,4
print_error_message_skip
		subq.w	#1,d4		; Start-Offset 0
		lea	custom_error_table(pc),a0
		move.l	(a0,d4.w*8),d2	; Zeiger auf Fehlertext
		move.l	4(a0,d4.w*8),d3	; Länge des Fehlertextes
		move.l	d0,d1		; Zeiger auf Datei-Handle
		CALLLIBS Write
		move.l	raw_handle(a3),d1
		lea	raw_buffer(a3),a0
		move.l	a0,d2		; Zeiger auf Puffer
		moveq	#1,d3		; Anzahl der Zeichen zum Lesen
		CALLLIBS Read
		move.l	raw_handle(a3),d1
		CALLLIBS Close
print_error_message_quit
		moveq	#RETURN_OK,d0
		rts


; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
close_dos_library
		move.l	_DOSBase(pc),a1
		CALLEXECQ CloseLibrary


		IFEQ workbench_start_enabled
; Input
; Result
; d0.l	... Kein Rückgabewert
			CNOP 0,4
reply_workbench_message
			move.l	workbench_message(a3),d2
			bne.s	workbench_message_ok
			rts
			CNOP 0,4
workbench_message_ok
			CALLEXEC Forbid
			move.l	d2,a1
			CALLLIBS ReplyMsg
			CALLLIBQ Permit
		ENDC
	ENDC

; Includedatei: "normsource-includes/error-texts.i"
; Datum:        11.3.2024
; Version:      2.6

; ** Fehlermeldungen **
  IFND SYS_TAKEN_OVER

error_text_graphics_library
    DC.B "Couldn't open graphics.library !",10,10
    DC.B "Press any key.",10
error_text_graphics_library_end
    EVEN

error_text_kickstart
    DC.B "This programm needs kickstart 3.0 or better !",10,10
    DC.B "Press any key.",10
error_text_kickstart_end
    EVEN

error_text_cpu_1
    DC.B "This programm needs a 68020 cpu or better !",10,10
    DC.B "Press any key.",10
error_text_cpu_1_end
    EVEN

error_text_chipset
    DC.B "No AGA-PAL-machine detected! Please run the shell command SetPatch before.",10,10
    DC.B "Press any key.",10
error_text_chipset_end
    EVEN

    IFEQ requires_030_cpu
error_text_cpu_2
      DC.B "This programm needs a 68030 cpu or better !",10,10
      DC.B "Press any key.",10
error_text_cpu_2_end
      EVEN
    ENDC
    IFEQ requires_040_cpu
error_text_cpu_2
      DC.B "This programm needs a 68040 cpu or better !",10,10
      DC.B "Press any key.",10
error_text_cpu_2_end
      EVEN
    ENDC
    IFEQ requires_060_cpu
error_text_cpu_2
      DC.B "This programm needs a 68060 cpu or better !",10,10
      DC.B "Press any key.",10
error_text_cpu_2_end
      EVEN
    ENDC

    IFEQ requires_fast_memory
error_text_fast_memory
      DC.B "This programm needs fast memory !",10,10
      DC.B "Press any key.",10
error_text_fast_memory_end
      EVEN
    ENDC

error_text_intuition_library
    DC.B "Couldn't open intuition.library !",10,10
    DC.B "Press any key.",10
error_text_intuition_library_end
    EVEN

error_text_ciaa_resource
    DC.B "Couldn't open ciaa.resource !",10,10
    DC.B "Press any key.",10
error_text_ciaa_resource_end
    EVEN
error_text_ciab_resource
    DC.B "Couldn't open ciab.resource !",10,10
    DC.B "Press any key.",10
error_text_ciab_resource_end
    EVEN

error_text_timer_device
    DC.B "Couldn't open timer device !",10,10
    DC.B "Press any key.",10
error_text_timer_device_end
    EVEN

error_text_cl1_construction1
    DC.B "Couldn't allocate memory for first copperlist1-buffer !",10,10
    DC.B "Press any key.",10
error_text_cl1_construction1_end
    EVEN
error_text_cl1_construction2
    DC.B "Couldn't allocate memory for second copperlist1-buffer !",10,10
    DC.B "Press any key.",10
error_text_cl1_construction2_end
    EVEN
error_text_cl1_display
    DC.B "Couldn't allocate memory for third copperlist1-buffer !",10,10
    DC.B "Press any key.",10
error_text_cl1_display_end
    EVEN

error_text_cl2_construction1
    DC.B "Couldn't allocate memory for first copperlist2-buffer !",10,10
    DC.B "Press any key.",10
error_text_cl2_construction1_end
    EVEN
error_text_cl2_construction2
    DC.B "Couldn't allocate memory for second copperlist2-buffer !",10,10
    DC.B "Press any key.",10
error_text_cl2_construction2_end
    EVEN
error_text_cl2_display
    DC.B "Couldn't allocate memory for third copperlist2-buffer !",10,10
    DC.B "Press any key.",10
error_text_cl2_display_end
    EVEN

error_text_pf1_construction1_1
    DC.B "Couldn't allocate memory for first playfield1-buffer !",10,10
    DC.B "Press any key.",10
error_text_pf1_construction1_1_end
    EVEN
error_text_pf1_construction1_2
    DC.B "Check of first playfieled1-buffer failed !",10,10
    DC.B "Press any key.",10
error_text_pf1_construction1_2_end
    EVEN
error_text_pf1_construction2_1
    DC.B "Couldn't allocate memory for second playfield1-buffer !",10,10
    DC.B "Press any key.",10
error_text_pf1_construction2_1_end
    EVEN
error_text_pf1_construction2_2
    DC.B "Check of second playfieled1-buffer failed !",10,10
    DC.B "Press any key.",10
error_text_pf1_construction2_2_end
    EVEN
error_text_pf1_display_1
    DC.B "Couldn't allocate memory for third playfield1-buffer !",10,10
    DC.B "Press any key.",10
error_text_pf1_display_1_end
    EVEN
error_text_pf1_display_2
    DC.B "Check of third playfield1-buffer failed !",10,10
    DC.B "Press any key.",10
error_text_pf1_display_2_end
    EVEN

error_text_pf2_construction1_1
    DC.B "Couldn't allocate memory for first playfield2-buffer !",10,10
    DC.B "Press any key.",10
error_text_pf2_construction1_1_end
    EVEN
error_text_pf2_construction1_2
    DC.B "Check of first playfield2-buffer failed !",10,10
    DC.B "Press any key.",10
error_text_pf2_construction1_2_end
    EVEN
error_text_pf2_construction2_1
    DC.B "Couldn't allocate memory for second playfield2-buffer !",10,10
    DC.B "Press any key.",10
error_text_pf2_construction2_1_end
    EVEN
error_text_pf2_construction2_2
    DC.B "Check of second playfield2-buffer failed !",10,10
    DC.B "Press any key.",10
error_text_pf2_construction2_2_end
    EVEN
error_text_pf2_display_1
    DC.B "Couldn't allocate memory for third playfield2-buffer !",10,10
    DC.B "Press any key.",10
error_text_pf2_display_1_end
    EVEN
error_text_pf2_display_2
    DC.B "Check of third playfield2-buffer failed !",10,10
    DC.B "Press any key.",10
error_text_pf2_display_2_end
    EVEN

error_text_extra_playfield_1
    DC.B "Couldn't allocate memory for extra playfield-buffer !",10,10
    DC.B "Press any key.",10
error_text_extra_playfield_1_end
    EVEN
error_text_extra_playfield_2
    DC.B "Check of extra playfield-buffer failed !",10,10
    DC.B "Press any key.",10
error_text_extra_playfield_2_end
    EVEN

error_text_spr_construction_1
    DC.B "Couldn't allocate memory for first sprites-buffer !",10,10
    DC.B "Press any key.",10
error_text_spr_construction_1_end
    EVEN
error_text_spr_construction_2
    DC.B "Check of first sprites-buffer failed !",10,10
    DC.B "Press any key.",10
error_text_spr_construction_2_end
    EVEN
error_text_spr_display_1
    DC.B "Couldn't allocate memory for second sprites-buffer !",10,10
    DC.B "Press any key.",10
error_text_spr_display_1_end
    EVEN
error_text_spr_display_2
    DC.B "Check of second sprites-buffer failed !",10,10
    DC.B "Press any key.",10
error_text_spr_display_2_end
    EVEN

error_text_audio_memory
    DC.B "Couldn't allocate memory for audio-buffer !",10 ,10
    DC.B "Press any key.",10
error_text_audio_memory_end
    EVEN

error_text_disk_memory
    DC.B "Couldn't allocate memory for disk-buffer !",10,10
    DC.B "Press any key.",10
error_text_disk_memory_end
    EVEN

error_text_extra_memory
    DC.B "Couldn't allocate extra memory !",10,10
    DC.B "Press any key.",10
error_text_extra_memory_end
    EVEN

error_text_chip_memory
    DC.B "Couldn't allocate chip memory !",10,10
    DC.B "Press any key.",10
error_text_chip_memory_end
    EVEN

error_text_custom_memory
    DC.B "Couldn't allocate custom memory !",10,10
    DC.B "Press any key.",10
error_text_custom_memory_end
    EVEN

error_text_exception_vectors
    DC.B "Couldn't allocate memory for exception-vectors-buffer !",10,10
    DC.B "Press any key.",10
error_text_exception_vectors_end
    EVEN

error_text_screen_color_table
    DC.B "Couldn't allocate memory for downgrade screen color table !",10,10
    DC.B "Press any key.",10
error_text_screen_color_table_end
    EVEN
error_text_screen
    DC.B "Couldn't open downgrade screen !",10,10
    DC.B "Press any key.",10
error_text_screen_end
    EVEN
error_text_screen_display_mode
    DC.B "Requested display mode for downgrade screen not available !",10,10
    DC.B "Press any key.",10
error_text_screen_display_mode_end
    EVEN

error_text_active_screen
    DC.B "Couldn't find active Screen !",10,10
    DC.B "Press any key.",10
error_text_active_screen_end
    EVEN
error_text_viewport
    DC.B "Couldn't get viewport monitor ID !",10,10
    DC.B "Press any key.",10
error_text_viewport_end
    EVEN

    IFEQ workbench_fade_enabled
error_text_workbench_fade_enabled
      DC.B "Couldn't allocate memory for color-values-buffers !",10,10
      DC.B "Press any key.",10
error_text_workbench_fade_enabled_end
      EVEN
    ELSE
error_text_workbench_fade_enabled
      DC.B "Couldn't allocate memory for color-values-buffer !",10,10
      DC.B "Press any key.",10
error_text_worbench_fade_end
      EVEN
    ENDC
  ENDC

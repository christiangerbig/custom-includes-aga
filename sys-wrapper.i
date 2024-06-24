; Includedatei: "normsource-includes/sys-wrapper.i"
; Datum:        19.6.2024
; Version:      1.0

  IFND sys_taken_over
    INCLUDE "screen-taglist-offsets.i"
    INCLUDE "sprite-taglist-offsets.i"
    INCLUDE "custom-error-entry.i"
  ENDC
  IFD pass_global_references
    INCLUDE "global-references-offsets.i"
  ENDC


start_all
  movem.l d2-d7/a2-a6,-(a7)
  lea     variables(pc),a3   ;Basisadresse aller Variablen
  bsr     init_variables
  IFD sys_taken_over
    tst.l   dos_return_code(a3) ;Ist bereits ein Fehler aufgetreten ?
    bne     end_final        ;Ja -> verzweige
  ENDC
  bsr     init_structures
  IFD sys_taken_over
    IFD custom_memory_used
      bsr     init_custom_memory_table ;Wird von außen aufgerufen
      bsr     extend_global_references_table ;Wird von außen aufgerufen
    ENDC
  ELSE
    bsr     init_custom_error_table
    bsr     init_taglists

; ** Testen, ob der Start ggf. von der Workbench aus erfolgte **
    IFEQ workbench_start_enabled
      bsr     test_start_from_workbench
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     end_final      ;Ja -> verzweige
    ENDC


; ## Initialisierungsroutinen aufrufen ##
; ---------------------------------------

; ** Dos-Bibliothek öffnen **
    bsr     open_dos_library
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_wb_message  ;Ja -> verzweige

; ** Graphics-Bibliothek öffnen **
    bsr     open_graphics_library
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_dos_library ;Ja -> verzweige

; ** Systemkonstanten überprüfen **
    bsr     check_system
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_graphics_library ;Ja -> verzweige

; ** Auf bestimmte CPU hin überprüfen **
    IFEQ requires_68030
      bsr     check_cpu_requirements
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_graphics_library ;Ja -> verzweige
    ENDC
    IFEQ requires_68040
      bsr     check_cpu_requirements
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_graphics_library ;Ja -> verzweige
    ENDC
    IFEQ requires_68060
      bsr     check_cpu_requirements
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_graphics_library ;Ja -> verzweige
    ENDC

; ** Generell auf Fast-Memory überprüfen **
    IFEQ requires_fast_memory
      bsr     check_memory_requirements
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_graphics_library ;Ja -> verzweige
    ENDC

; ** Intuition-Bibliothek öffnen **
    bsr     open_intuition_library
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_graphics_library ;Ja -> verzweige

; ** Userabfrage, wenn TCP/IP-Stack vorhanden ist **
    IFNE INTENABITS&INTF_PORTS
      bsr     do_tcp_stack_request
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_intuition_library ;Ja -> verzweige
    ENDC

; ** Userabfrage, ob Multifrequenz-Monitor angeschlossen ist **
    IFEQ requires_multiscan_monitor
      bsr     do_monitor_request
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_intuition_library ;Ja -> verzweige
    ENDC

; ** CIA-Resources öffnen **
    bsr     open_ciax_resources
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_intuition_library ;Ja -> verzweige

; ** Timer-Device öffnen **
    bsr     open_timer_device
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_intuition_library ;Ja -> verzweige
  ENDC

; ** Speicher für Copperlisten belegen **
  IFNE cl1_size1
    bsr     alloc_cl1_memory1
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE cl1_size2
    bsr     alloc_cl1_memory2
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE cl1_size3
    bsr     alloc_cl1_memory3
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE cl2_size1
    bsr     alloc_cl2_memory1
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE cl2_size2
    bsr     alloc_cl2_memory2
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE cl2_size3
    bsr     alloc_cl2_memory3
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC

; ** Speicher für Playfields belegen **
  IFNE pf1_x_size1
    bsr     alloc_pf1_memory1
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
    bsr     check_pf1_memory1
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE pf1_x_size2
    bsr     alloc_pf1_memory2
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
    bsr     check_pf1_memory2
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE pf1_x_size3
    bsr     alloc_pf1_memory3
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
    bsr     check_pf1_memory3
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE pf2_x_size1
    bsr     alloc_pf2_memory1
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
    bsr     check_pf2_memory1
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup__all_memory ;Ja -> verzweige
  ENDC
  IFNE pf2_x_size2
    bsr     alloc_pf2_memory2
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
    bsr     check_pf2_memory2
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE pf2_x_size3
    bsr     alloc_pf2_memory3
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
    bsr     check_pf2_memory3
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC
  IFNE extra_pf_number
    bsr     alloc_extra_pf_memory
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
    bsr     check_extra_pf_memory
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC

; ** Speicher für Sprites belegen **
  IFNE spr_number
    IFNE spr_x_size1
      bsr     alloc_sprite_memory1
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_all_memory ;Ja -> verzweige
      bsr     check_sprite_memory1
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_all_memory ;Ja -> verzweige
    ENDC
    IFNE spr_x_size2
      bsr     alloc_sprite_memory2
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_all_memory ;Ja -> verzweige
      bsr     check_sprite_memory2
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne     cleanup_all_memory ;Ja -> verzweige
    ENDC
  ENDC

; ** Speicher für Audio-Kanäle belegen **
  IFNE audio_memory_size
    bsr     alloc_audio_memory
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC

; ** Speicher für Diskettenpuffer belegen **
  IFNE disk_memory_size
    bsr     alloc_disk_memory
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC

; ** Extra-Memory (vorrangig Fast) belegen **
  IFNE extra_memory_size
    bsr     alloc_extra_memory
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
  ENDC

; ** Chip-Memory belegen **
  IFNE chip_memory_size
    bsr     alloc_chip_memory
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne.s   cleanup_all_memory ;Ja -> verzweige
  ENDC

  IFD sys_taken_over
; ** Custom-Speicher belegen **
    IFD custom_memory_used
      bsr     alloc_custom_memory ;Wird von außen aufgerufen
      move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
      bne.s   cleanup_timer_device ;Ja -> verzweige
    ENDC
  ELSE
; ** Speicher für Vektoren belegen **
    bsr     alloc_vectors_memory
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne     cleanup_all_memory ;Ja -> verzweige
    IFD pass_global_references
      bsr     init_global_references_table
    ENDC
  ENDC

; ** Variablen initialisieren **
  bsr     init_own_variables

  IFND sys_taken_over
; ** Maschine übernehmen **
; -------------------------
    bsr     disable_system   
    move.l  d0,dos_return_code(a3) ;Fehler aufgetreten ?
    bne.s   cleanup_all_memory ;Ja -> verzweige
    IFD all_caches
      bsr     enable_all_caches
    ENDC
    IFD no_store_buffer
      bsr     disable_store_buffer
    ENDC
    bsr     save_exception_vectors
  ENDC
    bsr     init_exception_vectors
  IFND sys_taken_over
    bsr     exception_vectors_to_fast_memory
  ENDC
  move.l  #_CIAB,a5          ;CIA-B-Base
  lea     _CIAA-_CIAB(a5),a4 ;CIA-A-Base
  move.l  #_CUSTOM+DMACONR,a6 ;DMACONR
  IFND sys_taken_over
    bsr     save_hardware_registers
    bsr     clear_important_registers
    bsr     turn_off_drive_motors
  ENDC
  move.w  #DMABITS&(~(DMAF_SPRITE|DMAF_COPPER|DMAF_RASTER)),DMACON-DMACONR(a6) ;DMA ausser Sprite/Copper/Bitplane-DMA an
  bsr     init_all
  bsr     start_own_display
  IFNE (INTENABITS-INTF_SETCLR)|(CIAAICRBITS-CIAICRF_SETCLR)|(CIABICRBITS-CIAICRF_SETCLR)
    bsr     start_own_interrupts
  ENDC
  IFEQ CIAA_TA_continuous_enabled&CIAA_TB_continuous_enabled&CIAB_TA_continuous_enabled&CIAB_TB_continuous_enabled
    bsr     start_CIA_timers
  ENDC

; ** Ausführen des eigentlichen Programms **
; ------------------------------------------
  IFD sys_taken_over
    IFD pass_return_code
      move.l  dos_return_code(a3),d0
      move.w  custom_error_code(a3),d1
    ENDC
    IFD pass_global_references
      move.l  global_references_table(a3),a0
    ENDC
  ELSE
    IFD pass_return_code
      move.l  dos_return_code(a3),d0
      move.w  custom_error_code(a3),d1
    ENDC
    IFD pass_global_references
      lea     global_references_table(pc),a0
    ENDC
  ENDC
  bsr     main_routine
  IFD pass_return_code
    move.l  d0,dos_return_code(a3)
    move.w  d1,custom_error_code(a3)
  ENDC

; ** Alles stoppen **
; -------------------
  IFEQ CIAA_TA_continuous_enabled&CIAA_TB_continuous_enabled&CIAB_TA_continuous_enabled&CIAB_TB_continuous_enabled
    bsr     stop_CIA_timers
  ENDC
  IFNE (INTENABITS-INTF_SETCLR)|(CIAAICRBITS-CIAICRF_SETCLR)|(CIABICRBITS-CIAICRF_SETCLR)
    bsr     stop_own_interrupts
  ENDC
  bsr     stop_own_display

  IFND sys_taken_over
; ** alte System-Parameter wieder herstellem **
; ---------------------------------------------
    bsr     clear_important_registers2
    bsr     restore_hardware_registers
    IFD all_caches
      bsr     enable_os_caches
    ENDC
    IFD no_store_buffer
      bsr     enable_store_buffer
    ENDC
    bsr     restore_exception_vectors
  
  ; ** Betriebssystem übernimmt wieder Maschine **
  ; ----------------------------------------------
    bsr     enable_system
    IFEQ text_output_enabled
      bsr     print_text
    ENDC
  ENDC

; ** Freigabe des belegten Speichers **
; -------------------------------------
cleanup_all_memory

  IFD sys_taken_over
; ** Speicherbelegung Custom-Memory freigeben **
    IFD custom_memory_used
      bsr     free_custom_memory ;Wird von außen aufgerufen
    ENDC
  ELSE
; ** Speicherbelegung für Exception-Vektors freigeben **
    bsr     free_vectors_memory
  ENDC

; ** Speicherbelegung für Chip-Memory freigeben **
  IFNE chip_memory_size
    bsr     free_chip_memory
  ENDC

; ** Speicherbelegung für Extra-Memory freigeben **
  IFNE extra_memory_size
    bsr     free_extra_memory
  ENDC

; ** Speicherbelegung für Diskettenpuffer freigeben **
  IFNE disk_memory_size
    bsr     free_disk_memory
  ENDC

; ** Speicherbelegung für Audiokanäle freigeben **
  IFNE audio_memory_size
    bsr     free_audio_memory
  ENDC

; ** Speicherbelegung für Sprites freigeben **
  IFNE spr_x_size2
    bsr     free_sprite_memory2
  ENDC
  IFNE spr_x_size1
    bsr     free_sprite_memory1
  ENDC

; ** Speicherbelegung für Playfields freigeben **
  IFNE extra_pf_number
    bsr     free_extra_pf_memory
  ENDC
  IFNE pf2_x_size3
    bsr     free_pf2_memory3
  ENDC
  IFNE pf2_x_size2
    bsr     free_pf2_memory2
  ENDC
  IFNE pf2_x_size1
    bsr     free_pf2_memory1
  ENDC
  IFNE pf1_x_size3
    bsr     free_pf1_memory3
  ENDC
  IFNE pf1_x_size2
    bsr     free_pf1_memory2
  ENDC
  IFNE pf1_x_size1
    bsr     free_pf1_memory1
  ENDC

; ** Speicherbelegung für Copperlisten freigeben **
  IFNE cl2_size3
    bsr     free_cl2_memory3
  ENDC
  IFNE cl2_size2
    bsr     free_cl2_memory2
  ENDC
  IFNE cl2_size1
    bsr     free_cl2_memory1
  ENDC
  IFNE cl1_size3
    bsr     free_cl1_memory3
  ENDC
  IFNE cl1_size2
    bsr     free_cl1_memory2
  ENDC
  IFNE cl1_size1
    bsr     free_cl1_memory1
  ENDC


; ** Timer-Device schließen **
cleanup_timer_device
  IFND sys_taken_over
    bsr     close_timer_device
  ENDC


; ** Intuition-Bibliothek wieder schließen **
cleanup_intuition_library
  IFND sys_taken_over
    bsr     close_intuition_library
  ENDC

; ** Graphics-Bibliothek wieder schließen **
cleanup_graphics_library
  IFND sys_taken_over
    bsr     close_graphics_library
  ENDC

; ** Dos-Bibliothek wieder schließen **
cleanup_dos_library
  IFND sys_taken_over
    bsr     print_error_message
    move.l  d0,dos_return_code(a3)
    bsr     close_dos_library
  ENDC

; ** Ggf. Workbench-Message beantworten **
cleanup_wb_message
  IFND sys_taken_over
    IFEQ workbench_start_enabled
      bsr     reply_wb_message
    ENDC
  ENDC

end_final
  IFD measure_rastertime
    move.l  rt_rasterlines_number(a3),d0
output_rasterlines_number
  ELSE
    move.l  dos_return_code(a3),d0
  ENDC
  IFD sys_taken_over
    IFD pass_return_code
      move.w  custom_error_code(a3),d1
    ENDC
    IFD pass_global_references
      move.l  global_references_table(a3),a0
    ENDC
  ENDC
  movem.l (a7)+,d2-d7/a2-a6
  rts

; ** Variablen initialisieren **
; ------------------------------
  CNOP 0,4
init_variables
  IFD sys_taken_over
    IFD pass_global_references
      move.l    a0,global_references_table(a3)
      lea       _SysBase(pc),a1
      move.l    (a0)+,(a1)   ;Zeiger auf Exec-Base
      lea       _GfxBase(pc),a1
      move.l    (a0),(a1)    ;Zeiger auf GFX-Base
    ENDC
    IFD wrapper
      moveq   #RETURN_OK,d2
      move.l  d2,dos_return_code(a3)
      move.w  #NO_CUSTOM_ERROR,custom_error_code(a3)
    ELSE
      IFD pass_return_code
        move.l  d0,dos_return_code(a3)
        move.w  d1,custom_error_code(a3)
      ENDC
    ENDC
  ELSE
    move.l  d0,(a3)          ;Länge des Eingabestrings retten
    move.l  a0,shell_parameters_pointer(a3) ;Zeiger auf Eingabestring retten

    moveq   #TRUE,d0
    IFEQ workbench_start_enabled
      move.l  d0,wb_message(a3)
    ENDC
    moveq   #FALSE,d1
    move.w  d1,fast_memory_available(a3)

    IFEQ workbench_fade_enabled
      move.w  d0,wbfi_active(a3)
      move.w  d0,wbfo_active(a3)
    ENDC

    move.l  d0,exception_vectors_base(a3)

    moveq   #RETURN_OK,d2
    move.l  d2,dos_return_code(a3)
    move.w  #NO_CUSTOM_ERROR,custom_error_code(a3)

    lea     _SysBase(pc),a0
    move.l  Exec_Base.w,(a0)
  ENDC
  IFD measure_rastertime
    moveq   #0,d0
    move.l  d0,rt_rasterlines_number(a3)
  ENDC
  rts

; ** Strukturen und initialisieren **
; -----------------------------------
  CNOP 0,4
init_structures
  IFND sys_taken_over
    bsr     init_easy_request_structure
    bsr     init_timer_io_structure
  ENDC
  IFNE extra_pf_number
    bsr     init_extra_pf_structure
  ENDC
  IFNE spr_x_size1|spr_x_size2
    bsr     spr_init_structure
  ENDC
  rts

  IFND sys_taken_over

; ** Tabelle mit Fehlermeldungen initialisieren **
; ------------------------------------------------
    CNOP 0,4
init_custom_error_table
    moveq   #GRAPHICS_LIBRARY_COULD_NOT_OPEN-1,d0
    lea     custom_error_table(pc),a0
    lea     error_text_graphics_library(pc),a1
    move.l  a1,(a0,d0.w*8)   ;Zeiger auf Fehlertext
    lea     error_text_graphics_library_end-error_text_graphics_library,a1
    move.l  a1,4(a0,d0.w*8)  ;Länge des Fehlertexts

    moveq   #KICKSTART_VERSION_NOT_FOUND-1,d0
    lea     error_text_kickstart(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_kickstart_end-error_text_kickstart,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #CPU_020_NOT_FOUND-1,d0
    lea     error_text_cpu_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_cpu_1_end-error_text_cpu_1,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #CHIPSET_NO_AGA_PAL-1,d0
    lea     error_text_chipset(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_chipset_end-error_text_chipset,a1
    move.l  a1,4(a0,d0.w*8)

    IFEQ requires_68030
      moveq   #CPU_030_REQUIRED-1,d0
      lea     error_text_cpu_2(pc),a1
      move.l  a1,(a0,d0.w*8)
      lea     error_text_cpu_2_end-error_text_cpu_2,a1
      move.l  a1,4(a0,d0.w*8)
    ENDC
    IFEQ requires_68040
      moveq   #CPU_040_REQUIRED-1,d0
      lea     error_text_cpu_2(pc),a1
      move.l  a1,(a0,d0.w*8)
      lea     error_text_cpu_2_end-error_text_cpu_2,a1
      move.l  a1,4(a0,d0.w*8)
    ENDC
    IFEQ requires_68060
      moveq   #CPU_060_REQUIRED-1,d0
      lea     error_text_cpu_2(pc),a1
      move.l  a1,(a0,d0.w*8)
      lea     error_text_cpu_2_end-error_text_cpu_2,a1
      move.l  a1,4(a0,d0.w*8)
    ENDC

    IFEQ requires_fast_memory
      moveq   #FAST_MEMORY_REQUIRED-1,d0
      lea     error_text_fast_memory(pc),a1
      move.l  a1,(a0,d0.w*8)
      lea     error_text_fast_memory_end-error_text_extra_memory,a1
      move.l  a1,4(a0,d0.w*8)
    ENDC

    moveq   #INTUITION_LIBRARY_COULD_NOT_OPEN-1,d0
    lea     error_text_intuition_library(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_intuition_library_end-error_text_intuition_library,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #CIAA_RESOURCE_COULD_NOT_OPEN-1,d0
    lea     error_text_ciaa_resource(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_ciaa_resource_end-error_text_ciaa_resource,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #CIAB_RESOURCE_COULD_NOT_OPEN-1,d0
    lea     error_text_ciab_resource(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_ciab_resource_end-error_text_ciab_resource,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #TIMER_DEVICE_COULD_NOT_OPEN-1,d0
    lea     error_text_timer_device(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_timer_device_end-error_text_timer_device,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #CL1_CONSTRUCTION1_NO_MEMORY-1,d0
    lea     error_text_cl1_construction1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_cl1_construction1_end-error_text_cl1_construction1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #CL1_CONSTRUCTION2_NO_MEMORY-1,d0
    lea     error_text_cl1_construction2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_cl1_construction2_end-error_text_cl1_construction2,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #CL1_DISPLAY_NO_MEMORY-1,d0
    lea     error_text_cl1_display(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_cl1_display_end-error_text_cl1_display,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #CL2_CONSTRUCTION1_NO_MEMORY-1,d0
    lea     error_text_cl2_construction1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_cl2_construction1_end-error_text_cl2_construction1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #CL2_CONSTRUCTION2_NO_MEMORY-1,d0
    lea     error_text_cl2_construction2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_cl2_construction2_end-error_text_cl2_construction2,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #CL2_DISPLAY_NO_MEMORY-1,d0
    lea     error_text_cl2_display(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_cl2_display_end-error_text_cl2_display,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #PF1_CONSTRUCTION1_NO_MEMORY-1,d0
    lea     error_text_pf1_construction1_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf1_construction1_1_end-error_text_pf1_construction1_1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF1_CONSTRUCTION1_NOT_INTERLEAVED-1,d0
    lea     error_text_pf1_construction1_2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf1_construction1_2_end-error_text_pf1_construction1_2,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF1_CONSTRUCTION2_NO_MEMORY-1,d0
    lea     error_text_pf1_construction2_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf1_construction2_1_end-error_text_pf1_construction2_1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF1_CONSTRUCTION2_NOT_INTERLEAVED-1,d0
    lea     error_text_pf1_construction2_2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf1_construction2_2_end-error_text_pf1_construction2_2,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF1_DISPLAY_NO_MEMORY-1,d0
    lea     error_text_pf1_display_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf1_display_1_end-error_text_pf1_display_1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF1_DISPLAY_NOT_INTERLEAVED-1,d0
    lea     error_text_pf1_display_2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf1_display_2_end-error_text_pf1_display_2,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #PF2_CONSTRUCTION1_NO_MEMORY-1,d0
    lea     error_text_pf2_construction1_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf2_construction1_1_end-error_text_pf2_construction1_1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF2_CONSTRUCTION1_NOT_INTERLEAVED-1,d0
    lea     error_text_pf2_construction1_2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf2_construction1_2_end-error_text_pf2_construction1_2,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF2_CONSTRUCTION2_NO_MEMORY-1,d0
    lea     error_text_pf2_construction2_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf2_construction2_1_end-error_text_pf2_construction2_1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF2_CONSTRUCTION2_NOT_INTERLEAVED-1,d0
    lea     error_text_pf2_construction2_2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf2_construction2_2_end-error_text_pf2_construction2_2,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF2_DISPLAY_NO_MEMORY-1,d0
    lea     error_text_pf2_display_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf2_display_1_end-error_text_pf2_display_1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #PF2_DISPLAY_NOT_INTERLEAVED-1,d0
    lea     error_text_pf2_display_2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_pf2_display_2_end-error_text_pf2_display_2,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #EXTRA_PLAYFIELD_NO_MEMORY-1,d0
    lea     error_text_extra_playfield_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_extra_playfield_1_end-error_text_extra_playfield_1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #EXTRA_PLAYFIELD_NOT_INTERLEAVED-1,d0
    lea     error_text_extra_playfield_2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_extra_playfield_2_end-error_text_extra_playfield_2,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #SPR_CONSTRUCTION_NO_MEMORY-1,d0
    lea     error_text_spr_construction_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_spr_construction_1_end-error_text_spr_construction_1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #SPR_CONSTRUCTION_NOT_INTERLEAVED-1,d0
    lea     error_text_spr_construction_2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_spr_construction_2_end-error_text_spr_construction_2,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #SPR_DISPLAY_NO_MEMORY-1,d0
    lea     error_text_spr_display_1(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_spr_display_1_end-error_text_spr_display_1,a1
    move.l  a1,4(a0,d0.w*8)
    moveq   #SPR_DISPLAY_NOT_INTERLEAVED-1,d0
    lea     error_text_spr_display_2(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_spr_display_2_end-error_text_spr_display_2,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #AUDIO_MEMORY_NO_MEMORY-1,d0
    lea     error_text_audio_memory(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_audio_memory_end-error_text_audio_memory,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #DISK_MEMORY_NO_MEMORY-1,d0
    lea     error_text_disk_memory(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_disk_memory_end-error_text_disk_memory,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #EXTRA_MEMORY_NO_MEMORY-1,d0
    lea     error_text_extra_memory(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_extra_memory_end-error_text_extra_memory,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #CHIP_MEMORY_NO_MEMORY-1,d0
    lea     error_text_chip_memory(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_chip_memory_end-error_text_chip_memory,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #CUSTOM_MEMORY_NO_MEMORY-1,d0
    lea     error_text_custom_memory(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_custom_memory_end-error_text_custom_memory,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #EXCEPTION_VECTORS_NO_MEMORY-1,d0
    lea     error_text_exception_vectors(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_exception_vectors_end-error_text_exception_vectors,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #ACTIVE_SCREEN_NOT_FOUND-1,d0
    lea     error_text_active_screen(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_active_screen_end-error_text_active_screen,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #VIEWPORT_MONITOR_ID_NOT_FOUND-1,d0
    lea     error_text_viewport(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_viewport_end-error_text_viewport,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #SCREEN_COLOR_TABLE_NO_MEMORY-1,d0
    lea     error_text_screen_color_table(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_screen_color_table_end-error_text_screen_color_table,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #SCREEN_COULD_NOT_OPEN-1,d0
    lea     error_text_screen(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_screen_end-error_text_screen,a1
    move.l  a1,4(a0,d0.w*8)

    moveq   #SCREEN_DISPLAY_MODE_NOT_AVAILABLE-1,d0
    lea     error_text_screen_display_mode(pc),a1
    move.l  a1,(a0,d0.w*8)
    lea     error_text_screen_display_mode_end-error_text_screen_display_mode,a1
    move.l  a1,4(a0,d0.w*8)

    IFEQ workbench_fade_enabled
      moveq   #WORKBENCH_FADE_NO_MEMORY-1,d0
      lea     error_text_workbench_fade_enabled(pc),a1
      move.l  a1,(a0,d0.w*8)
      lea     error_text_workbench_fade_enabled_end-error_text_workbench_fade_enabled,a1
      move.l  a1,4(a0,d0.w*8)
    ENDC
    rts

; ** Easy-Request-Struktur initialisieren **
; ------------------------------------------
    CNOP 0,4
init_easy_request_structure
    IFNE INTENABITS&INTF_PORTS
      lea     tcp_request_structure(pc),a0 ;Zeiger auf Easy-Struktur
      moveq   #EasyStruct_SIZEOF,d0
      move.l  d0,(a0)+           ;Größe der Struktur
      moveq   #0,d0
      move.l  d0,(a0)+           ;Keine Flags
      lea     tcp_requester_title(pc),a1
      move.l  a1,(a0)+           ;Zeiger auf Titeltext
      lea     tcp_requester_text(pc),a1
      move.l  a1,(a0)+           ;Zeiger auf Text in Requester
      lea     tcp_requester_gadgets_text(pc),a1
      move.l  a1,(a0)            ;Zeiger auf Gadgettexte
    ENDC
    IFEQ requires_multiscan_monitor
      lea     vga_request_monitor_structure(pc),a0 ;Zeiger auf Easy-Struktur
      moveq   #EasyStruct_SIZEOF,d0
      move.l  d0,(a0)+         ;Größe der Struktur
      moveq   #0,d0
      move.l  d0,(a0)+         ;Keine Flags
      lea     vga_requester_title(pc),a1
      move.l  a1,(a0)+         ;Zeiger auf Titeltext
      lea     vga_requester_text(pc),a1
      move.l  a1,(a0)+         ;Zeiger auf Text in Requester
      lea     vga_requester_gadgets_text(pc),a1
      move.l  a1,(a0)          ;Zeiger auf Gadgettexte
    ENDC
    rts
  
; ** Timer-IO-Struktur initialisieren **
; --------------------------------------
    CNOP 0,4
init_timer_io_structure
    lea     timer_io_structure(pc),a0
    moveq   #0,d0
    move.b  d0,LN_Type(a0)     ;Eintragstyp = Null
    move.b  d0,LN_Pri(a0)      ;Priorität der Struktur = Null
    move.l  d0,LN_Name(a0)     ;Keine Name der Struktur
    move.l  d0,MN_ReplyPort(a0) ;Kein Reply-Port
    rts
  
; ** Taglisten initialisieren **
; ------------------------------
    CNOP 0,4
init_taglists
    bsr.s   spr_init_taglist
    bra.s   init_downgrade_screen_taglist
  
; ** Sprite-Tagliste initialisieren **
; ------------------------------------
    CNOP 0,4
spr_init_taglist
    lea     spr_taglist(pc),a0
    move.l  #VTAG_SPRITERESN_GET,(a0)+
    moveq   #0,d0
    move.l  d0,(a0)+
    moveq   #TAG_DONE,d1
    move.l  d1,(a0)
    rts
  
; ** Screen-TagListe initialisieren **
; ------------------------------------
    CNOP 0,4
init_downgrade_screen_taglist
    lea     downgrade_screen_taglist(pc),a0
    move.l  #SA_Left,(a0)+
    moveq   #0,d0
    move.l  d0,(a0)+
    move.l  #SA_Top,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_Width,(a0)+
    moveq   #2,d2
    move.l  d2,(a0)+
    move.l  #SA_Height,(a0)+
    moveq   #2,d2
    move.l  d2,(a0)+
    move.l  #SA_Depth,(a0)+
    moveq   #1,d2
    move.l  d2,(a0)+
    move.l  #SA_DetailPen,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_BlockPen,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_Title,(a0)+
    lea     downgrade_screen_name(pc),a1
    move.l  a1,(a0)+
    move.l  #SA_Font,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_SysFont,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_Type,(a0)+
    move.l  #CUSTOMSCREEN,(a0)+
    move.l  #SA_DisplayID,(a0)+
    IFEQ requires_multiscan_monitor
      move.l  #VGA_MONITOR_ID|VGAPRODUCT_KEY,(a0)+
    ELSE
      move.l  #PAL_MONITOR_ID|LORES_KEY,(a0)+
    ENDC
    move.l  #SA_ShowTitle,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_Behind,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_Quiet,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_AutoScroll,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_Draggable,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_Interleaved,(a0)+
    move.l  d0,(a0)+
    move.l  #SA_Colors32,(a0)+
    move.l  d0,(a0)+           ;Farbtabelle noch nicht in Speicher belegt
    moveq   #TAG_DONE,d2
    move.l  d2,(a0)
    rts
  ENDC

; ** Extra-Playfield-Struktur initialisieren **
; ---------------------------------------------
  IFNE extra_pf_number
    CNOP 0,4
init_extra_pf_structure
    lea     extra_pf_attributes(pc),a0
    IFGE extra_pf_number-1
      move.l  #extra_pf1_x_size,(a0)+
      move.l  #extra_pf1_y_size,(a0)+
      moveq   #extra_pf1_depth,d0
      IFEQ extra_pf_number-1
        move.l  d0,(a0)
      ELSE
        move.l  d0,(a0)+
      ENDC
    ENDC
    IFGE extra_pf_number-2
      move.l  #extra_pf2_x_size,(a0)+
      move.l  #extra_pf2_y_size,(a0)+
      moveq   #extra_pf2_depth,d0
      IFEQ extra_pf_number-2
        move.l  d0,(a0)
      ELSE
        move.l  d0,(a0)+
      ENDC
    ENDC
    IFGE extra_pf_number-3
      move.l  #extra_pf3_x_size,(a0)+
      move.l  #extra_pf3_y_size,(a0)+
      moveq   #extra_pf3_depth,d0
      IFEQ extra_pf_number-3
        move.l  d0,(a0)
      ELSE
        move.l  d0,(a0)+
      ENDC
    ENDC
    IFGE extra_pf_number-4
      move.l  #extra_pf4_x_size,(a0)+
      move.l  #extra_pf4_y_size,(a0)+
      moveq   #extra_pf4_depth,d0
      IFEQ extra_pf_number-4
        move.l  d0,(a0)
      ELSE
        move.l  d0,(a0)+
      ENDC
    ENDC
    IFGE extra_pf_number-5
      move.l  #extra_pf5_x_size,(a0)+
      move.l  #extra_pf5_y_size,(a0)+
      moveq   #extra_pf5_depth,d0
      IFEQ extra_pf_number-5
        move.l  d0,(a0)
      ELSE
        move.l  d0,(a0)+
      ENDC
    ENDC
    IFGE extra_pf_number-6
      move.l  #extra_pf6_x_size,(a0)+
      move.l  #extra_pf6_y_size,(a0)+
      moveq   #extra_pf6_depth,d0
      IFEQ extra_pf_number-6
        move.l  d0,(a0)
      ELSE
        move.l  d0,(a0)+
      ENDC
    ENDC
    IFGE extra_pf_number-7
      move.l  #extra_pf7_x_size,(a0)+
      move.l  #extra_pf7_y_size,(a0)+
      moveq   #extra_pf7_depth,d0
      IFEQ extra_pf_number-7
        move.l  d0,(a0)
      ELSE
        move.l  d0,(a0)+
      ENDC
    ENDC
    IFGE extra_pf_number-8
      move.l  #extra_pf8_x_size,(a0)+
      move.l  #extra_pf8_y_size,(a0)+
      moveq   #extra_pf8_depth,d0
      IFEQ extra_pf_number-8
        move.l  d0,(a0)
      ELSE
        move.l  d0,(a0)+
      ENDC
    ENDC
    rts
  ENDC

; ** Sprite-Eigenschaften-Struktur initialisieren **
; --------------------------------------------------
  IFNE spr_x_size1|spr_x_size2
    CNOP 0,4
spr_init_structure
    IFNE spr_x_size1
      lea     sprite_attributes1(pc),a0
      moveq   #spr0_x_size1,d0
      move.l  d0,(a0)+
      move.l  #spr0_y_size1,(a0)+
      moveq   #spr_depth,d1
      move.l  d1,(a0)+

      moveq   #spr1_x_size1,d0
      move.l  d0,(a0)+
      move.l  #spr1_y_size1,(a0)+
      move.l  d1,(a0)+

      moveq   #spr2_x_size1,d0
      move.l  d0,(a0)+
      move.l  #spr2_y_size1,(a0)+
      move.l  d1,(a0)+

      moveq   #spr3_x_size1,d0
      move.l  d0,(a0)+
      move.l  #spr3_y_size1,(a0)+
      move.l  d1,(a0)+

      moveq   #spr4_x_size1,d0
      move.l  d0,(a0)+
      move.l  #spr4_y_size1,(a0)+
      move.l  d1,(a0)+

      moveq   #spr5_x_size1,d0
      move.l  d0,(a0)+
      move.l  #spr5_y_size1,(a0)+
      move.l  d1,(a0)+

      moveq   #spr6_x_size1,d0
      move.l  d0,(a0)+
      move.l  #spr6_y_size1,(a0)+
      move.l  d1,(a0)+

      moveq   #spr7_x_size1,d0
      move.l  d0,(a0)+
      move.l  #spr7_y_size1,(a0)+
      move.l  d1,(a0)
    ENDC
    IFNE spr_x_size2
      lea     sprite_attributes2(pc),a0 ;Zeiger auf Struktur
      moveq   #spr0_x_size2,d0
      move.l  d0,(a0)+
      move.l  #spr0_y_size2,(a0)+
      moveq   #spr_depth,d1
      move.l  d1,(a0)+

      moveq   #spr1_x_size2,d0
      move.l  d0,(a0)+
      move.l  #spr1_y_size2,(a0)+
      move.l  d1,(a0)+

      moveq   #spr2_x_size2,d0
      move.l  d0,(a0)+
      move.l  #spr2_y_size2,(a0)+
      move.l  d1,(a0)+

      moveq   #spr3_x_size2,d0
      move.l  d0,(a0)+
      move.l  #spr3_y_size2,(a0)+
      move.l  d1,(a0)+

      moveq   #spr4_x_size2,d0
      move.l  d0,(a0)+
      move.l  #spr4_y_size2,(a0)+
      move.l  d1,(a0)+

      moveq   #spr5_x_size2,d0
      move.l  d0,(a0)+
      move.l  #spr5_y_size2,(a0)+
      move.l  d1,(a0)+

      moveq   #spr6_x_size2,d0
      move.l  d0,(a0)+
      move.l  #spr6_y_size2,(a0)+
      move.l  d1,(a0)+

      moveq   #spr7_x_size2,d0
      move.l  d0,(a0)+
      move.l  #spr7_y_size2,(a0)+
      move.l  d1,(a0)
    ENDC
    rts
  ENDC

; ** Testen, ob von der Workbench ein Start erfolgte **
; -----------------------------------------------------
  IFND sys_taken_over
    IFEQ workbench_start_enabled
      CNOP 0,4
test_start_from_workbench
      sub.l   a1,a1            ;Nach dem eigenen Task suchen
      CALLEXEC FindTask
      tst.l   d0
      beq.s   task_error       ;Fehler -> verzweige
      move.l  d0,a2            ;aktueller Task 
      tst.l   pr_CLI(a2)       ;Von Workbench gestartet ?
      beq.s   start_from_workbench ;Ja -> verzweige
start_from_shell               ;Shell-Start
      moveq   #RETURN_OK,d0
      rts
      CNOP 0,4
start_from_workbench
      lea     pr_MsgPort(a2),a0 ;Zeiger auf Message-Port
      CALLLIBS WaitPort        ;Auf Start-Message warten
      lea     pr_MsgPort(a2),a0 ;Zeiger auf Message
      CALLLIBS GetMsg          ;Message 
      move.l  d0,wb_message(a3) 
      moveq   #RETURN_OK,d0
      rts
      CNOP 0,4
task_error
      moveq   #RETURN_FAIL,d0
      rts
    ENDC
  
  ; ** DOS-Library öffnen **
  ; ------------------------
    CNOP 0,4
open_dos_library
    lea     dos_name(pc),a1
    moveq   #ANY_LIB_VERSION,d0
    CALLEXEC OpenLibrary
    lea     _DOSBase(pc),a0
    move.l  d0,(a0)
    beq.s   dos_library_error  ;Wenn Fehler -> verzweige
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
dos_library_error
    moveq   #RETURN_FAIL,d0
    rts

; ** Graphics-Library öffnen **
; -----------------------------
    CNOP 0,4
open_graphics_library
    lea     graphics_name(pc),a1
    moveq   #ANY_LIB_VERSION,d0
    CALLEXEC OpenLibrary
    lea     _GfxBase(pc),a0
    move.l  d0,(a0)
    beq.s   gfx_library_error  ;Wenn Fehler -> verzweige
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
gfx_library_error
    move.w  #GRAPHICS_LIBRARY_COULD_NOT_OPEN,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts

; ** Systemkonstanten überprüfen **
; ---------------------------------
    CNOP 0,4
check_system
    move.l  _SysBase(pc),a6
    cmp.w   #OS_VERSION_AGA,Lib_Version(a6) ;Kickstart 3.0+ ?
    blt.s   system_error1      ;Nein -> verzweige
check_cpu
    move.w  AttnFlags(a6),d0   ;Prozessor-Flags
    move.w  d0,cpu_flags(a3)   
    and.b   #AFF_68020,d0      ;68020+ ?
    beq.s   system_error2      ;Nein -> verzweige
check_chipset
      move.l  _GfxBase(pc),a1
    IFD aga_check_by_hardware_enables
      move.l  #_CUSTOM+DENISEID,a0 ;DENISEID
      move.w  -(DENISEID-VPOSR)(a0),d0
      and.w   #$7e00,d0        ;Nur Bits 8-14
      cmp.w   #$22<<8,d0       ;PAL-Alice Revision 2 ?
      beq.s   check_lisa_id    ;Ja -> verzweige
      cmp.w   #$23<<8,d0       ;PAL-Alice Revision 3 & 4 ?
      bne.s   system_error3    ;Nein -> verzweige
check_lisa_id
      move.w  (a0),d0          ;ID 
      moveq   #32-1,d7         ;32x checken
check_lisa_id_loop
      move.w  (a0),d1          ;ID 
      cmp.b   d0,d1            ;identisch ?
      bne.s   system_error3    ;Nein -> verzweige
      dbf     d7,check_lisa_id_loop
      or.b    #$f0,d0          ;0th revision level setzen
      cmp.b   #$f8,d0          ;Lisa-ID ?
      bne.s   system_error3    ;Nein -> verzweige
    ELSE
      move.b  gb_ChipRevBits0(a1),d0 ;Chipversion
      btst    #GFXB_AA_ALICE,d0;ALICE ?
      beq.s   system_error3    ;Nein -> verzweige
      btst    #GFXB_AA_LISA,d0 ;LISA ?
      beq.s   system_error3    ;Nein -> verzweige
    ENDC
check_pal
    btst    #REALLY_PALn,gb_DisplayFlags+1(a1) ;PAL-Maschine ?
    beq.s   system_error3      ;Nein -> verzweige
check_fast_memory
    moveq   #MEMF_FAST,d1      ;FAST-Memory
    CALLLIBS AvailMem
    tst.l   d0                 ;Vorhanden ?
    beq.s   no_fast_memory_found ;Nein -> verzweige
    clr.w   fast_memory_available(a3) ;True = FAST-Memory vorhanden
no_fast_memory_found
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
system_error1
    move.w  #KICKSTART_VERSION_NOT_FOUND,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
    CNOP 0,4
system_error2
    CALLLIBS Permit
    move.w  #CPU_020_NOT_FOUND,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
    CNOP 0,4
system_error3
    CALLLIBS Permit
    move.w  #CHIPSET_NO_AGA_PAL,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
  
  ; ** Auf bestimmte CPU hin überprüfen **
  ; --------------------------------------
    IFEQ requires_68030
      CNOP 0,4
check_cpu_requirements
      btst   #AFB_68030,cpu_flags+1(a3) ;68030+ ?
      beq.s  check_cpu_error     ;Nein -> verzweige
      moveq  #RETURN_OK,d0
      rts
      CNOP 0,4
check_cpu_error
      move.w  #CPU_030_REQUIRED,custom_error_code(a3)
      moveq   #RETURN_FAIL,d0
      rts
    ENDC
    IFEQ requires_68040
      CNOP 0,4
check_cpu_requirements
      btst   #AFB_68040,cpu_flags+1(a3) ;68040+ ?
      beq.s  check_cpu_error     ;Nein -> verzweige
      moveq  #RETURN_OK,d0
      rts
      CNOP 0,4
check_cpu_error
      move.w  #CPU_040_REQUIRED,custom_error_code(a3)
      moveq   #RETURN_FAIL,d0
      rts
    ENDC
    IFEQ requires_68060
      CNOP 0,4
check_cpu_requirements
      tst.b   cpu_flags+1(a3)    ;68060 ?
      bpl.s   check_cpu_error    ;Nein -> verzweige
      moveq   #RETURN_OK,d0
      rts
      CNOP 0,4
check_cpu_error
      move.w  #CPU_060_REQUIRED,custom_error_code(a3)
      moveq   #RETURN_FAIL,d0
      rts
    ENDC
  
; ** Generell auf Fast-Memory prüfen **
; -------------------------------------
    IFEQ requires_fast_memory
      CNOP 0,4
check_memory_requirements
      tst.w   fast_memory_available(a3) ;FAST-Memory generell vorhanden ?
      bne.s   no_fast_memory   ;Nein -> verzweige
      moveq   #RETURN_OK,d0
      rts
      CNOP 0,4
no_fast_memory
      move.w  #FAST_MEMORY_REQUIRED,custom_error_code(a3)
      moveq   #RETURN_FAIL,d0
      rts
    ENDC
  
; ** Intuition-Library öffnen **
; ------------------------------
    CNOP 0,4
open_intuition_library
    lea     intuition_name(pc),a1
    moveq   #OS_VERSION_AGA,d0 ;Version 3.0+
    CALLEXEC OpenLibrary
    lea     _IntuitionBase(pc),a0
    move.l  d0,(a0)
    beq.s   intuition_library_error ;Wenn Fehler -> verzweige
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
intuition_library_error
    move.w  #INTUITION_LIBRARY_COULD_NOT_OPEN,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
  
; ** Userabfrage, wenn TCP-Stack vorhanden ist **
; -----------------------------------------------
    IFNE INTENABITS&INTF_PORTS
      CNOP 0,4
do_tcp_stack_request
      CALLEXEC Forbid
      lea     LibList(a6),a0     ;Zeiger auf Library-Liste
      lea     bsdsocket_name(pc),a1
      CALLLIBS FindName
      tst.l   d0
      beq.s   no_tcp_stack_found ;Wenn nicht gefunden -> verzweige
tcp_stack_found
      move.l  d0,a0
      tst.w   LIB_OPENCNT(a0)
      beq.s   no_tcp_stack_found ;Wenn Bibliothek nicht offen -> verzweige
      CALLLIBS Permit
      move.l  a3,a4              ;Inhalt von a3 retten
      sub.l   a0,a0              ;Requester erscheint auf Workbench
      lea     tcp_request_structure(pc),a1
      move.l  a0,a2              ;Keine IDCMP-Flags
      move.l  a0,a3              ;Keine Argumentenliste
      CALLINT EasyRequestArgs
      move.l  a4,a3              ;Alter Inhalt von a3
      CMPF.L  0,d0               ;Wurde rechtes Gadget "Quit" (0) angeklickt?
      beq.s   tcp_quit_prg       ;Ja -> verzweige
      cmp.b   #1,d0              ;Wurde linkes Gadget "Proceed" (1) angeklickt?
      beq.s   do_tcp_stack_request ;Ja -> verweige
      moveq   #RETURN_OK,d0
      rts
      CNOP 0,4
no_tcp_stack_found
      CALLLIBS Permit
      moveq   #RETURN_OK,d0
      rts
      CNOP 0,4
tcp_quit_prg
      moveq   #RETURN_WARN,d0
      rts
    ENDC
  
; ** Userabfrage, ob Multifrequenz-Monitor angeschlossen ist **
; -------------------------------------------------------------
    IFEQ requires_multiscan_monitor
      CNOP 0,4
do_monitor_request
      move.l  a3,a4            ;Inhalt von a3 retten
      sub.l   a0,a0            ;Requester erscheint auf Workbench
      lea     vga_request_monitor_structure(pc),a1 ;Zeiger auf Easy-Struktur
      move.l  a0,a2            ;Keine IDCMP-Flags
      move.l  a0,a3            ;Keine Argumentenliste
      CALLINT EasyRequestArgs
      move.l  a4,a3            ;Alter Inhalt von a3
      tst.l   d0               ;Wurde rechtes Gadget angeklickt ?
      beq.s   do_monitor_request_error ;Ja -> verzweige
      moveq   #RETURN_OK,d0
      rts
      CNOP 0,4
do_monitor_request_error
      moveq   #RETURN_FAIL,d0
      rts
    ENDC
  
; ** CIA-A und CIA-B Resources öffnen und ICR-Register retten **
; --------------------------------------------------------------
    CNOP 0,4
open_ciax_resources
    lea     CIAA_name(pc),a1
    CALLEXEC OpenResource
    lea     _CIABase(pc),a0
    move.l  d0,(a0)
    beq.s   ciaa_resources_error ;Wenn Fehler -> verzweige
    moveq   #0,d0              ;keine Maske
    CALLCIA AbleICR
    move.b  d0,os_CIAAICR(a3)  
  
    lea     CIAB_name(pc),a1
    CALLEXEC OpenResource
    lea     _CIABase(pc),a0
    move.l  d0,(a0)
    beq.s   ciab_resources_error ;Wenn Fehler -> verzweige
    moveq   #0,d0              ;keine Maske
    CALLCIA AbleICR
    move.b  d0,os_CIABICR(a3)  
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
ciaa_resources_error
    move.w  #CIAA_RESOURCE_COULD_NOT_OPEN,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
    CNOP 0,4
ciab_resources_error
    move.w  #CIAB_RESOURCE_COULD_NOT_OPEN,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
  
; ** Timer-Device öffnen **
; -------------------------
    CNOP 0,4
open_timer_device
    lea     timer_device_name(pc),a0
    lea     timer_io_structure(pc),a1
    moveq   #UNIT_MICROHZ,d0   ;Unit 0
    moveq   #0,d1              ;Keine Flags
    CALLEXEC OpenDevice
    tst.l   d0
    bne.s   open_timer_device_error ;Wenn Fehler -> verzweige
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
open_timer_device_error
    move.w  #TIMER_DEVICE_COULD_NOT_OPEN,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
  ENDC

; ** Speicher für erste Copperliste belegen **
; --------------------------------------------
  IFNE cl1_size1
    CNOP 0,4
alloc_cl1_memory1
    MOVEF.L cl1_size1,d0
    bsr     do_alloc_chip_memory
    move.l  d0,cl1_construction1(a3) ;1. Copperliste
    beq.s   cl1_memory_error1
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
cl1_memory_error1
    move.w  #CL1_CONSTRUCTION1_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0
    rts
  ENDC
; ** Speicher für zweite Copperliste belegen **
; ---------------------------------------------
  IFNE cl1_size2
    CNOP 0,4
alloc_cl1_memory2
    MOVEF.L cl1_size2,d0
    bsr     do_alloc_chip_memory
    move.l  d0,cl1_construction2(a3) ;2. Copperliste
    beq.s   cl1_memory_error2
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
cl1_memory_error2
    move.w  #CL1_CONSTRUCTION2_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0
    rts
  ENDC
; ** Speicher für dritte Copperlisten belegen **
; ----------------------------------------------
  IFNE cl1_size3
    CNOP 0,4
alloc_cl1_memory3
    MOVEF.L cl1_size3,d0
    bsr     do_alloc_chip_memory
    move.l  d0,cl1_display(a3) ;3. Copperliste
    beq.s   cl1_memory_error3
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
cl1_memory_error3
    move.w  #CL1_DISPLAY_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0
    rts
  ENDC

; ** Speicher für erste Copperliste belegen **
; --------------------------------------------
  IFNE cl2_size1
    CNOP 0,4
alloc_cl2_memory1
    MOVEF.L cl2_size1,d0
    bsr     do_alloc_chip_memory
    move.l  d0,cl2_construction1(a3) ;1. Copperliste
    beq.s   cl2_memory_error1
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
cl2_memory_error1
    move.w  #CL2_CONSTRUCTION1_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0
    rts
  ENDC
; ** Speicher für zweite Copperlisten belegen **
; ----------------------------------------------
  IFNE cl2_size2
    CNOP 0,4
alloc_cl2_memory2
    MOVEF.L cl2_size2,d0
    bsr     do_alloc_chip_memory
    move.l  d0,cl2_construction2(a3) ;2. Copperliste
    beq.s   cl2_memory_error2
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
cl2_memory_error2
    move.w  #CL2_CONSTRUCTION2_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0
    rts
  ENDC
; ** Speicher für dritte Copperlisten belegen **
; ----------------------------------------------
  IFNE cl2_size3
    CNOP 0,4
alloc_cl2_memory3
    MOVEF.L cl2_size3,d0
    bsr     do_alloc_chip_memory
    move.l  d0,cl2_display(a3) ;3. Copperliste
    beq.s   cl2_memory_error3
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
cl2_memory_error3
    move.w  #CL2_DISPLAY_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0  
    rts
  ENDC

; ** Speicher für erstes Playfield belegen **
; -------------------------------------------
  IFNE pf1_x_size1
    CNOP 0,4
alloc_pf1_memory1
    MOVEF.L pf1_x_size1,d0
    MOVEF.L pf1_y_size1,d1
    moveq   #pf1_depth1,d2
    bsr     do_alloc_bitmap_memory
    move.l  d0,pf1_bitmap1(a3);Zeiger auf Bitmap-Struktur
    beq.s   pf1_memory_error1   ;Wenn Null -> verzweige
    addq.l  #bm_Planes,d0
    move.l  d0,pf1_construction1(a3) ;Offset 1. Bitplanezeiger
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf1_memory_error1
    move.w  #PF1_CONSTRUCTION1_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0  
    rts
; ** Speicher des ersten Playfields überprüfen **
; -----------------------------------------------
    CNOP 0,4
check_pf1_memory1
    move.l  pf1_bitmap1(a3),a0 ;Zeiger auf Bitmap-Struktur
    moveq   #BMA_FLAGS,d1    ;Attribute
    CALLGRAF GetBitmapAttr   ;Merkmale der Bitmap 
    btst    #BMB_DISPLAYABLE,d0 ;Bitmap darstellbar ?
    beq.s   pf1_memory_error2 ;Nein -> verzweige
    moveq   #pf1_depth1,d1   ;Anzahl der Bitplanes
    subq.w  #1,d1            ;Nur 1 Bitplane ?
    beq.s   no_pf1_check1    ;Ja -> verzweige
    btst    #BMB_INTERLEAVED,d0 ;Bitmap an einem Stück ?
    beq.s   pf1_memory_error2   ;Nein -> verzweige
no_pf1_check1
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf1_memory_error2
    move.w  #PF1_CONSTRUCTION1_NOT_INTERLEAVED,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0  
    rts
  ENDC

; ** Speicher für zweites Playfield belegen **
; --------------------------------------------
  IFNE pf1_x_size2
    CNOP 0,4
alloc_pf1_memory2
    MOVEF.L pf1_x_size2,d0
    MOVEF.L pf1_y_size2,d1
    moveq   #pf1_depth2,d2
    bsr     do_alloc_bitmap_memory
    move.l  d0,pf1_bitmap2(a3) ;Zeiger auf Bitmap-Struktur
    beq.s   pf1_memory_error3   ;Wenn Null -> verzweige
    addq.l  #bm_Planes,d0
    move.l  d0,pf1_construction2(a3) ;Offset 1. Bitplanezeiger
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf1_memory_error3
    move.w  #PF1_CONSTRUCTION2_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0  
    rts
; ** Speicher des zweiten Playfields überprüfen **
; ------------------------------------------------
    CNOP 0,4
check_pf1_memory2
    move.l  pf1_bitmap2(a3),a0 ;Zeiger auf Bitmap-Struktur
    moveq   #BMA_FLAGS,d1    ;Attribute
    CALLGRAF GetBitmapAttr   ;Merkmale der Bitmap 
    btst    #BMB_DISPLAYABLE,d0 ;Bitmap darstellbar ?
    beq.s   pf1_memory_error4 ;Nein -> verzweige
    moveq   #pf1_depth2,d1   ;Anzahl der Bitplanes
    subq.w  #1,d1            ;Nur 1 Bitplane ?
    beq.s   no_pf1_check2    ;Ja -> verzweige
    btst    #BMB_INTERLEAVED,d0 ;Bitmap an einem Stück ?
    beq.s   pf1_memory_error4   ;Nein -> verzweige
no_pf1_check2
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf1_memory_error4
    move.w  #PF1_CONSTRUCTION2_NOT_INTERLEAVED,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0  
    rts
  ENDC

; ** Speicher für drittes Playfield belegen **
; --------------------------------------------
  IFNE pf1_x_size3
    CNOP 0,4
alloc_pf1_memory3
    MOVEF.L pf1_x_size3,d0
    MOVEF.L pf1_y_size3,d1
    moveq   #pf1_depth3,d2
    bsr     do_alloc_bitmap_memory
    move.l  d0,pf1_bitmap3(a3);Zeiger auf Bitmap-Struktur
    beq.s   pf1_memory_error5 ;Wenn Null -> verzweige
    addq.l  #bm_Planes,d0
    move.l  d0,pf1_display(a3) ;Offset 1. Bitplanezeiger
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf1_memory_error5
    move.w  #PF1_DISPLAY_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0     
    rts
; ** Speicher des dritten Playfields überprüfen **
; ------------------------------------------------
    CNOP 0,4
check_pf1_memory3
    move.l  pf1_bitmap3(a3),a0 ;Zeiger auf Bitmap-Struktur
    moveq   #BMA_FLAGS,d1    ;Attribute
    CALLGRAF GetBitmapAttr   ;Merkmale der Bitmap 
    btst    #BMB_DISPLAYABLE,d0 ;Bitmap darstellbar ?
    beq.s   pf1_memory_error6   ;Nein -> verzweige
    moveq   #pf1_depth3,d1   ;Anzahl der Bitplanes
    subq.w  #1,d1            ;Nur 1 Bitplane ?
    beq.s   no_pf1_check3    ;Ja -> verzweige
    btst    #BMB_INTERLEAVED,d0 ;Bitmap an einem Stück ?
    beq.s   pf1_memory_error6   ;Nein -> verzweige
no_pf1_check3
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf1_memory_error6
    move.w  #PF1_DISPLAY_NOT_INTERLEAVED,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0     
    rts
  ENDC

; ** Speicher für erstes Playfield belegen **
; -------------------------------------------
  IFNE pf2_x_size1
    CNOP 0,4
alloc_pf2_memory1
    MOVEF.L pf2_x_size1,d0
    MOVEF.L pf2_y_size1,d1
    moveq   #pf2_depth1,d2
    bsr     do_alloc_bitmap_memory
    move.l  d0,pf2_bitmap1(a3);Zeiger auf Bitmap-Struktur
    beq.s   pf2_memory_error1 ;Wenn Null -> verzweige
    addq.l  #bm_Planes,d0
    move.l  d0,pf2_construction1(a3) ;Offset 1. Bitplanezeiger
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf2_memory_error1
    move.w  #PF2_CONSTRUCTION1_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0         
    rts
; ** Speicher des ersten Playfields überprüfen **
; -----------------------------------------------
  CNOP 0,4
check_pf2_memory1
    move.l  pf2_bitmap1(a3),a0 ;Zeiger auf Bitmap-Struktur
    moveq   #BMA_FLAGS,d1    ;Attribute
    CALLGRAF GetBitmapAttr
    btst    #BMB_DISPLAYABLE,d0 ;Bitmap darstellbar ?
    beq.s   pf2_memory_error2 ;Nein -> verzweige
    moveq   #pf2_depth1,d1   ;Anzahl der Bitplanes
    subq.w  #1,d1            ;Nur 1 Bitplane ?
    beq.s   no_pf2_check1    ;Ja -> verzweige
    btst    #BMB_INTERLEAVED,d0 ;Bitmap an einem Stück ?
    beq.s   pf2_memory_error2 ;Nein -> verzweige
no_pf2_check1
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf2_memory_error2
    move.w  #PF2_CONSTRUCTION1_NOT_INTERLEAVED,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0        
    rts
  ENDC

; ** Speicher für zweites Playfield belegen **
; --------------------------------------------
  IFNE pf2_x_size2
    CNOP 0,4
alloc_pf2_memory2
    MOVEF.L pf2_x_size2,d0
    MOVEF.L pf2_y_size2,d1
    moveq   #pf2_depth2,d2
    bsr     do_alloc_bitmap_memory
    move.l  d0,pf2_bitmap2(a3) ;Zeiger auf Bitmap-Struktur
    beq.s   pf2_memory_error3 ;Wenn Null -> verzweige
    addq.l  #bm_Planes,d0
    move.l  d0,pf2_construction2(a3) ;Offset 1. Bitplanezeiger
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf2_memory_error3
    move.w  #PF2_CONSTRUCTION2_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0      
    rts
; ** Speicher des zweiten Playfields überprüfen **
; ------------------------------------------------
    CNOP 0,4
check_pf2_memory2
    move.l  pf2_bitmap2(a3),a0 ;Zeiger auf Bitmap-Struktur
    moveq   #BMA_FLAGS,d1    ;Attribute
    CALLGRAF GetBitmapAttr
    btst    #BMB_DISPLAYABLE,d0 ;Bitmap darstellbar ?
    beq.s   pf2_memory_error4 ;Nein -> verzweige
    moveq   #pf2_depth2,d1   ;Anzahl der Bitplanes
    subq.w  #1,d1            ;Nur 1 Bitplane ?
    beq.s   no_pf2_check2    ;Ja -> verzweige
    btst    #BMB_INTERLEAVED,d0 ;Bitmap an einem Stück ?
    beq.s   pf2_memory_error4 ;Nein -> verzweige
no_pf2_check2
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf2_memory_error4
    move.w  #PF2_CONSTRUCTION2_NOT_INTERLEAVED,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0      
    rts
  ENDC

; ** Speicher für drittes Playfield belegen **
; --------------------------------------------
  IFNE pf2_x_size3
    CNOP 0,4
alloc_pf2_memory3
    MOVEF.L pf2_x_size3,d0
    MOVEF.L pf2_y_size3,d1
    moveq   #pf2_depth3,d2
    bsr     do_alloc_bitmap_memory
    move.l  d0,pf2_bitmap3(a3) ;Zeiger auf Bitmap-Struktur
    beq.s   pf2_memory_error5 ;Wenn Null -> verzweige
    addq.l  #bm_Planes,d0
    move.l  d0,pf2_display(a3) ;Offset 1. Bitplanezeiger
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf2_memory_error5
    move.w  #PF2_DISPLAY_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0      
    rts
; ** Speicher des dritten Playfields überprüfen **
; ------------------------------------------------
    CNOP 0,4
check_pf2_memory3
    move.l  pf2_bitmap3(a3),a0 ;Zeiger auf Bitmap-Struktur
    moveq   #BMA_FLAGS,d1    ;Attribute
    CALLGRAF GetBitmapAttr
    btst    #BMB_DISPLAYABLE,d0 ;Bitmap darstellbar ?
    beq.s   pf2_memory_error6 ;Nein -> verzweige
    moveq   #pf2_depth3,d1   ;Anzahl der Bitplanes
    subq.w  #1,d1            ;Nur 1 Bitplane ?
    beq.s   no_pf2_check3    ;Ja -> verzweige
    btst    #BMB_INTERLEAVED,d0 ;Bitmap an einem Stück ?
    beq.s   pf2_memory_error6 ;Nein -> verzweige
no_pf2_check3
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
pf2_memory_error6
    move.w  #PF2_DISPLAY_NOT_INTERLEAVED,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0      
    rts
  ENDC

; ** Speicher für Extra-Playfield belegen **
; ------------------------------------------
  IFNE extra_pf_number
    CNOP 0,4
alloc_extra_pf_memory
    lea     extra_pf_bitmap1(a3),a2 ;Zeiger auf Bitmap-Struktur
    lea     extra_pf1(a3),a4 ;Zeiger auf Playfield-Bitmaps
    lea     extra_pf_attributes(pc),a5 ;Eigenschaften der Playfields
    moveq   #extra_pf_number-1,d7 ;Anzahl der Extra-Playfields
extra_pf_memory_loop
    move.l  (a5)+,d0         ;Breite des Playfields
    move.l  (a5)+,d1         ;Höhe des Playfields
    move.l  (a5)+,d2         ;Anzahl der Bitplanes
    bsr     do_alloc_bitmap_memory
    move.l  d0,(a2)+         ;Zeiger auf Bitmap-Struktur
    beq.s   extra_pf_memory_error ;Wenn Null -> verzweige
    addq.l  #bm_Planes,d0
    move.l  d0,(a4)+         ;Offset 1. Bitplanezeiger
    dbf     d7,extra_pf_memory_loop
    moveq   #RETURN_OK,d0
no_extra_pf_memory
    rts
    CNOP 0,4
extra_pf_memory_error
    move.w  #EXTRA_PLAYFIELD_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0      
    rts
; ** Speicher des Extra-Playfields überprüfen **
; ----------------------------------------------
    CNOP 0,4
check_extra_pf_memory
    lea     extra_pf_bitmap1(a3),a2 ;Zeiger auf Bitmap-Struktur
    lea     extra_pf_attributes(pc),a4 ;Eigenschaften der Extra-Playfields
    moveq   #extra_pf_number-1,d7 ;Anzahl der Extra-Playfields
extra_pf_check_loop
    move.l  (a2)+,a0         ;Zeiger auf Bitmap-Struktur
    moveq   #BMA_FLAGS,d1    ;Attribute
    CALLGRAF GetBitmapAttr
    btst    #BMB_DISPLAYABLE,d0 ;Bitmap darstellbar ?
    beq.s   extra_pf_memory_error2 ;Nein -> verzweige
    cmp.l   #1,extra_pf_attribute_depth(a4) ;Nur 1 Bitplane ?
    beq.s   no_extra_pf_check ;Ja -> verzweige
    btst    #BMB_INTERLEAVED,d0 ;Bitmap an einem Stück ?
    beq.s   extra_pf_memory_error2 ;Nein -> verzweige
no_extra_pf_check
    ADDF.W  extra_pf_attribute_SIZE,a4 ;nächster Eintrag
    dbf     d7,extra_pf_check_loop
no_extra_pf_check2
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
extra_pf_memory_error2
    move.w  #EXTRA_PLAYFIELD_NOT_INTERLEAVED,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0       
    rts
  ENDC

; ** Speicher für erste Spritestruktur belegen **
; -----------------------------------------------
  IFNE spr_x_size1
    CNOP 0,4
alloc_sprite_memory1
    lea     spr0_bitmap1(a3),a2 ;Zeiger auf Sprite-Bitmap-Struktur
    lea     spr0_construction(a3),a4 ;Zeiger auf Sprite-Bitmaps
    lea     sprite_attributes1(pc),a5 ;Eigenschaften der Sprites
    moveq   #spr_number-1,d7 ;Anzahl der Hardware-Sprites (1-8)
spr_memory_loop1
    move.l  (a5)+,d0         ;Breite des Sprites
    move.l  (a5)+,d1         ;Höhe des Sprites
    move.l  (a5)+,d2         ;Anzahl der Bitplanes
    bsr     do_alloc_bitmap_memory
    move.l  d0,(a2)+         ;Zeiger auf Sprite-Bitmap-Struktur
    beq.s   spr_memory_error1 ;Wenn Null -> verzweige
    addq.l  #bm_Planes,d0
    move.l  d0,(a4)+         ;Offset 1. Bitplanezeiger
    dbf     d7,spr_memory_loop1
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
spr_memory_error1
    move.w  #SPR_CONSTRUCTION_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0       
    rts

; ** Speicher der ersten Spritestruktur überprüfen **
; ---------------------------------------------------
    CNOP 0,4
check_sprite_memory1
    lea     spr0_bitmap1(a3),a2 ;Zeiger auf Sprite-Bitmap-Struktur
    moveq   #spr_number-1,d7 ;Anzahl der Hardware-Sprites (1-8)
spr_check_loop1
    move.l  (a2)+,a0         ;Zeiger auf Sprite-Bitmap-Struktur
    moveq   #BMA_FLAGS,d1    ;Attribute
    CALLGRAF GetBitmapAttr
    btst    #BMB_DISPLAYABLE,d0 ;Bitmap darstellbar ?
    beq.s   spr_memory_error2 ;Nein -> verzweige
    btst    #BMB_INTERLEAVED,d0 ;Bitmap an einem Stück ?
    beq.s   spr_memory_error2 ;Nein -> verzweige
    dbf     d7,spr_check_loop1
    moveq   #0,d0         
    rts
    CNOP 0,4
spr_memory_error2
    move.w  #SPR_CONSTRUCTION_NOT_INTERLEAVED,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0       
    rts
  ENDC

; ** Speicher für zweite Spritestruktur belegen **
; ------------------------------------------------
  IFNE spr_x_size2
    CNOP 0,4
alloc_sprite_memory2
    lea     spr0_bitmap2(a3),a2 ;Zeiger auf Sprite-Bitmap-Struktur
    lea     spr0_display(a3),a4 ;Zeiger auf Sprite-Bitmaps
    lea     sprite_attributes2(pc),a5 ;Eigenschaften der Sprites
    moveq   #spr_number-1,d7 ;Anzahl der Hardware-Sprites (1-8)
spr_memory_loop2
    move.l  (a5)+,d0         ;Breite des Sprites
    move.l  (a5)+,d1         ;Höhe des Sprites
    move.l  (a5)+,d2         ;Anzahl der Bitplanes
    bsr     do_alloc_bitmap_memory
    move.l  d0,(a2)+         ;Zeiger auf Sprite-Bitmap-Struktur
    beq.s   spr_memory_error3 ;Wenn Null -> verzweige
    addq.l  #bm_Planes,d0
    move.l  d0,(a4)+         ;Offset 1. Bitplanezeiger
    dbf     d7,spr_memory_loop2
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
spr_memory_error3
    move.w  #SPR_DISPLAY_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0       
    rts

; ** Speicher der zweiten Spritestruktur überprüfen **
; ----------------------------------------------------
    CNOP 0,4
check_sprite_memory2
    lea     spr0_bitmap2(a3),a2 ;Zeiger auf Sprite-Bitmap-Struktur
    moveq   #spr_number-1,d7 ;Anzahl der Hardware-Sprites (1-8)
spr_check_loop2
    move.l  (a2)+,a0         ;Zeiger auf Sprite-Bitmap-Struktur
    moveq   #BMA_FLAGS,d1    ;Attribute
    CALLGRAF GetBitmapAttr
    btst    #BMB_DISPLAYABLE,d0 ;Bitmap darstellbar ?
    beq.s   spr_memory_error4 ;Nein -> verzweige
    btst    #BMB_INTERLEAVED,d0 ;Bitmap an einem Stück ?
    beq.s   spr_memory_error4 ;Nein -> verzweige
    dbf     d7,spr_check_loop2
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
spr_memory_error4
    move.w  #SPR_DISPLAY_NOT_INTERLEAVED,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0       
    rts
  ENDC

; ** Speicher für Audio-Daten belegen **
; --------------------------------------
  IFNE audio_memory_size
    CNOP 0,4
alloc_audio_memory
    MOVEF.L audio_memory_size,d0
    bsr     do_alloc_chip_memory
    move.l  d0,audio_data(a3)
    beq.s   audio_memory_error
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
audio_memory_error
    move.w  #AUDIO_MEMORY_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0    
    rts
  ENDC

; ** Speicher für Diskettenpuffer belegen **
; ------------------------------------------
  IFNE disk_memory_size
    CNOP 0,4
alloc_disk_memory
    MOVEF.L disk_memory_size,d0
    bsr     do_alloc_chip_memory
    move.l  d0,disk_data(a3)
    beq.s   disk_memory_error
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
disk_memory_error
    move.w  #DISK_MEMORY_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0   
    rts
  ENDC

; ** Extra-Memory belegen **
; --------------------------
  IFNE extra_memory_size
    CNOP 0,4
alloc_extra_memory
    MOVEF.L extra_memory_size,d0
    bsr     do_alloc_memory
    move.l  d0,extra_memory(a3)
    beq.s   extra_memory_error
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
extra_memory_error
    move.w  #EXTRA_MEMORY_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0   
    rts
  ENDC

; ** Chip-Memory belegen **
; -------------------------
  IFNE chip_memory_size
    CNOP 0,4
alloc_chip_memory
    MOVEF.L chip_memory_size,d0
    bsr     do_alloc_chip_memory
    move.l  d0,chip_memory(a3)
    beq.s   chip_memory_error
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
chip_memory_error
    move.w  #CHIP_MEMORY_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0 
    rts
  ENDC

  IFND sys_taken_over
; ** Ggf. FAST-Memory für Vektoren belegen **
; -------------------------------------------
  CNOP 0,4
alloc_vectors_memory
    lea     read_vbr(pc),a5  ;Zeiger auf Supervisor-Routine
    CALLEXEC Supervisor
    move.l  d0,os_VBR(a3)    ;Inhalt von VBR retten
    move.l  d0,a1            ;Speicheradresse -> a1
    CALLLIBS TypeOfMem
    and.b   #MEMF_FAST,d0    ;FAST-Memory ?
    bne.s   no_alloc_vectors_memory ;Ja -> verzweige
    tst.w   fast_memory_available(a3) ;FAST-Memory vorhanden ?
    bne.s   no_alloc_vectors_memory ;Nein -> verzweige
    move.l  #exception_vectors_SIZE,d0
    bsr     do_alloc_fast_memory
    move.l  d0,exception_vectors_base(a3)
    beq.s   vectors_memory_error
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
no_alloc_vectors_memory
    move.l  os_VBR(a3),vbr_save(a3)
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
vectors_memory_error
    move.w  #EXCEPTION_VECTORS_NO_MEMORY,custom_error_code(a3)
    moveq   #RETURN_ERROR,d0  
    rts

    IFD pass_global_references
      CNOP 0,4
init_global_references_table
      lea     global_references_table(pc),a0
      move.l  _SysBase(pc),(a0)
      move.l  _GfxBase(pc),gr_graphics_base(a0)
      rts
    ENDC
  
  ; ** Betriebssystem ausschalten **
  ; --------------------------------
    CNOP 0,4
disable_system
    MOVEF.L delay_time1,d1
    CALLDOS Delay
  
get_os_screen
    moveq   #0,d0            ;alle Locks
    CALLINT LockIBase
    move.l  ib_ActiveScreen(a6),a2
    move.l  d0,a0
    CALLLIBS UnlockIBase
    move.l  a2,os_screen(a3) ;Zeiger auf aktiven Screen retten
    beq     no_active_screen_found ;Wenn Null -> verzweige
  
get_os_monitor_id
    lea     sc_ViewPort(a2),a0 ;Zeiger auf Viewport
    CALLGRAF GetVPModeID
    CMPF.L  INVALID_ID,d0    ;Keine ID ?
    beq     vp_monitor_id_error ;Ja -> verzweige
    and.l   #MONITOR_ID_MASK,d0 ;Ohne Auflösung
    move.l  d0,os_monitor_id(a3) ;Monitor-ID retten
  
get_os_sprite_resolution
    lea     spr_taglist(pc),a1
    move.l  sc_ViewPort+vp_ColorMap(a2),a4 ;Zeiger auf Farbtabelle
    move.l  a4,a0            ;Zeiger auf Farbtabelle
    CALLLIBS VideoControl
    lea     spr_taglist(pc),a1 ;Zeiger auf Sprite-Tagliste
    move.l  sprtl_VTAG_SPRITERESN+ti_Data(a1),os_sprite_resolution(a3) ;Alte Spriteauflösung retten
  
    IFEQ workbench_fade_enabled
wbf_get_os_screen_colors_number
      move.l  a2,a0          ;Zeiger auf Screen
      CALLINT GetScreenDrawInfo
      move.l  d0,a1          ;Zeiger auf Draw-Info-Struktur
      moveq   #1,d0          ;Minimale Tiefe = 1 Bitplane
      move.w  dri_depth(a1),d7 ;Tiefe des Screens
      subq.w  #1,d7          ;wegen dbf
wbf_os_screen_depth_loop
      add.w   d0,d0          ;2^n = Anzahl der Farben des Screen
      dbf     d7,wbf_os_screen_depth_loop
      move.l  d0,wbf_colors_number(a3)
      move.l  a2,a0          ;Zeiger auf Screen
      CALLLIBS FreeScreenDrawInfo
  
wbf_alloc_color_values32_memory
      move.l  #wbf_colors_number_max*3*LONGWORDSIZE,d0
      bsr     do_alloc_memory
      move.l  d0,wbf_color_values32(a3)
      beq     wbf_color_values32_memory_error
wbf_alloc_color_cache32_memory
      move.l  #(1+(wbf_colors_number_max*3)+1)*LONGWORDSIZE,d0
      bsr     do_alloc_memory
      move.l  d0,wbf_color_cache32(a3)
      beq     wbf_color_cache32_memory_error
  
wbf_get_os_screen_colors32
      move.l  a4,a0          ;Zeiger auf Farbtabelle
      move.l  wbf_color_values32(a3),a1 ;32-Bit RGB-Werte
      moveq   #0,d0          ;Ab COLOR00
      move.l  #wbf_colors_number_max,d1 ;Alle 256 Farben
      CALLGRAF GetRGB32
  
wbf_init_color_values32
      move.l  wbf_color_cache32(a3),a1 ;Ziel 32-Bit RGB-Werte
      lea     downgrade_screen_taglist(pc),a0 ;Zeiger auf Screen-TagListe
      move.l  a1,sctl_SA_Colors32+ti_Data(a0)
      move.l  wbf_color_values32(a3),a0 ;Quelle 32-Bit RGB-Werte
      move.w  #wbf_colors_number_max,(a1)+ ;Anzahl der Farben
      moveq   #0,d0
      move.w  d0,(a1)+       ;Ab COLOR00
      MOVEF.W wbf_colors_number_max-1,d7 ;Anzahl der Farbwerte
wbf_copy_color_values32_loop
      move.l  (a0)+,(a1)+    ;32-Bit-Rotwert
      move.l  (a0)+,(a1)+    ;32-Bit-Grünwert
      move.l  (a0)+,(a1)+    ;32-Bit-Blauwert
      dbf     d7,wbf_copy_color_values32_loop
      move.l  d0,(a1)
  
      move.l  a4,-(a7)
wbfo_wait_fade_out
      CALLGRAF WaitTOF
      bsr     workbench_fader_out
      bsr     wbf_set_new_colors32
      tst.w   wbfo_active(a3)
      beq.s   wbfo_wait_fade_out
      move.l  (a7)+,a4
    ELSE
alloc_screen_color_table32_memory
      move.l  #(1+(wbf_colors_number_max*3)+1)*LONGWORDSIZE,d0
      bsr     do_alloc_memory
      move.l  d0,screen_color_table32(a3)
      beq     screen_color_table32_memory_error
  
init_screen_color_table32
      move.l  screen_color_table32(a3),a0
      lea     downgrade_screen_taglist(pc),a1
      move.l  a0,sctl_SA_Colors32+ti_Data(a1)
      move.w  #wbf_colors_number_max,(a0)+ ;Alle 256 Farben
      moveq   #TRUE,d3
      move.w  d3,(a0)+       ;Ab COLOR00
      move.b  pf1_color_table+1(pc),d0 ;Rot 8 Bit
      move.b  pf1_color_table+2(pc),d1 ;Grün 8 Bit
      move.b  pf1_color_table+3(pc),d2 ;Blau 8 Bit
      MOVEF.W wbf_colors_number_max-1,d7
init_screen_color_table32_loop
      move.b  d0,(a0)+       ;3x Rot 8 Bit
      move.b  d0,(a0)+
      move.b  d0,(a0)+
      move.b  d1,(a0)+       ;3x Grün 8 Bit
      move.b  d1,(a0)+
      move.b  d1,(a0)+
      move.b  d2,(a0)+       ;3x Blau 8 Bit
      move.b  d2,(a0)+
      move.b  d2,(a0)+
      dbf     d7,init_screen_color_table32_loop
      move.l  d3,(a0)
    ENDC
  
open_downgrade_screen
    sub.l   a0,a0            ;Keine NewScreen-Struktur
    lea     downgrade_screen_taglist(pc),a1
    CALLINT OpenScreenTagList
    move.l  d0,downgrade_screen(a3)
    beq     open_downgrade_screen_error ;Wenn Null -> verzweige
  
check_downgrade_screen_mode
    move.l  d0,a0            ;Screenstruktur Custom-Screen
    ADDF.W  sc_ViewPort,a0   ;Zeiger auf Viewport des Custom-Screens
    CALLGRAF GetVPModeID
    CMPF.L  INVALID_ID,d0    ;Keine ID ?
    beq     vp_monitor_id_error ;Ja -> verzweige
    IFEQ requires_multiscan_monitor
      cmp.l   #VGA_MONITOR_ID|VGAPRODUCT_KEY,d0 ;Hat der Downgrade-Screen den gewünschten Modus?
    ELSE
      cmp.l   #PAL_MONITOR_ID|LORES_KEY,d0 ;Hat der Downgrade-Screen den gewünschten Modus?
    ENDC
    bne     check_downgrade_screen_mode_error ;Nein -> verzweige
  
get_os_view_parameters
    CALLINT ViewAddress
    move.l  d0,os_view(a3)   
    IFD save_BEAMCON0
      move.l  d0,a0
      CALLGRAF GfxLookUp
      move.l  d0,a0          ;Zeiger auf ViewExtra-Struktur retten
      move.l  ve_monitor(a0),a0 ;Zeiger auf MonitorSpec-Struktur 
      move.w  ms_BeamCon0(a0),os_BEAMCON0(a3) ;BEAMCON0 des Views retten
    ENDC

get_os_copperlist_pointers
    move.l  _GfxBase(pc),a6
    IFNE cl1_size3
      move.l  gb_Copinit(a6),os_COP1LC(a3) ;COP1LC retten
    ENDC
    IFNE cl2_size3
      move.l  gb_LOFlist(a6),os_COP2LC(a3) ;COP2LC (LOFlist, da OS das LOF-Bit bei non-Interlaced immer setzt!) retten
    ENDC
  
downgrade_display
    sub.l   a1,a1            ;View = NULL
    CALLLIBS LoadView        ;Display auf PAL-Standart zurückfahren
    CALLLIBS WaitTOF
    CALLLIBS WaitTOF         ;2x für Interlace
    tst.l   gb_ActiView(a6)  ;Erschien zwischenzeitlich ein anderer View ?
    bne.s   downgrade_display ;Wenn ja -> neuer Versuch
  
check_os_monitor_id
    move.l  os_monitor_id(a3),d0 ;Monitor-ID 
    CMPF.L  DEFAULT_MONITOR_ID,d0 ;15 kHz Default ?
    beq.s   take_over_sys    ;Ja -> verzweige
    cmp.l   #PAL_MONITOR_ID,d0 ;15 kHz PAL ?
    beq.s   take_over_sys    ;Ja -> verzweige
    MOVEF.L delay_time2,d1   ;Auf Umschalten des Monitors warten
    CALLDOS Delay
  
take_over_sys
    CALLGRAF OwnBlitter      ;Blitter für System sperren
    CALLLIBS WaitBlit        ;ggf. auf Blitter warten
    lea     timer_io_structure(pc),a1
    move.w  #TR_GETSYSTIME,IO_command(a1)
    CALLEXEC DoIO
    CALLLIBS Disable         ;Interrupts aus
    moveq    #RETURN_OK,d0
    rts
  
    CNOP 0,4
no_active_screen_found
    move.w  #ACTIVE_SCREEN_NOT_FOUND,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
    CNOP 0,4
vp_monitor_id_error
    move.w  #VIEWPORT_MONITOR_ID_NOT_FOUND,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts

    IFNE workbench_fade_enabled
screen_color_table32_memory_error
      move.w  #WORKBENCH_FADE_NO_MEMORY,custom_error_code(a3)
      moveq   #RETURN_ERROR,d0
      rts
    ENDC

    CNOP 0,4
open_downgrade_screen_error
    move.w  #SCREEN_COULD_NOT_OPEN,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
    CNOP 0,4
check_downgrade_screen_mode_error
    move.w  #SCREEN_DISPLAY_MODE_NOT_AVAILABLE,custom_error_code(a3)
    moveq   #RETURN_FAIL,d0
    rts
  
    IFEQ workbench_fade_enabled
      CNOP 0,4
wbf_color_cache32_memory_error
      move.l  wbf_color_values32(a3),d0 ;Konnte der Spwicher reserviert werden?
      beq.s   wbf_color_values32_memory_error ;Nein -> verzweige
      move.l  d0,a1            ;Zeiger auf Speicherbereich
      move.l  #wbf_colors_number_max*3*LONGWORDSIZE,d0
      CALLEXEC FreeMem         ;Speicher freigeben
wbf_color_values32_memory_error
      move.w  #WORKBENCH_FADE_NO_MEMORY,custom_error_code(a3)
      moveq   #RETURN_ERROR,d0
      rts
  
; ** Farben ausblenden **
; -----------------------
      CNOP 0,4
workbench_fader_out
      tst.w   wbfo_active(a3) ;Fading-Out an ?
      bne.s   no_workbench_fader_out ;Nein -> verzweige
      MOVEF.W wbf_colors_number_max*3,d6 ;Zähler
      move.l  wbf_color_cache32(a3),a0 ;Istwerte
      addq.w  #4,a0
      lea     pf1_color_table(pc),a1 ;Zielwert
      move.w  #wbfo_fader_speed,a4 ;Additions-/Subtraktionswert RGB-Werte
      move.l  (a1),a1          ;Sollwert COLOR00
      MOVEF.W wbf_colors_number_max-1,d7 ;Anzahl der Farbwerte
workbench_fader_out_loop
      moveq   #0,d0
      move.b  (a0),d0        ;8-Bit Rot-Istwert
      move.l  a1,d3          ;8-Bit Rot-Sollwert
      moveq   #0,d1
      swap    d3             ;$00Rr
      move.b  4(a0),d1       ;8-Bit Grün-Istwert
      moveq   #0,d2
      move.b  8(a0),d2       ;8-Bit Blau-Istwert
      move.w  a1,d4          ;8-Bit Grün-Sollwert
      moveq   #0,d5
      move.b  d4,d5          ;8-Bit Blau-Sollwert
      lsr.w   #8,d4          ;$00Gg
      
; ** Rotwert **
wbfo_check_red
      cmp.w   d3,d0          ;Ist-Rotwert mit Soll-Rotwert vergleichen
      bgt.s   wbfo_decrease_red ;Wenn Ist-Rotwert < Soll-Rotwert -> verzweige
      blt.s   wbfo_increase_red ;Wenn Ist-Rotwert > Soll-Rotwert -> verzweige
wbfo_matched_red
      subq.w  #1,d6          ;Zähler verringern
  
; ** Grünwert  **
wbfo_check_green
      cmp.w   d4,d1          ;Ist-Grünwert mit Soll-Grünwert vergleichen
      bgt.s   wbfo_decrease_green ;Wenn Ist-Grünwert < Soll-Grünwert -> verzweige
      blt.s   wbfo_increase_green ;Wenn Ist-Grünwert > Soll-Grünwert -> verzweige
wbfo_matched_green
      subq.w  #1,d6          ;Zähler verringern
  
; ** Blauwert **
wbfo_check_blue
      cmp.w   d5,d2          ;Ist-Blauwert mit Soll-Blauwert vergleichen
      bgt.s   wbfo_decrease_blue ;Wenn Ist-Blauwert < Soll-Blauwert -> verzweige
      blt.s   wbfo_increase_blue ;Wenn Ist-Blauwert > Soll-Blauwert -> verzweige
wbfo_matched_blue
      subq.w  #1,d6          ;Zähler verringern
  
wbfo_set_rgb
      move.b  d0,(a0)+       ;4x 8-Bit Rotwert in Cache schreiben
      move.b  d0,(a0)+
      move.b  d0,(a0)+
      move.b  d0,(a0)+
      move.b  d1,(a0)+       ;4x 8-Bit Grünwert in Cache schreiben
      move.b  d1,(a0)+
      move.b  d1,(a0)+
      move.b  d1,(a0)+
      move.b  d2,(a0)+       ;3x 8-Bit Blauwert in Cache schreiben
      move.b  d2,(a0)+
      move.b  d2,(a0)+
      move.b  d2,(a0)+
      dbf     d7,workbench_fader_out_loop
      tst.w   d6             ;Fertig mit ausblenden ?
      bne.s   wbfo_not_finished ;Nein -> verzweige
      moveq   #FALSE,d0
      move.w  d0,wbfo_active(a3) ;Fading-Out aus
wbfo_not_finished
      CALLEXEC CacheClearU   ;Caches flushen
no_workbench_fader_out
      rts
      CNOP 0,4
wbfo_decrease_red
      sub.w   a4,d0          ;Rotanteil verringern
      cmp.w   d3,d0          ;Ist-Rotwert > Soll-Rotwert ?
      bgt.s   wbfo_check_green ;Ja -> verzweige
      move.w  d3,d0          ;Ist-Rotwert <= Soll-Rotwert
      bra.s   wbfo_matched_red
      CNOP 0,4
wbfo_increase_red
      add.w   a4,d0          ;Rotanteil erhöhen
      cmp.w   d3,d0          ;Ist-Rotwert < Soll-Rotwert ?
      blt.s   wbfo_check_green ;Ja -> verzweige
      move.w  d3,d0          ;Ist-Rotwert >= Soll-Rotwert
      bra.s   wbfo_matched_red
      CNOP 0,4
wbfo_decrease_green
      sub.w   a4,d1          ;Grünanteil verringern
      cmp.w   d4,d1          ;Ist-Grünwert > Soll-Grünwert ?
      bgt.s   wbfo_check_blue  ;Ja -> verzweige
      move.w  d4,d1          ;Ist-Grünwert <= Soll-Grünwert
      bra.s   wbfo_matched_green
      CNOP 0,4
wbfo_increase_green
      add.w   a4,d1          ;Grünanteil erhöhen
      cmp.w   d4,d1          ;Ist-Grünwert < Soll-Grünwert ?
      blt.s   wbfo_check_blue  ;Ja -> verzweige
      move.w  d4,d1          ;Ist-Grünwert >= Soll-Grünwert
      bra.s   wbfo_matched_green
      CNOP 0,4
wbfo_decrease_blue
      sub.w   a4,d2          ;Blauanteil verringern
      cmp.w   d5,d2          ;Ist-Blauwert > Soll-Blauwert ?
      bgt.s   wbfo_set_rgb   ;Ja -> verzweige
      move.w  d5,d2          ;Ist-Blauwert <= Soll-Blauwert
      bra.s   wbfo_matched_blue
      CNOP 0,4
wbfo_increase_blue
      add.w   a4,d2          :Blauanteil erhöhen
      cmp.w   d5,d2          ;Ist-Blauwert < Soll-Blauwert ?
      blt.s   wbfo_set_rgb   ;Ja -> verzweige
      move.w  d5,d2          ;Ist-Blauwert >= Soll-Blauwert
      bra.s   wbfo_matched_blue
  
; ** Neue Farbwerte in Copperliste eintragen **
; ---------------------------------------------
      CNOP 0,4
wbf_set_new_colors32
      move.l  wbf_color_cache32(a3),a1
      lea     sc_ViewPort(a2),a0
      CALLGRAFQ LoadRGB32
    ENDC
  
; ** Alle Caches aktivieren **
; ----------------------------
    IFD all_caches
      CNOP 0,4
enable_all_caches
      move.l  #CACRF_EnableI+CACRF_IBE+CACRF_EnableD+CACRF_DBE+CACRF_WriteAllocate+CACRF_EnableE+CACRF_CopyBack,d0 ;Alle Caches einschalten
      move.l  #CACRF_EnableI+CACRF_FreezeI+CACRF_ClearI+CACRF_IBE+CACRF_EnableD+CACRF_FreezeD+CACRF_ClearD+CACRF_DBE+CACRF_WriteAllocate+CACRF_EnableE+CACRF_CopyBack,d1 ;Alle Bits ändern
      CALLEXEC CacheControl
      move.l  d0,os_CACR(a3)
      rts
    ENDC
  
; ** Store Buffer des 68060 aktivieren **
; ---------------------------------------
    IFD no_store_buffer
      CNOP 0,4
disable_store_buffer
      DISABLE_060_STORE_BUFFER
    ENDC
  
; ** Exception-Vektoren retten **
; -------------------------------
    CNOP 0,4
save_exception_vectors
    move.l  os_VBR(a3),a0    ;Quelle = Reset (Initial SSP)
    lea     exception_vecs_save(pc),a1 ;Ziel
    MOVEF.W (exception_vectors_SIZE/4)-1,d7 ;Anzahl der Vektoren
copy_exception_vectors_loop
    move.l  (a0)+,(a1)+      ;Vektor kopieren
    dbf     d7,copy_exception_vectors_loop
    rts
 ENDC
  
; ** Neue Zeiger auf Autovektoren eintragen **
; --------------------------------------------
  CNOP 0,4
init_exception_vectors
  IFD sys_taken_over
    IFNE INTENABITS&(~INTF_SETCLR)
      lea     read_vbr(pc),a5 ;Zeiger auf Supervisor-Routine
      CALLEXEC Supervisor    ;Routine ausführen
      move.l  d0,a0          ;VBR
    ENDC
  ELSE
    lea     read_vbr(pc),a5  ;Zeiger auf Supervisor-Routine
    CALLEXEC Supervisor      ;Routine ausführen
    move.l  d0,a0            ;VBR
  ENDC

; ** Level-1 - Level-7-Interrupt-Vektoren **
  IFNE INTENABITS&(INTF_TBE+INTF_DSKBLK+INTF_SOFTINT)
    lea     level_1_int_handler(pc),a1
    move.l  a1,LEVEL_1_AUTOVECTOR(a0) ;Neuer LEVEL_1_AUTOVECTOR
  ENDC
  IFNE INTENABITS&INTF_PORTS
    lea     level_2_int_handler(pc),a1
    move.l  a1,LEVEL_2_AUTOVECTOR(a0) ;Neuer LEVEL_2_AUTOVECTOR
  ENDC
  IFNE INTENABITS&(INTF_COPER+INTF_VERTB+INTF_BLIT)
    lea     level_3_int_handler(pc),a1
    move.l  a1,LEVEL_3_AUTOVECTOR(a0) ;Neuer LEVEL_3_AUTOVECTOR
  ENDC
  IFNE INTENABITS&(INTF_AUD0+INTF_AUD1+INTF_AUD2+INTF_AUD3)
    lea     level_4_int_handler(pc),a1
    move.l  a1,LEVEL_4_AUTOVECTOR(a0) ;Neuer LEVEL_4_AUTOVECTOR
  ENDC
  IFNE INTENABITS&(INTF_RBF+INTF_DSKSYNC)
    lea     level_5_int_handler(pc),a1
    move.l  a1,LEVEL_5_AUTOVECTOR(a0) ;Neuer LEVEL_5_AUTOVECTOR
  ENDC
  IFNE INTENABITS&INTF_EXTER
    lea     level_6_int_handler(pc),a1
    move.l  a1,LEVEL_6_AUTOVECTOR(a0) ;Neuer LEVEL_6_AUTOVECTOR
  ENDC
  IFND sys_taken_over
    lea     level_7_int_handler(pc),a1
    move.l  a1,LEVEL_7_AUTOVECTOR(a0) ;Neuer LEVEL_7_AUTOVECTOR
  ENDC

; ** Trap0-2-Interrupt-Vektoren **
  IFD TRAP0
    lea     trap_0_handler(pc),a1
    move.l  a1,TRAP_0_VECTOR(a0) ;Neuer Trap#0-Vektor
  ENDC
  IFD TRAP1
    lea     trap_1_handler(pc),a1
    move.l  a1,TRAP_1_VECTOR(a0) ;Neuer Trap#1-Vektor
  ENDC
  IFD TRAP2
    lea     trap_2_handler(pc),a1
    move.l  a1,TRAP_2_VECTOR(a0) ;Neuer Trap#2-Vektor
  ENDC
  CALLEXECQ CacheClearU

  IFND sys_taken_over
; ** Interruptvektoren ggf. ins Fast-Ram **
; -----------------------------------------
    CNOP 0,4
exception_vectors_to_fast_memory
    move.l  exception_vectors_base(a3),d0 ;Sollen Vektoren verschoben werden ?
    beq.s   no_vbr_move      ;FALSE -> verzweige
    move.l  d0,a1            ;Ziel = FAST-Memory
    move.l  os_VBR(a3),a0    ;Quelle = Reset (Initial SSP)
    MOVEF.W (exception_vectors_SIZE/4)-1,d7 ;Anzahl der Langwörter zum Kopieren
copy_exception_vectors_loop2
    move.l  (a0)+,(a1)+      ;1 Langwort kopieren
    dbf     d7,copy_exception_vectors_loop2
    CALLEXEC CacheClearU
    move.l  exception_vectors_base(a3),d0 ;neuen Inhalt in VBR schreiben
    move.l  d0,vbr_save(a3)  
    lea     write_vbr(pc),a5 ;Zeiger auf Supervisor-Routine
    CALLLIBQ Supervisor      ;Routine ausführen
    CNOP 0,4
no_vbr_move
    rts
  
; ** Hardware-Register retten **
; ------------------------------
    CNOP 0,4
save_hardware_registers
    move.w  (a6),os_DMACON(a3)
    move.w  INTENAR-DMACONR(a6),os_INTENA(a3)
    move.w  ADKCONR-DMACONR(a6),os_ADKCON(a3)
  
    move.b  CIAPRA(a4),os_CIAAPRA(a3)
    move.b  CIACRA(a4),d0
    move.b  d0,os_CIAACRA(a3)
    and.b   #~(CIACRAF_START),d0 ;Timer A stoppen
    or.b    #CIACRAF_LOAD,d0 ;Zählwert laden
    move.b  d0,CIACRA(a4)
    nop
    move.b  CIATALO(a4),os_CIAATALO(a3)
    move.b  CIATAHI(a4),os_CIAATAHI(a3)
  
    move.b  CIACRB(a4),d0
    move.b  d0,os_CIAACRB(a3)
    and.b   #~(CIACRBF_ALARM-CIACRBF_START),d0 ;Timer B stoppen
    or.b    #CIACRBF_LOAD,d0 ;Zählwert laden
    move.b  d0,CIACRB(a4)
    nop
    move.b  CIATBLO(a4),os_CIAATBLO(a3)
    move.b  CIATBHI(a4),os_CIAATBHI(a3)
  
    moveq   #0,d0
    move.b  CIATODHI(a4),d0  ;CIA-A TOD-clock Bits 23-16
    swap    d0               ;Bits in richtige Position bringen
    move.b  CIATODMID(a4),d0 ;CIA-A TOD-clock Bits 15-8
    lsl.w   #8,d0            ;Bits in richtige Position bringen
    move.b  CIATODLOW(a4),d0 ;CIA-A TOD-clock Bits 7-0
    move.l  d0,tod_time_save(a3) 
  
    move.b  CIAPRB(a5),os_CIABPRB(a3)
    move.b  CIACRA(a5),d0
    move.b  d0,os_CIAACRA(a3)
    and.b   #~(CIACRAF_START),d0 ;Timer A stoppen
    or.b    #CIACRAF_LOAD,d0 ;Zählwert laden
    move.b  d0,CIACRA(a5)
    nop
    move.b  CIATALO(a5),os_CIABTALO(a3)
    move.b  CIATAHI(a5),os_CIABTAHI(a3)
  
    move.b  CIACRB(a5),d0
    move.b  d0,os_CIABCRB(a3)
    and.b   #~(CIACRBF_ALARM-CIACRBF_START),d0 ;Timer B stoppen
    or.b    #CIACRBF_LOAD,d0 ;Zählwert laden
    move.b  d0,CIACRB(a5)
    nop
    move.b  CIATBLO(a5),os_CIABTBLO(a3)
    move.b  CIATBHI(a5),os_CIABTBHI(a3)
    rts
  
; ** Wichtige Register löschen **
; -------------------------------
    CNOP 0,4
clear_important_registers
    move.w  #$7fff,d0        ;Bits 0-14 löschen
    move.w  d0,DMACON-DMACONR(a6) ;DMA aus
    move.w  d0,INTENA-DMACONR(a6) ;Interrupts aus
    move.w  d0,INTREQ-DMACONR(a6) ;Interrupts löschen
    move.w  d0,ADKCON-DMACONR(a6) ;ADKCON löschen
  
    moveq   #0,d0
    move.w  d0,JOYTEST-DMACONR(a6) ;Maus + Joystickposition löschen
    move.w  d0,FMODE-DMACONR(a6) ;Fetchmode Sprites & Bitplanes = 1x
    move.l  d0,SPR0DATA-DMACONR(a6) ;Spritebitmaps löschen
    move.l  d0,SPR1DATA-DMACONR(a6)
    move.l  d0,SPR2DATA-DMACONR(a6)
    move.l  d0,SPR3DATA-DMACONR(a6)
    move.l  d0,SPR4DATA-DMACONR(a6)
    move.l  d0,SPR5DATA-DMACONR(a6)
    move.l  d0,SPR6DATA-DMACONR(a6)
    move.l  d0,SPR7DATA-DMACONR(a6)
  
    moveq   #$7f,d0
    move.b  d0,CIAICR(a4)    ;CIA-A-Interrupts aus
    move.b  d0,CIAICR(a5)    ;CIA-B-Interrupts aus
    move.b  CIAICR(a4),d0    ;CIA-A-Interrupts löschen
    move.b  CIAICR(a5),d0    ;CIA-B-Interrupts löschen
    rts
  
  ; ** Noch laufende Floppy-Motoren ausstellen **
  ; ---------------------------------------------
    CNOP 0,4
turn_off_drive_motors
    move.b  CIAPRB(a5),d0
    moveq   #CIAF_DSKSEL0+CIAF_DSKSEL1+CIAF_DSKSEL2+CIAF_DSKSEL3,d1 ;Unit 0-3
    or.b    d1,d0
    move.b  d0,CIAPRB(a5)    ;df0: bis df3: deaktivieren
    tas     d0
    move.b  d0,CIAPRB(a5)    ;Motor aus
    eor.b   d1,d0
    move.b  d0,CIAPRB(a5)    ;df0: bis df3: aus
    or.b    d1,d0
    move.b  d0,CIAPRB(a5)    ;df0: bis df3: deaktivieren
    rts
  ENDC

; ** Eigenes Display starten **
; -----------------------------
  CNOP 0,4
start_own_display
  bsr     wait_vbi
  bsr     wait_vbi
  moveq   #COPCONBITS,d0     ;Copper kann ggf. auf Blitteregister zurückgreifen
  move.w  d0,COPCON-DMACONR(a6)
  IFNE cl2_size3
    IFD own_display_set_second_copperlist
      move.l  cl2_display(a3),COP2LC-DMACONR(a6) ;2. Copperliste eintragen
    ENDC
  ENDC
  IFNE cl1_size3
    move.l  cl1_display(a3),COP1LC-DMACONR(a6) ;1. Copperliste eintragen
    moveq   #0,d0
    move.w  d0,COPJMP1-DMACONR(a6) ;sicherheitshalber manuell starten
  ENDC
  move.w  #DMABITS&(DMAF_SPRITE|DMAF_COPPER|DMAF_RASTER|DMAF_SETCLR),DMACON-DMACONR(a6) ;Sprite/Copper/Bitplane-DMA an
  rts

; ** Eigene Interrupts starten **
; -------------------------------
  IFNE (INTENABITS-INTF_SETCLR)|(CIAAICRBITS-CIAICRF_SETCLR)|(CIABICRBITS-CIAICRF_SETCLR)
    CNOP 0,4
start_own_interrupts
    IFNE INTENABITS-INTF_SETCLR
      move.w  #INTENABITS,INTENA-DMACONR(a6) ;Interrupts an
    ENDC
    IFNE CIAAICRBITS-CIAICRF_SETCLR
      MOVEF.B CIAAICRBITS,d0
      move.b  d0,CIAICR(a4)    ;CIA-A-Interrupts an
    ENDC
    IFNE CIABICRBITS-CIAICRF_SETCLR
      MOVEF.B CIABICRBITS,d0
      move.b  d0,CIAICR(a5)    ;CIA-B-Interrupts an
    ENDC
    rts
  ENDC

; ** CIA-Timer starten **
; -----------------------
  IFEQ CIAA_TA_continuous_enabled&CIAA_TB_continuous_enabled&CIAB_TA_continuous_enabled&CIAB_TB_continuous_enabled
    CNOP 0,4
start_CIA_timers
    IFEQ CIAA_TA_continuous_enabled
      moveq   #CIACRAF_START,d0
      or.b    d0,CIACRA(a4)      ;CIA-A-Timer-A starten
    ENDC
    IFEQ CIAA_TB_continuous_enabled
      moveq   #CIACRBF_START,d0
      or.b    d0,CIACRB(a4)      ;CIA-A-Timer-B starten
    ENDC
    IFEQ CIAB_TA_continuous_enabled
      moveq   #CIACRAF_START,d0
      or.b    d0,CIACRA(a5)      ;CIA-B-Timer-A starten
    ENDC
    IFEQ CIAB_TB_continuous_enabled
      moveq   #CIACRBF_START,d0
      or.b    d0,CIACRB(a5)      ;CIA-B-Timer-B starten
    ENDC
    rts
  ENDC

; ** Timer stoppen **
; -------------------
  IFEQ CIAA_TA_continuous_enabled&CIAA_TB_continuous_enabled&CIAB_TA_continuous_enabled&CIAB_TB_continuous_enabled
    CNOP 0,4
stop_CIA_timers
    IFNE CIAA_TA_time
      moveq   #~(CIACRAF_START),d0
      and.b   d0,CIACRA(a4)      ;CIA-A-Timer-A stoppen
    ENDC
    IFNE CIAA_TB_time
      moveq   #~(CIACRBF_START),d0
      and.b   d0,CIACRB(a4)      ;CIA-A-Timer-B stoppen
    ENDC
    IFNE CIAB_TA_time
      moveq   #~(CIACRAF_START),d0
      and.b   d0,CIACRA(a5)      ;CIA-B-Timer-A stoppen
    ENDC
    IFNE CIAB_TB_time
      moveq   #~(CIACRBF_START),d0
      and.b   d0,CIACRB(a5)      ;CIA-B-Timer-B stoppen
    ENDC
    rts
  ENDC

; ** Eigene Interrupts stoppen **
; -------------------------------
  IFNE (INTENABITS-INTF_SETCLR)|(CIAAICRBITS-CIAICRF_SETCLR)|(CIABICRBITS-CIAICRF_SETCLR)
    CNOP 0,4
stop_own_interrupts
    IFNE INTENABITS-INTF_SETCLR
      IFND sys_taken_over
        move.w  #INTF_INTEN,INTENA-DMACONR(a6) ;Interrupts aus
      ELSE
        move.w  #INTENABITS&(~INTF_SETCLR),INTENA-DMACONR(a6) ;Interrupts aus
      ENDC
    ENDC
    rts
  ENDC

; ** Eigenes Display stoppen **
; -----------------------------
  CNOP 0,4
stop_own_display
  IFNE COPCONBITS&COPCONF_CDANG
    moveq   #0,d0
    move.w  d0,COPCON-DMACONR(a6) ;Copper kann nicht auf Blitterregister zugreifen
  ENDC
  bsr     wait_beam_position
  IFNE DMABITS&DMAF_BLITTER
    WAITBLITTER
  ENDC
  IFD sys_taken_over
    move.w  #DMABITS&(~DMAF_SETCLR),DMACON-DMACONR(a6) ;DMA aus
  ELSE
    move.w  #DMAF_MASTER,DMACON-DMACONR(a6) ;DMA aus
  ENDC
  rts

  IFND sys_taken_over
; ** Wichtige Register löschen **
; -------------------------------
    CNOP 0,4
clear_important_registers2
    move.w  #$7fff,d0
    move.w  d0,DMACON-DMACONR(a6) ;DMA aus
    move.w  d0,INTENA-DMACONR(a6) ;Interrupts aus
    move.w  d0,INTREQ-DMACONR(a6) ;Interrupts löschen
    move.w  d0,ADKCON-DMACONR(a6) ;ADKCON löschen
  
    moveq   #0,d0
    move.w  d0,AUD0VOL-DMACONR(a6) ;Lautstärke aus
    move.w  d0,AUD1VOL-DMACONR(a6)
    move.w  d0,AUD2VOL-DMACONR(a6)
    move.w  d0,AUD3VOL-DMACONR(a6)
  
    move.w  d0,FMODE-DMACONR(a6) ;Fetchmode Sprites & Bitplanes = 1x
    move.l  d0,SPR0DATA-DMACONR(a6) ;Spritebitmaps manuell löschen
    move.l  d0,SPR1DATA-DMACONR(a6)
    move.l  d0,SPR2DATA-DMACONR(a6)
    move.l  d0,SPR3DATA-DMACONR(a6)
    move.l  d0,SPR4DATA-DMACONR(a6)
    move.l  d0,SPR5DATA-DMACONR(a6)
    move.l  d0,SPR6DATA-DMACONR(a6)
    move.l  d0,SPR7DATA-DMACONR(a6)
  
    moveq   #$7f,d0
    move.b  d0,CIAICR(a4)    ;CIA-A-Interrupts aus
    move.b  d0,CIAICR(a5)    ;CIA-B-Interrupts aus
    IFNE CIAAICRBITS-CIAICRF_SETCLR
      move.b  CIAICR(a4),d0  ;CIA-A-Interrupts löschen
    ENDC
    IFNE CIABICRBITS-CIAICRF_SETCLR
      move.b  CIAICR(a5),d0  ;CIA-B-Interrupts löschen
    ENDC
    rts
  
; ** Alten Inhalt in Register zurückschreiben **
; ----------------------------------------------
    CNOP 0,4
restore_hardware_registers
    move.b  os_CIAAPRA(a3),CIAPRA(a4)
  
    move.b  os_CIAATALO(a3),CIATALO(a4)
    nop
    move.b  os_CIAATAHI(a3),CIATAHI(a4)
  
    move.b  os_CIAATBLO(a3),CIATBLO(a4)
    nop
    move.b  os_CIAATBHI(a3),CIATBHI(a4)
  
    move.b  os_CIAAICR(a3),d0
    tas     d0               ;Bit 7 ggf. setzen
    move.b  d0,CIAICR(a4)
  
    move.b  os_CIAACRA(a3),d0
    btst    #CIACRAB_RUNMODE,d0 ;Continuous-Modus ?
    bne.s   CIAA_TA_no_continuous ;Nein -> verzweige
    or.b    #CIACRAF_START,d0 ;Ja -> Timer A starten
CIAA_TA_no_continuous
    move.b  d0,CIACRA(a4)
  
    move.b  os_CIAACRB(a3),d0
    btst    #CIACRBB_RUNMODE,d0 ;Continuous-Modus ?
    bne.s   CIAA_TB_no_continuous ;Nein -> verzweige
    or.b    #CIACRBF_START,d0 ;Ja -> Timer B starten
CIAA_TB_no_continuous
    move.b  d0,CIACRB(a4)
  
    move.b  os_CIABPRB(a3),CIAPRB(a5)
  
    move.b  os_CIABTALO(a3),CIATALO(a5)
    nop
    move.b  os_CIABTAHI(a3),CIATAHI(a5)
  
    move.b  os_CIABTBLO(a3),CIATBLO(a5)
    nop
    move.b  os_CIABTBHI(a3),CIATBHI(a5)
  
    move.b  os_CIABICR(a3),d0
    tas     d0               ;Bit 7 ggf. setzen
    move.b  d0,CIAICR(a5)
  
    move.b  os_CIABCRA(a3),d0
    btst    #CIACRAB_RUNMODE,d0 ;Continuous-Modus ?
    bne.s   CIAB_TA_no_continuous ;Nein -> verzweige
    or.b    #CIACRAF_START,d0 ;Ja -> Timer A starten
CIAB_TA_no_continuous
    move.b  d0,CIACRA(a5)
  
    move.b  os_CIABCRB(a3),d0
    btst    #CIACRBB_RUNMODE,d0 ;Continuous-Modus ?
    bne.s   CIAB_TB_no_continuous ;Nein -> verzweige
    or.b    #CIACRBF_START,d0 ;Ja -> Timer B starten
CIAB_TB_no_continuous
    move.b  d0,CIACRB(a5)
  
    move.l  tod_time_save(a3),d0 ;Zeit vor Programmstart
    moveq   #0,d1
    move.b  CIATODHI(a4),d1  ;CIA-A TOD-clock Bits 23-16
    swap    d1               ;Bits in richtige Position bringen
    move.b  CIATODMID(a4),d1 ;CIA-A TOD-clock Bits 15-8
    lsl.w   #8,d1            ;Bits in richtige Position bringen
    move.b  CIATODLOW(a4),d1 ;CIA-A TOD-clock Bits 7-0
    cmp.l   d0,d1            ;TOD Überlauf?
    bge.s   no_tod_overflow  ;Nein -> verzweige
    move.l  #$ffffff,d2      ;Maximalwert
    sub.l   d0,d2            ;Differenz bis zum Überlauf
    add.l   d2,d1            ;+ Wert nach dem Überlauf
    bra.s   save_tod
    CNOP 0,4
no_tod_overflow
    sub.l   d0,d1            ;Normale Differenz
save_tod
    move.l  d1,tod_time_save(a3) 
  
    IFD save_BEAMCON0
      move.w  os_BEAMCON0(a3),BEAMCON0-DMACONR(a6)
    ENDC
    IFNE cl2_size3
      move.l  os_COP2LC(a3),COP2LC-DMACONR(a6)
    ENDC
    IFNE cl1_size3
      move.l  os_COP1LC(a3),COP1LC-DMACONR(a6)
    ENDC
    moveq   #0,d0
    move.w  d0,COPJMP1-DMACONR(a6)
  
    move.w  os_DMACON(a3),d0
    and.w   #~DMAF_RASTER,d0 ;Bitplane-DMA ggf. aus
    or.w    #DMAF_SETCLR,d0  ;Bit 15 ggf. setzen
    move.w  d0,DMACON-DMACONR(a6)
    move.w  os_INTENA(a3),d0
    or.w    #INTF_SETCLR,d0  ;Bit 15 ggf. setzen
    move.w  d0,INTENA-DMACONR(a6)
    move.w  os_ADKCON(a3),d0
    or.w    #ADKF_SETCLR,d0  ;Bit 15 ggf. setzen
    move.w  d0,ADKCON-DMACONR(a6)
    move.l  os_VBR(a3),d0
    lea     write_VBR(pc),a5 ;Zeiger auf Supervisor-Routine
    CALLEXECQ Supervisor
  
    IFD all_caches
enable_os_caches
      move.l  os_CACR(a3),d0
      move.l  #CACRF_EnableI+CACRF_FreezeI+CACRF_ClearI+CACRF_IBE+CACRF_EnableD+CACRF_FreezeD+CACRF_ClearD+CACRF_DBE+CACRF_WriteAllocate+CACRF_EnableE+CACRF_CopyBack,d1 ;Alle Bits ändern
      CALLEXECQ CacheControl
    ENDC
  
    IFD no_store_buffer
enable_store_buffer
      ENABLE_060_STORE_BUFFER
    ENDC
  
  ; ** Alte Exception-Vektoren ggf. zurückschreiben **
  ; --------------------------------------------------
    CNOP 0,4
restore_exception_vectors
    lea     exception_vecs_save(pc),a0 ;Quelle
    move.l  os_VBR(a3),a1    ;Ziel = Reset (Initial SSP)
    MOVEF.W (exception_vectors_SIZE/LONGWORDSIZE)-1,d7 ;Anzahl der Vektoren
copy_vectors_loop3
    move.l  (a0)+,(a1)+      ;Vektor kopieren
    dbf     d7,copy_vectors_loop3
    CALLEXECQ CacheClearU
  
  ; ** Betriebssystem wieder aktivieren **
  ; --------------------------------------
    CNOP 0,4
enable_system
    CALLEXEC Enable          ;Interrupts an

update_clock
    move.l  tod_time_save(a3),d0 ;Vergangene Zeit, als System ausgeschaltet war
    moveq   #0,d1
    move.b  VBlankFrequency(a6),d1 ;Frequenz ermitteln
    lea     timer_io_structure(pc),a1 ;Zeiger auf Timer-IO-Struktur
    divu.w  d1,d0            ;/Vertikalfrequenz (50Hz) = Sekunden, Rest Microsekunden
    move.w  #TR_SETSYSTIME,IO_command(a1) ;Befehl für Timer-Device
    move.l  d0,d1            
    ext.l   d0               ;Auf 32 Bit erweitern
    swap    d1               ;Rest der Division
    add.l   d0,IO_SIZE+TV_SECS(a1) ;Unix-Time Sekunden setzen
    mulu.w  #10000,d1        ;In µs
    add.l   d1,IO_SIZE+TV_MICRO(a1) ;Unix-Time Mikrosekunden setzen
    CALLLIBS DoIO
  
restore_os_view
    CALLGRAF DisOwnBlitter
    sub.l    a1,a1           ;Kein Display
    CALLLIBS LoadView
    CALLLIBS WaitTOF
    CALLLIBS WaitTOF         ;Bei Interlace
    move.l   os_view(a3),a1
    CALLLIBS LoadView
    CALLLIBS WaitTOF
    CALLLIBS WaitTOF         ;Bei Interlace
    move.l  downgrade_screen(a3),a0
    CALLINT CloseScreen
  
    IFNE workbench_fade_enabled
free_screen_color_table32
      move.l  screen_color_table32(a3),d0 ;Wurde der Speicher belegt ?
      beq.s   restore_os_sprite_resolution ;Nein -> verzweige
      move.l  d0,a1          ;Zeiger auf Speicherbereich
      move.l  #(1+(wbf_colors_number_max*3)+1)*LONGWORDSIZE,d0 ;Größe der Speicherbereiches
      CALLEXEC FreeMem       ;Speicher freigeben
    ENDC
  
restore_os_sprite_resolution
    move.l  os_screen(a3),a2
    lea     spr_taglist(pc),a1
    move.l  sc_ViewPort+vp_ColorMap(a2),a0
    move.l  #VTAG_SPRITERESN_SET,sprtl_VTAG_SPRITERESN+ti_Tag(a1)
    move.l  os_sprite_resolution(a3),sprtl_VTAG_SPRITERESN+ti_Data(a1) ;alte Auflösung
    CALLGRAF VideoControl
    move.l  a2,a0            ;Zeiger auf alten Screen
    CALLINT MakeScreen
    CALLLIBS RethinkDisplay
  
    IFEQ workbench_fade_enabled
wbfi_check_monitor_id
      move.l  os_monitor_id(a3),d0
      CMPF.L  DEFAULT_MONITOR_ID,d0 ;15 kHz Default ?
      beq.s   wbfi_wait_fade_in ;Ja -> verzweige
      cmp.l   #PAL_MONITOR_ID,d0 ;15 kHz PAL ?
      beq.s   wbfi_wait_fade_in ;Ja -> verzweige
      MOVEF.L delay_time2,d1 ;Auf Umschalten des Monitors warten
      CALLDOS Delay
  
wbfi_wait_fade_in
      CALLGRAF WaitTOF
      bsr.s   workbench_fade_enabledr_in
      bsr     wbf_set_new_colors32
      tst.w   wbfi_active(a3)
      beq.s   wbfi_wait_fade_in
  
wbf_free_color_values32_memory
      move.l  wbf_color_values32(a3),d0 ;Wurde der Speicher belegt ?
      beq.s   wbf_free_color_cache32_memory ;Nein -> verzweige
      move.l  d0,a1          ;Zeiger auf Speicherbereich
      move.l  #wbf_colors_number_max*3*LONGWORDSIZE,d0
      CALLEXEC FreeMem       ;Speicher freigeben
wbf_free_color_cache32_memory
      move.l  wbf_color_cache32(a3),d0  ;Wurde der Speicher belegt ?
      beq.s   wbfi_skip_fade_in ;Nein -> verzweige
      move.l  d0,a1          ;Zeiger auf Speicherbereich
      move.l  #(1+(wbf_colors_number_max*3)+1)*LONGWORDSIZE,d0
      CALLLIBQ FreeMem       ;Speicher freigeben
      CNOP 0,4
wbfi_skip_fade_in
      rts
  
; ** Farben einblenden **
; -----------------------
  CNOP 0,4
workbench_fade_enabledr_in
      tst.w   wbfi_active(a3) ;Fading-In an ?
      bne     no_workbench_fade_enabledr_in ;Nein -> verzweige
      MOVEF.W wbf_colors_number_max*3,d6 ;Anzahl der Farbwerte*3 = Zähler
      move.l  wbf_color_cache32(a3),a0 ;Puffer für Farbwerte
      addq.w  #4,a0
      move.w  #wbfi_fader_speed,a4 ;Additions-/Subtraktionswert für RGB-Werte
      move.l  wbf_color_values32(a3),a1 ;Sollwerte
      MOVEF.W wbf_colors_number_max-1,d7 ;Anzahl der Farbwerte
workbench_fade_enabledr_in_loop
      moveq   #0,d0
      move.b  (a0),d0        ;8-Bit Rot-Istwert
      moveq   #0,d1
      move.b  4(a0),d1       ;8-Bit Grün-Istwert
      moveq   #0,d2
      move.b  8(a0),d2       ;8-Bit Blau-Istwert
      moveq   #0,d3
      move.b  (a1),d3        ;8-Bit Rot-Sollwert
      moveq   #0,d4
      move.b  4(a1),d4       ;8-Bit Grün-Sollwert
      moveq   #0,d5
      move.b  8(a1),d5       ;8-Bit Blau-Sollwert
  
; ** Rotwert **
wbfi_check_red
      cmp.w   d3,d0          ;Ist-Rotwert mit Soll-Rotwert vergleichen
      bgt.s   wbfi_decrease_red ;Wenn Ist-Rotwert < Soll-Rotwert -> verzweige
      blt.s   wbfi_increase_red ;Wenn Ist-Rotwert > Soll-Rotwert -> verzweige
wbfi_matched_red
      subq.w  #1,d6          ;Zähler verringern
  
; ** Grünwert **
wbfi_check_green
      cmp.w   d4,d1          ;Ist-Grünwert mit Soll-Grünwert vergleichen
      bgt.s   wbfi_decrease_green ;Wenn Ist-Grünwert < Soll-Grünwert -> verzweige
      blt.s   wbfi_increase_green ;Wenn Ist-Grünwert > Soll-Grünwert -> verzweige
wbfi_matched_green
      subq.w  #1,d6          ;Zähler verringern
  
; ** Blauwert **
wbfi_check_blue
      cmp.w   d5,d2          ;Ist-Blauwert mit Soll-Blauwert vergleichen
      bgt.s   wbfi_decrease_blue ;Wenn Ist-Blauwert < Soll-Blauwert -> verzweige
      blt.s   wbfi_increase_blue ;Wenn Ist-Blauwert > Soll-Blauwert -> verzweige
wbfi_matched_blue
      subq.w  #1,d6          ;Zähler verringern
  
wbfi_set_rgb
      move.b  d0,(a0)+       ;4x 8-Bit Rotwert in Cache schreiben
      move.b  d0,(a0)+
      move.b  d0,(a0)+
      move.b  d0,(a0)+
      move.b  d1,(a0)+       ;4x 8-Bit Grünwert in Cache schreiben
      move.b  d1,(a0)+
      move.b  d1,(a0)+
      move.b  d1,(a0)+
      move.b  d2,(a0)+       ;4x 8-Bit Blauwert in Cache schreiben
      move.b  d2,(a0)+
      addq.w  #8,a1          ;nächstes 32-Bit-Tripple (4*3)
      move.b  d2,(a0)+
      addq.w  #4,a1
      move.b  d2,(a0)+
      dbf     d7,workbench_fade_enabledr_in_loop
      tst.w   d6             ;Fertig mit ausblenden ?
      bne.s   wbfi_not_finished ;Nein -> verzweige
      not.w   wbfi_active(a3) ;Fading-In aus
wbfi_not_finished
      CALLEXEC CacheClearU   ;Caches flushen
no_workbench_fade_enabledr_in
      rts
      CNOP 0,4
wbfi_decrease_red
      sub.w   a4,d0          ;Rotanteil verringern
      cmp.w   d3,d0          ;Ist-Rotwert > Soll-Rotwert ?
      bgt.s   wbfi_check_green ;Ja -> verzweige
      move.w  d3,d0          ;Ist-Rotwert <= Soll-Rotwert
      bra.s   wbfi_matched_red
      CNOP 0,4
wbfi_increase_red
      add.w   a4,d0          ;Rotanteil erhöhen
      cmp.w   d3,d0          ;Ist-Rotwert <= Soll-Rotwert ?
      blt.s   wbfi_check_green ;Ja -> verzweige
      move.w  d3,d0          ;Ist-Rotwert >= Soll-Rotwert
      bra.s   wbfi_matched_red
      CNOP 0,4
wbfi_decrease_green
      sub.w   a4,d1          ;Grünanteil verringern
      cmp.w   d4,d1          ;Ist-Grünwert > Soll-Grünwert ?
      bgt.s   wbfi_check_blue ;Ja -> verzweige
      move.w  d4,d1          ;Ist-Grünwert <= Soll-Grünwert
      bra.s   wbfi_matched_green
      CNOP 0,4
wbfi_increase_green
      add.w   a4,d1          ;Grünanteil erhöhen
      cmp.w   d4,d1          ;Ist-Grünwert < Soll-Grünwert ?
      blt.s   wbfi_check_blue ;Ja -> verzweige
      move.w  d4,d1          ;Ist-Grünwert >= Soll-Grünwert
      bra.s   wbfi_matched_green
      CNOP 0,4
wbfi_decrease_blue
      sub.w   a4,d2          ;Blauanteil verringern
      cmp.w   d5,d2          ;Ist-Blauwert > Soll-Blauwert ?
      bgt.s   wbfi_set_rgb   ;Ja -> verzweige
      move.w  d5,d2          ;Ist-Blauwert <= Soll-Blauwert
      bra.s   wbfi_matched_blue
      CNOP 0,4
wbfi_increase_blue
      add.w   a4,d2          ;Blauanteil erhöhen
      cmp.w   d5,d2          ;Ist-Blauwert < Soll-Blauwert ?
      blt.s   wbfi_set_rgb   ;Ja -> verzweige
      move.w  d5,d2          ;Ist-Blauwert >= Soll-Blauwert
      bra.s   wbfi_matched_blue
    ELSE
exit_check_monitor_id
      move.l  os_monitor_id(a3),d0
      CMPF.L  DEFAULT_MONITOR_ID,d0 ;15 kHz Default ?
      beq.s   no_delay       ;Ja -> verzweige
      cmp.l   #NTSC_MONITOR_ID,d0 ;15 kHz NTSC ?
      beq.s   no_delay       ;Ja -> verzweige
      cmp.l   #PAL_MONITOR_ID,d0 ;15 kHz PAL ?
      beq.s   no_delay       ;Ja -> verzweige
      MOVEF.L delay_time2,d1 ;Auf Umschalten des Monitors warten
      CALLDOSQ Delay
      CNOP 0,4
no_delay
      rts
    ENDC
  
  ; ** formatierten Text ausgeben **
  ; --------------------------------
    IFEQ text_output_enabled
      CNOP 0,4
print_text
      lea     format_string(pc),a0
      lea     data_stream(pc),a1 ;Daten für den Format-String
      lea     put_ch_proc(pc),a2 ;Zeiger auf Kopierroutine
      move.l  a3,-(a7)
      lea     put_ch_data(pc),a3 ;Zeiger auf Ausgabestring
      CALLEXEC RawDoFmt
      move.l  (a7)+,a3
      CALLDOS Output
      move.l  d0,d1
      beq.s   no_print_text  ;Wenn Fehler -> verzweige
      lea     put_ch_data(pc),a0 ;Zeiger auf Text
      move.l  a0,d2
      moveq   #0,d3          ;Zeichenzähler = Null
search_nullbyte
      tst.b   (a0)+          ;Nullbyte gefunden ?
      beq.s   nullbyte_found ;Ja- > verzweige
      addq.w  #1,d3
      bra.s   search_nullbyte
nullbyte_found
      CALLLIBQ Write
      CNOP 0,4
no_print_text
      rts
      CNOP 0,4
put_ch_proc
      move.b  d0,(a3)+       ;Daten in den Ausgabestring schreiben
      rts
    ENDC
  
; ** Speicher für Vektoren wieder freigeben **
; --------------------------------------------
    CNOP 0,4
free_vectors_memory
    move.l  exception_vectors_base(a3),d0
    beq.s   no_free_vectors_memory ;Wenn Null -> verzweige
    move.l  d0,a1
    move.l  #exception_vectors_SIZE,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_vectors_memory
    rts
  ENDC

; ** Speicher für CHIP-Memory freigeben **
; ----------------------------------------
  IFNE CHIP_memory_size
    CNOP 0,4
free_chip_memory
    move.l  chip_memory(a3),d0
    beq.s   no_free_chip_memory ;Wenn Null -> verzweige
    move.l  d0,a1            
    MOVEF.L chip_memory_size,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_chip_memory
    rts
  ENDC

; ** Speicher für Extra-Memory freigeben **
; -----------------------------------------
  IFNE extra_memory_size
    CNOP 0,4
free_extra_memory
    move.l  extra_memory(a3),d0
    beq.s   no_free_extra_memory ;Wenn Null -> verzweige
    move.l  d0,a1            
    MOVEF.L extra_memory_size,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_extra_memory
    rts
  ENDC

; ** Speicher für Disk-Data wieder freigeben **
; ---------------------------------------------
  IFNE disk_memory_size
    CNOP 0,4
free_disk_memory
    move.l  disk_data(a3),d0
    beq.s   no_free_disk_memory ;Wenn Null -> verzweige
    move.l  d0,a1           
    MOVEF.L disk_memory_size,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_disk_memory
    rts
  ENDC

; ** Speicher für Audio-Data wieder freigeben **
; ----------------------------------------------
  IFNE audio_memory_size
    CNOP 0,4
free_audio_memory
    move.l  audio_data(a3),d0
    beq.s   no_free_audio_memory ;Wenn Null -> verzweige
    move.l  d0,a1         
    MOVEF.L audio_memory_size,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_audio_memory
    rts
  ENDC

; ** Speicher für zweite Sprite-Bitmap wieder freigeben **
; --------------------------------------------------------
  IFNE spr_x_size2
    CNOP 0,4
free_sprite_memory2
    lea     spr0_bitmap2(a3),a2
    moveq   #spr_number-1,d7 ;Anzahl der Hardware-Sprites (1-8)
free_sprite_memory2_loop
    move.l  (a2)+,d0
    beq.s   no_free_sprite_memory2 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAF FreeBitMap
    dbf     d7,free_sprite_memory2_loop
no_free_sprite_memory2
    rts
  ENDC

; ** Speicher für erste Sprite-Bitmap wieder freigeben **
; -------------------------------------------------------
  IFNE spr_x_size1
    CNOP 0,4
free_sprite_memory1
    lea     spr0_bitmap1(a3),a2
    moveq   #spr_number-1,d7 ;Anzahl der Hardware-Sprites (1-8)
free_sprite_memory1_loop
    move.l  (a2)+,d0
    beq.s   no_free_sprite_memory1 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAF FreeBitMap
    dbf     d7,free_sprite_memory1_loop
no_free_sprite_memory1
    rts
  ENDC

; ** Speicher für Extra-Playfield-Bitmap wieder freigeben **
; ----------------------------------------------------------
  IFNE extra_pf_number
    CNOP 0,4
free_extra_pf_memory
    lea     extra_pf_bitmap1(a3),a2
    moveq   #extra_pf_number-1,d7 ;Anzahl der Extra-Playfields
extra_pf_memory_loop2
    move.l  (a2)+,d0
    beq.s   no_free_extra_pf_memory ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAF FreeBitMap
    dbf     d7,extra_pf_memory_loop2
no_free_extra_pf_memory
    rts
  ENDC

; ** Speicher für dritte Playfield-Bitmap wieder freigeben **
; -----------------------------------------------------------
  IFNE pf2_x_size3
    CNOP 0,4
free_pf2_memory3
    move.l  pf2_bitmap3(a3),d0
    beq.s   no_free_pf2_memory3 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf2_memory3
    rts
  ENDC

; ** Speicher für zweite Playfield-Bitmap wieder freigeben **
; -----------------------------------------------------------
  IFNE pf2_x_size2
    CNOP 0,4
free_pf2_memory2
    move.l  pf2_bitmap2(a3),d0
    beq.s   no_free_pf2_memory2 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf2_memory2
    rts
  ENDC

; ** Speicher für erste Playfield-Bitmap wieder freigeben **
; ----------------------------------------------------------
  IFNE pf2_x_size1
    CNOP 0,4
free_pf2_memory1
    move.l  pf2_bitmap1(a3),d0
    beq.s   no_free_pf2_memory1 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf2_memory1
    rts
  ENDC

; ** Speicher für dritte Playfield-Bitmap wieder freigeben **
; -----------------------------------------------------------
  IFNE pf1_x_size3
    CNOP 0,4
free_pf1_memory3
    move.l  pf1_bitmap3(a3),d0
    beq.s   no_free_pf1_memory3 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf1_memory3
    rts
  ENDC

; ** Speicher für zweite Playfield-Bitmap wieder freigeben **
; -----------------------------------------------------------
  IFNE pf1_x_size2
    CNOP 0,4
free_pf1_memory2
    move.l  pf1_bitmap2(a3),d0
    beq.s   no_free_pf1_memory2 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf1_memory2
    rts
  ENDC

; ** Speicher für erste Playfield-Bitmap wieder freigeben **
; ----------------------------------------------------------
  IFNE pf1_x_size1
    CNOP 0,4
free_pf1_memory1
    move.l  pf1_bitmap1(a3),d0
    beq.s   no_free_pf1_memory1 ;Wenn Null -> verzweige
    move.l  d0,a0
    CALLGRAFQ FreeBitMap
    CNOP 0,4
no_free_pf1_memory1
    rts
  ENDC

; ** Speicher dritte Copperliste wieder freigeben **
; --------------------------------------------------
  IFNE cl2_size3
    CNOP 0,4
free_cl2_memory3
    move.l  cl2_display(a3),d0
    beq.s   no_free_cl2_memory3 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl2_size3,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl2_memory3
    rts
  ENDC

; ** Speicher zweite Copperliste wieder freigeben **
; --------------------------------------------------
  IFNE cl2_size2
    CNOP 0,4
free_cl2_memory2
    move.l  cl2_construction2(a3),d0
    beq.s   no_free_cl2_memory2 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl2_size2,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl2_memory2
    rts
  ENDC

; ** Speicher erste Copperliste wieder freigeben **
; -------------------------------------------------
  IFNE cl2_size1
    CNOP 0,4
free_cl2_memory1
    move.l  cl2_construction1(a3),d0
    beq.s   no_free_cl2_memory1 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl2_size1,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl2_memory1
    rts
  ENDC

; ** Speicher dritte Copperliste wieder freigeben **
; --------------------------------------------------
  IFNE cl1_size3
    CNOP 0,4
free_cl1_memory3
    move.l  cl1_display(a3),d0
    beq.s   no_free_cl1_memory3 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl1_size3,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl1_memory3
    rts
  ENDC

; ** Speicher zweite Copperliste wieder freigeben **
; --------------------------------------------------
  IFNE cl1_size2
    CNOP 0,4
free_cl1_memory2
    move.l  cl1_construction2(a3),d0 ;Zeiger auf Speicherbereich
    beq.s   no_free_cl1_memory2 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl1_size2,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl1_memory2
    rts
  ENDC

; ** Speicher erste Copperliste wieder freigeben **
; -------------------------------------------------
  IFNE cl1_size1
    CNOP 0,4
free_cl1_memory1
    move.l  cl1_construction1(a3),d0
    beq.s   no_free_cl1_memory1 ;Wenn Null -> verzweige
    move.l  d0,a1
    MOVEF.L cl1_size1,d0
    CALLEXECQ FreeMem
    CNOP 0,4
no_free_cl1_memory1
    rts
  ENDC

  IFND sys_taken_over
; ** Timer-Device schließen **
; ----------------------------
    CNOP 0,4
close_timer_device
    lea     timer_io_structure(pc),a1
    CALLEXECQ CloseDevice
  
  ; ** Intuition-Libary schließen **
  ; --------------------------------
    CNOP 0,4
close_intuition_library
    move.l  _IntuitionBase(pc),a1
    CALLEXECQ CloseLibrary

; ** Graphics-Libary schließen **
; -------------------------------
    CNOP 0,4
close_graphics_library
    move.l  _GfxBase(pc),a1
    CALLEXECQ CloseLibrary

  IFND sys_taken_over
; ** Fehler ausgeben **
; ---------------------
    CNOP 0,4
print_error_message
    move.w  custom_error_code(a3),d4 ;Ist ein eigener Fehler aufgetreten ?
    beq.s   no_print_error_message ;Nein -> verzweige
    CALLINT WBenchToFront
    lea     file_name(pc),a0
    move.l  a0,d1
    move.l  #MODE_OLDFILE,d2 ;Modus: Alt (Muß sein!)
    CALLDOS Open
    move.l  d0,file_handle(a3)
    beq.s   raw_open_error   ;Wenn NULL -> verzweige
    subq.w  #1,d4            ;Start-Offset 0
    lea     custom_error_table(pc),a0
    move.l  (a0,d4.w*8),d2   ;Zeiger auf Fehlertext
    move.l  4(a0,d4.w*8),d3  ;Länge des Fehlertextes
    move.l  d0,d1            ;Zeiger auf Datei-Handle
    CALLLIBS Write
    move.l  file_handle(a3),d1
    lea     raw_buffer(a3),a0
    move.l  a0,d2            ;Zeiger auf Puffer
    moveq   #1,d3            ;Anzahl der Zeichen zum Lesen
    CALLLIBS Read
    move.l  file_handle(a3),d1
    CALLLIBS Close
no_print_error_message
    moveq   #RETURN_OK,d0
    rts
    CNOP 0,4
raw_open_error
    moveq   #RETURN_FAIL,d0
    rts
  ENDC

; ** DOS-Libary schließen **
; --------------------------
    CNOP 0,4
close_dos_library
    move.l  _DOSBase(pc),a1
    CALLEXECQ CloseLibrary

; ** WB-Message ggf. noch beantworten **
; --------------------------------------
    IFEQ workbench_start_enabled
      CNOP 0,4
reply_wb_message
      move.l  wb_message(a3),d2
      bne.s   wb_message_ok  ;Wenn WB-Message vorhandern -> verzweige
      rts
      CNOP 0,4
wb_message_ok
      CALLEXEC Forbid
      move.l  d2,a1
      CALLLIBS ReplyMsg
      CALLLIBQ Permit
    ENDC
  ENDC

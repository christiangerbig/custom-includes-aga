; Includedatei: "normsource-includes/sys-structures.i"
; Datum:        27.10.2023
; Version:      1.9

;
  IFND SYS_TAKEN_OVER

; ** Easy-Struktur f�r TCP-Stack-Abfrage **
    IFNE intena_bits&INTF_PORTS
      CNOP 0,4
tcp_requester_structure
      DS.B EasyStruct_sizeOF
    ENDC
  
; ** Easy-Struktur f�r Monitorabfrage **
    IFEQ requires_multiscan_monitor
      CNOP 0,4
vga_requester_monitor_structure
      DS.B EasyStruct_sizeOF
    ENDC
  
; ** Timer-Request-Struktur f�r Timer-Device **
    CNOP 0,4
timer_io_structure
    DS.B IOTV_size
  
; ** Tagliste f�r Spriteaufl�sung **
    CNOP 0,4
spr_taglist
    DS.B (ti_sizeOF*1)+4
  
; ** Tagliste f�r Screen **
    CNOP 0,4
downgrade_screen_taglist
    DS.B screen_taglist_size

; ** Struktur f�r Fehlermeldungen **
    CNOP 0,4
custom_error_table
    DS.B custom_error_entry_size*custom_errors_number
  ENDC

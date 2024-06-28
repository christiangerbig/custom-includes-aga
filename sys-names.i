; Includedatei: "normsource-includes/sys-names.i"
; Datum:        27.10.2023
; Version:      2.1

; ## Speicherstellen für Namen ##
; -------------------------------
  IFND sys_taken_over
dos_name                   DC.B "dos.library",TRUE
graphics_name              DC.B "graphics.library",TRUE
    EVEN
intuition_name             DC.B "intuition.library",TRUE
ciaa_name                  DC.B "ciaa.resource",TRUE
ciab_name                  DC.B "ciab.resource",TRUE
timer_device_name          DC.B "timer.device",TRUE
    EVEN
    IFNE intena_bits&INTF_PORTS
bsdsocket_name             DC.B "bsdsocket.library",TRUE
tcp_requester_title        DC.B "TCP/IP-stack request",TRUE
      EVEN
tcp_requester_text         DC.B "An active TCP/IP-stack was detected.",10
                           DC.B "This may affect the interrupt handling",10
                           DC.B "of the demo and freeze it.",10
                           DC.B "Please close your application and proceed.",10,TRUE
      EVEN
tcp_requester_gadgets_text DC.B "Proceed|Skip|Quit",TRUE
      EVEN
    ENDC
    IFEQ requires_multiscan_monitor
vga_requester_title        DC.B "System monitor request",TRUE
      EVEN
vga_requester_text         DC.B "This demo opens a VGA screen with",10
                           DC.B "a horizontal frequency of 31 kHz.",10
                           DC.B "Check your monitor to be able",10
                           DC.B "to display this video mode.",TRUE
      EVEN
vga_requester_gadgets_text DC.B "Proceed|Quit",TRUE
      EVEN
    ENDC
downgrade_screen_name      DC.B "Downgrade 15kHz screen",TRUE
    EVEN
file_name                  DC.B "RAW:0/0/640/80/  **  Message Window  **  ",TRUE
    EVEN
  ENDC

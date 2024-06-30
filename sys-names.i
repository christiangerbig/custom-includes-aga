; Includedatei: "normsource-includes/sys-names.i"
; Datum:        27.10.2023
; Version:      2.1

; ## Speicherstellen für Namen ##
  IFND LINKER_SYS_TAKEN_OVER
dos_name                   DC.B "dos.library",0
graphics_name              DC.B "graphics.library",0
    EVEN
intuition_name             DC.B "intuition.library",0
ciaa_name                  DC.B "ciaa.resource",0
ciab_name                  DC.B "ciab.resource",0
timer_device_name          DC.B "timer.device",0
    EVEN
    IFNE intena_bits&INTF_PORTS
bsdsocket_name             DC.B "bsdsocket.library",0
tcp_requester_title        DC.B "TCP/IP-stack request",0
      EVEN
tcp_requester_text         DC.B "An active TCP/IP-stack was detected.",10
                           DC.B "This may affect the interrupt handling",10
                           DC.B "of the demo and freeze it.",10
                           DC.B "Please close your application and proceed.",10,0
      EVEN
tcp_requester_gadgets_text DC.B "Proceed|Skip|Quit",0
      EVEN
    ENDC
    IFEQ requires_multiscan_monitor
vga_requester_title        DC.B "System monitor request",0
      EVEN
vga_requester_text         DC.B "This demo opens a VGA screen with",10
                           DC.B "a horizontal frequency of 31 kHz.",10
                           DC.B "Check your monitor to be able",10
                           DC.B "to display this video mode.",0
      EVEN
vga_requester_gadgets_text DC.B "Proceed|Quit",0
      EVEN
    ENDC
downgrade_screen_name      DC.B "Downgrade 15kHz screen",0
    EVEN
file_name                  DC.B "RAW:0/0/640/80/  **  Message Window  **  ",0
    EVEN
  ENDC

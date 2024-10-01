; Datum:	07.09.2024
; Version:	2.2

	IFND SYS_TAKEN_OVER
dos_name			DC.B "dos.library",0
		EVEN
graphics_name			DC.B "graphics.library",0
		EVEN
intuition_name			DC.B "intuition.library",0
ciaa_name			DC.B "ciaa.resource",0
		EVEN
ciab_name			DC.B "ciab.resource",0
		EVEN
timer_device_name		DC.B "timer.device",0
		EVEN

		IFEQ requires_multiscan_monitor
monitor_request_title		DC.B "System monitor request",0
			EVEN
monitor_request_text_body	DC.B "This demo opens a VGA screen with",ASCII_LINE_FEED
				DC.B "a horizontal frequency of 31 kHz.",ASCII_LINE_FEED
				DC.B "Check your monitor to be able",ASCII_LINE_FEED
				DC.B "to display this video mode.",0
			EVEN
monitor_request_text_gadgets	DC.B "Proceed|Quit",0
			EVEN
		ENDC

		IFNE intena_bits&INTF_PORTS
bsdsocket_name			DC.B "bsdsocket.library",0
			EVEN

tcp_stack_request_title		DC.B "TCP/IP-stack request",0
			EVEN
tcp_stack_request_text_body	DC.B "An active TCP/IP-stack was detected.",ASCII_LINE_FEED
				DC.B "This may affect the interrupt handling",ASCII_LINE_FEED
				DC.B "of the demo and freeze it.",ASCII_LINE_FEED
				DC.B "Please close this application and proceed.",ASCII_LINE_FEED,0
			EVEN
tcp_stack_request_text_gadgets	DC.B "Proceed|Quit",0
			EVEN
		ENDC

pal_screen_name		DC.B "Degrade screen",0
		EVEN

invisible_window_name		DC.B "Invisible window",0
		EVEN
		
raw_name			DC.B "RAW:0/0/640/80/  **  Message Window  **  ",0
		EVEN
	ENDC

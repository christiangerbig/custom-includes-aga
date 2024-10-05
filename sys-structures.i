; Datum:	08.09.2023
; Version:	2.0

	IFND SYS_TAKEN_OVER
		IFEQ requires_multiscan_monitor
			CNOP 0,4
monitor_request
			DS.B EasyStruct_SIZEOF
		ENDC


		IFNE intena_bits&INTF_PORTS
			CNOP 0,4
tcp_stack_request
			DS.B EasyStruct_SIZEOF
		ENDC


		CNOP 0,4
timer_io
		DS.B IOTV_SIZE


                CNOP 0,4
video_control_tags
		DS.B video_control_tag_list_size

		IFNE screen_fader_enabled
			CNOP 0,4
pal_screen_rgb32_colors
			DS.B screen_02_colors_size
		ENDC

		CNOP 0,4
pal_screen_tags
		DS.B screen_tag_list_size

		CNOP 0,4
invisible_window_tags
		DS.B window_tag_list_size


		CNOP 0,4
custom_error_table
		DS.B custom_error_entry_size*custom_errors_number
	ENDC

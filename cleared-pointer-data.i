; Datum:	12.09.2024
; Version:	1.0

	RSRESET

cleared_pointer_data		RS.B 0

cpd_control_word1		RS.W 1 ; 1x Bandwidth
cpd_control_word2		RS.W 1
cpd_color_descriptor		RS.W 2
cpd_end_of_data			RS.W 2

cleared_pointer_data_size	RS.B 0

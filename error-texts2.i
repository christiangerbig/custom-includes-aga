; header for PrintFault()
error_header
	DC.B " ",0
	EVEN

error_text1
	DC.B "Couldn't allocate custom memory !",ASCII_LINE_FEED,ASCII_LINE_FEED
error_text1_end
	EVEN




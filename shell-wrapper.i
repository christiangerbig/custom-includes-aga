; Datum:	26.09.2024
; Version:	1.0


	movem.l	d2-d7/a2-a6,-(a7)
	lea	variables(pc),a3
	bsr	init_variables

	bsr	open_dos_library
	move.l	d0,dos_return_code(a3)
	bne.s	quit

	bsr	get_output
	move.l	d0,dos_return_code(a3)
	bne.s	cleanup_all

	bsr     init_main_variables	; Externe Routine

	IFD USE_CMD_LINE_CHECK
		bsr	check_command_line ; Externe Routine
		move.l	d0,dos_return_code(a3)
		bne.s	cleanup_all
	ENDC

	IFNE memory_size
		bsr	alloc_memory
		move.l	d0,dos_return_code(a3)
		bne.s	cleanup_all
	ENDC
	IFD USE_CUSTOM_MEMORY
		bsr	alloc_custom_memory ; Externe Routine
		move.l	d0,dos_return_code(a3)
		bne.s	cleanup_all
	ENDC

	bsr	init_main		; Externe Routine
	tst.l	d0
	bne.s	cleanup_all

	bsr	main			; Externe Routine
	move.l	d0,dos_return_code(a3)

cleanup_all
	bsr	cleanup_main		; Externe Routine

	IFNE memory_size
		bsr	free_memory
	ENDC
	IFD USE_CUSTOM_MEMORY
		bsr	free_custom_memory
	ENDC

	IFD USE_CMD_LINE_CHECK
		bsr	free_RDArgs
	ENDC

	bsr	print_error_text

	bsr	close_dos_library

quit
	move.l	dos_return_code(a3),d0
	movem.l	(a7)+,d2-d7/a2-a6
	rts


; Input
; Result
; d0.l	... Kein Rückgabewert	
	CNOP 0,4
init_variables
	move.l	a0,shell_parameters(a3)
	move.l	d0,shell_parameters_length(a3)

	lea	_SysBase(pc),a0
	move.l	exec_base.w,(a0)

	moveq	#0,d0
	move.l	d0,dos_return_code(a3)
	rts


; Input
; Result
; d0.l	... Return-Code
	CNOP 0,4
open_dos_library
	lea     dos_library_name(pc),a1
	moveq	#ANY_LIBRARY_VERSION,d0
	CALLEXEC OpenLibrary
	lea	_DOSBase(pc),a0
	move.l	d0,(a0)
	bne.s	open_dos_library_ok
	moveq	#RETURN_FAIL,d0
	rts
	CNOP 0,4
open_dos_library_ok
	moveq 	#RETURN_OK,d0
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


	IFNE memory_size
; Input
; Result
; d0.l	... Return-Code
		CNOP 0,4
alloc_memory
		MOVEF.L	memory_size,d0
		move.l	#MEMF_CLEAR|MEMF_PUBLIC,d1
		CALLEXEC AllocMem
		move.l	d0,memory(a3)
		bne.s	alloc_memory_ok
		lea	error_text1(pc),a0
		moveq	#error_text1_end-error_text1,d0
		bsr	print_text
		moveq	#RETURN_ERROR,d0
		rts
		CNOP 0,4
alloc_memory_ok
		moveq	#RETURN_OK,d0
		rts
	ENDC


	IFNE memory_size
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_memory
		move.l	memory(a3),d0
		bne.s   free_memory_skip
free_memory_quit
		rts
		CNOP 0,4
free_memory_skip
		move.l	d0,a1
		move.l	#memory_size,d0
		CALLEXEC FreeMem
		bra.s	free_memory_quit
	ENDC


	IFD USE_CMD_LINE_CHECK
; Input
; Result
; d0.l	... Kein Rückgabewert
		CNOP 0,4
free_RDArgs
		move.l	RDArgs(a3),d1
		bne.s   free_RDArgs_skip
free_RDArgs_quit
		rts
		CNOP 0,4
free_RDArgs_skip
		CALLDOS FreeArgs
		bra.s	free_RDArgs_quit
	ENDC


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
print_error_text
	move.l  dos_return_code(a3),d1
	moveq   #ERROR_NO_FREE_STORE,d0
	cmp.l   d0,d1
	bge.s	print_error_text_skip
print_error_text_quit
	rts
	CNOP 0,4
print_error_text_skip
	lea	error_header(pc),a0	; Header für Fehlermeldung
	move.l	a0,d2
	CALLDOS PrintFault
	bra.s	print_error_text_quit


; Input
; a0	... Zeiger auf Fehlertext
; d0.l	... Länge des Textes
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
print_text
	move.l	d0,d3			; Anzahl der Zeichen zum Schreiben
	move.l	output_handle(a3),d1
	move.l	a0,d2			; Zeiger auf Text
	CALLDOSQ Write


; Input
; Result
; d0.l	... Kein Rückgabewert
	CNOP 0,4
close_dos_library
	move.l	_DOSBase(pc),d0
	bne.s   close_dos_library_skip
close_dos_library_quit
	rts
	CNOP 0,4
close_dos_library_skip
	move.l	d0,a1
	CALLEXEC CloseLibrary
	bra.s	close_dos_library_quit

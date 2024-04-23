; Includedatei: "normsource-includes/variables-offsets.i"
; Datum:        11.3.2024
; Version:      3.4

; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------
  RSRESET

  IFND sys_taken_over

shell_parameters_length  RS.L 1
shell_parameters_pointer RS.L 1
    IFEQ workbench_start
wb_message               RS.L 1
    ENDC

file_handle              RS.L 1
raw_buffer               RS.B 1

cpu_flags                RS.W 1
fast_memory_available    RS.W 1

  ELSE

    IFD pass_global_references
      RS_ALIGN_LONGWORD
global_references_table  RS.L 1
    ENDC

  ENDC

custom_error_code        RS.W 1
  RS_ALIGN_LONGWORD
dos_return_code          RS.L 1

  IFND sys_taken_over
os_view                  RS.L 1
os_screen                RS.L 1
os_monitor_id            RS.L 1
os_sprite_resolution     RS.L 1

    IFNE workbench_fade
screen_color_table32     RS.L 1
    ENDC
downgrade_screen         RS.L 1

    IFEQ workbench_fade
wbf_colors_number        RS.L 1
wbf_color_values32       RS.L 1
wbf_color_cache32        RS.L 1
wbfi_state               RS.W 1
wbfo_state               RS.W 1
    ENDC

    IFNE cl1_size3
os_COP1LC                RS.L 1
    ENDC
    IFNE cl2_size3
os_COP2LC                RS.L 1
    ENDC

    IFD save_BEAMCON0
os_BEAMCON0              RS.L 1
    ENDC

os_VBR                   RS.L 1
    IFD all_caches
os_CACR                  RS.L 1
    ENDC
    IFD no_store_buffer
os_CACR                  RS.L 1
    ENDC

os_DMACON                RS.W 1
os_INTENA                RS.W 1
os_ADKCON                RS.W 1

os_CIAAPRA               RS.B 1
os_CIAATALO              RS.B 1
os_CIAATAHI              RS.B 1
os_CIAATBLO              RS.B 1
os_CIAATBHI              RS.B 1
os_CIAAICR               RS.B 1
os_CIAACRA               RS.B 1
os_CIAACRB               RS.B 1

os_CIABPRB               RS.B 1
os_CIABTALO              RS.B 1
os_CIABTAHI              RS.B 1
os_CIABTBLO              RS.B 1
os_CIABTBHI              RS.B 1
os_CIABICR               RS.B 1
os_CIABCRA               RS.B 1
os_CIABCRB               RS.B 1

    RS_ALIGN_LONGWORD
tod_time_save            RS.L 1

vbr_save                 RS.L 1
  ENDC

  IFNE cl1_size1
cl1_construction1        RS.L 1
  ENDC
  IFNE cl1_size2
cl1_construction2        RS.L 1
  ENDC
  IFNE cl1_size3
cl1_display              RS.L 1
  ENDC
  IFNE cl2_size1
cl2_construction1        RS.L 1
  ENDC
  IFNE cl2_size2
cl2_construction2        RS.L 1
  ENDC
  IFNE cl2_size3
cl2_display              RS.L 1
  ENDC

  IFNE pf1_depth1
pf1_bitmap1              RS.L 1
  ENDC
  IFNE pf1_depth2
pf1_bitmap2              RS.L 1
  ENDC
  IFNE pf1_depth3
pf1_bitmap3              RS.L 1
  ENDC
  IFNE pf1_depth1
pf1_construction1        RS.L 1
  ENDC
  IFNE pf1_depth2
pf1_construction2        RS.L 1
  ENDC
  IFNE pf1_depth3
pf1_display              RS.L 1
  ENDC
  IFNE pf2_depth1
pf2_bitmap1              RS.L 1
  ENDC
  IFNE pf2_depth2
pf2_bitmap2              RS.L 1
  ENDC
  IFNE pf2_depth3
pf2_bitmap3              RS.L 1
  ENDC
  IFNE pf2_depth1
pf2_construction1        RS.L 1
  ENDC
  IFNE pf2_depth2
pf2_construction2        RS.L 1
  ENDC
  IFNE pf2_depth3
pf2_display              RS.L 1
  ENDC

  IFNE extra_pf_number
    IFGE extra_pf_number-1
extra_pf_bitmap1         RS.L 1
    ENDC
    IFGE extra_pf_number-2
extra_pf_bitmap2         RS.L 1
    ENDC
    IFGE extra_pf_number-3
extra_pf_bitmap3         RS.L 1
    ENDC
    IFGE extra_pf_number-4
extra_pf_bitmap4         RS.L 1
    ENDC
    IFGE extra_pf_number-5
extra_pf_bitmap5         RS.L 1
    ENDC
    IFGE extra_pf_number-1
extra_pf1                RS.L 1
    ENDC
    IFGE extra_pf_number-2
extra_pf2                RS.L 1
    ENDC
    IFGE extra_pf_number-3
extra_pf3                RS.L 1
    ENDC
    IFGE extra_pf_number-4
extra_pf4                RS.L 1
    ENDC
    IFGE extra_pf_number-5
extra_pf5                RS.L 1
    ENDC
  ENDC

  IFNE spr_x_size1
spr0_bitmap1             RS.L 1
spr1_bitmap1             RS.L 1
spr2_bitmap1             RS.L 1
spr3_bitmap1             RS.L 1
spr4_bitmap1             RS.L 1
spr5_bitmap1             RS.L 1
spr6_bitmap1             RS.L 1
spr7_bitmap1             RS.L 1
spr0_construction        RS.L 1
spr1_construction        RS.L 1
spr2_construction        RS.L 1
spr3_construction        RS.L 1
spr4_construction        RS.L 1
spr5_construction        RS.L 1
spr6_construction        RS.L 1
spr7_construction        RS.L 1
  ENDC
  IFNE spr_x_size2
spr0_bitmap2             RS.L 1
spr1_bitmap2             RS.L 1
spr2_bitmap2             RS.L 1
spr3_bitmap2             RS.L 1
spr4_bitmap2             RS.L 1
spr5_bitmap2             RS.L 1
spr6_bitmap2             RS.L 1
spr7_bitmap2             RS.L 1
spr0_display             RS.L 1
spr1_display             RS.L 1
spr2_display             RS.L 1
spr3_display             RS.L 1
spr4_display             RS.L 1
spr5_display             RS.L 1
spr6_display             RS.L 1
spr7_display             RS.L 1
  ENDC

  IFNE audio_memory_size
audio_data               RS.L 1
  ENDC

  IFNE disk_memory_size
disk_data                RS.L 1
  ENDC

  IFNE extra_memory_size
extra_memory             RS.L 1
  ENDC

  IFNE chip_memory_size
chip_memory              RS.L 1
  ENDC

  IFND sys_taken_over
exception_vectors_base   RS.L 1
  ENDC

  IFD measure_rastertime
rt_rasterlines_number    RS.L 1
  ENDC

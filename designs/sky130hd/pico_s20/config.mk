export DESIGN_NAME     = pico_solo_top
export DESIGN_NICKNAME = pico_s20
export PLATFORM        = sky130hd

export VERILOG_FILES = $(sort $(wildcard /work/designs/src/pico_solo/*.v))
export SDC_FILE      = /work/designs/$(PLATFORM)/pico_s20/constraint.sdc

export CORE_UTILIZATION = 40
export TNS_END_PERCENT  = 100

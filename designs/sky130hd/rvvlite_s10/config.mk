export DESIGN_NAME     = rvvlite_top
export DESIGN_NICKNAME = rvvlite_s10
export PLATFORM        = sky130hd

export VERILOG_FILES = $(sort $(wildcard /work/designs/src/rvvlite_pcpi/*.v))
export SDC_FILE      = /work/designs/$(PLATFORM)/rvvlite_s10/constraint.sdc

export CORE_UTILIZATION = 40
export TNS_END_PERCENT  = 100

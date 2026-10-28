export DESIGN_NAME     = gcd
export DESIGN_NICKNAME = gcd_t32
export PLATFORM        = sky130hd

export VERILOG_FILES = $(DESIGN_HOME)/src/gcd/gcd.v
export SDC_FILE      = /work/designs/$(PLATFORM)/gcd_t32/constraint.sdc

# Adders degrade GCD
export ADDER_MAP_FILE :=

export CORE_UTILIZATION = 38
export TNS_END_PERCENT = 100
export SWAP_ARITH_OPERATORS = 1
export OPENROAD_HIERARCHICAL = 1

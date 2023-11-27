SIM ?=questa
TOPLEVEL_LANG ?= verilog
WAVES ?= 1

VERILOG_SOURCES += $(PWD)/prach_nco.sv
VERILOG_SOURCES += $(PWD)/delay.sv

TOPLEVEL = prach_nco

MODULE = test_prach_nco

include $(shell cocotb-config --makefiles)/Makefile.sim


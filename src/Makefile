SIM ?=questa
TOPLEVEL_LANG ?= verilog
WAVES ?= 1

VERILOG_SOURCES += $(PWD)/cmult.sv
VERILOG_SOURCES += $(PWD)/delay.sv
VERILOG_SOURCES += $(PWD)/prach_mixer.sv
VERILOG_SOURCES += $(PWD)/prach_nco.sv

TOPLEVEL ?= prach_mixer

MODULE ?= test_prach_mixer

include $(shell cocotb-config --makefiles)/Makefile.sim

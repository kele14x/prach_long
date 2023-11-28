SIM ?=questa
TOPLEVEL_LANG ?= verilog
WAVES ?= 1

VERILOG_SOURCES += $(PWD)/cmult.sv
VERILOG_SOURCES += $(PWD)/delay.sv
VERILOG_SOURCES += $(PWD)/prach_hb1_ch.sv
VERILOG_SOURCES += $(PWD)/prach_hb2_ch.sv
VERILOG_SOURCES += $(PWD)/prach_hb3.sv
VERILOG_SOURCES += $(PWD)/prach_hb4.sv
VERILOG_SOURCES += $(PWD)/prach_mixer.sv
VERILOG_SOURCES += $(PWD)/prach_nco.sv

TOPLEVEL ?= prach_hb4

MODULE ?= test_prach_hb4

include $(shell cocotb-config --makefiles)/Makefile.sim

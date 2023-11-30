SIM ?=questa
TOPLEVEL_LANG ?= verilog
WAVES ?= 1

VERILOG_SOURCES += $(PWD)/cmult.sv
VERILOG_SOURCES += $(PWD)/delay.sv
VERILOG_SOURCES += $(PWD)/prach_ditfft2.sv
VERILOG_SOURCES += $(PWD)/prach_ditfft2_bf.sv
VERILOG_SOURCES += $(PWD)/prach_ditfft2_twiddler.sv
VERILOG_SOURCES += $(PWD)/prach_ditfft3.sv
VERILOG_SOURCES += $(PWD)/prach_ditfft3_bf1.sv
VERILOG_SOURCES += $(PWD)/prach_ditfft3_bf2.sv
VERILOG_SOURCES += $(PWD)/prach_ditfft3_bf3.sv
VERILOG_SOURCES += $(PWD)/prach_fft.sv
VERILOG_SOURCES += $(PWD)/prach_hb1_ch.sv
VERILOG_SOURCES += $(PWD)/prach_hb2_ch.sv
VERILOG_SOURCES += $(PWD)/prach_hb3.sv
VERILOG_SOURCES += $(PWD)/prach_hb4.sv
VERILOG_SOURCES += $(PWD)/prach_hb5.sv
VERILOG_SOURCES += $(PWD)/prach_mixer.sv
VERILOG_SOURCES += $(PWD)/prach_nco.sv

TOPLEVEL ?= prach_fft

MODULE ?= test_prach_fft

include $(shell cocotb-config --makefiles)/Makefile.sim

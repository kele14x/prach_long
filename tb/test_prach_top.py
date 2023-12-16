import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock


async def reset(dut):
    pass

@cocotb.test()
async def test_prach_top(dut):
    await reset(dut)
    await Timer(100, units="ns")

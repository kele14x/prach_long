import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock

import matplotlib.pyplot as plt
import numpy as np


CONST_2PI = 49152
CONST_1PI = CONST_2PI / 2
CONST_PI2 = CONST_2PI / 4
CONST_PI4 = CONST_2PI / 8


async def reset(dut):
    dut.rst_n.value = 0

    dut.din_dv.value = 0
    dut.din_chn.value = 0
    dut.sync_in.value = 0
    for i in range(3):
        for j in range(3):
            dut.ctrl_fcw[i][j].value = 0

    await Timer(100, units="ns")
    dut.rst_n.value = 1
    await Timer(100, units="ns")
    await RisingEdge(dut.clk)


async def drive_stable(dut):
    synced = 0
    clkedge = RisingEdge(dut.clk)

    while True:
        for j in range(8):
            if synced == 0 and j == 0:
                dut.sync_in.value = 1
                synced = 1
            else:
                dut.sync_in.value = 0
            dut.din_chn.value = j
            dut.din_dv.value = 1
            for i in range(3):
                dut.din_dq[i].value = 0
            await clkedge


async def sample_of(dut, n):
    i = 0
    clkedge = RisingEdge(dut.clk)

    while i < n:
        await clkedge
        if dut.dout_dv.value == 1 and dut.dout_chn == 0:
            i = i + 1
            yield dut.dout_dq[0].value


@cocotb.test()
async def test_prach_nco(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    await reset(dut)

    dut.ctrl_fcw[0][0].value = int(-1 / 61.44 * CONST_2PI) % CONST_2PI

    cocotb.start_soon(drive_stable(dut))

    res = [dq async for dq in sample_of(dut, 1000)]
    print(res)

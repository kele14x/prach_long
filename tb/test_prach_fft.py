import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock

import random

NUM_FFT_STAGE = 2
NUM_FFT_LENGTH = 3 * 2 ** (NUM_FFT_STAGE - 1)


async def reset(dut):
    dut.rst_n.value = 0

    dut.din_dr.value = 0
    dut.din_di.value = 0
    dut.din_dv.value = 0
    dut.sync_in.value = 0

    await Timer(100, units="ns")
    dut.rst_n.value = 1
    await Timer(100, units="ns")
    await RisingEdge(dut.clk)


async def drive_frame(dut):
    clkedge = RisingEdge(dut.clk)

    for i in range(NUM_FFT_LENGTH):
        if i == 0:
            dut.sync_in.value = 1
        else:
            dut.sync_in.value = 0
        dut.din_dr.value = random.randint(-10, 10)
        dut.din_di.value = random.randint(-10, 10)
        dut.din_dv.value = 1
        await clkedge

    dut.sync_in.value = 0
    dut.din_dr.value = 0
    dut.din_di.value = 0
    dut.din_dv.value = 0


async def sample_of_frame(dut):
    i = 0
    clkedge = RisingEdge(dut.clk)

    while i < NUM_FFT_LENGTH:
        await clkedge
        if dut.dout_dv.value.is_resolvable and dut.dout_dv.value == 1:
            i = i + 1
            if dut.dout_dr.value.is_resolvable and dut.dout_di.value.is_resolvable:
                yield (
                    dut.dout_dr.value.signed_integer,
                    dut.dout_di.value.signed_integer,
                )
            else:
                yield float("nan")


@cocotb.test()
async def test_prach_ditff2(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    await reset(dut)
    cocotb.start_soon(drive_frame(dut))

    res = [x async for x in sample_of_frame(dut)]
    print(res)

    await Timer(100, units="ns")

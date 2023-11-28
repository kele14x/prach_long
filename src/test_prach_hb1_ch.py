import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock


async def reset(dut):
    dut.rst_n.value = 0

    dut.din_dp1.value = 0
    dut.din_dp2.value = 0
    dut.din_dv.value = 0
    dut.din_chn.value = 0
    dut.sync_in.value = 0

    await Timer(100, units="ns")
    dut.rst_n.value = 1
    await Timer(100, units="ns")
    await RisingEdge(dut.clk)


async def drive_stable(dut):
    synced = 0
    clkedge = RisingEdge(dut.clk)

    while True:
        for j in range(16):
            if synced == 0 and j == 0:
                dut.sync_in.value = 1
                synced = 1
            else:
                dut.sync_in.value = 0
            dut.din_dp1.value = 0
            dut.din_dp2.value = 0
            dut.din_dv.value = 1
            dut.din_chn.value = j
            await clkedge


async def drive_impulse(dut):
    synced = 0
    clkedge = RisingEdge(dut.clk)

    while True:
        for j in range(16):
            if synced == 0 and j == 0:
                dut.sync_in.value = 1
                dut.din_dp1.value = 32767
                dut.din_dp2.value = 32767
                synced = 1
            else:
                dut.sync_in.value = 0
                dut.din_dp1.value = 0
                dut.din_dp2.value = 0
            dut.din_dv.value = 1
            dut.din_chn.value = j
            await clkedge


async def sample_of(dut, n):
    i = 0
    clkedge = RisingEdge(dut.clk)

    while i < n:
        await clkedge
        if dut.dout_dv.value == 1 and dut.dout_chn == 0:
            i = i + 1
            yield dut.dout_dq.value


@cocotb.test()
async def test_prach_hb1_ch(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    await reset(dut)
    cocotb.start_soon(drive_impulse(dut))

    res = [x.signed_integer async for x in sample_of(dut, 100)]
    print(res)

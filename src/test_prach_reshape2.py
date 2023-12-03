import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer


async def reset(dut):
    dut.rst_n.value = 0

    dut.din_dv.value = 0
    dut.din_chn.value = 0
    dut.sync_in.value = 0
    for i in range(3):
        dut.din_dq[i].value = 0

    await Timer(100, units="ns")
    dut.rst_n.value = 1
    await Timer(100, units="ns")
    await RisingEdge(dut.clk)


async def drive_stable(dut):
    clkedge = RisingEdge(dut.clk)

    for i in range(1000):
        for j in range(16):
            if i == 0 and j == 0:
                dut.sync_in.value = 1
            else:
                dut.sync_in.value = 0
            dut.din_chn.value = j
            dut.din_dv.value = 1
            dut.din_dq[0].value = j * 256 + i
            await clkedge


async def sample_of(dut, n):
    i = 0
    clkedge = RisingEdge(dut.clk)

    while i < n:
        await clkedge
        if dut.dout_dv.value.is_resolvable and dut.dout_dv.value == 1:
            i = i + 1
            yield (
                dut.dout_dp1[0].value.signed_integer,
                dut.dout_dp2[0].value.signed_integer,
            )


@cocotb.test()
async def test_prach_reshape2(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    await reset(dut)

    cocotb.start_soon(drive_stable(dut))

    res = [(dp1, dp2) async for (dp1, dp2) in sample_of(dut, 1000)]
    print(res)
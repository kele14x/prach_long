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
    for i in range(8):
    	dut.ctrl_fcw[i].value = 0
    
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
            await clkedge


async def sample_of(dut, n):
    i = 0
    clkedge = RisingEdge(dut.clk)
    
    while i < n:
        await clkedge
        if dut.dout_dv.value == 1 and dut.dout_chn == 0:
            i = i + 1
            yield (dut.dout_cos.value, dut.dout_sin.value)

        

@cocotb.test()
async def test_prach_nco(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    await reset(dut)

    dut.ctrl_fcw[0].value = int(-1/61.44 * CONST_2PI) % CONST_2PI

    cocotb.start_soon(drive_stable(dut))

    res = np.zeros(1000, dtype=np.complex_)

    res = [(cos.signed_integer, sin.signed_integer) async for (cos, sin) in sample_of(dut, 1000)]
    res = np.array(res)
    res = res[:,0] + 1j * res[:,1]

    plt.plot(10*np.log10(np.abs(np.fft.fftshift(np.fft.fft(res)))))
    plt.show()


        


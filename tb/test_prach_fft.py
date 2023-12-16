from pathlib import Path

import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.handle import SimHandleBase
from cocotb.queue import Queue
from cocotb.runner import get_runner
from cocotb.triggers import ClockCycles, RisingEdge, Timer

W = 16
NFFT = 1536


async def reset(dut):
    dut.rst_n.value = 0
    dut.din_dr.value = 0
    dut.din_di.value = 0
    dut.din_dv.value = 0
    dut.sync_in.value = 0
    dut.hdr_in.value = 0
    await ClockCycles(dut.clk, 16)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 16)


def sequence():
    for _ in range(10):
        xr = np.random.randint(-(2 ** (W - 1)), 2 ** (W - 1) - 1, NFFT)
        xi = np.random.randint(-(2 ** (W - 1)), 2 ** (W - 1) - 1, NFFT)
        x = xr + 1j * xi
        hdr = np.random.randint(100)
        yield (x, hdr)


async def driver(dut, seq):
    clkedge = RisingEdge(dut.clk)

    (xs, hdr) = seq
    for i, x in enumerate(xs):
        dut.sync_in.value = 1 if i == 0 else 0
        dut.din_dr.value = int(np.real(x))
        dut.din_di.value = int(np.imag(x))
        dut.din_dv.value = 1
        dut.hdr_in.value = hdr
        await clkedge

    dut.sync_in.value = 0
    dut.din_dr.value = 0
    dut.din_di.value = 0
    dut.din_dv.value = 0
    dut.hdr_in.value = 0


async def input_monitor(dut: SimHandleBase, queue: Queue):
    clkedge = RisingEdge(dut.clk)

    while True:
        # Wait for sync
        while True:
            if dut.sync_in.value.is_resolvable and dut.sync_in.value == 1:
                hdr = dut.hdr_in.value.integer
                break
            await clkedge

        # Collect data
        y = np.zeros(NFFT, dtype=np.complex_)
        for i in range(NFFT):
            assert dut.din_dr.value.is_resolvable and dut.din_di.value.is_resolvable
            dr = dut.din_dr.value.signed_integer
            di = dut.din_di.value.signed_integer
            y[i] = dr + 1j * di
            await clkedge

        queue.put_nowait((y, hdr))


async def output_monitor(dut: SimHandleBase, queue: Queue):
    clkedge = RisingEdge(dut.clk)

    while True:
        # Wait for sync
        while True:
            if dut.sync_out.value.is_resolvable and dut.sync_out.value == 1:
                hdr = dut.hdr_out.value.integer
                break
            await clkedge

        # Collect data
        y = np.zeros(NFFT, dtype=np.complex_)
        for i in range(NFFT):
            assert dut.dout_dr.value.is_resolvable and dut.dout_di.value.is_resolvable
            dr = dut.dout_dr.value.signed_integer
            di = dut.dout_di.value.signed_integer
            y[i] = dr + 1j * di
            await clkedge

        queue.put_nowait((y, hdr))


def model(x):
    return np.fft.fft(x)


async def checker(input_queue, output_queue):
    while True:
        (x_in, hdr_in) = await input_queue.get()
        (x_out, hdr_out) = await output_queue.get()
        assert hdr_in == hdr_out
        # assert np.all(x_out == model(x_in))


@cocotb.test()
async def test_prach_fft(dut):
    cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())
    await reset(dut)

    input_queue = Queue()
    output_queue = Queue()

    cocotb.start_soon(input_monitor(dut, input_queue))
    cocotb.start_soon(output_monitor(dut, output_queue))
    cocotb.start_soon(checker(input_queue, output_queue))

    for seq in sequence():
        await driver(dut, seq)

    await Timer(5000, units="ns")


def test_prach_fft_runner():
    sim = "questa"

    path = Path(__file__).resolve().parent.parent
    print("Project path: %s" % path)

    hdl_toplevel = "prach_fft"
    hdl_toplevel_lang = "verilog"

    verilog_sources = [
        path / "src" / "cmult.sv",
        path / "src" / "delay.sv",
        path / "src" / "prach_ditfft2.sv",
        path / "src" / "prach_ditfft2_bf.sv",
        path / "src" / "prach_ditfft2_twiddler.sv",
        path / "src" / "prach_ditfft3.sv",
        path / "src" / "prach_ditfft3_bf1.sv",
        path / "src" / "prach_ditfft3_bf2.sv",
        path / "src" / "prach_ditfft3_bf3.sv",
        path / "src" / "prach_fft.sv",
    ]

    build_args = ["-L", "altera_mf_ver"]

    runner = get_runner(sim)
    runner.build(
        hdl_toplevel=hdl_toplevel,
        verilog_sources=verilog_sources,
        # build_args=build_args,
        always=True,
    )

    runner.test(
        hdl_toplevel=hdl_toplevel,
        hdl_toplevel_lang=hdl_toplevel_lang,
        test_args=build_args,
        test_module="test_prach_fft",
        waves=True,
    )


if __name__ == "__main__":
    test_prach_fft_runner()

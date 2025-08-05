from pathlib import Path

from gem5.resources.resource import obtain_resource
from gem5.simulate.simulator import Simulator
from gem5.utils.requires import requires
# from m5.objects import *

from gem5.components.boards.simple_board import SimpleBoard
from gem5.components.processors.cpu_types import CPUTypes
from gem5.isas import ISA

# TODO: Switch to only the provided CPU config
from gem5.components.processors.simple_processor import SimpleProcessor
# from configs import SimpleVALUCPU
from gem5.components.cachehierarchies.classic.private_l1_cache_hierarchy import PrivateL1CacheHierarchy
from gem5.components.memory.single_channel import SingleChannelDDR3_1600

# Set up multisim
from gem5.utils.multisim import multisim
multisim.set_num_processes(8)

requires(ISA.RISCV)

# Workloads with TODO elements are paired with false
WORKLOADS = [
    (True, "riscv-hello")
    # # Question 1, unvectorzed
    # (True, "riscv-elementwise-matmul"),
    # (True, "riscv-naive-matmul"),
    # (True, "riscv-naive-averagepool"),
    # # Question 1, vectorized
    # (True, "riscv-vectorized-elementwise-matmul"),
    # (True, "riscv-vectorized-naive-matmul"),
    # (True, "riscv-vectorized-naive-averagepool"),
    #
    # # Question 2
    # (True, "riscv-opt-matmul"),
    # (True, "riscv-naive-matmul"),
    # (True, "riscv-vectorized-opt-matmul"),
    # (True, "riscv-vectorized-naive-matmul"),
    #
    # # Question 3
    # (True, "riscv-dsp-realtime-compression"),
    # (True, "riscv-vectorized-dsp-realtime-compression"),
]

# Simple processor
processor = SimpleProcessor(num_cores=1, cpu_type=CPUTypes.O3, isa=ISA.RISCV)
# Simple cache hierarchy
cache = PrivateL1CacheHierarchy(l1d_size="32KiB", l1i_size="32KiB")
# Simple memory module
memory = SingleChannelDDR3_1600(size="8GiB")

# Link everything together in your board
board = SimpleBoard(
    clk_freq="3GHz",
    cache_hierarchy=cache,
    processor=processor,
    memory=memory,
)

for ready, resource in WORKLOADS:
    if not ready:
        print("Implementation TODOs left for {}, skipping".format(resource))
        continue
    # Check out https://resources.gem5.org for more things to run
    board.set_se_binary_workload(obtain_resource("riscv-hello"))
    
    # Set up the simulation (This is where you would set up the checkpoints)
    simulator = Simulator(
        id=resource,  # legal because multisim handles it differently
        board=board,
    )

    multisim.add_simulator(simulator)

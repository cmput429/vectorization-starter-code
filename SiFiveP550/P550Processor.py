from gem5.isas import ISA
from gem5.components.processors.base_cpu_core import BaseCPUCore
from gem5.components.processors.base_cpu_processor import BaseCPUProcessor
from gem5.utils.requires import requires

from m5.objects import *

class P550Core(BaseCPUCore):
    """
    A core for the P550 processor. Consisting of:
    - 1 Integer ALU
    - 1 MulDiv ALU
    - 1 RdWrPort ALU
    """

    def __init__(
        self,
        vlen: int,
        core_id: int,
    ) -> None:
        requires(isa_required=ISA.RISCV)

        # The basic OOO CPU
        cpu = RiscvO3CPU(
            cpu_id=core_id,
            # fetchWidth=1,
        )
        cpu.isa = [RiscvISA(vlen=vlen)]

        # Inheritance requirements
        super().__init__(
            core=cpu,
            isa=ISA.RISCV
        )


class P550Processor(BaseCPUProcessor):
    """
    The full processor (multiple cores) for the P550 machine
    """

    def __init__(
        self,
        isa_vlen: int,
        num_cores: int = 1
    ) -> None:
        super().__init__(
            # Initialize as many cores as we want
            cores=[
                P550Core(vlen=isa_vlen, core_id=i)
                for i in range(num_cores)
            ]
        )

    def __repr__(self):
        return "SiFiveP550"

    def __str__(self):
        return "Member of SiFiveP550"

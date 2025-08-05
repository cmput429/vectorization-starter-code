# Cleaned Makefile

# Paths and tools
HIP_PATH      ?= /opt/rocm
HIPCC          = $(HIP_PATH)/bin/hipcc
GEM5_PATH     ?= /mnt/c/Users/kevin/gem5stuff/gem5

# Build directories
BIN_DIR       ?= ./bin

# Compiler and linker flags
CXXFLAGS       = \
    -I$(GEM5_PATH)/include \
    -I$(GEM5_PATH)/util/m5/src \
    -I$(GEM5_PATH) \
    -DGEM5_FS \
    --amdgpu-target=gfx942,gfx90a \
    -O3 \
    -DGPUFS

LDFLAGS        = \
    -L$(GEM5_PATH)/util/m5/build/x86/out \
    -lm5

# Source sets
THREAD_SRCS    = divergent non_divergent
MEMORY_SRCS    = divergent_coalesced non_divergent_coalesced
ROOT_SRCS      = point_of_arrays array_of_points 
ASM_SRCS       = point_of_arrays array_of_points divergent non_divergent divergent_coalesced non_divergent_coalesced

# Targets
EXE_TARGETS    := $(THREAD_SRCS) $(ROOT_SRCS) $(MEMORY_SRCS)
ASM_TARGETS  := $(addsuffix _asm.s,$(ASM_SRCS)) 
ASM_G_TARGETS  := $(addsuffix _asm_g.s,$(ASM_SRCS)) 

.PHONY: all clean

# Default target: build all executables
all: | $(BIN_DIR) $(addprefix $(BIN_DIR)/,$(EXE_TARGETS))
all_asm: | $(BIN_DIR) $(addprefix $(BIN_DIR)/,$(ASM_TARGETS))
all_asm_g: | $(BIN_DIR) $(addprefix $(BIN_DIR)/,$(ASM_G_TARGETS))
# all_asm_mem: | $(BIN_DIR) $(addprefix $(BIN_DIR)/,$(ASM_mem_TARGETS))

# Build thread-divergence executables
$(addprefix $(BIN_DIR)/,$(THREAD_SRCS)): $(BIN_DIR)/%: thread-divergence/%.cpp | $(BIN_DIR)
	$(HIPCC) $(CXXFLAGS) $< -o $@ $(LDFLAGS)
# Build thread-divergence executables
$(addprefix $(BIN_DIR)/,$(MEMORY_SRCS)): $(BIN_DIR)/%: memory-coalesing/%.cpp | $(BIN_DIR)
	$(HIPCC) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

# Build root-source executables
$(addprefix $(BIN_DIR)/,$(ROOT_SRCS)): $(BIN_DIR)/%: %.cpp | $(BIN_DIR)
	$(HIPCC) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

# Generate assembly with debug symbols
$(addprefix $(BIN_DIR)/,$(ASM_G_TARGETS)): $(BIN_DIR)/%_asm_g.s: %.cpp | $(BIN_DIR)
	$(HIPCC) $(CXXFLAGS) $< -g -S -o $@ $(LDFLAGS)
# $(addprefix $(BIN_DIR)/,$(ASM_mem_TARGETS)): $(BIN_DIR)/%_asm_g.s: memory-coalesing/%.cpp | $(BIN_DIR)
# 	$(HIPCC) $(CXXFLAGS) $< -g -S -o $@ $(LDFLAGS)

# Generate assembly without debug symbols
$(addprefix $(BIN_DIR)/,$(ASM_TARGETS)): $(BIN_DIR)/%_asm.s: %.cpp | $(BIN_DIR)
	$(HIPCC) $(CXXFLAGS) $< -S -o $@ $(LDFLAGS)

# Ensure bin directory exists
$(BIN_DIR):
	mkdir -p $@

# Clean generated files
clean:
	rm -rf $(BIN_DIR)

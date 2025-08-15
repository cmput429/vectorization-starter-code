# =========================== Paths & tools ===========================
CMPUT429DIR ?= /cshome/cmput429
HIP_PATH    ?= $(CMPUT429DIR)/TheRock/build
HIPCC       ?= $(HIP_PATH)/bin/hipcc
GEM_PATH    ?= $(CMPUT429DIR)/gem5
GEM5GPU     ?= $(GEM_PATH)/build/VEGA_X86/gem5.fast

# =========================== Dirs & discovery ========================
SRC_DIR ?= .
BIN_DIR ?= bin
SIMS_DIR ?= sims

SRCS := $(wildcard $(SRC_DIR)/*.cpp)
BINS := $(patsubst $(SRC_DIR)/%.cpp,$(BIN_DIR)/%,$(SRCS))
APPS := $(patsubst $(SRC_DIR)/%.cpp,%,$(SRCS))
SIMS_DONE := $(addprefix $(SIMS_DIR)/,$(addsuffix /.done,$(APPS)))

# =========================== Architecture ===========================
OFFLOAD_ARCHS ?= gfx942 gfx90a
OFFLOAD_FLAGS := $(foreach a,$(OFFLOAD_ARCHS),--offload-arch=$(a))

# =========================== Build flags =============================
CXXFLAGS := -x hip \
            -I$(GEM_PATH)/include \
            -I$(GEM_PATH)/util/m5/src \
            -I$(GEM_PATH) \
            $(OFFLOAD_FLAGS) \
            -fno-unroll-loops \
            -DGPUFS \
            -O1

# Avoid PIE when linking with non-PIC libm5.a
LDFLAGS  := -L$(GEM_PATH)/util/m5/build/x86/out -lm5 -Wl,-no-pie

# =========================== Sim config ==============================
PYTHON_CONFIG = $(GEM_PATH)/configs/example/gpufs/mi200.py
DISK_IMAGE    = $(GEM_PATH)/gem5-resources/src/x86-ubuntu-gpu-ml/disk-image/x86-ubuntu-gpu-ml
KERNEL        = $(GEM_PATH)/gem5-resources/src/x86-ubuntu-gpu-ml/vmlinux-gpu-ml
COMMON_OPTS   = --disk-image $(DISK_IMAGE) --kernel $(KERNEL)

# =========================== Phony ==============================
.PHONY: all build run clean clean_bins clean_sims run-%

# Default: build & simulate everything
all: $(SIMS_DONE)

# Build only
build: $(BINS)

# Simulate everything (alias)
run: $(SIMS_DONE)

# =========================== Compile =============================
$(BIN_DIR)/%: $(SRC_DIR)/%.cpp | $(BIN_DIR)
	$(HIPCC) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

$(BIN_DIR):
	mkdir -p $@

# =========================== Simulate ============================
# sims/<app>/.done depends on bin/<app>
$(SIMS_DIR)/%/.done: $(BIN_DIR)/%
	mkdir -p $(@D)
	$(GEM5GPU) -d $(@D) $(PYTHON_CONFIG) $(COMMON_OPTS) --app $<
	@touch $@

# Run a single app: make run-<app>
run-%: $(SIMS_DIR)/%/.done

# =========================== Clean ===============================
clean: clean_bins clean_sims

clean_bins:
	rm -rf $(BIN_DIR)

clean_sims:
	rm -rf $(SIMS_DIR)

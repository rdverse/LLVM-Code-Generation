## LLVM Test Suite Setup

**Step 1: Clone the test suite repository**
```bash
# Clone to the expected location (if not already present)
git clone https://github.com/llvm/llvm-test-suite.git ${LLVM_TEST_SUITE_SRC:-source/llvm-test-suite}
```

**Step 2: Source environment and configure**
```bash
# First, source the environment script from the repo root
source ../../llvm_env.sh
```

```bash  
# Create build directory and configure
mkdir -p ${LLVM_TEST_BUILD}
cd ${LLVM_TEST_BUILD}
```

```bash
# Configure (CC/CXX/ASM are automatically set by llvm_env.sh)
cmake -GNinja ${LLVM_TEST_SUITE_SRC}
```

Alternative with explicit compiler paths:
```bash
# cmake -GNinja -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_ASM_COMPILER=${ASM} ${LLVM_TEST_SUITE_SRC}
```

**Step 3: Build and run tests**
```bash
# Build all tests
ninja

# Run a specific test (use 'check' for all tests)
ninja check

# Or run lit directly on specific test directories
${LIT} ${LIT_OPTS} SingleSource/
${LIT} ${LIT_OPTS} MultiSource/
${LIT} ${LIT_OPTS} MicroBenchmarks/

# Run all tests with lit
${LIT} ${LIT_OPTS} .

```




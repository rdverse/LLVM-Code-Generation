## List of commands to test a small unit of llvm such as an optimization or a behavior

**Setup:** First source the environment script: `source ../../llvm_env.sh`

${LLVM_SRC}/llvm/unittests : tests written using gtest
${LLVM_SRC}/llvm/test :  tests written with llvm-lit

- automatic run (otherways to test):
ninja check-all/ check-llvm/ check-mlir (based on which project) - this automatically sets the paths, etc. 

- manual run :  
  - ${LIT:-${LLVM_BIN}/llvm-lit} -sv test/<testname>
  - ${LIT:-${LLVM_BIN}/llvm-lit} -sv tools/<project>/test/<testname>
  
Note: After sourcing llvm_env.sh, you can also use:
  - ${LIT} ${LIT_OPTS} test/<testname>
  - ${LIT} ${LIT_OPTS} tools/<project>/test/<testname>



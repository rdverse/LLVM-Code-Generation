This directory contains example of how FileCheck can be used.

The examples are sorted in increasing order of complexity.
- ex1: Uses only the simplest form of directives
- ex2: Shows how to use more than one prefix
- ex3: Introduces keywords
- ex4: Shows how to add regex in the mix
- ex5: Introduces variables

Each example lives in its own directory.
Each directory follows the same structure:
- `README.md` describes what there is to see in this example
- `run.sh` contains the command to run to demonstrate the specific example
- `input.txt` contains the input of the example
- `check-file.txt` contains the patterns that FileCheck will match in `run.sh`

To run the example:
- Make sure that FileCheck is in your `PATH`
```sh

# FileCheck should be available after following above instructions, otherwise run ninja FileCheck

# Location:
After building, FileCheck is located in 
../source/clang/bin/FileCheck

# Either load PATh
export PATH="/../source/clang/bin:$PATH"

# or add it to bashrc
vim ~/.bashrc
(add export PATh to script)
source ~/.bashrc
```
- Change directory to exN
- Open `run.sh` to see what is being tested
- Either:
  - run the commands manually by copy/pasting them, or
  - execute `bash run.sh`

## Building Clang
```sh
# Create a source folder and run the following:
git clone https://github.com/llvm/llvm-project.git
mkdir clang
cd clang
#For just getting Clang's frontend capabilities
cmake -DLLVM_ENABLE_PROJECTS=clang -GNinja -DCMAKE_BUILD_TYPE=Release ../llvm-project/llvm
# for debug build - for developing compiler
cmake -GNinja -DCMAKE_BUILD_TYPE=Debug ../llvm-project/llvm
# recommended for faster build - select arch
cmake -GNinja -DCMAKE_BUILD_TYPE=Debug -DLLVM_TARGETS_TO_BUILD="X86;AArch64" -DLLVM_OPTIMIZED_TABLEGEN=1 ../llvm-project/llvm
ninja clang
```

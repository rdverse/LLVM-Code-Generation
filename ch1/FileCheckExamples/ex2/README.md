This example shows how to use several prefixes with FileCheck.

We use the `check-prefixes` command line option to match expression that start
with a different keyword than CHECK.

Using this option, you can use several prefixes but only use a subset of what
your check file holds.



- All the checks should be in order in the input file
- There can be extra lines between first CHECK: and SECOND:
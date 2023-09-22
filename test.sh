#!/bin/bash

# LinuxX64 Brainfuck testing script
# (needs to be excecuted from project root)

do_test () {
    out=$(echo $3 | ./bf $1);
    if [ "$out" != "$2" ]; then
        echo "bf $(basename $1)\tFAILED | output: $out (excpected was \"$2\")"
        exit
    fi
    echo "bf $(basename $1)\tSUCCESS"
}

make;

do_test "tests/print.b" "0" "";
do_test "tests/read.b" "A" "A";
do_test "tests/comments.b" "!" "";
do_test "tests/loops.b" "22" "";
do_test "tests/formatting.b" "" "";
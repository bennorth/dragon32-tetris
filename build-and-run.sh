#!/bin/bash -e

asm6809 -o tetris.bin tetris.s
bin2cas.pl --load=0x7000 --exec=0x7000 -o tetris.cas tetris.bin
xroar --run tetris.cas

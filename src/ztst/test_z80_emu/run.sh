#!/bin/bash

./main --zx ../z80test/src/z80ccf.out      >z80ccf.log
#./main --zx ../z80test/src/z80ccfscr.out   >z80ccfscr.log
./main --zx ../z80test/src/z80docflags.out >z80docflags.log
./main --zx ../z80test/src/z80doc.out      >z80doc.log
./main --zx ../z80test/src/z80flags.out    >z80flags.log
./main --zx ../z80test/src/z80full.out     >z80full.log
./main --zx ../z80test/src/z80memptr.out   >z80memptr.log


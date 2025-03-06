#!/bin/bash

./main --nedoos ../z80test/z80ccf.com      >z80ccf.log
./main --nedoos ../z80test/z80docflags.com >z80docflags.log
./main --nedoos ../z80test/z80doc.com      >z80doc.log
./main --nedoos ../z80test/z80flags.com    >z80flags.log
./main --nedoos ../z80test/z80full.com     >z80full.log
./main --nedoos ../z80test/z80memptr.com   >z80memptr.log


mbgen - Plan JT helper (standalone)
===================================

Build (separate from multibank.com):
  tools\build.bat
  -> tools\mbgen.exe

Run GUI:
  mbgen.exe

CLI:
  mbgen.exe --scan codebank_02.c
  mbgen.exe --apply codebank_02.c bank_jt2.asm bank_jt.h bank_call.c mb_req.h 1

What it does
------------
Scans codebank_XX.c for non-static functions (skip `static`).
For each new export:
  r_foo  ->  define MB_JT_FOO, wrapper mb_foo() with MB_BANK_SAVE/ENTER/LEAVE,
             EXTERN/JP in THAT bank's JT asm, prototype in mb_req.h

Per-bank JT (important):
  codebank_01.c  ->  bank_jt.asm
  codebank_02.c  ->  bank_jt2.asm
  codebank_03.c  ->  bank_jt3.asm
GUI Autofill / codebank path change picks the matching JT file.
Never put bank02 exports into bank_jt.asm (breaks ovl01 link).

Already present names are skipped (idempotent).
Bank page index: from codebank_NN filename (NN-1) or manual.
Next JT slot = JP count in the selected bank_jtN.asm only.

App .com name can be anything; banking files stay
codebank_XX.c / bank_jt* / bank_call.c / mb_*.

See ../banking.txt for SAVE/LEAVE overrides and full checklist.

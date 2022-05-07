;
;65C02 emulator on a Z80
;by James Smith (UK), 2008
;
        DEVICE ZXSPECTRUM1024
        include "../_sdk/sys_h.asm"

;UNEXPANDED VIC20

;section below defines macros

;V1.01 - 2T off decoding loop and 4T off BRAnch instructions.
;V1.02 - 4T off ZP,X ; ZP,Y code
;V1.03 - fixed JSR (a,X) instruction. 11T off INX/DEX/INY/DEY instructions 
;V1.04 - fixed PLP (Z flag lost). Modified TRB (CPL before AND now)
;v1.05 - redesigned ADC and SBC instructions to cope with BCD more quickly
;v1.06 - UK101 related
;v1.10 - improved 6502 core - using half of DR BEEP method
;v1.11 - UK101 related
;v1.12 - better way of setting Z flag - improved TRB,TSB,BIT and PHP instructions
;v1.13 - better way of setting V flag - improved ADC,SBC instructions
;v1.14 - fixed (indirect,X) addressing mode - missed out LD L,A after ADD A,L instruction
;v1.15 - 3T off BVC instruction. Improved keyscan routine - quicker and supports CTRL+C
;v1.16 - 7T off absolute,X ; abs,Y ; (ind),Y routines
;v1.17 - 4T off (indirect,X). Fix from v1.14 has been optimised.
;v1.18 - UK101 related
;v1.19 - 2T off PHP, 12T off RTI, 13T off PLP instructions
;v1.20 - 4T off abs,X ; abs,Y ; (ind),Y routines
;v1.21 - bug fixed in new PHP. 4T off (indirect,X). Illegal opcodes reduced to 3 bytes long
;v1.22 - branch instructions recoded. 7T/10T off each instruction
;v1.23 - 7T off JSR, 2T off BRK instructions
;v1.24 - UK101 related
;v1.25 - change refs from vYreg to IYH - effectively a test to see if it works
;v1.26 - change refs from vXreg to IYL. 4T off LDX/LDY instructions

;v1.41 - implemented $9120 (write), keyboard routines. Fixed bug in row 16+ of screendraw
;v1.42 - implemented F1/3/5/7 keys, cursor keys, RUNSTOP, left arrow, VIC table, Column width register
;	 however cursor keys now stop normal SHIFT+5 to +8 which means you can't do '(' !
;V1.43 - 3K expanded RAM added. Charmap made read only now.
;v1.44 - 4T off TSX and TXS. Changes to code to make it more address independent.
;v1.45 - NMI implemented. Pound sign key defined. Charset pointer ($9005) implemented. Cursor keys removed.
;	 tried to implement VIA1 IFR and IER - still no RUN/STOP+RESTORE break key.
;V1.50 - New memory maps specified - 8K VIC RAM now contiguous. Assembly less sensitive on location address
;v1.51 - New way of accessing VIC/VIA I/O addresses
;v1.52 - Fixed JR error in TRB,TSB. 2T off PLP, 4T off PHP instructions. Removed need for FFpage constant.
;v1.53 - Row depth register implemented. False border implemented to give indication of VIC screen size.
;v1.54 - Colour RAM implemented. Invert screen bit and background colour of $900F now implemented.
;v1.55 - redesigned colour ram/invert implementation. Now trap updates to colour ram and update colours
;	 seperately from screen ram. Invert now done in ATTR stage rather than screen ram stage.
;	 RUN/STOP+RESTORE now works as $912F and $911F are write mirrors of $9121 and $9111 and need to work.
;v1.56 - put bright colours into colour mapping table. Supported wraparound when chargen points to 7168
;	 (codes 128+ wrap into ROM at $8000). Fixed bug in $9003 routine. Changed SUB $CE to SUB colourram.
;v1.57 - change to background colour now forces whole screen attr refresh. Unneeded SUB $F0 removed from $9005
;v1.58 - added support for joystick (via Kempston). $9003 routine modified to refresh screen when row depth
;	 changed. Attribute refresh routines also take into account row depth now (didn't before). All access
;	 for reading to VIA/VIC is via a jump table
;v1.59 - 10T off write traps and a further 11T off screenwrite. RUN/STOP key implemented.
;	 Discovered that v1.58/9 are slower as VIC is always checking VIA1 911F (tape sense in IRQ routine - $EAEF)
;v1.60 - another core change. This time to memory read/write routines. 4T off each memory read/write (not M1 fetch)
;	 also some changes to I/O routines as they have to set H on exit rather than A. FFrealpage re-implemented.
;V1.61 - Psuedo double-height chars routine implemented. Right joystick routine fixed.
;	 9T off VICout routine as quicker method than PUSH BC/POP IX is used
;	 Rowtable used in screenwrite routine - over 10T quicker now
;	 Minor speed improvements in ATTR and VICout routines.
;v1.62 - Improvements to double-height routine made. Screenwrite DJNZ loop expanded out for increased speed.
;	 $9004 (and $9003 bit 7) raster counter implemented. Implemented CBM key (SYM+C)
;v1.63 - Implemented SOUND ($900A-$900D). VIA T1 lsb emulated for randomness by using Z80 R register
;v1.64 - Improved reset routine to reset VIC display. Fixed JR bug in $900F routine.
;	 3T off RAMread_trap routine. Stopped VICborder from going bright.
;v1.65 - 6T off CLI/SEI/CLD/SED. Speed improvements in VIAout, VIA2B, rVICsoundA/B/C. Fixed bug in RAMread_trap
;	 causing character set changes to fail.
;v1.66 - Faster attr4 routine. Added SYM+6 for CURSOR DOWN and SYM+8 for CURSOR RIGHT. SYM+4 is HOME.
;v1.67 - Fault in paging tables. Unallocated memory should point to $02 not $00 - otherwise it corrupts
;	 page $FF (top of Kernal ROM). Also fixed character ROM pointers. RAMread_trap faster as IOread will never
;	 straddle 2 pages, so safe to use 8-bit arithmetic.
;v1.68 - Major fault in Writescreen fixed! When non-double height chars were in use, IX wasn't being reset back to
;	 normal effectively causing the routine to be run twice. LISTing a BASIC program is now 20% quicker!! Also
;	 changed limits of column width to 31 columns (was 27). EI at start relocated after 6502 has been initialised.
;v1.69 - assembly listing tidied up. Routines re-organised (couldn't make it 256 bytes shorter). Other tables moved
;	 in memory to fit. All tables moved to end of code for easier changing in the future. refreshattr, NMI and
; 	 IRQ routines modified to be position independent. Slightly faster NMI and IRQ routines.
;v1.70 - Core change. The addressing modes which fetch 2 bytes after opcode (eg: absolute,X) were translating DE twice.
;	 Now DE is only retranslated if page boundary is crossed via the nextbyte2 routine. JSR + JMP also changed.
;v1.71 - Further core changes. Now nextbyte has also been changed. Unfortunately the main decode loop is 4T slower as
;	 the translated address msb needs to be stored for use by nextbyte.
;v1.72 - 32T off PLP! 3T off BVC and BVS instructions. BIT #imm fixed as it should only modify Z flag. Attr5/6 modified
;	 to handle BRIGHT bit correctly. VIC9002 modified to support colourRAM at either $9400 or $9600.
;v1.73 - Flaw in PLP fixed, but now it's only -15T off. JMP (addr) changed to use correct macros (readtrap). Core changes
;	 of 1.70 and 1.71 have been changed. Getting the opcode and following byte or two should be treat as "M1"
;	 fetches. These aren't trapped only translated, so the code therefore never needs to CALL RAMread_trap. The main
;	 decoding loop is 4T faster (back to how it was).
;v1.74 - Back to v1.72 core, but with revised m1trap routine.
;v1.75 - Back to v1.73 core but with revised "nextbyte2" macro and faster m1trap routine. Fix for ROL A and ROR A.
;v1.76 - Re-org of 6502 routines - 768 bytes shorter. Fixes for JMP (A,X) and BRK included.
;v1.77 - Keyboard scan routine modified to exit quickly if no keys are pressed and other minor speed improvements.
;v1.80 - core verification with C64 utilities. Changes : 1) PLP forces bit 5 to 1. 2) PHP/BRK force B flag set during
;	 push. D mode can now be set via PLP.
;v1.81 - speed improvements to BCS/CC/PL/MI/VS/VC/EQ/NE as full nextbyte macro is only needed when branch is required.
;	 22T saved when condition isn't met.
;v1.82 - Speed up for Ind,Y; abs,X and abs,Y instructions. Improvement to ADC.
;	 Changed RETI to RET in interrupt routine. Better 'illegal' routines.
;v1.83 - Improvements to graphics routines.  Faster attr routines as coltrans table is page aligned. Screen now
;	 allowed to be 24 rows high. Screen memory now allowed to be moved, enabling expanded memory support.
;v1.86 - At least 10T off PHP, 2T off PLP. SP moved to non-contended RAM. Attr5/6 shorter and faster. RAMtrap moved
;	 into screenwrite routine saving 6T when writing to screen. Changes to bit 7 of $9002 now force screen
;	 memory to be recalculated - this fixes many bugs.
;v1.87 - 3T off RTI. 4T off PLP (except when using RTI). Rewritten joystick routines. Writescreen 8/16 row code (got rid
;	 of jp to enddisplay2 and row counting code optimised - use ADD instead of SBC). Several VIC routines also
;	 changed to cope with this.
;v1.88 - speed up in attr4
;v1.89 - fixed PLP (4T slower). RTI -6T. ADD and SBC ops are shorter and 3T faster when overflow set. Rewritten sound
;	 routines. BRK 3T quicker, 1 byte shorter.
;v1.90 - routines modified to use real AF for 6502 A and F registers. AF' used by Z80 routines. Imm + ZP modes don't
;	 corrupt Z80 A-reg or flags. TSB/TRB/BIT recoded. Bug in screenshow when rows (9003)=0 fixed. VIA/VIC
;	 trap code quicker. NMI/IRQ code changed. Various memory sizes implemented.

;#define DEFB .BYTE
;#define DW .WORD
;#define DEFM .TEXT
;#define ORG  .ORG
;#define EQU  .EQU
;#define equ  .EQU
;#define DB   .BYTE
;#define db   .BYTE

base		EQU $B400	;THIS IS +512 FROM WHERE CODE STARTS!!

ZPrealpage	EQU $80
SPrealpage	EQU $81
FFrealpage	EQU $7F
chargen		EQU $A000
ScreenPage	EQU $9E
colourram	EQU $B0
;page 1 must ALWAYS be after page 0!

M1page		EQU (base+$2900)/256	;was $DB
MRpage		EQU (base+$2A00)/256	;was $DC ;read readdressing+1 for every HSB
MWpage		EQU (base+$2B00)/256	;was $DD ;write readdressing+1 for every HSB
Oppage		EQU (base+$2800)/256	;was $DA
IM2page		EQU (base+$2600)/256	;was $D8
Safepage	EQU base+$1800
        ;display "end=",end

;all opcode routine addresses need to be
;defined before trying to assemble it
;otherwise the ORG base+x instructions won't make much sense

OP0	EQU base+$0	;len=57
OP1	EQU base+$1701	;len=42
OP2	EQU base+$1602	;len=3
OP3	EQU base+$1503	;len=3
OP4	EQU base+$1404	;len=22
OP5	EQU base+$1605	;len=20
OP6	EQU base+$1506	;len=17
OP7	EQU base+$1307	;len=3
OP8	EQU base+$1208	;len=29
OP9	EQU base+$1109	;len=17
OP10	EQU base+$130A	;len=8
OP11	EQU base+$100B	;len=3
OP12	EQU base+$F0C	;len=37
OP13	EQU base+$E0D	;len=35
OP14	EQU base+$100E	;len=32
OP15	EQU base+$D0F	;len=3
OP16	EQU base+$C10	;len=21
OP17	EQU base+$B11	;len=39
OP18	EQU base+$1312	;len=34
OP19	EQU base+$D13	;len=3
OP20	EQU base+$A14	;len=23
OP21	EQU base+$915	;len=25
OP22	EQU base+$D16	;len=22
OP23	EQU base+$1517	;len=3
OP24	EQU base+$818	;len=5
OP25	EQU base+$1619	;len=41
OP26	EQU base+$151A	;len=7
OP27	EQU base+$141B	;len=3
OP28	EQU base+$111C	;len=38
OP29	EQU base+$81D	;len=41
OP30	EQU base+$141E	;len=38
OP31	EQU base+$71F	;len=3
OP32	EQU base+$620	;len=29
OP33	EQU base+$1521	;len=42
OP34	EQU base+$722	;len=3
OP35	EQU base+$523	;len=3
OP36	EQU base+$424	;len=32
OP37	EQU base+$1225	;len=20
OP38	EQU base+$C26	;len=17
OP39	EQU base+$727	;len=3
OP40	EQU base+$528	;len=49
OP41	EQU base+$329	;len=17
OP42	EQU base+$72A	;len=7
OP43	EQU base+$172B	;len=3
OP44	EQU base+$D2C	;len=47
OP45	EQU base+$A2D	;len=35
OP46	EQU base+$172E	;len=32
OP47	EQU base+$102F	;len=3
OP48	EQU base+$E30	;len=21
OP49	EQU base+$F31	;len=39
OP50	EQU base+$1032	;len=34
OP51	EQU base+$933	;len=3
OP52	EQU base+$1334	;len=37
OP53	EQU base+$735	;len=25
OP54	EQU base+$936	;len=22
OP55	EQU base+$C37	;len=3
OP56	EQU base+$B38	;len=4
OP57	EQU base+$1239	;len=41
OP58	EQU base+$C3A	;len=7
OP59	EQU base+$33B	;len=3
OP60	EQU base+$B3C	;len=53
OP61	EQU base+$63D	;len=41
OP62	EQU base+$33E	;len=38
OP63	EQU base+$23F	;len=3
OP64	EQU base+$140	;len=16
OP65	EQU base+$C41	;len=45
OP66	EQU base+$1642	;len=3
OP67	EQU base+$1143	;len=3
OP68	EQU base+$1444	;len=3
OP69	EQU base+$1645	;len=20
OP70	EQU base+$1146	;len=17
OP71	EQU base+$1447	;len=3
OP72	EQU base+$E48	;len=9
OP73	EQU base+$849	;len=17
OP74	EQU base+$44A	;len=8
OP75	EQU base+$154B	;len=3
OP76	EQU base+$94C	;len=17
OP77	EQU base+$24D	;len=35
OP78	EQU base+$174E	;len=32
OP79	EQU base+$154F	;len=3
OP80	EQU base+$A50	;len=24
OP81	EQU base+$E51	;len=39
OP82	EQU base+$1552	;len=37
OP83	EQU base+$753	;len=3
OP84	EQU base+$1054	;len=3
OP85	EQU base+$455	;len=25
OP86	EQU base+$756	;len=22
OP87	EQU base+$1157	;len=3
OP88	EQU base+$1058	;len=8
OP89	EQU base+$1659	;len=41
OP90	EQU base+$135A	;len=17
OP91	EQU base+$115B	;len=3
OP92	EQU base+$F5C	;len=3
OP93	EQU base+$D5D	;len=41
OP94	EQU base+$115E	;len=38
OP95	EQU base+$F5F	;len=3
OP96	EQU base+$1060	;len=15
OP97	EQU base+$961	;len=37
OP98	EQU base+$1262	;len=3
OP99	EQU base+$F63	;len=3
OP100	EQU base+$864	;len=14
OP101	EQU base+$1265	;len=15
OP102	EQU base+$F66	;len=17
OP103	EQU base+$667	;len=3
OP104	EQU base+$A68	;len=9
OP105	EQU base+$569	;len=24
OP106	EQU base+$66A	;len=8
OP107	EQU base+$136B	;len=3
OP108	EQU base+$76C	;len=42
OP109	EQU base+$36D	;len=30
OP110	EQU base+$176E	;len=32
OP111	EQU base+$136F	;len=3
OP112	EQU base+$1070	;len=24
OP113	EQU base+$C71	;len=34
OP114	EQU base+$1372	;len=29
OP115	EQU base+$B73	;len=3
OP116	EQU base+$1274	;len=19
OP117	EQU base+$A75	;len=20
OP118	EQU base+$B76	;len=22
OP119	EQU base+$1577	;len=3
OP120	EQU base+$1478	;len=8
OP121	EQU base+$F79	;len=36
OP122	EQU base+$157A	;len=17
OP123	EQU base+$E7B	;len=3
OP124	EQU base+$87C	;len=39
OP125	EQU base+$67D	;len=36
OP126	EQU base+$E7E	;len=38
OP127	EQU base+$47F	;len=3
OP128	EQU base+$280	;len=18
OP129	EQU base+$581	;len=35
OP130	EQU base+$1682	;len=3
OP131	EQU base+$1483	;len=3
OP132	EQU base+$1184	;len=15
OP133	EQU base+$1685	;len=13
OP134	EQU base+$D86	;len=18
OP135	EQU base+$1487	;len=3
OP136	EQU base+$1288	;len=5
OP137	EQU base+$1089	;len=18
OP138	EQU base+$A8A	;len=10
OP139	EQU base+$158B	;len=3
OP140	EQU base+$B8C	;len=30
OP141	EQU base+$128D	;len=28
OP142	EQU base+$178E	;len=33
OP143	EQU base+$158F	;len=3
OP144	EQU base+$1390	;len=20
OP145	EQU base+$991	;len=32
OP146	EQU base+$1692	;len=27
OP147	EQU base+$1593	;len=3
OP148	EQU base+$1194	;len=20
OP149	EQU base+$C95	;len=18
OP150	EQU base+$1596	;len=23
OP151	EQU base+$A97	;len=3
OP152	EQU base+$D98	;len=7
OP153	EQU base+$799	;len=34
OP154	EQU base+$A9A	;len=10
OP155	EQU base+$109B	;len=3
OP156	EQU base+$49C	;len=29
OP157	EQU base+$F9D	;len=34
OP158	EQU base+$109E	;len=38
OP159	EQU base+$D9F	;len=3
OP160	EQU base+$3A0	;len=14
OP161	EQU base+$6A1	;len=31
OP162	EQU base+$DA2	;len=17
OP163	EQU base+$8A3	;len=3
OP164	EQU base+$13A4	;len=17
OP165	EQU base+$EA5	;len=15
OP166	EQU base+$AA6	;len=20
OP167	EQU base+$CA7	;len=3
OP168	EQU base+$11A8	;len=7
OP169	EQU base+$12A9	;len=12
OP170	EQU base+$CAA	;len=10
OP171	EQU base+$BAB	;len=3
OP172	EQU base+$5AC	;len=32
OP173	EQU base+$16AD	;len=30
OP174	EQU base+$15AE	;len=35
OP175	EQU base+$17AF	;len=3
OP176	EQU base+$11B0	;len=20
OP177	EQU base+$BB1	;len=34
OP178	EQU base+$17B2	;len=31
OP179	EQU base+$DB3	;len=3
OP180	EQU base+$EB4	;len=22
OP181	EQU base+$13B5	;len=20
OP182	EQU base+$12B6	;len=25
OP183	EQU base+$DB7	;len=3
OP184	EQU base+$CB8	;len=8
OP185	EQU base+$9B9	;len=36
OP186	EQU base+$DBA	;len=12
OP187	EQU base+$ABB	;len=3
OP188	EQU base+$7BC	;len=38
OP189	EQU base+$4BD	;len=36
OP190	EQU base+$ABE	;len=41
OP191	EQU base+$FBF	;len=3
OP192	EQU base+$CC0	;len=15
OP193	EQU base+$6C1	;len=33
OP194	EQU base+$FC2	;len=3
OP195	EQU base+$3C3	;len=16
OP196	EQU base+$11C4	;len=18
OP197	EQU base+$10C5	;len=14
OP198	EQU base+$FC6	;len=16
OP199	EQU base+$DC7	;len=3
OP200	EQU base+$14C8	;len=5
OP201	EQU base+$13C9	;len=11
OP202	EQU base+$ECA	;len=5
OP203	EQU base+$16CB	;len=3
OP204	EQU base+$DCC	;len=33
OP205	EQU base+$14CD	;len=29
OP206	EQU base+$16CE	;len=31
OP207	EQU base+$12CF	;len=3
OP208	EQU base+$ED0	;len=20
OP209	EQU base+$17D1	;len=33
OP210	EQU base+$15D2	;len=31
OP211	EQU base+$12D3	;len=3
OP212	EQU base+$13D4	;len=3
OP213	EQU base+$10D5	;len=19
OP214	EQU base+$12D6	;len=21
OP215	EQU base+$13D7	;len=3
OP216	EQU base+$11D8	;len=18
OP217	EQU base+$FD9	;len=35
OP218	EQU base+$13DA	;len=11
OP219	EQU base+$CDB	;len=6
OP220	EQU base+$BDC	;len=3
OP221	EQU base+$9DD	;len=35
OP222	EQU base+$8DE	;len=37
OP223	EQU base+$BDF	;len=3
OP224	EQU base+$5E0	;len=15
OP225	EQU base+$CE1	;len=37
OP226	EQU base+$BE2	;len=3
OP227	EQU base+$7E3	;len=3
OP228	EQU base+$EE4	;len=18
OP229	EQU base+$13E5	;len=15
OP230	EQU base+$BE6	;len=16
OP231	EQU base+$AE7	;len=3
OP232	EQU base+$10E8	;len=5
OP233	EQU base+$7E9	;len=26
OP234	EQU base+$14EA	;len=6
OP235	EQU base+$12EB	;len=3
OP236	EQU base+$AEC	;len=33
OP237	EQU base+$DED	;len=30
OP238	EQU base+$6EE	;len=31
OP239	EQU base+$16EF	;len=3
OP240	EQU base+$12F0	;len=20
OP241	EQU base+$5F1	;len=34
OP242	EQU base+$4F2	;len=32
OP243	EQU base+$17F3	;len=3
OP244	EQU base+$16F4	;len=3
OP245	EQU base+$10F5	;len=20
OP246	EQU base+$EF6	;len=21
OP247	EQU base+$17F7	;len=3
OP248	EQU base+$BF8	;len=18
OP249	EQU base+$3F9	;len=36
OP250	EQU base+$2FA	;len=20
OP251	EQU base+$17FB	;len=3
OP252	EQU base+$16FC	;len=3
OP253	EQU base+$1FD	;len=36
OP254	EQU base+$FE	;len=37
OP255	EQU base+$15FF	;len=3


;A in A'
;N,C and Z of flags in F'
;B,D and I flags in (vXflag)
;V in (vVflag)
;X in IYL
;Y in IYH
;S (stack) in E', D' will always contain SPrealpage as a constant
;PC in DE

;IX contains address of op_decode to do a fast jump to it (JP (IX) takes 8T)

        org PROGSTART
begin
        ld e,3+0x80 ;6912+keep
        ;ld e,0+0x80 ;EGA+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ;call setgfx

        ld e,0 ;color byte
        OS_CLS

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000 
        ld a,e
        ;ld (pgmain4000),a
        ld a,h
        ;ld (pgmain8000),a
        ld a,l
        ;ld (pgspr),a  

        ld a,(user_scr0_high) ;ok
        SETPG4000

        ld hl,wasbasicrom
        ld de,0xe000
        ld bc,0x2000
        ldir
        ld hl,waskernalrom
        ld de,0x6000
        ld bc,0x2000
        ldir
        ld hl,wasloadfile
        ld de,loadfile
        ld bc,loadfile_sz
        ldir

        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr z,noautoload
;command line = bk <file to load>"
       ld (filenameaddr),hl
       ;jr autoloadq
       
noautoload
;autoloadq
        jp GO

wasloadfile
        disp 0x5b00
loadfile
        im 1
        push af
        push bc
        push de
        push hl
        push ix
        push iy
        exx
        ex af,af' ;'
        push af
        push bc
        push de
        push hl
filenameaddr=$+1
        ld de,0
        
      ld hl,(0x7ffe)
      push hl
;de=filename
        OS_OPENHANDLE
        push bc
        ld de,0x7ffe
        ld hl,0x2002
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE
      pop hl
      ld (0x7ffe),hl
        pop hl
        pop de
        pop bc
        pop af
        ex af,af' ;'
        exx
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        im 2
        ret
        ent
loadfile_sz=$-wasloadfile

skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

wasbasicrom
        incbin "vic20.rom"

        org 0x8000 ;will be 8k RAM
waskernalrom
        incbin "vic20a.rom"
        org 0xa000
        incbin "vic20f.rom"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ORG base-$0200
GO
	DI		;as we're messing with IX/IY disable interrupts!

			;6502 gets contents of
			;?FFFC and ?FFFD
			;and jumps to their contents
	LD SP,base-$20	;for some reason TIMEX machines have silly values for SP!
	LD A,IM2page
	LD I,A
	IM 2		;we want to trap interrupts so we can simulate 6502 IRQ

	LD A,$05
	LD BC,$1FFD
	NOP		;these bytes can be changed to OUT (C),A
	NOP

superinit:
	LD BC,$FFFD	;now port $FFFD
	LD A,$07
	OUT (C),A	;select mixer control (R7)
	LD A,B		;A=255 = all silent
	LD B,$BF	;port BFFD now
	OUT (C),A	;select tone only on channels A,B and C

reset:
	LD HL,(FFrealpage*256)+$FC
			;HL points to RESET vector on virtual machine
	LD E,(HL)
	INC HL
	LD D,(HL)	;DE now contains correct PC value
	EXX
	LD DE,$0000
	PUSH DE		;used to set AF' later
	LD D,SPrealpage
	DEC E		;change E from 0 to FF, so SP starts at 01FF
	EXX
	LD HL,vXflag
	LD (HL),$34	;on reset 6502 sets bit 5 (undef), 4 (brk), 2 (irq)
			;and resets bit 3 (dec). The rest are undefined
	DEC HL
	LD (HL),$00
	LD HL,VIC900F
	INC (HL)	;force a change in background colour - forces graphics to redraw screen
		
	LD IY,$0000	;X/Y to 0
	LD HL,trapback2here
	POP AF		;set A and flags to 0
	
	PUSH HL		;preload stack with right address
	DEC DE		;dec PC by 1 to compensate for CLD increasing it
	EI		;safe to enable interrupts now
	LD IX,rVIC900F	;need to reset display after sorting out BCD mode
	JP cld		;make sure ADC/SBC are correct
			;it will JP (IX) into rVIC900F which will sort the screen out
			;and will reset IX to op_decode

vVflag:
	DB $00
vXflag:
	DB $00

vtemp:
	DW $00


m1wrap:
;INC E has caused PC to wrap to next page
;therefore we have to re-translate DE

	INC D		;next page
	LD L,D
	LD H,M1page
	LD H,(HL)	;translated address in HL once LD L,E done
			;but that's done outside m1wrap routine
	RET


;increments PC by one
;used after most instructions
        macro incPC
        INC DE
	JP (IX)
        endm

        macro nextbyte
        INC DE
	LD L,D
	LD H,M1page
	LD H,(HL)
	LD L,E
        endm

;start with AF flags paged in
;end with them paged out
        macro opPHP
        LD HL,(vVflag)
	JR NZ,$+4
	SET 1,H
	JR NC,$+4
	SET 0,H
	JP P,$+5
	SET 7,H
	EX AF,AF' ;'
	LD A,H
	OR L
        endm
;L contains I,D,5 and B flags to be added
;notice that A is NOT PUSHED onto the stack!
;EX AF,AF' must also be done outside macro
;this MUST be done outside the macro
;(this is because BRK and IRQ have different requirements for B flag)

;pushes value in A on 6502 stack
;best to do this with AF paged out to preserve 6502/Z80 flags
        macro do_pushA
        EXX
	LD (DE),A
	DEC E
	EXX
        endm



; "illegal" opcodes come here

illegal3:
	INC DE		;skip 3 bytes
illegal2:
	INC DE		;skip 2 bytes
illegal:
	EX AF,AF' ;'
	LD A,$02
	OUT ($FE),A	;make border red for now
	EX AF,AF' ;'
	incPC		;skip just one byte


nmi_handler:
	LD HL,(M1page*256)+$26	;LD H,$M1page instead of JR $-4
				;$26 is opcode for LD H,nn
	LD (op_decode+1),HL	;reset 2 bytes to what they normally are

         call loadfile ;FIXME!

;PC (DE) is already correct at this point - so stack it

	EX AF,AF' ;'
	LD A,D
	do_pushA
	LD A,E
	do_pushA
	LD HL,(FFrealpage*256)+$FA	;pre-validated page 255 value used
			;to get true NMI address
	LD E,(HL)
	INC L		;safe to do as we know HL has to be FFFA - therfore validated page still valid
			;also L will never overflow so quicker to do INC L than INC HL
	LD D,(HL)	;DE (PC) now contains  vector

	EX AF,AF' ;'
	opPHP		;prepare flags in A to be stacked
;correct flags are in A
	AND $EF		;force B bit clear (like IRQ)
	do_pushA	;stack flags

	LD HL,vXflag
	LD A,(HL)
	AND $E3		;clear bits 4,3 and 2
	OR $14		;have to set bit 2 (I)	
	LD (HL),A
	EX AF,AF' ;'
	JP (IX)		;no incPC as DE (PC) is already correct

signalNMI:
;currently an IRQ could override an NMI which is wrong!

	LD HL,$18+(irqND*256)
				;force interrupt to be serviced once
				;current 6502 instruction has finished
	LD (op_decode+1),HL	;overwrite with JR irqN instruction
	RET			;eventually code will get to nmi_handler


;this is the main opcode decoding routine
;every 6502 instruction starts at op_decode.

irqN:	JP nmi_handler
irqM:	JP irq_handler

op_decode:
	LD L,D
	LD H,M1page	;interrupts will overwrite this byte pair with a JR to irqM or irqN instruction
			;Remember - trapped I/O will alter IX, interrupts alter code.
			;(otherwise you can lose I/O or IRQ depending on order they happen)
			;This instruction is changed rather than first instruction as
			;2 bytes have to be changed and Z80 IRQ could occur in between the 2
			;instructions causing the Z80 to interpret the LD H,M1page as something
			;completely different

;remember DE contains the 6502 program counter
;we're now "translating" a 6502 page to a ZX Spectrum page
;ie: address $1000 (page $10) on the VIC translates into address $9000 (page $90) on the Spectrum
;see the M1 page table near the end of the code

	LD H,(HL)
	LD L,E		;HL now contains translated address

;now HL contains a translated address we need to get the opcode at that address

	LD L,(HL)

;and work out address of routine to call

	LD H,Oppage
	LD H,(HL)

;each 6502 routine starts at an address where it's lsb = opcode value
;ie: RTS = opcode $60, so you'll find the RTS routine begins at $xx60

	JP (HL)		;47T just to decode the opcode!
			;you can see the virtual 6502 is going to be a lot slower than the real thing!
			;adding INC DE and JP (IX) brings it up to 61T
			;therefore the shortest 6502 instruction (NOP) takes 61T to run
			;which gives 0.057 MIPS on a real Spectrum!
			;the real 6502 @1 MHz could do 0.5 MIPS - we are therefore nearly 9 times slower
			;in reality it is more like x15 times slower


irqND	EQU 256-(op_decode+3-irqN)	;calculate JR displacements for self modifying-code
irqMD	EQU 256-(op_decode+3-irqM)

trapback2here:
;TRAPS will come back here
;traps are currently not used in this VIC 20 implmentation of 6502 core

	LD A,$04
	OUT ($FE),A
	DI
	HALT

;use this macro for BRAnch instructions (they don't have the INC DE bit)
        macro nextbyteB
        LD L,D
	LD H,M1page
	LD H,(HL)
	LD L,E
        endm

;use this macro when HL still contains validated address of DE
;#define nextbyte2		INC E
;#defcont		\	CALL Z,m1wrap
;#defcont		\	LD L,E

        macro nextbyte2
        INC DE
	LD L,D
	LD H,M1page
	LD H,(HL)
	LD L,E
        endm

;L(msb) and C(lsb) must be correct before using macro
        macro readtrap
	LD H,MRpage
	LD H,(HL)
	DEC H
	CALL Z,RAMread_trap
	LD L,C
        endm

;L(msb) and C(lsb) must be correct before using macro
        macro writetrap
	LD H,MWpage
	LD H,(HL)
	DEC H
	CALL Z,RAMwrite_trap
	LD L,C
        endm

;zero page
;a1=?PC
;d=?a1	(where a1 msb=00)
        macro getZP_read
        nextbyte
	LD L,(HL)
	LD H,ZPrealpage
        endm

;zero page,X
;a1=?PC
;d=?(a1+X)	(where a1 msb=00)
        macro getZPX_read
        nextbyte
	DB $FD
	LD A,L
 	ADD A,(HL)
	LD L,A
	LD H,ZPrealpage
        endm

;zero page,Y
;a1=?PC
;d=?(a1+Y)	(where a1 msb=00)
        macro getZPY_read
        nextbyte
	DB $FD
	LD A,H
 	ADD A,(HL)
	LD L,A
	LD H,ZPrealpage
        endm

;(indirect zero page)
;a1=?PC
;a2=?a1+256*?(a1+1)
;d=?a2
        macro get_ZP_read
	nextbyte
	LD L,(HL)
	LD H,ZPrealpage
	LD C,(HL)
	INC HL
	LD L,(HL)
;new address in HL (well it would be if LD H,(HL) was done instead along with LD L,C being added)
;but we need to validate this new address and that only needs msb
	readtrap
        endm

;absolute_read
;a1=?PC+256*?(PC+1)
;d=?a1
        macro getabsolute_read
        nextbyte
	LD C,(HL)
	nextbyte2
	LD L,(HL)
	readtrap
        endm

;absolute_RWM
;a1=?PC+256*?(PC+1)
;d=?a1
        macro getabsolute_RWM
        nextbyte
	LD C,(HL)
	nextbyte2
	LD B,(HL)
	PUSH BC
	LD L,B
	writetrap		//this sets IX
	POP BC
	LD L,B
	readtrap
        endm

;absolute_read,X
;a1=?PC+256*?(PC+1)
;a2=a1+X
;d=?a2
        macro getabsoluteX_read
	nextbyte
	LD A,(HL)
	DB $FD
	ADD A,L
	LD C,A
;correct lo-byte stored in C for use later
	nextbyte2
;BC would contains new absolute_read address, but we haven't set B yet - it's at (HL)
;now add X to it
;C,A and CFlag not affected by nextbyte(2)
	LD A,$00
	ADC A,(HL)
;would've been ADC A,B - but quicker to use ADC A,(HL) and ditch earlier LD B,(HL)
;need to add carry in case C+X overflowed from earlier
;thus the value in A is the correct hi-byte.
	LD L,A
;however the validation routine requires hi-byte in L
	readtrap
        endm

;absolute_read,Y
;a1=?PC+256*?(PC+1)
;a2=a1+Y
;d=?a2
        macro getabsoluteY_read
        nextbyte
	LD A,(HL)
	DB $FD
	ADD A,H
	LD C,A
;correct lo-byte stored in C for use later
	nextbyte2
	LD A,$00
	ADC A,(HL)
	LD L,A
	readtrap
        endm

;(indirect,X)
;a=(?PC)+X where msb=00
;a2=?a+256*?(a+1)
;d=?a2
        macro indirectX_read
        nextbyte
	DB $FD
	LD A,L
	ADD A,(HL)
	LD L,A
	LD H,ZPrealpage
;validated address in HL. We've used ADD A,L because address at this point is always page 0
	LD C,(HL)
	INC HL
;address is always validated because page 1 always follows page 0, and HL is 0-$FF
	LD L,(HL)
;validate new address (a2)
	readtrap
        endm

;(indirect),Y
;a=?PC
;a2=?a+256*?(a+1)
;a3=a2+Y
;d=?a3
        macro indirectY_read
        nextbyte
	LD L,(HL)
;we know H=0 at this point (zero page), so validate it using ZPrealpage constant
	LD H,ZPrealpage
	LD A,(HL)
	INC HL
;even if HL goes from FF to 00 (ie: into Page 1), the validated page 1 address is always +1 of validated page 0 address
;BC would contain new pointer - just got to add Y to it. B is still at (HL) and C is in A
	DB $FD
	ADD A,H
	LD C,A
;store lo-byte of result in C for later
	LD A,$00
	ADC A,(HL)
;would've been ADC A,B - but quicker to use ADC A,(HL) and ditch earlier LD B,(HL)
;need to add carry in case C+Y overflowed earlier
;this is hi-byte of result, but validation routine requires
;hi-byte in L so instead of saving in H we save in L
	LD L,A
	readtrap
        endm

;*** WRITE to memory versions***

;zero page
;a1=?PC
;d=?a1	(where a1 msb=00)
        macro getZP_write
        nextbyte
	LD L,(HL)
	LD H,ZPrealpage
        endm

;zero page,X
;a1=?PC
;d=?(a1+X)	(where a1 msb=00)
        macro getZPX_write
        nextbyte
	DB $FD
	LD A,L
	ADD A,(HL)
	LD L,A
	LD H,ZPrealpage
        endm

;zero page,Y
;a1=?PC
;d=?(a1+Y)	(where a1 msb=00)
        macro getZPY_write
        nextbyte
	DB $FD
	LD A,H
	ADD A,(HL)
	LD L,A
	LD H,ZPrealpage
        endm

;(indirect zero page)
;a1=?PC
;a2=?a1+256*?(a1+1)
;d=?a2
        macro get_ZP_write
        nextbyte
	LD L,(HL)
	LD H,ZPrealpage
	LD C,(HL)
	INC HL
	LD L,(HL)
;new address in HL (well it would be if LD H,(HL) was done instead along with LD L,C being added)
;but we need to validate this new address and that only needs msb
	writetrap
        endm

;absolute
;a1=?PC+256*?(a1+1)
;d=?a1
        macro getabsolute_write
	nextbyte
	LD C,(HL)
	nextbyte2
	LD L,(HL)
	writetrap
        endm

;absolute,X
;a1=?PC+256*?(a1+1)
;a2=a1+X
;d=?a2
        macro getabsoluteX_write
	nextbyte
	LD A,(HL)
	DB $FD
	ADD A,L
	LD C,A
;correct lo-byte stored in C for use later
	nextbyte2
;BC would contains new absolute_read address, but we haven't set B yet - it's at (HL)
;now add X to it
;C,A and CFlag not affected by nextbyte(2)
	LD A,$00
	ADC A,(HL)
;would've been ADC A,B - but quicker to use ADC A,(HL) and ditch earlier LD B,(HL)
;need to add carry in case C+X overflowed from earlier
;thus the value in A is the correct hi-byte.
	LD L,A
;however the validation routine requires hi-byte in L
	writetrap
        endm

;absolute,Y
;a1=?PC+256*?(a1+1)
;a2=a1+Y
;d=?a2
        macro getabsoluteY_write
        nextbyte
	LD A,(HL)
	DB $FD
	ADD A,H
	LD C,A
;correct lo-byte stored in C for use later
	nextbyte2
	LD A,$00
	ADC A,(HL)
	LD L,A
	writetrap
        endm

;(indirect,X)
;a=(?PC)+X where msb=00
;a2=?a+256*?(a+1)
;d=?a2
        macro indirectX_write
        nextbyte
	DB $FD
	LD A,L
	ADD A,(HL)
	LD L,A
	LD H,ZPrealpage
;validated address in HL. We've used ADD A,L because address at this point is always page 0
	LD C,(HL)
	INC HL
;address is always validated because page 1 always follows page 0, and HL is 0-$FF
	LD L,(HL)
;validate new address (d2)
	writetrap
        endm

;(indirect),Y
;a=?PC
;a2=?a+256*?(a+1)
;a3=a2+Y
;d=?a3
        macro indirectY_write
        nextbyte
	LD L,(HL)
;we know H=0 at this point (zero page), so validate it using ZPrealpage constant
	LD H,ZPrealpage
	LD A,(HL)
	INC HL
;even if HL goes from FF to 00 (ie: into Page 1), the validated page 1 address is always +1 of validated page 0 address
;BC would contain new pointer - just got to add Y to it. B is still at (HL) and C is in A
	DB $FD
	ADD A,H
	LD C,A
;store lo-byte of result in C for later
	LD A,$00
	ADC A,(HL)
;need to add carry in case C+Y overflowed earlier
;this is hi-byte of result, but validation routine requires
;hi-byte in L so instead of saving in H we save in L
	LD L,A
	writetrap
        endm



;the sequence INC A / DEC A gets the Z80 to set the S (6502 N flag)
;and Z flags correctly - without touching the C flag (which OR A would do)

;LDA - load accumulator
;set Z and N only
        macro opLDA
        LD A,(HL)
	INC A
	DEC A
        endm

;LDX - load X reg
;set Z and N only
        macro opLDX
        LD B,(HL)
	INC B
	DEC B
	DB $FD
	LD L,B
        endm

;LDY - load Y reg
;set Z and N only
        macro opLDY
        LD B,(HL)
	INC B
	DEC B
	DB $FD
	LD H,B
        endm

;DEC - decrease by one
;set Z and N only
        macro opDEC
        DEC (HL)
        endm
;flags set correctly by DEC instruction in this case


;INC - increase by one
;set Z and N only
        macro opINC
        INC (HL)
        endm
;flags set correctly by INC instruction in this case


;CPY - compare with Y
;set Z,N and C only
        macro opCPY
        LD B,A
	DB $FD
	LD A,H
	CP (HL)
	CCF
;flags set correctly by CP instruction in this case, except Carry flag
;which for some reason is the opposite on 6502 compared to Z80
	LD A,B
        endm


;CPX - compare with X
;set Z,N and C only
        macro opCPX
        LD B,A
	DB $FD
	LD A,L
	CP (HL)
	CCF
;flags set correctly by CP instruction in this case, except Carry flag
;which for some reason is the opposite on 6502 compared to Z80
	LD A,B
        endm


;CMP - compare with A
;set Z,N and C only
        macro opCMP
        CP (HL)
	CCF
        endm
;flags set correctly by CP instruction in this case, except Carry flag
;which for some reason is the opposite on 6502 compared to Z80

;STA - store A in memory
;no flags affected
        macro opSTA
        LD (HL),A
        endm

;STX - store X in memory
;no flags affected
        macro opSTX
        DB $FD
	LD B,L
	LD (HL),B
        endm

;STY - store Y in memory
;no flags affected
        macro opSTY
        DB $FD
	LD B,H
	LD (HL),B
        endm

;STZ - clear memory
;no flags affected
        macro opSTZ
        LD (HL),$00
        endm

;AND - bitwise AND against A
;set Z and N only
;Z80 clears C so have to be careful!
        macro opAND
        JR NC,$+7
	AND (HL)
	SCF
;put carry back to how it was
	incPC
	AND (HL)
;carry was already clear so doesn't matter about Z80 clearing it
;JP to here
        endm

;ORA - bitwise OR against A
;set Z and N only
;Z80 clears C so have to be careful!
        macro opORA
        JR NC,$+7
        OR (HL)
	SCF
;put carry back to how it was
	incPC
	OR (HL)
;carry was already clear so doesn't matter about Z80 clearing it
;JP to here
        endm

;EOR - bitwise EOR against A
;set Z and N only
;Z80 clears C so have to be careful!
        macro opEOR
        JR NC,$+7
	XOR (HL)
	SCF
;put carry back to how it was
	incPC
	XOR (HL)
;carry was already clear so doesn't matter about Z80 clearing it
;JP to here
        endm

;ADC - add with carry to A
;sets C,Z,V and N flags
        macro opADC
        JP sharedadc2
        endm


;TRB - test and reset bits
;sets Z flag only
        macro opTRB
        PUSH AF
	CPL
	AND (HL)
	LD (HL),A
	JR NZ,$+$06
;result was 0, so we need to set Z flag (and Z flag only!)
	POP HL
;flags in L
	SET 6,L
;set Z flag (bit 6 on Z80)
	PUSH HL
;back here from earlier JR
	POP AF
        endm

;TSB - test and set bits
;sets Z flag only
        macro opTSB
	PUSH AF
	OR (HL)
	LD (HL),A
	JR NZ,$+$06
;result was 0, so we need to set Z flag (and Z flag only!)
	POP HL
;flags in L
	SET 6,L
;set Z flag (bit 6 on Z80)
	PUSH HL
;back here from earlier JR
	POP AF
        endm

;ASL - arithmetic shift left
;sets C,Z and N flags
        macro opASL
        SLA (HL)
        endm

;LSR - logical shift right
;sets C,Z and N flags
        macro opLSR
        SRL (HL)
        endm

;ROL - rotate left one bit
;sets C,Z and N flags
        macro opROL
        RL (HL)
        endm

;ROR - rotate right one bit
;sets C,Z and N flags
        macro opROR
        RR (HL)
        endm

;SBC - subtract with carry from accumulator
;sets C,Z,V and N flags
        macro opSBC
        JP sharedsbc2
        endm

;BIT - test bits against accumulator (AND without storing result)
;sets Z,V and N flags
;except BIT #imm which only sets Z (CMOS)
        macro opBIT
        LD B,A
	LD C,(HL)
	INC C
	DEC C
	PUSH AF
	LD A,C
	AND $40
	LD (vVflag),A
	LD A,B
	AND C
	JR NZ,$+6
	POP HL
	SET 6,L
	PUSH HL
	POP AF
        endm


WriteScreen:
	LD IX,op_decode
RAMtrap	EQU $+1
	LD HL,RAMtrap	;this value gets overwritten as required
WriteDirect:
	EX AF,AF' ;'	;save 6502 AF
	LD C,(HL)	;get contents of that byte - to be used later
	LD A,H
	PUSH DE		;preserve DE (PC)
			;on VIC it's 23 lines of 22 chars!
	SUB ScreenPage	;make address become an offset of 0000-01FF
	LD H,A		;HL contains offset
WriteScreenSize:
;the following parameters can be adjusted by POKEing the VIC
	LD DE,$FFEA	;-22 chars per row!
	LD B,$17	;23 rows
			;if B=0 here then trouble arises...
write0:
	ADD HL,DE
	JR NC,write1
	DJNZ write0

	JP display7bytes8	;outside range of ZX screen so abort
				;or some clever person set col size to 0!
				;have to jump to this addr and not "write3"
				;as we don't know if we're in 8 or 16 row mode
write1:
;at this point B sort of contains number of rows
;and the remainder in HL (should be <255 so use just L) is number of columns

	LD A,$17
	SUB B		;row count in A

	SBC HL,DE	;correct for taking off 1 too many rows
			;CF cleared by SUB B above

	ADD A,A		;double up so if A was 3, it's now 6
	LD E,A
	LD D,rowtable/256	;rowtable msb - DE points to correct entry in table
	EX DE,HL	;now HL points there
	LD (RAMtrap),HL	;store for later
	LD A,(HL)
	INC L
	LD D,(HL)
	ADD A,E		;add in column from HL (now DE)
	LD E,A		;DE now contains correct addr on screen


writescreen3:
	LD L,C		;C contains (HL) from earlier
	LD H,$00	;copy into HL

writescreen4:
	ADD HL,HL	;contains NOP for 8 high characters
			;or ADD HL,HL for 16 high characters
	ADD HL,HL	;multiply by 2
	ADD HL,HL	;multiply by 4
	ADD HL,HL	;multiply by 8
WriteScreenCharset:
	LD BC,chargen
	ADD HL,BC	;reference into character map
write2:
	LD A,(HL)
	LD (DE),A
	INC D
	INC L		;safe to use INC L rather than INC HL as charmap always on 1024 byte boundary
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A	;don't need last 2 INC D/L - no point!

write3:
write3a:
;the following 7 (8!!!) bytes change depending on 8 or 16 row display mode
	LD A,E
	AND $1F		;keep column
	LD B,A		;in B for safe keeping
	LD DE,(RAMtrap)

	INC E
	INC E		;INC DE twice to get to next row (2nd half of 16-bytes)
	LD A,(DE)
	LD C,A
	INC E
	LD A,(DE)
	LD D,A
	LD A,B		;column
	ADD A,C		;add to DE
	LD E,A		;new row addr in DE
			;HL continues where we left off
write16:
	LD A,(HL)
	LD (DE),A
	INC D
	INC L		;safe to use INC L rather than INC HL as charmap always on 1024 byte boundary
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A
	INC D
	INC L
	LD A,(HL)
	LD (DE),A	;don't need last 2 INC D/L - no point!
	
display7bytes8:
	POP DE		;restore PC
	EX AF,AF' ;'	;back to using real AF
	JP (IX)

display7bytes16:
	LD A,E
	AND $1F		;keep column
	LD B,A		;in B for safe keeping
	LD DE,(RAMtrap)	;yes I know that makes 8 bytes!!

	EX AF,AF' ;'	;back to using real AF
	JP (IX)

attr2:
	EX AF,AF' ;'	;preserve 6502 AF
	LD IX,op_decode
	PUSH DE		;preserve DE
	LD HL,(RAMtrap)	;get back what we wrote to earlier

;ATTR3-$0B IS HERE
attr30B:
	PUSH HL		;preserve it for later
	LD A,H
	AND $01		;this clears CF flag
	LD H,A		;HL now contains 0-1FF = offset from top left
	LD DE,(WriteScreenSize+1)	;width in DE
	LD B,$17	;max 24 rows - value changed as necessary
attr3:
	ADD HL,DE
	JR NC,attr4
	DJNZ attr3
	POP HL		;drop HL off stack
	JR attrEnd	;outside screen area so abort!
attr4:
	SBC HL,DE	;compensate for going too far
attr4a:
	LD A,$17	;this value is changed as necessary
	SUB B		;row counter in A
			;remainder (column) in L
attr316:
	NOP		;this is NOP for 8-row high chars or
			;ADD A,A for 16-row high chars!

	LD C,L		;copy col to C for later
	ADD A,A		;safe to double up in 8 bits
			;as row should be <32
	ADD A,A		;x4
	ADD A,A		;x8
	LD L,A
	LD H,$16	;now go to 16 bit addition
			;set H to $0B, so when x8 it goes to $58
			;set H to $16, so when x4 it goes to $58
			;which is $5800 for attribute area
	ADD HL,HL	;x16
	ADD HL,HL	;x32 - 32 bytes per row
	LD A,L
	ADD A,C		;include columns
	LD L,A

	POP DE		;get earlier RAMtrap addr back as DE
	LD A,(DE)
	AND $07		;keep only colour nybble - ignore multicolour
	LD B,A		;INK into B

	LD A,(VIC900F)	;get background colour
			;are we inversed?

attr4b: ;patch jr nc/c
	JR NC,attr5	;C is always RESET by AND entry above

attr6:
;no inverse
	AND $F0		;by keeping only bits 7-4
	OR B		;merge in INK
	JP attr7

attr5:
;inverse
	AND $F0
	OR B
	RRCA
	RRCA
	RRCA
	RRCA		;swap INK and PAPER nybbles

attr7:
;A now contains 0-255 value which we reference into table to convert into Spectrum ATTR value

	LD E,A
	LD D,attrs/256
	LD A,(DE)	;convert VIC value (bbbb0fff) into ZX ATTR value
	LD (HL),A	;update Spectrum screen

attrEnd:
	POP DE		;restore DE
	
	EX AF,AF' ;'	;restore 6502 AF
	JP (IX)


	ORG base-$20
RELOCATE_KERNAL:
	LD HL,$8000
	LD DE,$6000
	LD BC,$2000
	LDIR
	JP base-$0200

	ORG base-$08
ANTIPRG:
	LD HL,$FF72
	LD ($7FFE),HL
	JP (IX)

;start of routines

	ORG base

brk:
	INC DE		;skip past BRK instruction
	INC DE		;remember BRK increases PC by 1 to skip following byte
			;before stacking PC - unlike JSR
	EX AF,AF'
	LD A,D
	do_pushA
	LD A,E
	do_pushA
	LD HL,FFrealpage*256+$FE	;validate it!
	LD E,(HL)
	INC L		;safe to do as we know HL has to be FFFE - therfore validated page still valid
			;also L will never overflow so quicker to do INC L than INC HL
	LD D,(HL)	;DE (PC) now contains  vector

	EX AF,AF'
	opPHP		;prepare flags in A
	OR $10		;force B flag to be set (only IRQ pushes this bit as 0)

;correct flags are in A
	do_pushA

	LD HL,vXflag
	LD A,(HL)
	AND $E3		;clear bits 4,3 and 2
	OR $14		;have to set bits 4 (B) and 2 (I)	
	LD (HL),A
	EX AF,AF'
	JP (IX)		;no incPC as DE (PC) is already correct

	ORG OP1
ora_zpx:
	EX AF,AF'
	indirectX_read
	EX AF,AF'
	opORA
	incPC

	ORG OP2
	JP illegal2

	ORG OP3
	JP illegal

	ORG OP4
tsbzp:
	getZP_read
	opTSB
	incPC

	ORG OP5
orazp:
	getZP_read
	opORA
	incPC

	ORG OP6
aslzp:
	getZP_read
	opASL
	incPC

	ORG OP7
	JP illegal

	ORG OP8
php:
;start with flags in...
	opPHP
;flags now out
	OR $10		;force B flag to be set (only IRQ pushes this bit as 0)
	do_pushA
	EX AF,AF'
	incPC

	ORG OP9
ora_imm:
	nextbyte
	opORA
	incPC

	ORG OP10
;ASL - arithmetic shift left
;sets C,Z and N flags
asla:	SLA A
	incPC

	ORG OP11
	JP illegal

	ORG OP12
tsbA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opTSB
	incPC

	ORG OP13
oraA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opORA
	incPC

	ORG OP14
aslA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opASL
	incPC

	ORG OP15
	JP illegal

	ORG OP16
bpl:
	INC DE
	JP M,bpl2
	EX AF,AF'
	nextbyteB
	LD L,(HL)
	LD A,L
	RLCA
	SBC A,A
	LD H,A
	ADD HL,DE	;add displacement to PC (DE)
	EX DE,HL
	EX AF,AF'
bpl2:
	incPC

	ORG OP17
ora_zp_y:
	EX AF,AF'
	indirectY_read
	EX AF,AF'
	opORA
	incPC

	ORG OP18
ora_zp:
	get_ZP_read
	opORA
	incPC

	ORG OP19
	JP illegal

	ORG OP20
trbzp:
	getZP_read
	opTRB
	incPC

	ORG OP21
orazpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opORA
	incPC

	ORG OP22
aslzpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opASL
	incPC

	ORG OP23
	JP illegal

	ORG OP24
clc:
	SCF
	CCF		;no clear carry flag on Z80, so have to set then compliment it!
	incPC

	ORG OP25
oraay:
	EX AF,AF'
	getabsoluteY_read
	EX AF,AF'
	opORA
	incPC

	ORG OP26
;INC - increase by one
;set Z and N only
inca:	INC A
;flags set correctly by INC instruction in this case
	incPC

	ORG OP27
	JP illegal

	ORG OP28
trbA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opTRB
	incPC

	ORG OP29
oraax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opORA
	incPC

	ORG OP30
aslax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opASL
	incPC

	ORG OP31
	JP illegal

	ORG OP32
jsrA:
	EX AF,AF'
	nextbyte
	LD C,(HL)
	nextbyte2
	LD A,D
	do_pushA	;we're pushing PC+2 here rather than PC+3 (ie: byte after JSR b1b2)
	LD A,E		;as RTS does +1 to POP'd result
	do_pushA
	LD E,C
	LD D,(HL)	;quicker to do this than LD B,(HL) , LD D,B
	EX AF,AF'
	JP (IX)		;go straight to decode routine

	ORG OP33
and_zpx:
	EX AF,AF'
	indirectX_read
	EX AF,AF'
	opAND
	incPC

	ORG OP34
	JP illegal2

	ORG OP35
	JP illegal

	ORG OP36
bitzp:
	getZP_read
	opBIT
	incPC

	ORG OP37
andzp:
	getZP_read
	opAND
	incPC

	ORG OP38
rolzp:
	getZP_read
	opROL
	incPC

	ORG OP39
	JP illegal

	ORG OP40
plp:
	LD B,A		;keep A
	EXX
	INC E		;SP is 0100-01FF only
	LD A,(DE)
	EXX
plp2:
	LD C,A		;take copy of flags!
	AND $40
	LD L,A

	LD A,C
	AND $3C
	OR $20
	LD H,A
	LD (vVflag),HL	;53T

	LD A,C		;restore flags
	AND $83		;keep N+C+Z flags (6502)
	ADD A,$3E	;move Z flag from bit 1 to bit 6 if it was set
	LD C,A		;new flags in L
	PUSH BC		;(B has real 6502 Acc from earlier)
	LD A,(adcdaa2)
	XOR H
	AND $08		;=0 at this point means we don't need to change BCD mode
	JR NZ,plp32

	POP AF		;reset C,Z,N flags
	incPC
plp32:
	BIT 3,H
	JR NZ,plp42
	POP AF
	JP cld2
plp42:
	POP AF		;reset C,Z,N flags
	JP sed2		;jump into SED routine

	ORG OP41
and_imm:
	nextbyte
	opAND
	incPC

	ORG OP42
;ROL - rotate left one bit
;sets C,Z and N flags
rola:	ADC A,A		;can't use RLA (4T) as it doesn't set Z and N flags
			;ADC A,A does same as "RL A" (except H and V flags), but is 4T quicker
	incPC

	ORG OP43
	JP illegal

	ORG OP44
bitA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opBIT
	incPC

	ORG OP45
andA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opAND
	incPC

	ORG OP46
rolA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opROL
	incPC

	ORG OP47
	JP illegal


	ORG OP48
bmi:
	INC DE
	JP P,bmi2
	EX AF,AF'
	nextbyteB
	LD L,(HL)
	LD A,L
	RLCA
	SBC A,A
	LD H,A
	ADD HL,DE	;add displacement to PC (DE)
	EX DE,HL
	EX AF,AF'
bmi2:
	incPC

	ORG OP49
and_zp_y:
	EX AF,AF'
	indirectY_read
	EX AF,AF'
	opAND
	incPC

	ORG OP50
and_zp:
	get_ZP_read
	opAND
	incPC

	ORG OP51
	JP illegal

	ORG OP52
bitzpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opBIT
	incPC

	ORG OP53
andzpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opAND
	incPC

	ORG OP54
rolzpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opROL
	incPC

	ORG OP55
	JP illegal

	ORG OP56
sec:
	SCF
	incPC

	ORG OP57
anday:
	EX AF,AF'
	getabsoluteY_read
	EX AF,AF'
	opAND
	incPC

	ORG OP58
;DEC - decrease by one
;set Z and N only
deca:	DEC A
;flags set correctly by DEC instruction in this case
	incPC

	ORG OP59
	JP illegal

	ORG OP60
bitax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opBIT
	incPC

	ORG OP61
andax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opAND
	incPC

	ORG OP62
rolax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opROL
	incPC

	ORG OP63
	JP illegal

	ORG OP64
rti:
;pops address and status register
;doesn't +1 to PC!
;now doesn't destroy H'L'
	LD B,A		;keep 6502 Acc for PLP2
	EXX
	INC E
	LD A,(DE)	;status byte off stack first
	INC E
	PUSH DE
	INC E		;another 2 bytes off stack
	EXX
	POP HL
	LD E,(HL)	;lo byte next
	INC L
	LD D,(HL)	;hi byte last
	DEC DE		;adjust PC so the incPC at end of PLP
			;doesn't affect us
	JP plp2		;carry on inside PLP (we've still got wrong AF)


	ORG OP65
eor_zpx:
	EX AF,AF'
	indirectX_read
	EX AF,AF'
	opEOR
	incPC

	ORG OP66
	JP illegal2

	ORG OP67
	JP illegal

	ORG OP68
	JP illegal2

	ORG OP69
eorzp:
	getZP_read
	opEOR
	incPC

	ORG OP70
lsrzp:
	getZP_read
	opLSR
	incPC
	
	ORG OP71
	JP illegal

	ORG OP72
;PHA - push A
;no flags affected
pha:
	EXX
	LD (DE),A
	EX AF,AF'
	DEC E
	EX AF,AF'
	EXX
	incPC

	ORG OP73
eor_imm:
	nextbyte
	opEOR
	incPC

	ORG OP74
;LSR - logical shift right
;sets C,Z and N flags
lsra:	SRL A
	incPC

	ORG OP75
	JP illegal

	ORG OP76
jmpA:
	nextbyte
	LD C,(HL)
	nextbyte2
	LD D,(HL)
	LD E,C
	JP (IX)	

	ORG OP77
eorA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opEOR
	incPC
	
	ORG OP78
lsrA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opLSR
	incPC

	ORG OP79
	JP illegal

	ORG OP80
bvc:
	EX AF,AF'
	INC DE
	LD A,(vVflag)
	AND A		;is it zero?
	JR NZ,bvc2
	nextbyteB
	LD L,(HL)
	LD A,L
	RLCA
	SBC A,A
	LD H,A
	ADD HL,DE	;add displacement to PC (DE)
	EX DE,HL
bvc2:
	EX AF,AF'
	incPC

	ORG OP81
eor_zp_y:
	EX AF,AF'
	indirectY_read
	EX AF,AF'
	opEOR
	incPC

	ORG OP82
eor_zp:
	get_ZP_read
	opEOR
	incPC

	ORG OP83
	JP illegal

	ORG OP84
	JP illegal2

	ORG OP85
eorzpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opEOR
	incPC

	ORG OP86
lsrzpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opLSR
	incPC

	ORG OP87
	JP illegal

	ORG OP88
cli:
	LD HL,vXflag
	RES 2,(HL)	;reset I bit
	incPC

	ORG OP89
eoray:
	EX AF,AF'
	getabsoluteY_read
	EX AF,AF'
	opEOR
	incPC

	ORG OP90
;PHY - push Y
;no flags affected
phy:
	EXX
	EX AF,AF'

	DB $FD
	LD A,H

	LD (DE),A
	DEC E
	EX AF,AF'
	EXX
	incPC

	ORG OP91
	JP illegal

	ORG OP92
	JP illegal3

	ORG OP93
eorax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opEOR
	incPC

	ORG OP94
lsrax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opLSR
	incPC

	ORG OP95
	JP illegal

	ORG OP96
rts:
;pops address and adds 1!
	EX AF,AF'
	EXX
	INC E
	LD A,(DE)	;lo-byte off stack first
	EXX
	LD E,A		;set lo-byte of PC
	EXX
	INC E
	LD A,(DE)	;hi-byte off stack
	EXX
	LD D,A		;DE now contains value off stack
	EX AF,AF'
	incPC		;incPC does the +1 to PC for us

	ORG OP97
adc_zpx:
	EX AF,AF'
	indirectX_read
	EX AF,AF'
	opADC
	incPC

	ORG OP98
	JP illegal2

	ORG OP99
	JP illegal

	ORG OP100
stzzp:
	getZP_write
	opSTZ
	incPC

	ORG OP101
adczp:
	getZP_read
	opADC
	incPC

	ORG OP102
rorzp:
	getZP_read
	opROR
	incPC

	ORG OP103
	JP illegal

	ORG OP104
;PLA - pull A
;sets Z and N flags
pla:
	EXX
	INC E		;this will upset flags - but we're going to change them anyway!
	LD A,(DE)
	INC A
	DEC A
	EXX
	incPC

	ORG OP105
adc_imm:
	nextbyte

;every other ADC instruction has to JP to here
;but ADC #imm carries straight on into code

sharedadc2:
;all ADC opcodes come here - it's quicker to waste 10T
;on a JP instruction then to test D flag and JP according to it

	ADC A,(HL)
;the following byte is modified by SED and CLD instructions
;to either NOP (CLD) or DAA (SED)

adcdaa2:
	DAA

;C,Z and N are correct
;but V needs to be stored elsewhere

	LD HL,vVflag
	JP PO,$+8
;jump if overflow unset
;A=$40 if V set, A=0 if V reset
	LD (HL),$40
	incPC
;no overflow comes here
	LD (HL),$00
	incPC

	ORG OP106
;ROR - rotate right one bit
;sets C,Z and N flags
rora:	RR A		;can't use RRA (4T) as it doesn't set Z and N flags
	incPC

	ORG OP107
	JP illegal

	ORG OP108
jmp_a:
	EX AF,AF'
	nextbyte
	LD C,(HL)
	nextbyte2
	LD D,(HL)
	LD E,C		;address following JMP into DE
	LD L,D		;pre-load L for readtrap (C already OK)
	readtrap
	LD B,(HL)
	INC DE
	LD C,E
	LD L,D		;pre-load L and C for readtrap
	readtrap
	LD D,(HL)
	LD E,B		;get (DE) into PC
	EX AF,AF'
	JP (IX)

	ORG OP109
adcA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opADC
	incPC

	ORG OP110
rorA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opROR
	incPC

	ORG OP111
	JP illegal

	ORG OP112
bvs:
	EX AF,AF'
	INC DE
	LD A,(vVflag)
	AND A		;is it zero?
	JR Z,bvs2
	nextbyteB
	LD L,(HL)
	LD A,L
	RLCA
	SBC A,A
	LD H,A
	ADD HL,DE	;add displacement to PC (DE)
	EX DE,HL
bvs2:
	EX AF,AF'
	incPC

	ORG OP113
adc_zp_y:
	EX AF,AF'
	indirectY_read
	EX AF,AF'
	opADC
	incPC

	ORG OP114
adc_zp:
	get_ZP_read
	opADC
	incPC

	ORG OP115
	JP illegal

	ORG OP116
stzzpx:
	EX AF,AF'
	getZPX_write
	EX AF,AF'
	opSTZ
	incPC
	
	ORG OP117
adczpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opADC
	incPC

	ORG OP118
rorzpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opROR
	incPC

	ORG OP119
	JP illegal

	ORG OP120
sei:
	LD HL,vXflag
	SET 2,(HL)	;set I bit
	incPC

	ORG OP121
adcay:
	EX AF,AF'
	getabsoluteY_read
	EX AF,AF'
	opADC
	incPC

	ORG OP122
;PLY - pull Y
;sets Z and N flags
ply:
	EXX
	EX AF,AF'
	INC E
	LD A,(DE)
	EXX
	LD B,A
	EX AF,AF'
	INC B
	DEC B
	DB $FD
	LD H,B
	incPC

	ORG OP123
	JP illegal

	ORG OP124
jmp_ax:
;this is a one off instruction, but it's similar to absoluteX_read...
	EX AF,AF'
	nextbyte
	LD C,(HL)
	nextbyte2
	LD B,(HL)
	DB $FD
	LD A,L
	LD L,A
	LD H,$00
	ADD HL,BC	;now got address + X in HL
	EX DE,HL	;set DE to this address
	nextbyteB	;don't increase DE as it's already correct!
	LD C,(HL)
	nextbyte2
	LD D,(HL)
	LD E,C		;DE now contains new addr for PC
	EX AF,AF'
	JP (IX)

	ORG OP125
adcax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opADC
	incPC

	ORG OP126
rorax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opROR
	incPC

	ORG OP127
	JP illegal

	ORG OP128
bra:	EX AF,AF'
	nextbyte
	LD L,(HL)	;displacement
	LD A,L		;copy into A
	RLCA		;bit 7 into C flag
	SBC A,A		;if C=0 then A=0, C=1 then A=FF
	LD H,A		;which is correct value for H in HL
	ADD HL,DE	;add displacement to PC (DE)
	EX DE,HL
	EX AF,AF'
	incPC

	ORG OP129
sta_zpx:
	EX AF,AF'
	indirectX_write
	EX AF,AF'
	opSTA
	incPC

	ORG OP130
	JP illegal2

	ORG OP131
	JP illegal

	ORG OP132
styzp:
	getZP_write
	opSTY
	incPC

	ORG OP133
stazp:
	getZP_write
	opSTA
	incPC

	ORG OP134
stxzp:
	getZP_write
	opSTX
	incPC

	ORG OP135
	JP illegal

	ORG OP136
dey:	DB $FD
	DEC H
;flags set correctly by DEC instruction in this case
	incPC

	ORG OP137
bit_imm:
	PUSH AF		;get flags and 6502 A
	nextbyte
;BIT #imm does not set V and N flags, so we can't use opBIT
	AND (HL)	;do the BIT test against the immediate value
	JR NZ,$+6	;if A<>0 then skip setting real Z flag
	POP BC
	SET 6,C		;Z80 Z flag is bit 6
	PUSH BC
;earlier JR comes in here
	POP AF		;restores 6502 A and sets flags
	incPC


	ORG OP138
;TXA - transfer X to A
;sets Z and N flags
txa:
	DB $FD
	LD A,L
	INC A
	DEC A
	incPC

	ORG OP139
	JP illegal

	ORG OP140
styA:
	EX AF,AF'
	getabsolute_write
	EX AF,AF'
	opSTY
	incPC

	ORG OP141
staA:
	EX AF,AF'
	getabsolute_write
	EX AF,AF'
	opSTA
	incPC

	ORG OP142
stxA:
	EX AF,AF'
	getabsolute_write
	EX AF,AF'
	opSTX
	incPC

	ORG OP143
	JP illegal

	ORG OP144
bcc:
	INC DE
	JR C,bcc2
	EX AF,AF'
	nextbyteB
	LD L,(HL)
	LD A,L
	RLCA
	SBC A,A
	LD H,A
	ADD HL,DE	;add displacement to PC (DE)
	EX DE,HL
	EX AF,AF'
bcc2:
	incPC

	ORG OP145
sta_zp_y:
	EX AF,AF'
	indirectY_write
	EX AF,AF'
	opSTA
	incPC

	ORG OP146
sta_zp:
	get_ZP_write
	opSTA
	incPC

	ORG OP147
	JP illegal

	ORG OP148
styzpx:
	EX AF,AF'
	getZPX_write
	EX AF,AF'
	opSTY
	incPC

	ORG OP149
stazpx:
	EX AF,AF'
	getZPX_write
	EX AF,AF'
	opSTA
	incPC

	ORG OP150
stxzpy:
	EX AF,AF'
	getZPY_write
	EX AF,AF'
	opSTX
	incPC

	ORG OP151
	JP illegal

	ORG OP152
;TYA - transfer Y to A
;sets Z and N flags
tya:
	DB $FD
	LD A,H
	INC A
	DEC A
	incPC

	ORG OP153
staay:
	EX AF,AF'
	getabsoluteY_write
	EX AF,AF'
	opSTA
	incPC

	ORG OP154
;TXS - transfer SP to X
;doesn't set any flags (unlike TSX)
txs:
	EXX
	DB $FD
	LD E,L
	EXX
	incPC

	ORG OP155
	JP illegal

	ORG OP156
stzA:
	EX AF,AF'
	getabsolute_write
	EX AF,AF'
	opSTZ
	incPC

	ORG OP157
staax:
	EX AF,AF'
	getabsoluteX_write
	EX AF,AF'
	opSTA
	incPC

	ORG OP158
stzax:
	EX AF,AF'
	getabsoluteX_write
	EX AF,AF'
	opSTZ
	incPC

	ORG OP159
	JP illegal

	ORG OP160
ldy_imm:
	nextbyte
	opLDY
	incPC

	ORG OP161
lda_zpx:
	EX AF,AF'
	indirectX_read
	EX AF,AF'
	opLDA
	incPC

	ORG OP162
ldx_imm:
	nextbyte
	opLDX
	incPC
	
	ORG OP163
	JP illegal

	ORG OP164
ldyzp:
	getZP_read
	opLDY
	incPC

	ORG OP165
ldazp:
	getZP_read
	opLDA
	incPC

	ORG OP166
ldxzp:
	getZP_read
	opLDX
	incPC

	ORG OP167
	JP illegal

	ORG OP168
;TAY - transfer A to Y
;sets Z and N flags
tay:
	INC A
	DEC A
	DB $FD
	LD H,A
	incPC

	ORG OP169
;op173 starts very soon after op169!
lda_imm:
	nextbyte
	opLDA
	incPC

	ORG OP170
;TAX - transfer A to X
;sets Z and N flags
tax:
	INC A
	DEC A
	DB $FD
	LD L,A
	incPC

	ORG OP171
	JP illegal

	ORG OP172
ldyA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opLDY
	incPC

	ORG OP173
ldaA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opLDA
	incPC

	ORG OP174
ldxA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opLDX
	incPC

	ORG OP175
	JP illegal

	ORG OP176
bcs:
	INC DE
	JR NC,bcs2
	EX AF,AF'
	nextbyteB
	LD L,(HL)	;better to do this after checking flag - not before!
	LD A,L
	RLCA
	SBC A,A
	LD H,A
	ADD HL,DE	;add displacement to PC (DE)
	EX DE,HL
	EX AF,AF'
bcs2:
	incPC


	ORG OP177
lda_zp_y:
	EX AF,AF'
	indirectY_read
	EX AF,AF'
	opLDA
	incPC

	ORG OP178
lda_zp:
	EX AF,AF'
	get_ZP_read
	EX AF,AF'
	opLDA
	incPC

	ORG OP179
	JP illegal

	ORG OP180
ldyzpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opLDY
	incPC

	ORG OP181
ldazpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opLDA
	incPC

	ORG OP182
ldxzpy:
	EX AF,AF'
	getZPY_read
	EX AF,AF'
	opLDX
	incPC

	ORG OP183
	JP illegal

	ORG OP184
clv:
	LD HL,vVflag
	LD (HL),$00
	incPC

	ORG OP185
ldaay:
	EX AF,AF'
	getabsoluteY_read
	EX AF,AF'
	opLDA
	incPC

	ORG OP186
;TSX - transfer SP to X
;sets Z and N flags
tsx:
	EXX
	DB $FD
	LD L,E
	INC E		;quicker to INC E then to transfer A into A' and INC that
	DEC E
	EXX
	incPC

	ORG OP187
	JP illegal

	ORG OP188
ldyax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opLDY
	incPC

	ORG OP189
ldaax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opLDA
	incPC

	ORG OP190
ldxay:
	EX AF,AF'
	getabsoluteY_read
	EX AF,AF'
	opLDX
	incPC

	ORG OP191
	JP illegal

	ORG OP192
cpy_imm:
	nextbyte
	opCPY
	incPC

	ORG OP193
cmp_zpx:
	EX AF,AF'
	indirectX_read
	EX AF,AF'
	opCMP
	incPC

	ORG OP194
	JP illegal2

	ORG OP195
	JP illegal
;or use alternative opcode "ostrap"
;it allows seamless merging of 6502 and Z80 code
;use as $C3 lsb msb to call your Z80 code from 6502
;and finish Z80 code with call to 'rts' routine
;
;ostrap:
;	nextbyte
;	LD C,(HL)
;	nextbyte2
;	LD H,(HL)
;	LD L,C
;	JP (HL)		;yikes!!

	ORG OP196
cpyzp:
	getZP_read
	opCPY
	incPC

	ORG OP197
cmpzp:
	getZP_read
	opCMP
	incPC

	ORG OP198
deczp:
	getZP_read
	opDEC
	incPC

	ORG OP199
	JP illegal

	ORG OP200
iny:	DB $FD
	INC H
;flags set correctly by INC instruction in this case
	incPC

	ORG OP201
cmp_imm:
	nextbyte
	opCMP
	incPC

	ORG OP202
dex:	DB $FD
	DEC L
;flags set correctly by DEC instruction in this case
	incPC

	ORG OP203
wai:
	incPC		;do nothing for now!

	ORG OP204
cpyA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opCPY
	incPC

	ORG OP205
cmpA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opCMP
	incPC

	ORG OP206
decA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opDEC
	incPC

	ORG OP207
	JP illegal

	ORG OP208
bne:
	INC DE
	JR Z,bne2
	EX AF,AF'
	nextbyteB
	LD L,(HL)
	LD A,L
	RLCA
	SBC A,A
	LD H,A
	ADD HL,DE	;add displacement to PC (DE)
	EX DE,HL
	EX AF,AF'
bne2:
	incPC

	ORG OP209
cmp_zp_y:
	EX AF,AF'
	indirectY_read
	EX AF,AF'
	opCMP
	incPC

	ORG OP210
cmp_zp:
	get_ZP_read
	opCMP
	incPC

	ORG OP211
	JP illegal

	ORG OP212
	JP illegal2

	ORG OP213
cmpzpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opCMP	
	incPC

	ORG OP214
deczpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opDEC
	incPC

	ORG OP215
	JP illegal

	ORG OP216
cld:
	LD HL,vXflag
	RES 3,(HL)	;clear D bit
cld2:
	LD HL,adcdaa2
	LD (HL),$00	;set these routines to NOP (opcode 00) instead of DAA
	LD HL,sbcdaa2
	LD (HL),$00	;preserve flags
	incPC

	ORG OP217
cmpay:
	EX AF,AF'
	getabsoluteY_read
	EX AF,AF'
	opCMP
	incPC

	ORG OP218
;PHX - push X
;no flags affected
phx:
	EXX
	EX AF,AF'
	DB $FD
	LD A,L
	LD (DE),A
	DEC E		;SP is 0100-01FF only
	EX AF,AF'
	EXX
	incPC

	ORG OP219
stp:
	incPC		;do nothing for now!

	ORG OP220
	JP illegal3

	ORG OP221
cmpax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opCMP
	incPC

	ORG OP222
decax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opDEC
	incPC
	
	ORG OP223
	JP illegal

	ORG OP224
cpx_imm:
	nextbyte
	opCPX
	incPC

	ORG OP225
sbc_zpx:
	EX AF,AF'
	indirectX_read
	EX AF,AF'
	opSBC
	incPC

	ORG OP226
	JP illegal2

	ORG OP227
	JP illegal

	ORG OP228
cpxzp:
	getZP_read
	opCPX
	incPC

	ORG OP229
sbczp:
	getZP_read
	opSBC
	incPC

	ORG OP230
inczp:
	getZP_read
	opINC
	incPC

	ORG OP231
	JP illegal

	ORG OP232
inx:	DB $FD
	INC L
;flags set correctly by INC instruction in this case
	incPC

	ORG OP233
sbc_imm:
	nextbyte

sharedsbc2:
;same comments as ADC for reasons of shared routine
;
;SBC on 6502 is quite different to Z80!
;it is effectively A-operand-(1-CF)
;so complement CF flag first!
	CCF
	SBC A,(HL)

;the following byte is modified by SED and CLD instructions
;to either NOP (CLD) or DAA (SED)

;and result of CF flag is opposite to Z80 too!
sbcdaa2:
	DAA ;patch daa/nop

;and result of CF flag is opposite to Z80 too!
	CCF
	LD HL,vVflag
	JP PO,$+8
;jump if overflow unset
;A=$40 if V set, A=0 if V reset
	LD (HL),$40
	incPC
;no overflow comes here
	LD (HL),$00
	incPC

	ORG OP234
nop:
	incPC		;do nothing!

	ORG OP235
	JP illegal

	ORG OP236
cpxA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opCPX
	incPC

	ORG OP237
sbcA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opSBC
	incPC

	ORG OP238
incA:
	EX AF,AF'
	getabsolute_read
	EX AF,AF'
	opINC
	incPC

	ORG OP239
	JP illegal

	ORG OP240
beq:
	INC DE
	JR NZ,beq2
	EX AF,AF'
	nextbyteB
	LD L,(HL)
	LD A,L
	RLCA
	SBC A,A
	LD H,A
	ADD HL,DE	;add displacement to PC (DE)
	EX DE,HL
	EX AF,AF'
beq2:
	incPC

	ORG OP241
sbc_zp_y:
	EX AF,AF'
	indirectY_read
	EX AF,AF'
	opSBC
	incPC

	ORG OP242
sbc_zp:
	get_ZP_read
	opSBC
	incPC

	ORG OP243
	JP illegal

	ORG OP244
	JP illegal2

	ORG OP245
sbczpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opSBC
	incPC

	ORG OP246
inczpx:
	EX AF,AF'
	getZPX_read
	EX AF,AF'
	opINC
	incPC

	ORG OP247
	JP illegal

	ORG OP248
sed:
	LD HL,vXflag
	SET 3,(HL)	;set D bit
sed2:
	LD HL,adcdaa2
	LD (HL),$27	;set these routines to DAA (opcode 27) instead of NOP
	LD HL,sbcdaa2
	LD (HL),$27	;preserve flags
	incPC

	ORG OP249
sbcay:
	EX AF,AF'
	getabsoluteY_read
	EX AF,AF'
	opSBC
	incPC

	ORG OP250
;PLX - pull X
;sets Z and N flags
plx:
	EXX
	EX AF,AF'
	INC E
	LD A,(DE)
	LD B,A
	EXX
	EX AF,AF'
	INC B
	DEC B
	DB $FD
	LD L,B
	incPC

	ORG OP251
	JP illegal

	ORG OP252
	JP illegal3

	ORG OP253
sbcax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opSBC
	incPC

	ORG OP254
incax:
	EX AF,AF'
	getabsoluteX_read
	EX AF,AF'
	opINC
	incPC

	ORG OP255
	JP illegal

	ORG IM2page*256

;this is used as an IM2 vector table so we don't care if a kempston joystick is plugged in or not!

	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1,IM2page+1
	DB IM2page+1	;257th byte goes here




	ORG Oppage*256
	DB OP0/256
	DB OP1/256
	DB OP2/256
	DB OP3/256
	DB OP4/256
	DB OP5/256
	DB OP6/256
	DB OP7/256
	DB OP8/256
	DB OP9/256
	DB OP10/256
	DB OP11/256
	DB OP12/256
	DB OP13/256
	DB OP14/256
	DB OP15/256
	DB OP16/256
	DB OP17/256
	DB OP18/256
	DB OP19/256
	DB OP20/256
	DB OP21/256
	DB OP22/256
	DB OP23/256
	DB OP24/256
	DB OP25/256
	DB OP26/256
	DB OP27/256
	DB OP28/256
	DB OP29/256
	DB OP30/256
	DB OP31/256
	DB OP32/256
	DB OP33/256
	DB OP34/256
	DB OP35/256
	DB OP36/256
	DB OP37/256
	DB OP38/256
	DB OP39/256
	DB OP40/256
	DB OP41/256
	DB OP42/256
	DB OP43/256
	DB OP44/256
	DB OP45/256
	DB OP46/256
	DB OP47/256
	DB OP48/256
	DB OP49/256
	DB OP50/256
	DB OP51/256
	DB OP52/256
	DB OP53/256
	DB OP54/256
	DB OP55/256
	DB OP56/256
	DB OP57/256
	DB OP58/256
	DB OP59/256
	DB OP60/256
	DB OP61/256
	DB OP62/256
	DB OP63/256
	DB OP64/256
	DB OP65/256
	DB OP66/256
	DB OP67/256
	DB OP68/256
	DB OP69/256
	DB OP70/256
	DB OP71/256
	DB OP72/256
	DB OP73/256
	DB OP74/256
	DB OP75/256
	DB OP76/256
	DB OP77/256
	DB OP78/256
	DB OP79/256
	DB OP80/256
	DB OP81/256
	DB OP82/256
	DB OP83/256
	DB OP84/256
	DB OP85/256
	DB OP86/256
	DB OP87/256
	DB OP88/256
	DB OP89/256
	DB OP90/256
	DB OP91/256
	DB OP92/256
	DB OP93/256
	DB OP94/256
	DB OP95/256
	DB OP96/256
	DB OP97/256
	DB OP98/256
	DB OP99/256
	DB OP100/256
	DB OP101/256
	DB OP102/256
	DB OP103/256
	DB OP104/256
	DB OP105/256
	DB OP106/256
	DB OP107/256
	DB OP108/256
	DB OP109/256
	DB OP110/256
	DB OP111/256
	DB OP112/256
	DB OP113/256
	DB OP114/256
	DB OP115/256
	DB OP116/256
	DB OP117/256
	DB OP118/256
	DB OP119/256
	DB OP120/256
	DB OP121/256
	DB OP122/256
	DB OP123/256
	DB OP124/256
	DB OP125/256
	DB OP126/256
	DB OP127/256
	DB OP128/256
	DB OP129/256
	DB OP130/256
	DB OP131/256
	DB OP132/256
	DB OP133/256
	DB OP134/256
	DB OP135/256
	DB OP136/256
	DB OP137/256
	DB OP138/256
	DB OP139/256
	DB OP140/256
	DB OP141/256
	DB OP142/256
	DB OP143/256
	DB OP144/256
	DB OP145/256
	DB OP146/256
	DB OP147/256
	DB OP148/256
	DB OP149/256
	DB OP150/256
	DB OP151/256
	DB OP152/256
	DB OP153/256
	DB OP154/256
	DB OP155/256
	DB OP156/256
	DB OP157/256
	DB OP158/256
	DB OP159/256
	DB OP160/256
	DB OP161/256
	DB OP162/256
	DB OP163/256
	DB OP164/256
	DB OP165/256
	DB OP166/256
	DB OP167/256
	DB OP168/256
	DB OP169/256
	DB OP170/256
	DB OP171/256
	DB OP172/256
	DB OP173/256
	DB OP174/256
	DB OP175/256
	DB OP176/256
	DB OP177/256
	DB OP178/256
	DB OP179/256
	DB OP180/256
	DB OP181/256
	DB OP182/256
	DB OP183/256
	DB OP184/256
	DB OP185/256
	DB OP186/256
	DB OP187/256
	DB OP188/256
	DB OP189/256
	DB OP190/256
	DB OP191/256
	DB OP192/256
	DB OP193/256
	DB OP194/256
	DB OP195/256
	DB OP196/256
	DB OP197/256
	DB OP198/256
	DB OP199/256
	DB OP200/256
	DB OP201/256
	DB OP202/256
	DB OP203/256
	DB OP204/256
	DB OP205/256
	DB OP206/256
	DB OP207/256
	DB OP208/256
	DB OP209/256
	DB OP210/256
	DB OP211/256
	DB OP212/256
	DB OP213/256
	DB OP214/256
	DB OP215/256
	DB OP216/256
	DB OP217/256
	DB OP218/256
	DB OP219/256
	DB OP220/256
	DB OP221/256
	DB OP222/256
	DB OP223/256
	DB OP224/256
	DB OP225/256
	DB OP226/256
	DB OP227/256
	DB OP228/256
	DB OP229/256
	DB OP230/256
	DB OP231/256
	DB OP232/256
	DB OP233/256
	DB OP234/256
	DB OP235/256
	DB OP236/256
	DB OP237/256
	DB OP238/256
	DB OP239/256
	DB OP240/256
	DB OP241/256
	DB OP242/256
	DB OP243/256
	DB OP244/256
	DB OP245/256
	DB OP246/256
	DB OP247/256
	DB OP248/256
	DB OP249/256
	DB OP250/256
	DB OP251/256
	DB OP252/256
	DB OP253/256
	DB OP254/256
	DB OP255/256

trap	EQU $01

	ORG M1page*256
;Opcode decode table

	DB $80
	DB $81
	DB $82	
	DB $83	;VIC-20 had 1/2K at start of memory!
;3K RAM expansion table goes here!
	DB $84
	DB $85
	DB $86
	DB $87
	DB $88
	DB $89
	DB $8A
	DB $8B
	DB $8C
	DB $8D
	DB $8E
	DB $8F	
;4K base RAM goes here
	DB $90
	DB $91
	DB $92
	DB $93
	DB $94
	DB $95
	DB $96
	DB $97
	DB $98
	DB $99
	DB $9A
	DB $9B
	DB $9C
	DB $9D
	DB $9E
	DB $9F
;2000-7FFF unused memory
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
;character bit maps now (A000-AFFF)
	DB $A0
	DB $A1
	DB $A2
	DB $A3
	DB $A4
	DB $A5
	DB $A6
	DB $A7
	DB $A8
	DB $A9
	DB $AA
	DB $AB
	DB $AC
	DB $AD
	DB $AE
	DB $AF
;VIC chip (9000-93FF)
	DB $02	;can't execute VIC registers!
	DB $02
	DB $02
	DB $02
;alternate colour nybble
	DB colourram+1		;you can run code in nybble area if you want!
	DB colourram+2
;main colour nybble (in unexpanded VIC) (9600-97FF)
	DB colourram+1
	DB colourram+2
;more possible expansion RAM (9800-BFFF)
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
;CARTRIDGE AREA $A000-$BFFF
	DB $20
	DB $21
	DB $22
	DB $23
	DB $24
	DB $25
	DB $26
	DB $27
	DB $28
	DB $29
	DB $2A
	DB $2B
	DB $2C
	DB $2D
	DB $2E
	DB $2F
	DB $30
	DB $31
	DB $32
	DB $33
	DB $34
	DB $35
	DB $36
	DB $37
	DB $38
	DB $39
	DB $3A
	DB $3B
	DB $3C
	DB $3D
	DB $3E
	DB $3F
;BASIC2 ROM C000-DFFF
	DB $E0
	DB $E1
	DB $E2
	DB $E3
	DB $E4
	DB $E5
	DB $E6
	DB $E7
	DB $E8
	DB $E9
	DB $EA
	DB $EB
	DB $EC
	DB $ED
	DB $EE
	DB $EF
	DB $F0
	DB $F1
	DB $F2
	DB $F3
	DB $F4
	DB $F5
	DB $F6
	DB $F7
	DB $F8
	DB $F9
	DB $FA
	DB $FB
	DB $FC
	DB $FD
	DB $FE
	DB $FF
;KERNAL ROM E000-FFFF
	DB $60
	DB $61
	DB $62
	DB $63
	DB $64
	DB $65
	DB $66
	DB $67
	DB $68
	DB $69
	DB $6A
	DB $6B
	DB $6C
	DB $6D
	DB $6E
	DB $6F
	DB $70
	DB $71
	DB $72
	DB $73
	DB $74
	DB $75
	DB $76
	DB $77
	DB $78
	DB $79
	DB $7A
	DB $7B
	DB $7C
	DB $7D
	DB $7E
	DB $7F

;*** MEMORY READ TABLE ***
;MRpage
	DB $81
	DB $82	
	DB $83	;VIC-20 had 1/2K at start of memory!
	DB $84
;3K RAM expansion table goes here!
	DB $85
	DB $86
	DB $87
	DB $88
	DB $89
	DB $8A
	DB $8B
	DB $8C
	DB $8D
	DB $8E
	DB $8F	
	DB $90
;4K base RAM goes here
	DB $91
	DB $92
	DB $93
	DB $94
	DB $95
	DB $96
	DB $97
	DB $98
	DB $99
	DB $9A
	DB $9B
	DB $9C
	DB $9D
	DB $9E
	DB $9F
	DB $A0
;2000-7FFF unused memory
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
;character bit maps now (A000-AFFF)
	DB $A1
	DB $A2
	DB $A3
	DB $A4
	DB $A5
	DB $A6
	DB $A7
	DB $A8
	DB $A9
	DB $AA
	DB $AB
	DB $AC
	DB $AD
	DB $AE
	DB $AF
	DB $B0
;VIC chip (9000-93FF)
	DB trap		;VIC chip
	DB trap		;VIA chip
	DB $02
	DB $02
;alternate colour nybble
	DB colourram+1
	DB colourram+2
;main colour nybble (in unexpanded VIC) (9600-97FF)
	DB colourram+1
	DB colourram+2
;more possible expansion RAM (9800-BFFF)
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
;CARTRIDGE AREA $A000-$BFFF
	DB $21
	DB $22
	DB $23
	DB $24
	DB $25
	DB $26
	DB $27
	DB $28
	DB $29
	DB $2A
	DB $2B
	DB $2C
	DB $2D
	DB $2E
	DB $2F
	DB $30
	DB $31
	DB $32
	DB $33
	DB $34
	DB $35
	DB $36
	DB $37
	DB $38
	DB $39
	DB $3A
	DB $3B
	DB $3C
	DB $3D
	DB $3E
	DB $3F
	DB $40
;BASIC2 ROM C000-DFFF
	DB $E1
	DB $E2
	DB $E3
	DB $E4
	DB $E5
	DB $E6
	DB $E7
	DB $E8
	DB $E9
	DB $EA
	DB $EB
	DB $EC
	DB $ED
	DB $EE
	DB $EF
	DB $F0
	DB $F1
	DB $F2
	DB $F3
	DB $F4
	DB $F5
	DB $F6
	DB $F7
	DB $F8
	DB $F9
	DB $FA
	DB $FB
	DB $FC
	DB $FD
	DB $FE
	DB $FF
	DB $00	;this really should be $00 so it wraps around to $FF
;KERNAL ROM E000-FFFF
	DB $61
	DB $62
	DB $63
	DB $64
	DB $65
	DB $66
	DB $67
	DB $68
	DB $69
	DB $6A
	DB $6B
	DB $6C
	DB $6D
	DB $6E
	DB $6F
	DB $70
	DB $71
	DB $72
	DB $73
	DB $74
	DB $75
	DB $76
	DB $77
	DB $78
	DB $79
	DB $7A
	DB $7B
	DB $7C
	DB $7D
	DB $7E
	DB $7F
	DB $80

;*** MEMORY WRITE TABLE ***
;MWpage
	DB $81
	DB $82	
	DB $83	;VIC-20 had 1/2K at start of memory!
	DB $84
;3K RAM expansion table goes here!
	DB $85
	DB $86
	DB $87
	DB $88
	DB $89
	DB $8A
	DB $8B
	DB $8C
	DB $8D
	DB $8E
	DB $8F	
	DB $90
;4K base RAM goes here
	DB $91
	DB $92
	DB $93
	DB $94
	DB $95
	DB $96
	DB $97
	DB $98
	DB $99
	DB $9A
	DB $9B
	DB $9C
	DB $9D
	DB $9E
	DB $9F		;trap writes to screen done via VIC9005!
	DB $A0
;2000-7FFF unused memory
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02	;set this to $03 if you want +8K RAM
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
;character bit maps (A000-AFFF)
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
;VIC chip (9000-93FF)
	DB trap		;VIC chip
	DB trap		;VIA chip
	DB $02
	DB $02
;alternate colour nybble
	DB trap
	DB trap
;main colour nybble (in unexpanded VIC) (9600-97FF)
	DB trap
	DB trap
;more possible expansion RAM (9800-BFFF)
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
;BASIC2 ROM C000-DFFF
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
;KERNAL ROM E000-FFFF
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
	DB $02
M1pagesize=$-(M1page*256)

	ORG (IM2page*256)+257
;after IM2 IRQ vector table
;now use some of this blank space between $B901 and $B9B9

RAMwrite_trap:

;To get to this point the 6502 has tried to write to a page which
;is marked "to be trapped". This usually means I/O or screen memory space.
;
;Some routines just update a RAM copy of a hardware register. Therefore HL is modified from a 6502 address
;to a Z80 address and the 6502 instruction works on the "real" Z80 address
;
;Others require "post-processing" such as writing to the screen. To do this IX is modified to point to another routine.
;This routine is called after the 6502 instruction has been run.
;An example is the colourRAM routine. Any changes to colour RAM are implemented by changing IX to point to "attr2".
;The attr2 routine then updates the Spectrum screen to reflect the change.


;on entry
;hi-byte of trapped address is in L
;lo-byte of trapped address is in C

;when finished
;hi-byte of new address is taken from A
;lo-byte of new address is taken from C

;DON'T NEED TO SAVE AF WITH RAMTRAPs AS WE'VE ALREADY PAGED OUT AF

	LD A,L			;get hi-byte of trapped address
	AND A			;set SF flag, is it >=$80xx (ie: VIA or VIC?)
	JP M,writeIO		;skip if so

;otherwise assume it's the screen
	LD IX,WriteScreen	;draw screen once opcode has been done
	ADD A,ScreenPage-$1E	;adjust msb so virtual 1E00 goes to real RAM address ($9E00)
	LD H,A			;make HL back to what it was
	LD L,C
	LD (RAMtrap),HL		;make note of addr used
	RET			;back to WRITE memory operation!



irq_handler:

;maskable interrupt (IRQ) has been generated
;so push PC and flags on stack
;clear BCD mode (like CMOS 6502)
;and jump to contents of $FFFE

;first un-modify the opcode_decode routine to clear the IRQ

	LD HL,(M1page*256)+$26	;LD H,$M1page instead of JR $-4
				;$26 is opcode for LD H,nn
	LD (op_decode+1),HL	;reset 2 bytes to what they normally are

;PC (DE) is already correct at this point - so stack it
	EX AF,AF' ;'

	LD A,D
	do_pushA
	LD A,E
	do_pushA
	LD HL,FFrealpage*256+$FE	;validate it!
	LD E,(HL)
	INC L		;safe to do as we know HL has to be FFFE - therfore validated page still valid
			;also L will never overflow so quicker to do INC L than INC HL
	LD D,(HL)	;DE (PC) now contains  vector

	EX AF,AF' ;'
	opPHP		;prepare flags in A
	AND $EF		;force B flag to be clear (only IRQ pushes this bit as 0)
	do_pushA	;correct flags are in A

	LD HL,vXflag
	LD A,(HL)
	AND $E3		;clear bits 4,3 and 2 (B,D and I)
	OR $04		;have to set bit 2 (I flag)
	LD (HL),A
irq_finish:
	EX AF,AF' ;'

	JP (IX)		;no incPC as DE (PC) is already correct


;process BREAK as RESTORE key
kkey10:
	LD A,$FE
	IN A,($FE)		;CAPS pressed?
	RRCA
kkey11:
	RET C		;exit if not (C) or if is (NC)
	LD HL,irq1
	LD A,(HL)
	XOR $08		;JR C or JR NC
	LD (HL),A
	LD HL,kkey11
	LD A,(HL)	;see if we're RET C or RET NC
	XOR $08		;D0 or D8
	LD (HL),A
	CP $D8		;=RET C
	RET Z		;exit if so because we can now accept a new BREAK press

kkey12:	
	LD HL,VIA911E	;IER to see if CA1 is enabled
	BIT 1,(HL)	;bit 1 controls CA1
	RET Z		;if not set then CA1 has been disabled
			;therefore no restore key
	DEC HL		;IFR (911D) shows where irq came from
	LD A,(HL)
	OR $82		;set bits 7 (irq flag) and 1 (CA1 irq)
	LD (HL),A	;NMI generate by IM2 routine
	JP signalNMI	;CALL/RET

markIRQ:
	LD A,(op_decode+1)
	CP $18
	JR Z,irq_di		;IRQ can't override NMI
	LD A,$18		;opcode for JR
	LD (op_decode+1),A	;force interrupt to be serviced once
	LD A,irqMD		;displacement value to get to irqM routine
	LD (op_decode+2),A
	JP irq_di

	ORG (IM2page*256)+257+IM2page
;interrupt handler at XYXY address, eg:$B9B9

;check for restore (generate NMI regardless of SEI/CLI setting)
	PUSH AF			;preserve flags
	LD A,$7F
	IN A,($FE)		;SPACE pressed?
	RRCA
irq1:
	JR C,irq2
	PUSH HL	
	CALL kkey10
	POP HL
irq2:
	LD A,(vXflag)
	AND $04			;get I flag
	JR NZ,irq_di		;if set then interrupts are disabled

	LD A,(VIA912E)		;VIA D2IER
	AND $40			;is TIMER1 enabled?
	JP NZ,markIRQ		;if so then get ready to process IRQ

irq_di:

	POP AF
	EI
	RET


	ORG Safepage
;this table is page aligned for speed

VIC9000:
	DB $00
VIC9001:
	DB $00
VIC9002:
	DB $00
VIC9003:
	DB $00
VIC9004:
	DB $00
VIC9005:
	DB $00
VIC9006:
	DB $00
VIC9007:
	DB $00
VIC9008:
	DB $00
VIC9009:
	DB $00
VIC900A:
	DB $00
VIC900B:
	DB $00
VIC900C:
	DB $00
VIC900D:
	DB $00
VIC900E:
	DB $00
VIC900F:
	DB $00
VIA9110:
	DB $00
VIA9111:
	DB $00
VIA9112:
	DB $00
VIA9113:
	DB $00
VIA9114:
	DB $00
VIA9115:
	DB $00
VIA9116:
	DB $00
VIA9117:
	DB $00
VIA9118:
	DB $00
VIA9119:
	DB $00
VIA911A:
	DB $00
VIA911B:
	DB $00
VIA911C:
	DB $00
VIA911D:
	DB $00
VIA911E:
	DB $00
VIA911F:
	DB $00
VIA9120:
	DB $00
VIA9121:
	DB $00
VIA9122:
	DB $00
VIA9123:
	DB $00
VIA9124:
	DB $00
VIA9125:
	DB $00
VIA9126:
	DB $00
VIA9127:
	DB $00
VIA9128:
	DB $00
VIA9129:
	DB $00
VIA912A:
	DB $00
VIA912B:
	DB $00
VIA912C:
	DB $00
VIA912D:
	DB $00
VIA912E:
	DB $00
VIA912F:
	DB $00

;safe gap to stop code being overwritten (AND $3F used so possible to overwrite $30-$3F)
	DB $00,$00,$00,$00
	DB $00,$00,$00,$00
	DB $00,$00,$00,$00
	DB $00,$00,$00,$00

IOread:
;table used for when READING from VIC and VIA registers

	DW VICthru	;$9000 - VIC
	DW VICthru
	DW VICthru
	DW VICraster03	;bit 7 contains lsb bit of raster
	DW VICraster04	;contains bits 1-8 of raster
	DW VICthru
	DW VICthru
	DW VICthru
	DW VICthru	;08
	DW VICthru
	DW VICthru
	DW VICthru
	DW VICthru
	DW VICthru
	DW VICthru
	DW VICthru	;0F
;VIA1
	DW VIAthru	;$9110 +00	D1ORB
	DW D1ORA	;+01
	DW VIAthru
	DW VIAthru
	DW D1T1lsb	;TIMER1 counter lsb
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW D1ORA	;0F (non latching)
;VIA2
	DW D2ORB	;10 - $9120
	DW D2ORA	;11
	DW VIAthru
	DW VIAthru
	DW D2T1lsb	;TIMER1 counter lsb
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW VIAthru
	DW D2ORA	;1F (non latching)

VICthru:
;VIC and VIA just read from RAM copy of register
;they are the same for now
	
VIAthru:
;as MSB of VIAthru is safe as MSB of Safepage
;H is already correct
;and as C is already correct, just ...
	RET

D2ORA:
;attempt to read from keyboard
	XOR A
	IN A,($FE)		;scan all keys at once
	CPL
	AND $1F			;convert FF (no keys) to 00 - setting Z flag
	JR Z,keyQ2		;if Z then no key pressed so quickly exit

;clear previous key states
	PUSH DE
	LD HL,vkeypage		;vkeypage always starts on a page boundary
	LD B,$08
key0:	LD (HL),$FF
	INC L
	DJNZ key0

;read in ZX keyboard (with sym-shift processing)
readZXkeys:
	CALL keyrows

;now read in which VIC key columns should be read (D2ORB) and only process them
	LD A,(VIA9120)		;D2ORB
	LD D,A
	LD A,$FF
	LD HL,vkeypage
	LD B,$08
keyskip1:
	RRC D
	JR C,keyskip2		;only merge in if column was required
	AND (HL)
keyskip2:
	INC L			;vkeypage is page aligned
	DJNZ keyskip1
	POP DE

keyQ:
	LD HL,VIA9121		;D2ORA
	LD (HL),A
	LD C,L		;H already correct from VIA9121
	RET		;back to READ memory operation!
keyQ2:
	LD HL,VIA9121		;D2ORA
	LD (HL),$FF		;no keys
	LD C,L		;H already correct from VIA9121
	RET		;back to READ memory operation!

keyrows:
	LD BC,$7FFE	;port
	IN A,(C)
	LD B,C		;set port to $FEFE ready for main loop
	LD HL,keydata
	RRCA
	RRCA		;is SYM pressed?
	JP C,key1	;skip if not
	LD HL,keydata+$0050	;80 bytes = 2x40 keys
key1:
	IN A,(C)
	PUSH BC
	LD B,$05
key2:
	RRCA
	JP NC,keypressed
	INC HL
key3:
	INC HL
	DJNZ key2
	POP BC
	RLC B
	JP C,key1
	
	IN A,(C)	;BC=$FEFE at this point
	RRCA		;is CAPS pressed?
	RET C		;finished if not

	LD A,$EF	;check for CAPS+number
	IN A,($FE)
	OR $E0		;mask out top 3 bits
	CP $FF
	JR NZ,key4	;deal with 6-0
	LD A,$7F
	IN A,($FE)	;check space ,ie: BREAK
	RRCA
	JP C,keyshiftonly

	LD HL,vkeypage+4
	SET 0,(HL)	;mark SPACE as not pressed
	DEC L		;onto vkeypage+3
	RES 0,(HL)	;mark RUN/STOP as pressed
	RET
keyshiftonly:
	LD HL,vkeypage+3
	RES 1,(HL)	;mark LEFT SHIFT as pressed
	RET
key4:
	RRCA		;deal with CAPS+0
	JR C,keyshiftonly
	LD HL,vkeypage		;deal with col 0
	RES 7,(HL)		;mark DELETE as pressed
	LD HL,vkeypage+7	;0 is in col 7
	SET 4,(HL)		;mark 0 as not pressed
	RET


keypressed:
	LD E,(HL)
	INC HL
	LD D,(vkeypage/256)
	LD C,A		;preserve A
	LD A,(DE)	;get existing key state for VIC20 column
	AND (HL)	;change key status as per table
	LD (DE),A
	LD A,C		;restore A
	JP key3		;quicker than CALL/RET
	
keydata:
	DB $09,$FF	;we don't do caps here
	DB 4,$FD
	DB 3,$FB
	db 4,$FB	;c
	db 3,$F7	;v
	db 2,$FD	;a
	db 5,$FD
	db 2,$FB
	db 5,$FB
	db 2,$F7	;g
	db 6,$FE	;q
	db 1,$FD
	db 6,$FD
	db 1,$FB
	db 6,$FB
	db 0,$FE ;1
	db 7,$FE
	db 0,$FD
	db 7,$FD
	db 0,$FB	;5
	db 7,$EF	;0
	db 0,$EF
	db 7,$F7
	db 0,$F7
	db 7,$FB	;6
	db 1,$DF	;p
	db 6,$EF
	db 1,$EF
	db 6,$F7
	db 1,$F7	;y
	db 1,$7F ;enter
	db 2,$DF
	db 5,$EF
	db 2,$EF
	db 5,$F7	;h
	db 4,$FE	;space
	db $09,$ff	;we don't do sym here
	db 4,$EF
	db 3,$EF
	db 4,$F7	;b
;now with SYM
	db 9,$ff
	db 5,$DF	;':'
	db 0,$BF	;'£'
	db 5,$FE	;'CBM'
	db 3,$BF	;'/'
	db 3,$FE	;'run/STOP'	row 2
	db 9,$ff
	db 9,$ff
	db 9,$ff
	db 9,$ff
	db 9,$ff	;row 3
	db 9,$ff
	db 9,$ff
	db 1,$FE	;'left arrow'
	db 9,$ff
	db 4,$7F	;F1 row 4
	db 6,$DF	;"@"
	db 5,$7F	;F3
	db 7,$BF	;HOME key
	db 6,$7F	;F5
	db 9,$ff	;row 5
	db 9,$ff
	db 2,$7F	;RIGHT cursor key
	db 7,$7F	;F7
	db 3,$7F	;DOWN cursor key
	db 9,$ff	;row 6
	db 2,$BF	;';'
	db 9,$ff
	db 9,$ff
	db 9,$ff
	db 9,$ff	;row 7
	db 5,$BF	;"="
	db 0,$DF	;'+'
	db 7,$DF	;'-'
	db 6,$BF	;'^'
	db 9,$ff	;row 8
	db 9,$ff
	db 4,$DF	;'.'
	db 3,$DF	;','
	db 1,$BF	;'*'


RAMread_trap:
;on entry
;hi-byte of trapped address is in L
;lo-byte of trapped address is in C

;when finished
;hi-byte of new address is taken from H
;lo-byte of new address is taken from C

;ONLY I/O DEVICES ARE TRAPPED WHEN READING

	LD A,C
	AND $3F
	ADD A,A		;double up as 2 bytes per entry
			;A would be transferred to BC
	ADD A,IOread%256	;effectively do HL+BC
	LD L,A		;lsb first
	LD H,IOread/256	;msb next - as A must be <$3F and IOread must be $40 bytes into a page
			;(safepage starts on a page boundary), (A*2)+$40 can never overflow from lsb into msb
	LD B,(HL)
	INC L		;quicker to use INC L than INC HL - always in same page
	LD H,(HL)
	LD L,B		;routine address in HL

	JP (HL)		;jump to routine


D1ORA:
;read joystick
	IN A,($1F)	;read kempston joystick (ZX)
	RRA		;ignore bit 0 (RIGHT)
	AND $0F		;only want FUDL bits
	LD HL,Kempston_Table
	ADD A,L
	LD L,A		;let's hope HL+15 doesn't wrap around a page!!
	LD C,(HL)
	LD HL,VIA9113	;DDR on VIA 1, port A
	LD A,(HL)	;get which bits are input (=0) and output (=1)
	CPL		;we're interested in input bits, so flip
	AND C		;and only keep joystick bits if they're input enabled
	LD C,A
	LD L,VIA9111%256	;H already correct
	LD A,(HL)	;joystick is bits 5,4,3,2
	AND $C3		;so only keep bits 7,6,1,0 of existing VIA value
	OR C		;merge in joystick
	LD (HL),A	;store it in RAM copy of register
	LD C,L		;H already setup
	RET

D2ORB:
;read right bit of joystick
	LD HL,VIA9122		;VIA2 DDRB
	LD C,VIA9120%256	;H is already correct
	BIT 7,(HL)
	RET NZ		;DDR says this port is for output if bit 7 set
			;so no joystick check - therefore skip
	IN A,($1F)	;kempston joystick
	CPL		;flip bits
	AND $01
	RRCA		;joystick R bit into bit 7
	LD B,A
	LD A,(HL)
	AND $7F
	OR B		;merge in joystick
	LD (HL),A	;store in VIA9120 (VIA 2 IO PORT B)
	RET		;H & C already set correctly

D2T1lsb:
	LD HL,VIA9124	;lsb of T1
	JR randomT1

D1T1lsb:
	LD HL,VIA9114	;lsb of T1
randomT1:
	LD A,R
	RLA		;R doesn't set bit 7 randomly, so let's assume CF is random here!
	LD (HL),A
	LD C,L		;H already correct
	RET


vtemp2:
	DB $00

complain:
	LD A,$06
	OUT ($FE),A
	JR complain



writeIO:

;RAM Write trap continues here
;at this point A=msb of trapped address (copy of L register)
;and C=lsb of trapped address

;when finished
;hi-byte of new address is taken from H
;lo-byte of new address is taken from C

;only traps >= $8000 come here - everything else goes to screen write!

	CP $94
	JR C,writeIO2	;we've not trapped a colour RAM write so skip attr1 routine

attr1:
;in this case HL should be between $9400-$97FF (colour RAM)
	LD IX,attr2
	AND $01			;A is 0 or 1 depending on it being $94/96 or $95/97
	ADD A,colourram		;adjust HL so it points to host's
	LD H,A			;address of colour RAM
	LD L,C
	LD (RAMtrap),HL		;6502 will be working on real copy of colour RAM
	RET

writeIO2:
	CP $90
	JR Z,VICchipOUT		;if not $90 then we must be writing to $91xx (VIA)

VIAout:	
	LD A,C			;get lo-byte of original address back
	AND $3F	
	LD C,A			;store safe (0-3F) version of lsb back in C
	LD H,Safepage/256	;write into RAM copy of h/w register
				;H and C now correct
	CPL			;flip bits in A
	AND $0F			;is it 911F or 912F?
	CP $0F
	RET C			;exit if not

;	CP $0E
;	RET C			;finished unless we're talking +0E or +0F
	
;	CP $0F
;	JR NZ,VIAout2
	LD A,C			;deal with 911F and 912F
	AND $F1			;force $1F to 11 and $2F to 21
	LD C,A			;update C
	RET			;done!
	
VIAout2:
;deal with IER of each VIA
	LD A,C
	AND $20			;are we dealing with VIA2
;	JR Z,VIAout3		;jump if so

;	LD IX,DealWithIER1
	RET			;done! (H & C already correct)

VIAout3:
;	LD IX,DealWithIER2
	RET			;done! (H & C already correct)

DealWithIER2:
	LD HL,VIA912E
	JP dealwithIER

DealWithIER1:
	LD HL,VIA911E

dealwithIER:
	EX AF,AF' ;'
	LD IX,op_decode
	LD A,(BC)
	BIT 7,A
	JR Z,clearIER
;set IER:

	OR (HL)			;merge in existing IER
	LD (HL),A
	EX AF,AF' ;'		;back to 6502 AF
	JP (IX)
clearIER:

	CPL
	AND (HL)		;reset bits which were set to 1
	OR $80			;bit 7 is always set when reading back in
	LD (HL),A
	EX AF,AF' ;'		;back to 6502 AF
	JP (IX)


VICchipOUT:
	LD A,C
	AND $0F			;keep to 00-0F
	LD C,A			;update C (lsb)
	ADD A,A			;double up VIC register (00-0F becomes 00-1E)
	LD HL,VICtable		;VICtable doesn't cross page boundary at any point
	ADD A,L			;add lsb of VICtable to A
	LD L,A			;which is lsb for HL
	LD A,(HL)		;can't corrupt C so use A instead
	INC HL
	LD B,(HL)

	DB $DD
	LD H,B			;copy B/A into IX
	DB $DD			;as IX routine will deal with the write request
	LD L,A	

	LD H,Safepage/256	;write into RAM copy of h/w register
				;C (lsb) is already correct
	RET

rVIC900F:
	EX AF,AF' ;'		;save 6502 AF
	LD A,(VIC900F)
	LD H,A
	AND $08
	OR $30
	LD (attr4b),a		;$30=jr nc, $38=jr c
				;default is to JR C,attr6 (effectively jr to attr5)
VIC900Fb:
	LD A,H
	AND $F0			;only need top 4 bits of $900F for background colour
	LD L,A

	LD H,attrs/256
	LD A,(HL)		;convert VIC value (bbbb0fff) into ZX ATTR value
	LD HL,VICbackg
	CP (HL)			;has colour changed?
	LD (HL),A		;set background colour
	CALL NZ,refreshattr	;refresh whole screen if colour has changed
				;and carry on into border routine either way

VIC900Fd:
;sort out border
	LD IX,op_decode
	LD A,(VIC900F)		;get original $900F register contents back
	AND $07			;keep lower bits 0-2 which has border in it

	LD L,A
	ADD A,A
	ADD A,A
	ADD A,A
	ADD A,A			;multiply by 16 to make paper colour (upper) = border (lower ink)
	OR L			;add original ink back in (ink=paper here)
	LD L,A
	LD H,attrs/256
	LD A,(HL)		;convert VIC colour to Speccy colour
	AND $3F			;filter out BRIGHT/FLASH attributes as border can't be bright
	LD (VIC9002d+1),A
	AND $07
	OUT ($FE),A

	LD A,(WriteScreenSize+1)
	NEG			;convert back to 0-31
	LD L,A
	JP VIC9002b1		;don't need to alter screensize so skip first bit
				;this routine draws the "inner border".

rVIC9002:
;number of columns
;also manipulates colourRAM location

	EX AF,AF' ;'		;save 6502 AF
	LD IX,op_decode
	LD BC,$0102
	LD A,(VIC9002)
	AND $80
	RLCA
	RLCA			;A now =0 or =2
	ADD A,$94		;colourRAM base msb now in A				
	LD L,A
	LD H,MWpage
	LD (HL),B		;=trap!
	INC L
	LD (HL),B		;=trap!
;	XOR $02			;trap might not always be =2, but this needs to be =2 for it to work
	XOR C			;change A to the opposite base
	LD L,A
	LD (HL),C		;=dump to ROM (unused)
	INC L
	LD (HL),C		;=dump to ROM (unused)

	LD A,(VIC9002)
	AND $1F			;ignore bit 7 and keep column width as 1-31

VIC9002b:
	LD L,A		;width of screen in L
	NEG		;before we negate it
	LD (WriteScreenSize+1),A
			;adjust VIC column size as required
VIC9002b1:
	LD H,$58
	LD BC,$0020

VIC9002c:
	BIT 5,L		;have we done all 31 cols yet? (we have if we're now at 32)
	JR NZ,VIC9002e	;skip if so

;draw vertical lines
VIC9002d:
	LD (HL),$00	;this value is changed as required
	ADD HL,BC
	LD A,H
	CP $5B		;have we gone outside attr area?
	JR NZ,VIC9002d	;keep going until we do
	LD H,$58	;top of attr again
	INC L		;next column
	JP VIC9002c	;loop until done!

;draw horizontal rows
VIC9002e:
	LD A,$18	;24 ZX rows
	LD HL,write0-1
	SUB (HL)	;subtract number of VIC rows from 24
	JR Z,VIC9002h	;no border rows to draw (row depth =24) so skip
	LD B,A		;we've got B number of rows to do false border in
	LD HL,$5B00
	LD A,(VIC9002d+1)	;VIC border colour

VIC9002f:
	PUSH BC
	LD B,$20	;32 cols
VIC9002g:
	DEC HL
	LD (HL),A
	DJNZ VIC9002g
	POP BC
	DJNZ VIC9002f
VIC9002h:
	JP rVIC9005b	;process start of screen memory (also affected by bit 7 of $9002)

rVIC9003:
;number of rows
	EX AF,AF' ;'	;save 6502 AF
	LD A,(VIC9003)
	AND $7F		;drop bit 7
	RRA		;div by 2 (CF will be cleared by above AND)
			;CF now shows whether we're in 8 or 16 high characters
	LD HL,writescreen4
	JR NC,rVIC9003_8
rVIC9003_16:
	LD (HL),$29	;opcode for ADD HL,HL - needed for 16 high characters
	LD HL,attr316
	LD (HL),$87	;ADD A,A
	LD HL,display7bytes16
	JR VIC9003a
rVIC9003_8:
	LD (HL),$00
	LD HL,attr316
	LD (HL),$00	;NOP
	LD HL,display7bytes8
VIC9003a:
	PUSH DE
	LD DE,write3
	LDI
	LDI		;do this for 7 bytes
	LDI	
	LDI
	LDI
	LDI
	LDI
	LDI		;NEEDS TO BE FOR 8 BYTES NOW DUE TO EXTRA AF,AF'
	POP DE
	DEC A		;setting rows to zero upsets screendraw routine!
			;0-24 to 255-23
	CP $18		;only up to 24 rows allowed
	JR C,VIC9003b
	LD A,$17	;force to 23+1 rows
VIC9003b:
	INC A		;bring back to 1-24
	LD (write0-1),A	;alter gfx routine to display correct number of rows
	LD (write1+1),A
	LD (attr3-1),A	;and attribute routine too
	LD (attr4a+1),A
	CALL refreshattr
	LD IX,op_decode
	JP VIC9002e	;exit via column routine to draw new false border
			;only need to draw rows because columns can't have changed via $9003


rVIC9005:
	EX AF,AF' ;'	;save 6502 AF

;deal with charset pointer first

	LD A,(VIC9005)
	LD B,$0F
	AND B			;0-15 only
	LD HL,CharsetTranslation-$0F00	;compensate for BC being $0Fxx
	LD C,A
	ADD HL,BC
	LD A,(HL)	;get new value for charset
	LD HL,WriteScreenSize-$02
	INC (HL)		;force an update
	LD (WriteScreenCharset+2),A	;adjust character set pointer as required


rVIC9005b:

;now deal with screen memory
;  X = ($9005) AND 112
;  Y = ($9002) AND 128
;  Address = 4*Y + 64*X
;
;    X       Y         Address
;
;    128       0             0          0
;    128     128          $200        512
;    144       0          $400       1024
;    144     128          $600       1536
;    160       0          $800       2048
;    160     128          $A00       2560
;    176       0          $C00       3072
;    176     128          $E00       3584
;    192       0         $1000       4096
;    192     128         $1200       4608
;    208       0         $1400       5120
;    208     128         $1600       5632
;    224       0         $1800       6144
;    224     128         $1A00       6656
;    240       0         $1C00       7168
;    240     128         $1E00       7680

	LD HL,(oldVDUtrap)	;address in MW table that was altered
	LD BC,(oldVDUrambytes)	;previous contents of those addresses
	LD (HL),C
	INC L
	LD (HL),B		;effectively untrap them
	LD A,(VIC9002)
	RLCA			;move bit 7 into C flag
	LD A,(VIC9005)
	RRA		;take bit 7 of $9002 into account
	RRCA		;shift significant nybble into
	RRCA
	RRCA		;least significant nybble
	AND $1F		;keep screen memory bits only (32 different values)
	LD C,A
	LD HL,screenmemorymap
	LD B,$00
	ADD HL,BC
	LD A,(HL)			;page to be trapped (also page+1)
	LD HL,WriteScreenSize-$02
	CP (HL)				;have we changed? (this code is also called from elsewhere)
	LD (HL),A
	CALL NZ,RedrawScreen		;if we have then redraw entire screen
	SUB ZPrealpage			;adjust to 6502 memory space (ie:$90 = ZX real address, convert to $10 = VIC real address)
	LD L,A
	LD H,MWpage
	LD (oldVDUtrap),HL
	LD C,(HL)
	LD (HL),trap		;mark as trap
	INC L
	LD B,(HL)
	LD (HL),trap		;mark as trap
	LD (oldVDUrambytes),BC
	EX AF,AF' ;'		;restore 6502 AF
	LD IX,op_decode
	JP (IX)

VICraster04:
	LD HL,VIC9004	;point to bits 1-8 of raster
	LD C,L
	JP VICraster03b	;use same routine as raster03 in case software only reads $9004
			;we've still got to increase $9004 and keep it in range

VICraster03:
	LD HL,VIC9003
	LD A,(HL)
	ADD A,$80
	LD (HL),A
	LD C,L		;H already correct
	RET NC		;finished if bit 0 of raster went from 0 to 1
	INC L		;HL to point to VIC9004 (rest of raster)

VICraster03b:
	INC (HL)	;increase VIC9004 (rest of raster)
	RET P		;finished if 0-127 (which is 0-255 for raster)
	LD A,(HL)
	CP $9C		;max value for raster is 311, so we need to check against 312/2
	RET C		;finished if we're under
	LD (HL),$00	;back to 0
	RET


rVICsoundvol:
;sound volume
	EX AF,AF' ;'	;save 6502 AF
rVICsoundvol1:
	LD IX,op_decode
	LD BC,$FFFD	;port $FFFD - sound port on 128
	LD H,$08	;R8 - vol A
	OUT (C),H
	LD B,$BF	;want port $BFFD now
	LD A,(VIC900E)
	AND $0F		;keep to 0-15
	OUT (C),A	;set volume

	INC H
	LD B,$FF	;port $FFFD again
	OUT (C),H
	LD B,$BF	;want port $BFFD now
	OUT (C),A	;set volume on channel B

	INC H
	LD B,$FF	;port $FFFD again
	OUT (C),H
	LD B,$BF	;want port $BFFD now
	OUT (C),A	;set volume on channel C

;now turn channels on/off

	LD BC,$8000
	LD HL,VIC900D
	LD A,(HL)
	AND B			;is sound channel enabled?
	JR Z,rVICsoundvol2	;0=off
	INC C			;set bit 0. This will be shifted into bit 3.
				;noise is on channel A.

rVICsoundvol2:
	SLA C
	DEC HL		;VIC900C

	LD A,(HL)
	AND B			;is sound channel enabled?
	JR Z,rVICsoundvol3	;0=off
	INC C

rVICsoundvol3:
	SLA C
	DEC HL		;VIC900B

	LD A,(HL)
	AND B			;is sound channel enabled?
	JR Z,rVICsoundvol4	;0=off
	INC C

rVICsoundvol4:
	SLA C
	DEC HL		;VIC900A

	LD A,(HL)
	AND B			;is sound channel enabled?
	JR Z,rVICsoundvol5	;0=off
	INC C

rVICsoundvol5:
	LD A,C		;channels on/off in H now
	CPL		;flip because 0=on on the AY chip!
	LD H,A
	LD BC,$FFFD	;sound port on 128
	LD A,$07	;R7 - tone/noise selection
	OUT (C),A
	LD B,$BF	;want port $BFFD now
	OUT (C),H	;enable all 3 tone channels and possibly noise channel on A

	EX AF,AF' ;'	;restore 6502 AF
	JP (IX)

rVICsoundA:
;IX set via rVICsoundvol
	EX AF,AF' ;'	;save 6502 AF
	LD A,(VIC900A)
	CPL		;255 is highest note
	LD L,A
	LD H,$00
	LD B,H
	LD C,L		;copy HL into BC
	ADD HL,HL	;x2
	ADD HL,BC	;x3
	ADD HL,HL	;x6
	ADD HL,HL	;x12
	ADD HL,BC	;x13
	ADD HL,HL	;x26
			;real value should be 25.6, but this is close enough!
	LD BC,$FFFD
	XOR A		;R0 - lsb of tone for channel A
	OUT (C),A	;select register of 128 sound chip
	LD B,$BF	;port $BFFD
	OUT (C),L	;out lsb of period
	LD B,$FF
	INC A		;R1 - msb of tone
	OUT (C),A
	LD B,$BF
	OUT (C),H	;out msb of period
	JP rVICsoundvol1	;if not then channel should be silent!
				;so just set volume to 0 via this routine


rVICsoundB:
;IX set via rVICsoundvol
	EX AF,AF' ;'	;save 6502 AF
	LD A,(VIC900B)
	CPL
	LD L,A
	LD H,$00
	LD B,H
	LD C,L		;copy HL into BC
	ADD HL,HL	;x2
	ADD HL,BC	;x3
	ADD HL,HL	;x6
	ADD HL,HL	;x12
	ADD HL,BC	;x13
			;real value should be 12.8, but this is close enough!
	LD BC,$FFFD
	LD A,$02	;R2 - lsb of tone for channel B
	OUT (C),A	;select register of 128 sound chip
	LD B,$BF	;port $BFFD
	OUT (C),L	;out lsb of period
	LD B,$FF
	INC A		;R3 - msb of tone
	OUT (C),A
	LD B,$BF
	OUT (C),H	;out msb of period
	JP rVICsoundvol1	;if not then channel should be silent!
				;so just set volume to 0 via this routine

rVICsoundC:
;IX set via rVICsoundvol
	EX AF,AF' ;'	;save 6502 AF
	LD A,(VIC900C)
	CPL
	LD L,A
	LD H,$00
	LD B,H
	SRL A		;halve A
	LD C,A		;so half HL is in BC
	ADD HL,BC	;x1.5
	ADD HL,HL	;x3
	ADD HL,HL	;x6
	ADD HL,BC	;x6.5
			;real value should be 6.4, but this is close enough!
	LD BC,$FFFD
	LD A,$04	;R4 - lsb of tone for channel C
	OUT (C),A	;select register of 128 sound chip
	LD B,$BF	;port $BFFD
	OUT (C),L	;out lsb of period
	LD B,$FF
	INC A		;R5 - msb of tone
	OUT (C),A
	LD B,$BF
	OUT (C),H	;out msb of period
	JP rVICsoundvol1	;if not then channel should be silent!
				;so just set volume to 0 via this routine

rVICsoundD:
;IX set via rVICsoundvol
	EX AF,AF' ;'	;save 6502 AF
	LD A,(VIC900D)
	CPL		;255 is highest note
	LD L,A
	LD H,$00
	LD B,H
	LD C,L		;copy HL into BC

	ADD HL,HL	;x2
	ADD HL,BC	;x3
	ADD HL,HL	;x6
	ADD HL,HL	;x12
	ADD HL,BC	;x13

;	LD A,L		;keep only lsb of result as noise channel only has 5-bit resolution on AY
	SRL L		;halve A
	SRL L		;quarter A as quarter of 13 = 3.25
			;real value should be 3.2, but this is close enough!

	LD BC,$FFFD
	LD A,$06	;R6 - tone for noise channel
	OUT (C),A	;select register of 128 sound chip
	LD B,$BF	;port $BFFD
	OUT (C),L	;out lsb of period
	JP rVICsoundvol1

refreshattr:
	LD HL,colourram*256	;start at top left
	LD IX,refreshattr2
	PUSH AF			;save our AF because both AF and AF' will be destroyed
refreshattr1:
	PUSH HL			;remember which attr square we're updating for later
	PUSH DE			;preserve DE

	JP attr30B		;refresh attr
;JP (IX) comes back here with 6502 AF paged in and POP DE already done
refreshattr2:
	POP HL			;get which attr square we're updating back
	INC HL
	LD A,colourram+2	;done all 512? (2 pages = 512 bytes)
	CP H
	JP NZ,refreshattr1
	POP AF			;restore 6502 AF as current AF
	RET

RedrawScreen:
	PUSH AF
	LD H,A			; H will contain 'screenpage'
	LD L,$00
	LD IX,redraw2
	LD BC,$0200
redraw1:
	PUSH BC
	PUSH HL
	JP WriteDirect
redraw2:
	POP HL
	INC HL
	POP BC
	DEC BC
	LD A,B
	OR C
	JR NZ,redraw1
	POP AF
	RET

;FOLLOWING IS BASED ON GEOFF WEARMOUTH'S ROM DISASSEMBLY
;It is not verified to work yet (on real hardware)
;It allos you to load a headerless block of code into VIC RAM space from 0000 upwards

; ------------------------------------
; Load header or block of information
; ------------------------------------
;   This routine is used to load bytes and on entry A is set to $00 for a 
;   header or to $FF for data.  IX points to the start of receiving location 
;   and DE holds the length of bytes to be loaded. If, on entry the carry flag 
;   is set then data is loaded, if reset then it is verified.

;; LD-BYTES
L0556:  INC     D               ; reset the zero flag without disturbing carry.
        EX      AF,AF' ;'          ; preserve entry flags.
        DEC     D               ; restore high byte of length.

        DI                      ; disable interrupts

        LD      A,$0F           ; make the border white and mic off.
        OUT     ($FE),A         ; output to port.


;   the reading of the EAR bit (D6) will always be preceded by a test of the 
;   space key (D0), so store the initial post-test state.

        IN      A,($FE)         ; read the ear state - bit 6.
        RRA                     ; rotate to bit 5.
        AND     $20             ; isolate this bit.
        OR      $02             ; combine with red border colour.
        LD      C,A             ; and store initial state long-term in C.
        CP      A               ; set the zero flag.

; 

;; LD-BREAK
L056B:  RET     NZ              ; return if at any time space is pressed.

;; LD-START
L056C:  CALL    L05E7           ; routine LD-EDGE-1
        JR      NC,L056B        ; back to LD-BREAK with time out and no
                                ; edge present on tape.

;   but continue when a transition is found on tape.

        LD      HL,$0415        ; set up 16-bit outer loop counter for 
                                ; approx 1 second delay.

;; LD-WAIT
L0574:  DJNZ    L0574           ; self loop to LD-WAIT (for 256 times)

        DEC     HL              ; decrease outer loop counter.
        LD      A,H             ; test for
        OR      L               ; zero.
        JR      NZ,L0574        ; back to LD-WAIT, if not zero, with zero in B.

;   continue after delay with H holding zero and B also.
;   sample 256 edges to check that we are in the middle of a lead-in section. 

        CALL    L05E3           ; routine LD-EDGE-2
        JR      NC,L056B        ; back to LD-BREAK
                                ; if no edges at all.

;; LD-LEADER
L0580:  LD      B,$9C           ; set timing value.
        CALL    L05E3           ; routine LD-EDGE-2
        JR      NC,L056B        ; back to LD-BREAK if time-out

        LD      A,$C6           ; two edges must be spaced apart.
        CP      B               ; compare
        JR      NC,L056C        ; back to LD-START if too close together for a 
                                ; lead-in.

        INC     H               ; proceed to test 256 edged sample.
        JR      NZ,L0580        ; back to LD-LEADER while more to do.

;   sample indicates we are in the middle of a two or five second lead-in.
;   Now test every edge looking for the terminal sync signal.

;; LD-SYNC
L058F:  LD      B,$C9           ; initial timing value in B.
        CALL    L05E7           ; routine LD-EDGE-1
        JR      NC,L056B        ; back to LD-BREAK with time-out.

        LD      A,B             ; fetch augmented timing value from B.
        CP      $D4             ; compare 
        JR      NC,L058F        ; back to LD-SYNC if gap too big, that is,
                                ; a normal lead-in edge gap.

;   but a short gap will be the sync pulse.
;   in which case another edge should appear before B rises to $FF

        CALL    L05E7           ; routine LD-EDGE-1
        RET     NC              ; return with time-out.

; proceed when the sync at the end of the lead-in is found.
; We are about to load data so change the border colours.

        LD      A,C             ; fetch long-term mask from C
        XOR     $03             ; and make blue/yellow.

        LD      C,A             ; store the new long-term byte.

        LD      H,$00           ; set up parity byte as zero.
        LD      B,$B0           ; timing.
        JR      L05C8           ; forward to LD-MARKER 
                                ; the loop mid entry point with the alternate 
                                ; zero flag reset to indicate first byte 
                                ; is discarded.

; --------------
;   the loading loop loads each byte and is entered at the mid point.

;; LD-LOOP
L05A9:  EX      AF,AF' ;'          ; restore entry flags and type in A.
        JR      NZ,L05B3        ; forward to LD-FLAG if awaiting initial flag
                                ; which is to be discarded.

        JR      NC,L05BD        ; forward to LD-VERIFY if not to be loaded.

	EX AF,AF' ;'
	LD B,MRpage		;this allows us to write ROM cart area
	DB $DD
	LD C,H
	LD A,(BC)		;translated page
	DEC A			;now has correct value
	LD B,A
	DB $DD
	LD C,L			;ZX address in BC
	EX AF,AF' ;'
	LD A,L			;byte loaded from tape (must keep!)
	LD (BC),A		; place loaded byte at memory location.
        JR L05C2           ; forward to LD-NEXT

; ---

;; LD-FLAG
;first byte is 00 for header, FF for data
;last byte is parity
L05B3:  RL      C               ; preserve carry (verify) flag in long-term
                                ; state byte. Bit 7 can be lost.

        XOR     L               ; compare type in A with first byte in L.
        RET     NZ              ; return if no match e.g. CODE vs. DATA.

;   continue when data type matches.

        LD      A,C             ; fetch byte with stored carry
        RRA                     ; rotate it to carry flag again
        LD      C,A             ; restore long-term port state.

        JR      L05C5           ; forward to LD-DEC.
                                ; but why not to location after ?


;;LD-VERIFY
L05BD:

;; LD-NEXT
L05C2:  INC     IX              ; increment byte pointer.

;; LD-DEC
L05C4:  DEC     DE              ; decrement length.

L05C5:
        EX      AF,AF' ;'          ; store the flags.
        LD      B,$B2           ; timing.

;   when starting to read 8 bits the receiving byte is marked with bit at right.
;   when this is rotated out again then 8 bits have been read.

;; LD-MARKER
L05C8:  LD      L,$01           ; initialize as %00000001

;; LD-8-BITS
;returns byte loaded in L
L05CA:  CALL    L05E3           ; routine LD-EDGE-2 increments B relative to
                                ; gap between 2 edges.
        RET     NC              ; return with time-out.

        LD      A,$CB           ; the comparison byte.
        CP      B               ; compare to incremented value of B.
                                ; if B is higher then bit on tape was set.
                                ; if <= then bit on tape is reset. 

        RL      L               ; rotate the carry bit into L.

        LD      B,$B0           ; reset the B timer byte.
        JP      NC,L05CA        ; JUMP back to LD-8-BITS

;   when carry set then marker bit has been passed out and byte is complete.

        LD      A,H             ; fetch the running parity byte.
        XOR     L               ; include the new byte.
        LD      H,A             ; and store back in parity register.

        LD      A,D             ; check length of
        OR      E               ; expected bytes.
        JR      NZ,L05A9        ; back to LD-LOOP 
                                ; while there are more.

;   when all bytes loaded then parity byte should be zero.

        LD      A,H             ; fetch parity byte.
        CP      $01             ; set carry if zero.
        RET                     ; return
                                ; in no carry then error as checksum disagrees.
; -------------------------
; Check signal being loaded
; -------------------------
;   An edge is a transition from one mic state to another.
;   More specifically a change in bit 6 of value input from port $FE.
;   Graphically it is a change of border colour, say, blue to yellow.
;   The first entry point looks for two adjacent edges. The second entry point
;   is used to find a single edge.
;   The B register holds a count, up to 256, within which the edge (or edges) 
;   must be found. The gap between two edges will be more for a '1' than a '0'
;   so the value of B denotes the state of the bit (two edges) read from tape.

; ->

;; LD-EDGE-2
L05E3:  CALL    L05E7           ; call routine LD-EDGE-1 below.
        RET     NC              ; return if space pressed or time-out.
                                ; else continue and look for another adjacent 
                                ; edge which together represent a bit on the 
                                ; tape.

; -> 
;   this entry point is used to find a single edge from above but also 
;   when detecting a read-in signal on the tape.

;; LD-EDGE-1
L05E7:  LD      A,$16           ; a delay value of twenty two.

;; LD-DELAY
L05E9:  DEC     A               ; decrement counter
        JR      NZ,L05E9        ; loop back to LD-DELAY 22 times.

        AND      A              ; clear carry.

;; LD-SAMPLE
L05ED:  INC     B               ; increment the time-out counter.
        RET     Z               ; return with failure when $FF passed.

        LD      A,$7F           ; prepare to read keyboard and EAR port
        IN      A,($FE)         ; row $7FFE. bit 6 is EAR, bit 0 is SPACE key.
        RRA                     ; test outer key the space. (bit 6 moves to 5)
        RET     NC              ; return if space pressed.  >>>

        XOR     C               ; compare with initial long-term state.
        AND     $20             ; isolate bit 5
        JR      Z,L05ED         ; back to LD-SAMPLE if no edge.

;   but an edge, a transition of the EAR bit, has been found so switch the
;   long-term comparison byte containing both border colour and EAR bit. 

        LD      A,C             ; fetch comparison value.
        CPL                     ; switch the bits
        LD      C,A             ; and put back in C for long-term.

        AND     $07             ; isolate new colour bits.
        OR      $08             ; set bit 3 - MIC off.
        OUT     ($FE),A         ; send to port to effect the change of colour. 

        SCF                     ; set carry flag signaling edge found within
                                ; time allowed.
        RET                     ; return.


VICLOAD:
	PUSH IX
	PUSH DE
	PUSH AF
	LD IX,$0000
	LD DE,$4000
	LD A,$FF
	SCF
	CALL L0556
	POP AF
	POP DE
	POP IX
	EI
	LD DE,$E5B5	;VIC KERNAL panic
	JP (IX)		;back to 6502

	ORG $1450+base
VICtable:
;MUST NOT STRADDLE A PAGE BOUNDARY!
;list of routines that deal with each register of VIC chip
;when WRITING to register
	DW VICignore
	DW VICignore
	DW rVIC9002	;col width
	DW rVIC9003	;row depth
	DW VICignore
	DW rVIC9005	;charmap pointer
	DW VICignore
	DW VICignore
	DW VICignore
	DW VICignore
	DW rVICsoundA	;channel A
	DW rVICsoundB	;channel B
	DW rVICsoundC	;channel C
	DW VICignore
	DW rVICsoundvol	;sound volume
	DW rVIC900F	;border colour

VICignore:
	LD IX,op_decode
	EX AF,AF' ;'		;restore 6502 AF
	JP (IX)		;ignore value and carry on!

;was org $0e00+base

	ORG $1490+base
CharsetTranslation:
;safe place for CHARSET translation table
;subtract 240 from POKE $9005,x value
	DB chargen/256
	DB (chargen/256)+4
	DB (chargen/256)+8
	DB (chargen/256)+12
	DB $00		;would be VIC i/o space
	DB colourram	;colour RAM
	DB $00
	DB $00		;these 2 would do nothing anyway
	DB ZPrealpage	;page 0!
	DB ZPrealpage+4	;1024
	DB ZPrealpage+8	;2048
	DB ZPrealpage+12	;3192
	DB ZPrealpage+16
	DB ZPrealpage+20
	DB ZPrealpage+24
	DB ZPrealpage+28	;7168
screenmemorymap:
;take bits 7-4 of $9005. Rotate right
;move bit 7 of $9002 into bit 7 of result
	DB 0			;$8000
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB ZPrealpage
	DB ZPrealpage+4
	DB ZPrealpage+8
	DB ZPrealpage+12
	DB ZPrealpage+16
	DB ZPrealpage+20
	DB ZPrealpage+24
	DB ZPrealpage+28
	DB 0			;$8200
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
	DB ZPrealpage+2
	DB ZPrealpage+6
	DB ZPrealpage+10
	DB ZPrealpage+14
	DB ZPrealpage+18
	DB ZPrealpage+22
	DB ZPrealpage+26
	DB ZPrealpage+30
oldVDUtrap:
	DW vkeypage		;address in MW table that was altered
				;fill with dummy address to stop it altering $0000/$01
oldVDUrambytes:
	DW $00			;previous contents of those addresses


	ORG base+$1000

;this is a safe blank area to use that's on a page boundary
vkeypage:
	DB $00
	DB $00
	DB $00
	DB $00
	DB $00
	DB $00
	DB $00
	DB $00


	ORG base+$08C6
;kempston table - converts IN31 to VIC equivalent
;this 16-byte table must not cross a page boundary!
;it doesn't have to be page aligned though!

;don't need bit 0 of IN 31 (RIGHT) as that's in a separate VIC register

Kempston_Table:
	DB $FF	;nothing pressed (all values INVERTED)
	DB $EF	;L (bit 4 on VIC)
	DB $F7	;D (bit 3 on VIC)
	DB $E7	;LD
	DB $FB	;U (bit 2 on VIC)
	DB $EB	;LU
	DB $F3	;UD
	DB $E3	;LUD
	DB $DF	;F	(bit 5 on VIC)
	DB $CF	;FL
	DB $D7	;FD
	DB $C7	;FLD
	DB $D3	;FU
	DB $CB	;FLU
	DB $D3	;FUD
	DB $C3	;FLUD

	ORG base+$2600
;this occupies last page before MR,MW,M1,IRQroutine,IM2 tables
rowtable:
	DW $4000
	DW $4020
	DW $4040
	DW $4060
	DW $4080
	DW $40A0
	DW $40C0
	DW $40E0
	DW $4800
	DW $4820
	DW $4840
	DW $4860
	DW $4880
	DW $48A0
	DW $48C0
	DW $48E0
	DW $5000
	DW $5020
	DW $5040
	DW $5060
	DW $5080
	DW $50A0
	DW $50C0
	DW $50E0
;repeat list of addresses again in case somebody sets row depth >24
	DW $4000
	DW $4020
	DW $4040
	DW $4060
	DW $4080
	DW $40A0
	DW $40C0
	DW $40E0
	DW $4800
	DW $4820
	DW $4840
	DW $4860
	DW $4880
	DW $48A0
	DW $48C0
	DW $48E0


VICborder:
	DB $00
VICbackg:
	DB $00
VICforeg:
	DB $00


	ORG base+$2500
attrs:
;	R   G   B
;			needs to go Ggg Rrr Bb
;black	00  00  00
;	000 000 00 = $00	= 000 000 00 = $00
;white	FF  FF  FF
;	111 111 11 = $FF	= 111 111 11 = $FF
;red	B4  18  18
;	110 001 00 = $C4	= 001 110 00 = $38
;cyan	4C  E6  D8
;	010 110 10 = $5A	= 110 010 10 = $CA
;purple	BC  29  CA
;	110 001 10 = $C6	= 001 110 10 = $3A
;green	42  E4  36
;	010 110 01 = $59	= 110 010 01 = $C9
;blue	32  2A  C8
;	001 001 10 = $2C	= 001 001 10 = $26
;yellow	D2  E1  26
;	110 110 01 = $D9	= 110 110 01 = $D9
;orange	CA  5A  02
;	110 011 00 = $CC	= 011 110 00 = $78
;l oran	DE  AC  80
;	110 101 10 = $D6	= 101 110 10 = $BA
;pink	DC  94  94
;	110 100 10 = $D2 	= 100 110 10 = $9A
;l cyan	A5  F4  EC
;	101 111 11 = $BF	= 111 101 11 = $F7
;l purp E0  9A  E4
;	110 101 11 = $D7	= 101 110 11 = $BB
;l grn	A0  F2  9A
;	101 111 10 = $BE	= 111 101 10 = $F6
;l blue	9C  92  E4
;	101 100 11 = $B3	= 100 101 11 = $97
;l yel	EF  F8  9A
;	111 111 10 = $FE	= 111 111 10 = $FE



;8 cols is black,white,red,cyan,purple,green,blue,yellow

	ORG attrs
        DB 0	; p=blk i=blk
        DB 7	; p=blk i=wht
        DB 2	; p=blk i=red
        DB 5	; p=blk i=cyn
        DB 3	; p=blk i=pur
        DB 4	; p=blk i=grn
        DB 1	; p=blk i=blu
        DB 6	; p=blk i=yel
        DB 6	; p=blk i=ora
        DB 70	; p=blk i=l ora
        DB 66	; p=blk i=l pnk
        DB 69	; p=blk i=l cyn
        DB 67	; p=blk i=l pur
        DB 68	; p=blk i=l grn
        DB 65	; p=blk i=l blu
        DB 70	; p=blk i=l yel
        DB 56	; p=wht i=blk
        DB 63	; p=wht i=wht
        DB 58	; p=wht i=red
        DB 61	; p=wht i=cyn
        DB 59	; p=wht i=pur
        DB 60	; p=wht i=grn
        DB 57	; p=wht i=blu
        DB 62	; p=wht i=yel
        DB 62	; p=wht i=ora
        DB 126	; p=wht i=l ora
        DB 122	; p=wht i=l pnk
        DB 125	; p=wht i=l cyn
        DB 123	; p=wht i=l pur
        DB 124	; p=wht i=l grn
        DB 121	; p=wht i=l blu
        DB 126	; p=wht i=l yel
        DB 16	; p=red i=blk
        DB 23	; p=red i=wht
        DB 18	; p=red i=red
        DB 21	; p=red i=cyn
        DB 19	; p=red i=pur
        DB 20	; p=red i=grn
        DB 17	; p=red i=blu
        DB 22	; p=red i=yel
        DB 22	; p=red i=ora
        DB 86	; p=red i=l ora
        DB 83	; p=red i=l pnk clash
        DB 85	; p=red i=l cyn
        DB 83	; p=red i=l pur
        DB 84	; p=red i=l grn
        DB 81	; p=red i=l blu
        DB 86	; p=red i=l yel
        DB 40	; p=cyn i=blk
        DB 47	; p=cyn i=wht
        DB 42	; p=cyn i=red
        DB 45	; p=cyn i=cyn
        DB 43	; p=cyn i=pur
        DB 44	; p=cyn i=grn
        DB 41	; p=cyn i=blu
        DB 46	; p=cyn i=yel
        DB 46	; p=cyn i=ora
        DB 110	; p=cyn i=l ora
        DB 106	; p=cyn i=l pnk
        DB 77	; p=cyn i=l cyn
        DB 107	; p=cyn i=l pur
        DB 108	; p=cyn i=l grn
        DB 105	; p=cyn i=l blu
        DB 110	; p=cyn i=l yel
        DB 24	; p=pur i=blk
        DB 31	; p=pur i=wht
        DB 26	; p=pur i=red
        DB 29	; p=pur i=cyn
        DB 27	; p=pur i=pur
        DB 28	; p=pur i=grn
        DB 25	; p=pur i=blu
        DB 30	; p=pur i=yel
        DB 30	; p=pur i=ora
        DB 94	; p=pur i=l ora
        DB 90	; p=pur i=l pnk
        DB 93	; p=pur i=l cyn
        DB 93	; p=pur i=l pur clash
        DB 92	; p=pur i=l grn
        DB 89	; p=pur i=l blu
        DB 94	; p=pur i=l yel
        DB 32	; p=grn i=blk
        DB 39	; p=grn i=wht
        DB 34	; p=grn i=red
        DB 37	; p=grn i=cyn
        DB 35	; p=grn i=pur
        DB 36	; p=grn i=grn
        DB 33	; p=grn i=blu
        DB 38	; p=grn i=yel
        DB 38	; p=grn i=ora
        DB 102	; p=grn i=l ora
        DB 98	; p=grn i=l pnk
        DB 101	; p=grn i=l cyn
        DB 99	; p=grn i=l pur
        DB 101	; p=grn i=l grn clash
        DB 97	; p=grn i=l blu
        DB 102	; p=grn i=l yel
        DB 8	; p=blu i=blk
        DB 15	; p=blu i=wht
        DB 10	; p=blu i=red
        DB 13	; p=blu i=cyn
        DB 11	; p=blu i=pur
        DB 12	; p=blu i=grn
        DB 9	; p=blu i=blu
        DB 14	; p=blu i=yel
        DB 14	; p=blu i=ora
        DB 78	; p=blu i=l ora
        DB 74	; p=blu i=l pnk
        DB 77	; p=blu i=l cyn
        DB 75	; p=blu i=l pur
        DB 76	; p=blu i=l grn
        DB 77	; p=blu i=l blu clash
        DB 78	; p=blu i=l yel
        DB 48	; p=yel i=blk
        DB 55	; p=yel i=wht
        DB 50	; p=yel i=red
        DB 53	; p=yel i=cyn
        DB 51	; p=yel i=pur
        DB 52	; p=yel i=grn
        DB 49	; p=yel i=blu
        DB 54	; p=yel i=yel
        DB 50	; p=yel i=ora clash
        DB 114	; p=yel i=l ora clash
        DB 114	; p=yel i=l pnk
        DB 117	; p=yel i=l cyn
        DB 115	; p=yel i=l pur
        DB 116	; p=yel i=l grn
        DB 113	; p=yel i=l blu
        DB 119	; p=yel i=l yel clash
        DB 48	; p=ora i=blk
        DB 55	; p=ora i=wht
        DB 50	; p=ora i=red
        DB 53	; p=ora i=cyn
        DB 51	; p=ora i=pur
        DB 52	; p=ora i=grn
        DB 49	; p=ora i=blu
        DB 22	; p=ora i=yel clash
        DB 54	; p=ora i=ora
        DB 86	; p=ora i=l ora clash
        DB 114	; p=ora i=l pnk
        DB 117	; p=ora i=l cyn
        DB 115	; p=ora i=l pur
        DB 116	; p=ora i=l grn
        DB 113	; p=ora i=l blu
        DB 22	; p=ora i=l yel clash
        DB 112	; p=l ora i=blk
        DB 119	; p=l ora i=wht
        DB 114	; p=l ora i=red
        DB 117	; p=l ora i=cyn
        DB 115	; p=l ora i=pur
        DB 116	; p=l ora i=grn
        DB 113	; p=l ora i=blu
        DB 86	; p=l ora i=yel clash
        DB 86	; p=l ora i=ora clash
        DB 118	; p=l ora i=l ora
        DB 114	; p=l ora i=l pnk
        DB 117	; p=l ora i=l cyn
        DB 115	; p=l ora i=l pur
        DB 116	; p=l ora i=l grn
        DB 113	; p=l ora i=l blu
        DB 119	; p=l ora i=l yel clash
        DB 80	; p=l pnk i=blk
        DB 87	; p=l pnk i=wht
        DB 83	; p=l pnk i=red clash
        DB 85	; p=l pnk i=cyn
        DB 83	; p=l pnk i=pur
        DB 84	; p=l pnk i=grn
        DB 81	; p=l pnk i=blu
        DB 86	; p=l pnk i=yel
        DB 86	; p=l pnk i=ora
        DB 86	; p=l pnk i=l ora
        DB 82	; p=l pnk i=l pnk
        DB 85	; p=l pnk i=l cyn
        DB 83	; p=l pnk i=l pur
        DB 84	; p=l pnk i=l grn
        DB 81	; p=l pnk i=l blu
        DB 86	; p=l pnk i=l yel
        DB 104	; p=l cyn i=blk
        DB 111	; p=l cyn i=wht
        DB 106	; p=l cyn i=red
        DB 105	; p=l cyn i=cyn clash
        DB 107	; p=l cyn i=pur
        DB 108	; p=l cyn i=grn
        DB 105	; p=l cyn i=blu
        DB 110	; p=l cyn i=yel
        DB 110	; p=l cyn i=ora
        DB 110	; p=l cyn i=l ora
        DB 106	; p=l cyn i=l pnk
        DB 109	; p=l cyn i=l cyn
        DB 107	; p=l cyn i=l pur
        DB 108	; p=l cyn i=l grn
        DB 105	; p=l cyn i=l blu
        DB 110	; p=l cyn i=l yel
        DB 88	; p=l pur i=blk
        DB 95	; p=l pur i=wht
        DB 90	; p=l pur i=red
        DB 93	; p=l pur i=cyn
        DB 93	; p=l pur i=pur clash
        DB 92	; p=l pur i=grn
        DB 89	; p=l pur i=blu
        DB 94	; p=l pur i=yel
        DB 94	; p=l pur i=ora
        DB 94	; p=l pur i=l ora
        DB 90	; p=l pur i=l pnk
        DB 93	; p=l pur i=l cyn
        DB 91	; p=l pur i=l pur
        DB 92	; p=l pur i=l grn
        DB 89	; p=l pur i=l blu
        DB 94	; p=l pur i=l yel
        DB 96	; p=l grn i=blk
        DB 103	; p=l grn i=wht
        DB 98	; p=l grn i=red
        DB 101	; p=l grn i=cyn
        DB 99	; p=l grn i=pur
        DB 101	; p=l grn i=grn clash
        DB 97	; p=l grn i=blu
        DB 102	; p=l grn i=yel
        DB 102	; p=l grn i=ora
        DB 102	; p=l grn i=l ora
        DB 98	; p=l grn i=l pnk
        DB 101	; p=l grn i=l cyn
        DB 99	; p=l grn i=l pur
        DB 100	; p=l grn i=l grn
        DB 97	; p=l grn i=l blu
        DB 102	; p=l grn i=l yel
        DB 72	; p=l blu i=blk
        DB 79	; p=l blu i=wht
        DB 74	; p=l blu i=red
        DB 77	; p=l blu i=cyn
        DB 75	; p=l blu i=pur
        DB 76	; p=l blu i=grn
        DB 72	; p=l blu i=blu clash
        DB 78	; p=l blu i=yel
        DB 78	; p=l blu i=ora
        DB 78	; p=l blu i=l ora
        DB 74	; p=l blu i=l pnk
        DB 77	; p=l blu i=l cyn
        DB 75	; p=l blu i=l pur
        DB 76	; p=l blu i=l grn
        DB 73	; p=l blu i=l blu
        DB 78	; p=l blu i=l yel
        DB 112	; p=l yel i=blk
        DB 119	; p=l yel i=wht
        DB 114	; p=l yel i=red
        DB 117	; p=l yel i=cyn
        DB 115	; p=l yel i=pur
        DB 116	; p=l yel i=grn
        DB 113	; p=l yel i=blu
        DB 119	; p=l yel i=yel clash
        DB 114	; p=l yel i=ora clash
        DB 114	; p=l yel i=l ora clash
        DB 114	; p=l yel i=l pnk
        DB 117	; p=l yel i=l cyn
        DB 115	; p=l yel i=l pur
        DB 116	; p=l yel i=l grn
        DB 113	; p=l yel i=l blu
        DB 118	; p=l yel i=l yel

;#END
        ;display "begin=",begin
end=(M1page*256)+M1pagesize
        display "end=",end


	savebin "vic20.com",begin,end-begin

	LABELSLIST "../../us/user.l"

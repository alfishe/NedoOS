Uwol - Quest For Money v1.2 (22.11.11)

2006-2009 Mojon Twins (http://mojontwins.com/)
2010 Shiru (shiru@mail.ru http://shiru.untergrund.net/)

The original game was made for ZX Spectrum by Mojon Twins, a team of homebrew game developers from Spain, and released in 2009. It is a nice little old-style arcade game about jumping around and collecting coins, and I liked it much. Unusual thing about all the Mojon Twins games is that they are made in C (for platforms with Z80 @ ~3.5 MHz). After I looked into the sources, I got an idea to try to port the game to SMD using the original sources. I asked Na_th_an from Mojon Twins for permission, he said they don't mind, as long as they are credited, and the game remains open source.

I wanted to make not just exact port of the game, which would make not much sense, but to improve some details, as long as they will not take too much time.

The project has been started February 18 2010, and pre-release version was finished March 3. This include few days of fulltime (>8hrs) work on the project. Most part of the time took graphics works, then code, and least part of the time (about 3 days) took sound part.

Code. The original code was modified, both in porting process, and also in order to improve the playability. The most difficult parts were tweaking all the parameters to slowdown the movements (the original runs at ~35 frames per second, SMD version at 50 frames per second) without breaking the gameplay, reworking player-background collisions to make player bounding box smaller (very important to make jumps in tight places easier). Most boring thing was conversion of the levels data - in the original they are stored as assembly listing with lot of db's with binary numbers, arranged as C structure (so you can just set structure pointer to the address, and get all the data in comfortable way, as the structure fields). I had to manually edit all >1500 lines of the data to convert it into BIN macro (making conversion script should've took about the same time), and load the data into RAM array of structures at start-up. All the levels were tested to be possible to beat, few changes were made to compensate changes in the gameplay.

Everything was done using emulators - mostly Gens32, also Gens KMod, Regen, Megasys, Kega Fusion. No tests on the real hardware were made until almost finished version. The only test on the hardware was done by HardWareMan March 3, it ran without any problems for first attempt.

Music. When I started to think about the music, I got problems with .NET on my PC, so WYZ Tracker (the tool where the original music was made) refused to work, though it worked before. All attempts to fix the problem wasn't successful, so I had to think up another solution, rather than recreating the music by hand. Possible solutions were to reverse-engineer the original sound format (using Z80 player source code), and make player or converter; or make AY registers dump of the original music, and then convert it into FM somehow. Accidentally I figured out that the WYZ tracker stores it's data in GZip'ed XML files, so the solution was to make custom tool to convert the original data (notes only) into TFM Music Maker v1.4 format. Making of the tool took a single day, and manual editing of converted music took another day.

Sound. I felt really lazy about recreating all the effects by hand, so I decided to convert the original effects. I also felt lazy about reverse-engineering the original effects data, so I modified original driver to play all the effects one by one, ran it in Z80Stealth emulator, and dumped AY-3-8910 registers output into PSG file. Then I made a custom tool that converted the PSG file to VGM with SN76489 data. This file was slightly edited using Mod2PSG2 v2.04, then used together with my old PSG effects system. I also added few new effects, these were created manually in Mod2PSG2.

Graphics. I choose 256x224 resolution, because the original game runs in 256x192 and has large black borders on the sides. For all the graphics works I used Graphics Gale Free Edition and GIMP. I made completely new sprites, new title and end screens (using cover art, with heavy manual edit after conversion), and recolored tiles from ZX Spectrum version. Probably the most difficult thing was to choose palettes configuration, to get colorful picture with single palette settings for all the levels. I managed to fit all the sprites into single 16-color palette, this allowed to use three other 16-color palettes for the background tiles.

The original game stores all the screens, except for the piramide and levels itself, as packed fullscreen pictures. I decided to do the same, with another packer however. After a few experiments I choose Team Bomba's BitBuster, which gave best compress ratio (other options were Hrust and mic's Sixpack). Depacker is in pure C code, I ported it to SMD using original source code few years ago. It depacks whole picture into 32K RAM buffer, and then the picture transferred to VRAM through DMA. It is not effective in speed and memory terms at all, but it is easy to do and works good enough. I also packed sprites and tiles graphics, though it was not really necessary. Without it the game size was just above 64K, and I thought it would be nice to fit into 64K.

How to compile the sources. You'll need Windows NT, 2K, XP or greater (9x has not support for some features for .bat), and installed Stef's Devkit. Set correct paths to the devkit components in genbuild.bat and makefile.gen (e:\gendev by default). Run makeres.bat to prepare all resources, then run genbuild.bat.


Update for v1.1. March 14 I got a report from Txai that level 9-9 is unbeatable. It was a major bug, because instead of the level there was indeed garbage in the game (my mistake, introduced in porting process). And because I had to release fixed version, I decided to make some other minor improvements as well. Here is list of the changes:

- Level 9-9 is now works
- Level 8-6 is now much easier
- Arrows above the exit blocks added
- Pause added
- Start button now works everywhere
- BitBuster replaced with aPLib (SyX version), because it is faster, smaller, and also compressed the graphics better
- One word corrected at the credits screen


Update for v1.2. In Semptemer 2011 I got a report that there are minor graphical artifacts in the game due to late CRAM writes. I also found a bug later, sprites weren't cleared at soft reset and remained above the title screen. This version fixes these two problems.
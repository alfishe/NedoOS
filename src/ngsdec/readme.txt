NGSdec
~~~~~~

Simple player that streams files to a hardware codec installed on NeoGS card.
Supports the following media types:
.mp3 can be played on all codecs on all NeoGS revisions
.mid requires VS1003, VS1033, or VS1053 on NeoGS.CM
.ogg requires VS1053, or VS1063 on NeoGS.CM
.aac requires VS1033, VS1053, or VS1063 on NeoGS.CM

Note that VLSI codecs only support MIDI format 0
https://www.vlsi.fi/fileadmin/app_notes/usable_midi_formats.pdf
If your file isn't playing, you can try converting it with GN1:0 MIDI Converter (or any similar program)
http://www.gnmidi.com/gn1to0.zip

Command line parameters:
ngsdec.com [<FileName>]
The player will be looping the file infinitely if file name was provided by user or nv.com.
Otherwise, it's going to play all supported files from the current folder.

Press [Up] or [Down] keys to adjust volume.
Press [Right] key to skip to the next file when playing files from folder.

Related projects:
Neo Player Light http://nedopc.com/gs/npl.php
Arduino VS1053 Library https://github.com/mpflaga/Arduino_Library-vs1053_for_SdFat

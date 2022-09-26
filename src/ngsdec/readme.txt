Player for streaming files to a hardware codec installed on NeoGS card.
Supports the following media types. Note that codec support is required.
.mp3 : all codecs on all NeoGS revisions
.mid : requires VS1003 or VS1033 or VS1053 on NeoGS.CM
.ogg : requires VS1053 or VS1063 on NeoGS.CM
.aac : requires VS1033 or VS1053 or VS1063 on NeoGS.CM

Use: ngsdec.com [<FileName>]
The player just loops the file infinitely if file name was specified (by user or nv.com).
Otherwise, it's going to stream all supported files from the current folder.

Related projects:
Neo Player Light http://nedopc.com/gs/npl.php
Arduino VS1053 Library https://github.com/mpflaga/Arduino_Library-vs1053_for_SdFat

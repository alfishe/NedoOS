@ECHO OFF
SetLocal EnableExtensions EnableDelayedExpansion
For /F "Delims=" %%I In ('WHERE /R . *.asm') Do Set V=!V!%%~I 
echo !V:\=/!
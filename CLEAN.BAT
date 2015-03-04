TITLE CLEANING...
REM CLEAN SCRIPT by NEOFF and BITNIK
@Echo off
cls
color 2
Echo  Cleaning Trash Files...
del /s *.~*
del /s *.dcu
del /s *.dsk
del /s *.dsm
del /s *.rsm
REM del /s *.cfg
REM del /s *.rar
del /s *.ddp
del /s BASENFK\debug_*.log
cls
Exit
del /s *.obj
del /s *.tds
del /s *.~c
del /s *.~h
del /s *.~dsk
del /s *.~bpr
del /s *.~cpp
del /s *.~dfm
del /s *.org
del /s *.pst
del /s *.ast
del /s *.var
del /s *.A_
del /s *.V_
del /s *.I_
del /s *.S_
del /s *.D_
del /s label.f
del /s label0.f
del /s err.f
del /s asmerr.f
del /s test.trd
del /s nedogift.trd
del *.$c
del /s out.bin
del /s tokarm.bin
del /s *.mlz
del /s user.l
del /s *.r01
del /s *.s01
del /s *.lst
del /s cout.html
FOR /R . %%i IN (list) DO (
	if exist %%i (
		rd %%i
	)
)
FOR /R . %%i IN (tmp) DO (
	if exist %%i (
		rd %%i
	)
)

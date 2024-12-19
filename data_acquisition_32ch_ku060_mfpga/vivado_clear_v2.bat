for /r /d %%b in (*.Xil) do rd "%%b" /s /q 

for /r /d %%b in (*.cache) do rd "%%b" /s /q 
::删除当前目录下的所有_ngo文件夹

for /r /d %%b in (*.sim) do rd "%%b" /s /q 
::删除当前目录下的所有db文件夹

::注意运行时注意拷贝.bit文件
for /r /d %%b in (*.runs) do rd "%%b" /s /q 

for /r /d %%b in (*.hw) do rd "%%b" /s /q 


del *.jou /s
del *.backup /s
del *.backup.log /s




exit

for /r /d %%b in (*.Xil) do rd "%%b" /s /q 

for /r /d %%b in (*.cache) do rd "%%b" /s /q 
::ɾ����ǰĿ¼�µ�����_ngo�ļ���

for /r /d %%b in (*.sim) do rd "%%b" /s /q 
::ɾ����ǰĿ¼�µ�����db�ļ���

::ע������ʱע�⿽��.bit�ļ�
for /r /d %%b in (*.runs) do rd "%%b" /s /q 

for /r /d %%b in (*.hw) do rd "%%b" /s /q 


del *.jou /s
del *.backup /s
del *.backup.log /s




exit

@echo off
rem drag n drop folder of interest
@echo warning pew file templates will give erroneous results

moveobject -p %1 >%1%.Objects.txt
findstr  /i "\\" %1%.Objects.txt >dump.txt
findstr  /iv "layers" dump.txt >%1%.Objects.txt
findstr  /iv "=" %1%.Objects.txt >dump.txt
echo ------contents of %1 -------------- >%1%.objects.txt
echo ***WARNING*** pew file templates will give erroneous results>>%1%.objects.txt
echo ----------------------------------- >>%1%.objects.txt
sort dump.txt >>%1%.objects.txt
del dump.txt

rem global change of all paths 
rem example
rem mv_changeall.bat cwr_editor\cwr_editor\models\rvmatfiles  anwywere\models\rvmatfiles
FOR %%X in (*.p3d) DO CALL mv_change  %%X %1 %2
 
FOR %%X in (*.rvmat) DO CALL mv_change  %%X  %1 %2



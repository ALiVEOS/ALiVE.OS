@echo off

IF NOT EXIST P:\NUL GOTO MAP_P
subst P: /D 

:MAP_P
subst P: "C:\Users\%USERNAME%\Documents\Arma 3\missions"

rem pause
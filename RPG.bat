@setlocal enableextensions enabledelayedexpansion
@ECHO off
title RPG
color 0a
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::
::
::
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:beginning
:: define LF as a Line Feed (newline) character
SET ^"LF=^

^" Above empty line is required - DO not remove

SET ^"\n=^^^%LF%%LF%^%LF%%LF%^^"


::CALL :RandomWorld
CALL :Fileworld


:: THIS IS THE MAIN LOOP
:Overworld
CALL :Compile_Screen
CALL :Controls
CALL :SPRITE_ACTION
GOTO :Overworld


::------------------------------------------------------------------------------------------

:Fileworld
:: CREATE Turrain ARRAY

SET /A _mapSizeY=20
SET /A _mapSizeX=40
SET /A _mapSizeXY=!_mapSizeY!*!_mapSizeX!

SET /A i=0

FOR /F "tokens=*" %%A IN (level1.txt) DO (
SET _0world!i!=%%A
SET /A i+=1
)

CALL :Create Variables
GOTO :EOF

::------------------------------------------------------------------------------------------

:map2
:: BUILDS A Single String of the World MAP and OPENS it in a NEW Window
SET "_screen="
SET /a _cols=(!_mapSizeX!)+1
SET /a _lines=(!_mapSizey!)+4

ECHO.>level1.txt
FOR /l %%A IN (0, 1, !_mapSizeY!) DO (
ECHO !_0world%%A!>>level1.txt
FOR /l %%B IN (0, 1, !_mapSizeX!) DO (
:::: TRANSFER WORLD TO TILE
SET _tile=!_0world%%A:~%%B,1!
IF "!_pY!,!_pX!"=="%%A,%%B" SET _tile=è
SET _screen=!_screen!!_tile!
)
SET _screen=!_screen!
)

Start "MAP" CMD /c "mode con cols=!_cols! lines=!_lines!&color 0e&@ECHO off&ECHO.!_screen! &pause"

GOTO :EOF
::------------------------------------------------------------------------------------------

:Create Variables

SET /a _screenSizeX=22
SET /a _menuSizeX=10
SET /a _screenSizeY=!_screenSizeX!/2+1
SET /a _topBlockL=(!_screenSizeX!)+(!_menuSizeX!)+7
mode con cols=!_topBlockL! lines=36

SET "_screenBorder="
FOR /l %%A IN (0, 1, !_screenSizeX!) DO (
SET _screenBorder=!_screenBorder!Õ
SET _screenBlank=!_screenBlank!^ 
SET _titleBorder=!_titleBorder!ƒ
)
SET "_menuBorder="
FOR /l %%A IN (0, 1, !_menuSizeX!) DO (
SET _menuBorder=!_menuBorder!Õ
SET _menuBlank=!_menuBlank!^ 
SET _titleMenu=!_titleMenu!ƒ
)

SET /a _mapX=(!_mapSizeX!/2)-(!_screenSizeX!/2)
SET /a _mRightX=!_mapSizeX!-!_screenSizeX!
SET /a _mapY=(!_mapSizeY!/2)-(!_screenSizeY!/2)
SET /a _mDownY=!_mapSizeY!-!_screenSizeY!

SET /a _pX=(!_mapSizeX!/2)-(!_screenSizeX!/2)+(!_screenSizeX!/2)
SET /a _pLeftX=!_screenSizeX!/4
SET /a _pRightX=!_screenSizeX!-!_pLeftX!
SET /a _pY=(!_mapSizeY!/2)-(!_screenSizeY!/2)+(!_screenSizeY!/2)
SET /a _pUpY=!_screenSizeX!/6
SET /a _pDownY=!_screenSizeY!-!_pUpY!

:: CREATE SOLID OBJECT ARRAY
SET i=0
FOR %%a IN (≥ @ ≤ # ‹ › ﬁ ﬂ €) DO (
   SET /A i+=1
   SET _solidTile[!i!]=%%a
   SET _solidNum=!i!
)

SET _solidString=≥ @ ≤ # ‹ › ﬁ ﬂ €

:: CREATE GROUND OBJECT ARRAY
SET i=0
FOR %%a IN (∫ ± ∞ € Ô ˘ ˙  ) DO (
   SET /A i+=1
   SET _visTile[!i!]=%%a
   SET _visNum=!i!
)

::SET ^"_visTile[8]= ^" 

:: CREATE PLAYER TILE ARRAY
SET i=0
FOR %%a IN (è è è è è ß ß -) DO (
   SET /A i+=1
   SET _pTile[!i!]=%%a
   SET _pNum=!i!
)

pause
SET /A _hold=1

SET /A _tempX=!_pX!-!_mapX!
SET /A _spriteNum=0
SET _sprite[0]=è,!_pX!,!_pY!,!_tempX!

GOTO :EOF



::------------------------------------------------------------------------------------------


::------------------------------------------------------------------------------------------
:Controls
:: CHANGE PLAYER AND SCREEN POSITION BASED ON 4 DIRECTIONAL PLAYER INPUT
CHOICE /C:wasdgmrklx /N /D:x /T:1
IF %errorlevel% EQU 10 GOTO :EOF
IF %errorlevel% EQU 9 GOTO :attack
IF %errorlevel% EQU 8 GOTO :build
IF %errorlevel% EQU 7 GOTO :beginning
IF %errorlevel% EQU 6 GOTO :map2
IF %errorlevel% EQU 5 GOTO :gfx
IF %errorlevel% EQU 4 GOTO :right
IF %errorlevel% EQU 3 GOTO :down
IF %errorlevel% EQU 2 GOTO :left
IF %errorlevel% EQU 1 GOTO :up 
GOTO :EOF

:left
IF !_pX! NEQ 0 SET /A _nX=!_pX!-1
SET _pTile=!_0world%_pY%:~%_pX%,1!
SET _nTile=!_0world%_pY%:~%_nX%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
IF "!_solidString:%_nTile%=!"=="!_solidString!" (
SET /A _pX=!_nX!
SET /a _pX1=!_pX!-!_mapX! 
IF !_pX1! EQU !_pLeftX! IF !_mapX! NEQ 0 SET /a _mapX-=1
)
) ELSE (
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (
SET /A _pX=!_nX!
SET /a _pX1=!_pX!-!_mapX! 
IF !_pX1! EQU !_pLeftX! IF !_mapX! NEQ 0 SET /a _mapX-=1
)
)
GOTO :EOF

:right
IF !_pX! NEQ !_mapSizeX! SET /A _nX=!_pX!+1
SET _pTile=!_0world%_pY%:~%_pX%,1!
SET _nTile=!_0world%_pY%:~%_nX%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
IF "!_solidString:%_nTile%=!"=="!_solidString!" (
SET /A _pX=!_nX!
SET /A _pX1=!_pX!-!_mapX!
IF !_pX1! EQU !_pRightX! IF !_mapX! NEQ !_mRightX! SET /a _mapX+=1
) 
) ELSE (
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (
SET /A _pX=!_nX!
SET /A _pX1=!_pX!-!_mapX!
IF !_pX1! EQU !_pRightX! IF !_mapX! NEQ !_mRightX! SET /a _mapX+=1
) 
)

GOTO :EOF

:up
IF !_pY! NEQ 0 SET /a _nY=!_pY!-1
SET _pTile=!_0world%_pY%:~%_pX%,1!
SET _nTile=!_0world%_nY%:~%_pX%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
::PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (
SET /A _pY=!_nY!
SET /A _pY1=!_pY!-!_mapY!
IF !_pY1! EQU !_pUpY! IF !_mapY! NEQ 0 SET /a _mapY-=1
)
IF "!_pTile!"=="∞" (
SET /A _pY=!_nY!
SET /A _pY1=!_pY!-!_mapY!
IF !_pY1! EQU !_pUpY! IF !_mapY! NEQ 0 SET /a _mapY-=1a
)
) ELSE (
::PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (
SET /A _pY=!_nY!
SET /A _pY1=!_pY!-!_mapY!
IF !_pY1! EQU !_pUpY! IF !_mapY! NEQ 0 SET /a _mapY-=1
)
)
GOTO :EOF

:down
IF !_pY! NEQ !_mapSizeY! SET /A _nY=!_pY!+1
SET _pTile=!_0world%_pY%:~%_pX%,1!
SET _nTile=!_0world%_nY%:~%_pX%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
::PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (
SET /A _pY=!_nY!
SET /A _pY1=!_pY!-!_mapY!
IF !_pY1! EQU !_pDownY! IF !_mapY! NEQ !_mDownY! SET /a _mapY+=1
)
) ELSE (
::PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (
SET /A _pY=!_nY!
SET /A _pY1=!_pY!-!_mapY!
IF !_pY1! EQU !_pDownY! IF !_mapY! NEQ !_mDownY! SET /a _mapY+=1
)
IF "!_nTile!"=="∞" (
SET /A _pY=!_nY!
SET /A _pY1=!_pY!-!_mapY!
IF !_pY1! EQU !_pDownY! IF !_mapY! NEQ !_mDownY! SET /a _mapY+=1
)
)

GOTO :EOF

::------------------------------------------------------------------------------------------

:build
:: CHANGE PLAYER AND SCREEN POSITION BASED ON 4 DIRECTIONAL PLAYER INPUT

CALL :Compile_HOLDScreen

choice /c wasdkl123456789 /n

IF %errorlevel% EQU 15 SET _hold=Í&GOTO:build
IF %errorlevel% EQU 14 SET _hold=&GOTO:build
IF %errorlevel% EQU 13 SET _hold=#&GOTO:build
IF %errorlevel% EQU 12 SET _hold=˛&GOTO:build
IF %errorlevel% EQU 11 SET _hold=Ô&GOTO:build
IF %errorlevel% EQU 10 SET _hold=±&GOTO:build
IF %errorlevel% EQU 9 SET _hold=∞&GOTO:build
IF %errorlevel% EQU 8 SET _hold=≤&GOTO:build
IF %errorlevel% EQU 7 SET _hold=€&GOTO:build
IF %errorlevel% EQU 6 GOTO :sprite
IF %errorlevel% EQU 5 GOTO :EOF
IF %errorlevel% EQU 4 GOTO :rightB
IF %errorlevel% EQU 3 GOTO :downB
IF %errorlevel% EQU 2 GOTO :leftB
IF %errorlevel% EQU 1 GOTO :upB
GOTO :EOF

:leftB
SET /a _aY=!_pX!-1
SET /a _aX=!_pX!
SET _0world!_pY!=!_0world%_pY%:~0,%_ay%!!_hold!!_0world%_pY%:~%_ax%!
GOTO :EOF

:rightB
ECHO.RIGHT
SET /a _aY=!_pX!+1
SET /a _aX=!_pX!+2
SET _0world!_pY!=!_0world%_pY%:~0,%_ay%!!_hold!!_0world%_pY%:~%_ax%!
GOTO :EOF

:upB
ECHO.UP
SET /a _aY=!_pY!-1
SET /a _aX=!_pX!+1
SET _0world!_aY!=!_0world%_aY%:~0,%_px%!!_hold!!_0world%_aY%:~%_ax%!
GOTO :EOF

:downB
ECHO.DOWN
SET /a _aY=!_pY!+1
SET /a _aX=!_pX!+1
SET _0world!_aY!=!_0world%_aY%:~0,%_px%!!_hold!!_0world%_aY%:~%_ax%!
GOTO :EOF

:sprite
:: CHANGE PLAYER AND SCREEN POSITION BASED ON 4 DIRECTIONAL PLAYER INPUT

CALL :Compile_SPRITEScreen

choice /c wasdkl123456789 /n

IF %errorlevel% EQU 15 SET _hold=Í&GOTO:sprite
IF %errorlevel% EQU 14 SET _hold=&GOTO:sprite
IF %errorlevel% EQU 13 SET _hold=ù&GOTO:sprite
IF %errorlevel% EQU 12 SET _hold=Î&GOTO:sprite
IF %errorlevel% EQU 11 SET _hold=&GOTO:sprite
IF %errorlevel% EQU 10 SET _hold=&GOTO:sprite
IF %errorlevel% EQU 9 SET _hold=&GOTO:sprite
IF %errorlevel% EQU 8 (
SET _hold=^&
GOTO:sprite)
IF %errorlevel% EQU 7 SET _hold=Ü&GOTO:sprite
IF %errorlevel% EQU 6 GOTO :build
IF %errorlevel% EQU 5 GOTO :EOF
IF %errorlevel% EQU 4 GOTO :rightS
IF %errorlevel% EQU 3 GOTO :downS
IF %errorlevel% EQU 2 GOTO :leftS
IF %errorlevel% EQU 1 GOTO :upS
pause

:leftS
SET /A _spriteNUM+=1
SET /A _temp=!_pX!-1
SET _sprite[!_spriteNUM!]=!_hold!,!_temp!,!_pY!
GOTO :EOF

:rightS
SET /A _spriteNUM+=1
SET /A _temp=!_pX!+1
SET _sprite[!_spriteNUM!]=!_hold!,!_temp!,!_pY!
GOTO :EOF

:upS
SET /A _spriteNUM+=1
SET /A _temp=!_pY!-1
SET _sprite[!_spriteNUM!]=!_hold!,!_pX!,!_temp!
GOTO :EOF

:downS
SET /A _spriteNUM+=1
SET /A _temp=!_pY!+1
SET _sprite[!_spriteNUM!]=!_hold!,!_pX!,!_temp!
GOTO :EOF

:attack
:: CHANGE PLAYER AND SCREEN POSITION BASED ON 4 DIRECTIONAL PLAYER INPUT

choice /c wasd /n 

IF %errorlevel% EQU 4 GOTO :rightA
IF %errorlevel% EQU 3 GOTO :downA
IF %errorlevel% EQU 2 GOTO :leftA
IF %errorlevel% EQU 1 GOTO :upA
GOTO :EOF

:leftA
SET /a _aY=!_pX!-1
SET /a _aX=!_pX!
SET _0world!_pY!=!_0world%_pY%:~0,%_ay%!±!_0world%_pY%:~%_ax%!
GOTO :EOF

:rightA
SET /a _aY=!_pX!+1
SET /a _aX=!_pX!+2
SET _0world!_pY!=!_0world%_pY%:~0,%_ay%!±!_0world%_pY%:~%_ax%!
GOTO :EOF

:upA
SET /a _aY=!_pY!-1
SET /a _aX=!_pX!+1
SET _0world!_aY!=!_0world%_aY%:~0,%_px%!±!_0world%_aY%:~%_ax%!
GOTO :EOF

:downA
SET /a _aY=!_pY!+1
SET /a _aX=!_pX!+1
SET _0world!_aY!=!_0world%_aY%:~0,%_px%!±!_0world%_aY%:~%_ax%!
GOTO :EOF


::------------------------------------------------------------------------------------------



:RandomWorld
:: CREATE Turrain ARRAY

SET /a _mapSizeX=100
SET /a _mapSizeY=!_mapSizeX!/2
CALL :Create Variables

SET i=0
FOR %%a IN (    ∞ ≤) DO (
   SET _turfTile[!i!]=%%a
   SET _turfNum=!i!
   SET /A i+=1
)
:: GENERATES A WORLD RANDOMLY
:: FOR /l %%A IN (0, 1, !_mapSizeY!) DO (
:: SET "_0world%%A="
:: )

FOR /l %%A IN (0, 1, !_mapSizeY!) DO (
FOR /l %%B IN (0, 1, !_mapSizeX!) DO (
:: DETERMINE WHAT RANDOM TILE IS NEXT
SET /a rnd=!random!%%4
if !rnd! equ 0 SET _tile=±
if !rnd! equ 1 SET _tile=±
if !rnd! equ 2 SET _tile=±
if !rnd! equ 3 SET _tile=±
if !rnd! equ 4 SET _tile=±
:: ADD THE RANDOM TILE TO THE WORLD
SET _0world%%A=!_0world%%A!!_tile!
)
cls
ECHO.Loading %%A!_0world%%A!
)
pause
GOTO :EOF

::------------------------------------------------------------------------------------------

:SPRITE_ACTION

:: SPRITE MOVEMENT CALCULATIONS

FOR /F "tokens=1-10 delims==," %%q in ('SET _sprite[') DO (

SET /A _offsetX=0
SET /A _offsetY=0

IF "%%s,%%t"=="!_pX!,!_pY!" ECHO.HEY
IF NOT "%%u"=="" (
SET /a rnd=!random!%%5
if !rnd! equ 0 SET /A _newX+=1&SET /A _offsetX+=1
if !rnd! equ 1 SET /A _newX-=1&SET /A _offsetX-=1
if !rnd! equ 2 SET /A _newY+=1&SET /A _offsetY+=1
if !rnd! equ 3 SET /A _newY-=1&SET /A _offsetY-=1
)

SET /A _newX=%%s+!_offsetX!
SET /A _newY=%%t+!_offsetY!

CALL :GRAB_WORLDTILES %%s %%t !_newX! !_newY!

::: IF THE NEW TILE MATCHES THE OLD TILE MOVE
IF NOT "!_newX!,!_newY!"=="!_pX!,!_pY!" IF "!_tile!"=="!_newtile!" SET %%q=%%r,!_newX!,!_newY!,%%s,%%t
IF "!_tile!"=="!_newtile!" SET %%q=%%r,!_newX!,!_newY!,%%s,%%t

)

GOTO :EOF

::------------------------------------------------------------------------------------------

:GRAB_WORLDTILES
SET _tile=!_0world%2:~%1,1!
SET _newtile=!_0world%4:~%3,1!
EXIT /B

:PRINT_SPRITE 
SET _rowLeft=!_screenB[%2]:~0,%1!
SET _rowRight=!_screenB[%2]:~%1!
EXIT /B


::------------------------------------------------------------------------------------------

:Compile_Screen

:: COMPILES A VISUAL REPRESENTATION OF WORLD + OBJECTS + LIGHTING
SET /A _endY=!_mapY!+!_screenSizeY!
SET /A _nextY=!_endY!+1
SET /A _endX=!_mapX!+!_screenSizeX!
SET /A _nextX=!_screenSizeX!+1
SET /A _pAX=!_pX!-!_mapX!
SET /A _pAY=!_pY!-!_mapY!
SET /A _pBY=!_pY!-!_mapY!-1


SET /a _cntY=-1

FOR /l %%A IN (!_mapY!, 1, !_nextY!) DO (
SET _row=!_0world%%A:~%_mapX%,%_nextX%!
SET _screenA[!_cntY!]=!_row!
SET /A _cntY+=1
SET _screenB[!_cntY!]=!_row!
)

::SPRITE PLACEMENT ON MAP SCREEN
FOR /F "tokens=1-10 delims==," %%q in ('SET _sprite[') DO (
IF %%s GEQ !_mapX! IF %%t GEQ !_mapY! IF %%s LEQ !_endX! IF %%t LEQ !_endY! (
SET /A _xPos=%%s-!_mapX!
SET /A _yPos=%%t-!_mapY!
CALL :PRINT_SPRITE !_xPos! !_yPos!
SET _screenB[!_yPos!]=!_rowLeft!%%r!_rowRight:~1!
)

)

SET _screen=!LF! …!_screenBorder!—!_menuBorder!∏!LF!

FOR /l %%A IN (0, 1, !_screenSizeY!) DO (

SET _lastTile=
SET _screen=!_screen! ∫

FOR /l %%B IN (0, 1, !_screenSizeX!) DO (

:::: TRANSFER WORLD TO TILE
SET _tile=^!_screenB[%%A]:~%%B,1!


IF "!_0world%_pY%:~%_pX%,1!"=="≤" ( 
SET /A _darkWest=!_pAX!-3
SET /A _darkEast=!_pAX!+3
SET /A _darkNorth=!_pAY!-2
SET /A _darkSouth=!_pAY!+2
IF "!_screenB[%%A]:~%%B,1!"=="≤" SET _tile=±
IF "!_screenB[%%A]:~%%B,1!"=="€" SET _tile=∞
IF "!_screenB[%%A]:~%%B,1!"=="±" SET _tile=∞
::: ADDS A DOOR GRAPHICS
IF "!_screenB[%%A]:~%%B,1!"=="≤" IF "!_screenA[%%A]:~%%B,1!"=="∞" SET _tile=€
IF "!_pAY!,!_pAX!"=="%%A,%%B" SET _tile=è
IF "%%A,%%B"=="!_darkNorth!,!_darkWest!" SET _tile= 
IF "%%A,%%B"=="!_darkSouth!,!_darkWest!" SET _tile= 
IF "%%A,%%B"=="!_darkNorth!,!_darkEast!" SET _tile= 
IF "%%A,%%B"=="!_darkSouth!,!_darkEast!" SET _tile= 
IF %%B LSS !_darkWest! SET _tile= 
IF %%B GTR !_darkEast! SET _tile= 
IF %%A LSS !_darkNorth! SET _tile= 
IF %%A GTR !_darkSouth! SET _tile= 
) ELSE (


:::: IF TILE IS GROUND AND LEFT TILE IS SOLID ADD A SHADOW
IF "!_tile!"=="€" SET _tile=≤

::: ADDS A SHADOW TO THE RIGHT OF TALL BLOCKS
IF "!_tile!"=="±" IF "!_lastTile!"=="≤" SET _tile=∞
IF "!_tile!"=="±" IF "!_lastTile!"=="€" SET _tile=∞

::: ADDS A DOOR GRAPHICS
IF "!_tile!"=="≤" IF "!_screenA[%%A]:~%%B,1!"=="∞" SET _tile= 

rem „   Í 

IF "!_pAY!,!_pAX!"=="%%A,%%B" SET _tile=è

::: ADDS A WHITE TOP FOR THESE TILES ≤ € ˛ Ô #
IF "!_screenA[%%A]:~%%B,1!"=="≤"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="#"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="€"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="˛"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="Ô"  SET _tile=€

)

SET _screen=!_screen!!_tile!
SET _lastTile=!_screenB[%%A]:~%%B,1!

)
SET _screen=!_screen!√!_cntY:~-1!!_menuBlank:~0,-1!¥!LF!
)

SET _screen=!_screen! «!_titleBorder!≈!_titleMenu!¥!LF!
SET _screen=!_screen! ∫!_screenBlank!≥!_menuBlank!≥!LF!
SET _screen=!_screen! ∫!_screenBlank!≥!_menuBlank!≥!LF!
SET _screen=!_screen! ”!_titleBorder!¡!_titleMenu!Ÿ!LF!
SET _screen=!_screen! Player:(X!_pX!,Y!_pY!) Map:(X!_mapX!,Y!_mapY!) TILE:!_0world%_pY%:~%_pX%,1!!LF!!LF!
SET _screen=!_screen!        !LF!
SET _screen=!_screen!       W               (L)=ATTACK!LF!
SET _screen=!_screen!    A   D!LF!
SET _screen=!_screen!       S            (K)=BUILD!LF!
SET _screen=!_screen!            !LF!
SET _screen=!_screen!                 (M)=MAP

cls&ECHO.!_screen!
GOTO :EOF

::------------------------------------------------------------------------------------------

:Compile_HOLDScreen

:: COMPILES A VISUAL REPRESENTATION OF WORLD + OBJECTS + LIGHTING
SET /A _endY=!_mapY!+!_screenSizeY!
SET /A _nextY=!_endY!+1
SET /A _endX=!_mapX!+!_screenSizeX!
SET /A _nextX=!_screenSizeX!+1
SET /A _pAX=!_pX!-!_mapX!
SET /A _pAY=!_pY!-!_mapY!
SET /A _pBY=!_pY!-!_mapY!-1


SET /a _cntY=-1

FOR /l %%A IN (!_mapY!, 1, !_nextY!) DO (
SET _row=!_0world%%A:~%_mapX%,%_nextX%!
SET _screenA[!_cntY!]=!_row!
SET /a _cntY+=1
SET _screenB[!_cntY!]=!_row!
)

:: SPRITE MOVEMENT CALCULATIONS

FOR /F "tokens=1-10 delims==," %%q in ('SET _sprite[') DO (

SET /A _offsetX=0
SET /A _offsetY=0

IF "%%u" NEQ "" (
SET /a rnd=!random!%%5
if !rnd! equ 0 SET /A _newX+=1&SET /A _offsetX+=1
if !rnd! equ 1 SET /A _newX-=1&SET /A _offsetX-=1
if !rnd! equ 2 SET /A _newY+=1&SET /A _offsetY+=1
if !rnd! equ 3 SET /A _newY-=1&SET /A _offsetY-=1
)

SET /A _newX=%%s+!_offsetX!
SET /A _newY=%%t+!_offsetY!
SET /A _tempX=%%s-!_mapX!
SET /A _tempY=%%t-!_mapY!
SET /A _newtempX=!_tempX!+!_offsetX!
SET /A _newtempY=!_tempY!+!_offsetY!

SET %%q=%%r,%%s,%%t,!_newX!,!_newY!,!_tempX!,!_tempY!,!_newTempX!,!_newTempY!
)


::SPRITE PLACEMENT ON MAP SCREEN


FOR /F "tokens=1-10 delims==," %%q in ('SET _sprite[') DO (

IF "!_0world%%v:~%%u,1!"=="!_0world%%t:~%%s,1!" (
IF "!_screenB[%%z]:~%%y,1!"=="!_0world%%v:~%%u,1!" SET _rowRight=!_screenB[%%z]:~%%y!&SET _screenB[%%z]=!_screenB[%%z]:~0,%%y!%%r!_rowRight:~1!
SET %%q=%%r,%%u,%%v,%%u,%%v,%%y,%%z,%%y,%%z
) ELSE (
IF "!_screenB[%%x]:~%%w,1!"=="!_0world%%t:~%%s,1!" SET _rowRight=!_screenB[%%x]:~%%w!&SET _screenB[%%x]=!_screenB[%%x]:~0,%%w!%%r!_rowRight:~1!
SET %%q=%%r,%%s,%%t,%%s,%%t,%%w,%%x,%%w,%%x
)

)


SET _screen=!LF! …!_screenBorder!—!_menuBorder!∏!LF!

FOR /l %%A IN (0, 1, !_screenSizeY!) DO (

SET _lastTile=
SET _screen=!_screen! ∫

FOR /l %%B IN (0, 1, !_screenSizeX!) DO (

:::: TRANSFER WORLD TO TILE
SET _tile=!_screenB[%%A]:~%%B,1!


IF "!_0world%_pY%:~%_pX%,1!"=="≤" ( 
SET /A _darkWest=!_pAX!-3
SET /A _darkEast=!_pAX!+3
SET /A _darkNorth=!_pAY!-2
SET /A _darkSouth=!_pAY!+2
IF "!_screenB[%%A]:~%%B,1!"=="≤" SET _tile=±
IF "!_screenB[%%A]:~%%B,1!"=="€" SET _tile=∞
IF "!_screenB[%%A]:~%%B,1!"=="±" SET _tile=∞
::: ADDS A DOOR GRAPHICS
IF "!_screenB[%%A]:~%%B,1!"=="≤" IF "!_screenA[%%A]:~%%B,1!"=="∞" SET _tile=€
IF "!_pAY!,!_pAX!"=="%%A,%%B" SET _tile=é
IF "!_pBY!,!_pAX!"=="%%A,%%B" SET _tile=!_hold!
IF "%%A,%%B"=="!_darkNorth!,!_darkWest!" SET _tile= 
IF "%%A,%%B"=="!_darkSouth!,!_darkWest!" SET _tile= 
IF "%%A,%%B"=="!_darkNorth!,!_darkEast!" SET _tile= 
IF "%%A,%%B"=="!_darkSouth!,!_darkEast!" SET _tile= 
IF %%B LSS !_darkWest! SET _tile= 
IF %%B GTR !_darkEast! SET _tile= 
IF %%A LSS !_darkNorth! SET _tile= 
IF %%A GTR !_darkSouth! SET _tile= 
) ELSE (

:::: IF TILE IS GROUND AND LEFT TILE IS SOLID ADD A SHADOW
IF "!_tile!"=="€" SET _tile=≤

::: ADDS A SHADOW TO THE RIGHT OF TALL BLOCKS
IF "!_tile!"=="±" IF "!_lastTile!"=="≤" SET _tile=∞
IF "!_tile!"=="±" IF "!_lastTile!"=="€" SET _tile=∞

::: ADDS A DOOR GRAPHICS
IF "!_tile!"=="≤" IF "!_screenA[%%A]:~%%B,1!"=="∞" SET _tile= 

rem „   Í 

IF "!_pAY!,!_pAX!"=="%%A,%%B" SET _tile=é
IF "!_pBY!,!_pAX!"=="%%A,%%B" SET _tile=!_hold!

::: ADDS A WHITE TOP FOR THESE TILES ≤ € ˛ Ô #
IF "!_screenA[%%A]:~%%B,1!"=="≤"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="#"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="€"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="˛"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="Ô"  SET _tile=€

)

SET _screen=!_screen!!_tile!
SET _lastTile=!_screenB[%%A]:~%%B,1!

)
SET _screen=!_screen!√!_cntY:~-1!!_menuBlank:~0,-1!¥!LF!
)

SET _screen=!_screen! «!_titleBorder!≈!_titleMenu!¥!LF!
SET _screen=!_screen! ∫!_screenBlank!≥!_menuBlank!≥!LF!
SET _screen=!_screen! ∫!_screenBlank!≥!_menuBlank!≥!LF!
SET _screen=!_screen! ”!_titleBorder!¡!_titleMenu!Ÿ!LF!
SET _screen=!_screen!  1.€ 2.≤ 3.∞ 4.± 5.Ô 6.˛ 7.# 8.# 9.Í !LF!!LF!
SET _screen=!_screen!        !LF!
SET _screen=!_screen!       W               (L)=SPRITE!LF!
SET _screen=!_screen!    A   D!LF!
SET _screen=!_screen!       S            (K)=WALK!LF!
SET _screen=!_screen!            !LF!
SET _screen=!_screen!                 (M)=MAP

cls&ECHO.!_screen!

GOTO :EOF


::------------------------------------------------------------------------------------------

:Compile_SPRITEScreen
:: COMPILES A VISUAL REPRESENTATION OF WORLD + OBJECTS + LIGHTING
SET /A _endY=!_mapY!+!_screenSizeY!
SET /A _nextY=!_endY!+1
SET /A _endX=!_mapX!+!_screenSizeX!
SET /A _nextX=!_screenSizeX!+1
SET /A _pAX=!_pX!-!_mapX!
SET /A _pAY=!_pY!-!_mapY!
SET /A _pBY=!_pY!-!_mapY!-1


SET /a _cntY=-1

FOR /l %%A IN (!_mapY!, 1, !_nextY!) DO (
SET _row=!_0world%%A:~%_mapX%,%_nextX%!
SET _screenA[!_cntY!]=!_row!
SET /a _cntY+=1
SET _screenB[!_cntY!]=!_row!
)

:: SPRITE MOVEMENT CALCULATIONS

FOR /F "tokens=1-10 delims==," %%q in ('SET _sprite[') DO (

SET /A _offsetX=0
SET /A _offsetY=0

IF "%%u" NEQ "" (
SET /a rnd=!random!%%5
if !rnd! equ 0 SET /A _newX+=1&SET /A _offsetX+=1
if !rnd! equ 1 SET /A _newX-=1&SET /A _offsetX-=1
if !rnd! equ 2 SET /A _newY+=1&SET /A _offsetY+=1
if !rnd! equ 3 SET /A _newY-=1&SET /A _offsetY-=1
)

SET /A _newX=%%s+!_offsetX!
SET /A _newY=%%t+!_offsetY!
SET /A _tempX=%%s-!_mapX!
SET /A _tempY=%%t-!_mapY!
SET /A _newtempX=!_tempX!+!_offsetX!
SET /A _newtempY=!_tempY!+!_offsetY!

SET %%q=%%r,%%s,%%t,!_newX!,!_newY!,!_tempX!,!_tempY!,!_newTempX!,!_newTempY!
)


::SPRITE PLACEMENT ON MAP SCREEN


FOR /F "tokens=1-10 delims==," %%q in ('SET _sprite[') DO (

IF "!_0world%%v:~%%u,1!"=="!_0world%%t:~%%s,1!" (
IF "!_screenB[%%z]:~%%y,1!"=="!_0world%%v:~%%u,1!" SET _rowRight=!_screenB[%%z]:~%%y!&SET _screenB[%%z]=!_screenB[%%z]:~0,%%y!%%r!_rowRight:~1!
SET %%q=%%r,%%u,%%v,%%u,%%v,%%y,%%z,%%y,%%z
) ELSE (
IF "!_screenB[%%x]:~%%w,1!"=="!_0world%%t:~%%s,1!" SET _rowRight=!_screenB[%%x]:~%%w!&SET _screenB[%%x]=!_screenB[%%x]:~0,%%w!%%r!_rowRight:~1!
SET %%q=%%r,%%s,%%t,%%s,%%t,%%w,%%x,%%w,%%x
)

)


SET _screen=!LF! …!_screenBorder!—!_menuBorder!∏!LF!

FOR /l %%A IN (0, 1, !_screenSizeY!) DO (

SET _lastTile=
SET _screen=!_screen! ∫

FOR /l %%B IN (0, 1, !_screenSizeX!) DO (

:::: TRANSFER WORLD TO TILE
SET _tile=!_screenB[%%A]:~%%B,1!


IF "!_0world%_pY%:~%_pX%,1!"=="≤" ( 
SET /A _darkWest=!_pAX!-3
SET /A _darkEast=!_pAX!+3
SET /A _darkNorth=!_pAY!-2
SET /A _darkSouth=!_pAY!+2
IF "!_screenB[%%A]:~%%B,1!"=="≤" SET _tile=±
IF "!_screenB[%%A]:~%%B,1!"=="€" SET _tile=∞
IF "!_screenB[%%A]:~%%B,1!"=="±" SET _tile=∞
::: ADDS A DOOR GRAPHICS
IF "!_screenB[%%A]:~%%B,1!"=="≤" IF "!_screenA[%%A]:~%%B,1!"=="∞" SET _tile=€
IF "!_pAY!,!_pAX!"=="%%A,%%B" SET _tile=è
IF "%%A,%%B"=="!_darkNorth!,!_darkWest!" SET _tile= 
IF "%%A,%%B"=="!_darkSouth!,!_darkWest!" SET _tile= 
IF "%%A,%%B"=="!_darkNorth!,!_darkEast!" SET _tile= 
IF "%%A,%%B"=="!_darkSouth!,!_darkEast!" SET _tile= 
IF %%B LSS !_darkWest! SET _tile= 
IF %%B GTR !_darkEast! SET _tile= 
IF %%A LSS !_darkNorth! SET _tile= 
IF %%A GTR !_darkSouth! SET _tile= 
) ELSE (


:::: IF TILE IS GROUND AND LEFT TILE IS SOLID ADD A SHADOW
IF "!_tile!"=="€" SET _tile=≤

::: ADDS A SHADOW TO THE RIGHT OF TALL BLOCKS
IF "!_tile!"=="±" IF "!_lastTile!"=="≤" SET _tile=∞
IF "!_tile!"=="±" IF "!_lastTile!"=="€" SET _tile=∞

::: ADDS A DOOR GRAPHICS
IF "!_tile!"=="≤" IF "!_screenA[%%A]:~%%B,1!"=="∞" SET _tile= 

rem „   Í 

IF "!_pAY!,!_pAX!"=="%%A,%%B" SET _tile=é
IF "!_pBY!,!_pAX!"=="%%A,%%B" SET _tile=!_hold!

::: ADDS A WHITE TOP FOR THESE TILES ≤ € ˛ Ô #
IF "!_screenA[%%A]:~%%B,1!"=="≤"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="#"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="€"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="˛"  SET _tile=€
IF "!_screenA[%%A]:~%%B,1!"=="Ô"  SET _tile=€

)

SET _screen=!_screen!!_tile!
SET _lastTile=!_screenB[%%A]:~%%B,1!

)
SET _screen=!_screen!√!_cntY:~-1!!_menuBlank:~0,-1!¥!LF!
)

SET _screen=!_screen! «!_titleBorder!≈!_titleMenu!¥!LF!
SET _screen=!_screen! ∫!_screenBlank!≥!_menuBlank!≥!LF!
SET _screen=!_screen! ∫!_screenBlank!≥!_menuBlank!≥!LF!
SET _screen=!_screen! ”!_titleBorder!¡!_titleMenu!Ÿ!LF!
SET _screen=!_screen!  1.Ü 2.^& 3. 4. 5. 6.Î 7.ù 8. 9.Í !LF!!LF!
SET _screen=!_screen!        !LF!
SET _screen=!_screen!       W               (L)=BUILD!LF!
SET _screen=!_screen!    A   D!LF!
SET _screen=!_screen!       S            (K)=WALK!LF!
SET _screen=!_screen!            !LF!
SET _screen=!_screen!                 (M)=MAP

cls&ECHO.!_screen!

GOTO :EOF

::------------------------------------------------------------------------------------------
:gfx
Start "MAP" CMD /c "
mode con cols=80 lines=80
SET _pTile=!_0world1%:~%_pPos%,1!
ECHO.Current Tile = %_pTile%
ECHO.
ECHO.     a b c d e f g h i j k l m n o p q r s t u v w x y z 
ECHO.     A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 
ECHO.     0 1 2 3 4 5 6 7 8 9
ECHO.
ECHO        1:      2:      3:      4:      5:      6:     11:     12: 
ECHO.
ECHO       14:     15:     16:     17:     18:     19:     20:     21: 
ECHO.
ECHO       22:     23:     24:     25:     27:     28:     29:     30:    
ECHO.
ECHO       31:     32:    
ECHO.
ECHO.      33: ^^!    34: "    35: #    36: $    37: %%    38: ^&    39: '    40: (
ECHO.
ECHO.      41: )    42: *    43: +    44: ,    45: -    46: .    47: /    58: :
ECHO.     
ECHO.      59: ;    60: ^<    61: =    62: ^>    63: ?    64: @    91: [    92: \
ECHO.
ECHO.      93: ]    94: ^^^    95: _    96: `   123: {   124: ^|   125: }   126: ~
ECHO.
ECHO      127:    128: Ä   129: Å   130: Ç   131: É   132: Ñ   133: Ö   134: Ü
ECHO.
ECHO      135: á   136: à   137: â   138: ä   139: ã   140: å   141: ç   142: é
ECHO.
ECHO      143: è   144: ê   145: ë   146: í   147: ì   148: î   149: ï   150: ñ
ECHO.
ECHO      151: ó   152: ò   153: ô   154: ö   155: õ   156: ú   157: ù   158: û
ECHO.
ECHO      159: ü   160: †   161: °   162: ¢   163: £   164: §   165: •   166: ¶
ECHO.
ECHO      167: ß   168: ®   169: ©   170: ™   171: ´   172: ¨   173: ≠   174: Æ
ECHO.
ECHO      175: Ø   176: ∞   177: ±   178: ≤   179: ≥   180: ¥   181: µ   182: ∂
ECHO.
ECHO      183: ∑   184: ∏   185: π   186: ∫   187: ª   188: º   189: Ω   190: æ
ECHO.
ECHO      191: ø   192: ¿   193: ¡   194: ¬   195: √   196: ƒ   197: ≈   198: ∆
ECHO.
ECHO      199: «   200: »   201: …   202:     203: À   204: Ã   205: Õ   206: Œ
ECHO.
ECHO      207: œ   208: –   209: —   210: “   211: ”   212: ‘   213: ’   214: ÷
ECHO.
ECHO      215: ◊   216: ÿ   217: Ÿ   218: ⁄   219: €   220: ‹   221: ›   222: ﬁ
ECHO.
ECHO      223: ﬂ   224: ‡   225: ·   226: ‚   227: „   228: ‰   229: Â   230: Ê
ECHO.
ECHO      231: Á   232: Ë   233: È   234: Í   235: Î   236: Ï   237: Ì   238: Ó
ECHO.
ECHO      239: Ô   240:    241: Ò   242: Ú   243: Û   244: Ù   245: ı   246: ˆ
ECHO.
ECHO      247: ˜   248: ¯   249: ˘   250: ˙   251: ˚   252: ¸   253: ˝   254: ˛
ECHO.
ECHO.
pause
mode con cols=!_topBlockL! lines=36
GOTO :EOF
"
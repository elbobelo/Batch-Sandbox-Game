REM ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM :: Have Player Position in an Array. 
REM :: Save Sprite Array into File and Load From File.
REM :: Create the build/edit mode to place blocks. 
REM ::
REM ::
REM ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO off
SETLOCAL enableextensions enabledelayedexpansion

TITLE RPG
COLOR 0A


:BEGINNING

CALL :Create_Variables

REM THIS IS THE MAIN LOOP
:OVERWORLD
REM ---------  CAPTURE START TIME

set start_time=%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%%TIME:~9,2%

< "level2.txt" (SET /p "_world=")
REM ECHO. !_world!
REM PAUSE

IF !_pMode! NEQ 0 (
CALL :Build_Screen
CALL :Build_Controls
) ELSE (
CALL :Play_Screen
CALL :Play_Controls
)

REM ---------  CALCULATE TIME DIFFERENCE
set /A "elapsed_time=end_time-start_time"

set end_time=%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%%TIME:~9,2%

set /A "elapsed_time=end_time-start_time"

ECHO %elapsed_time% ms.

GOTO :Overworld


REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------

:Create_Variables

REM define LF as a Line Feed (newline) character
SET ^"LF=^

^" Above empty line is required - DO NOT remove

SET ^"\n=^^^!LF!!LF!^!LF!!LF!^^"

SET /A _mapSizeY=20
SET /A _mapSizeX=40
SET /A _mapSizeXY=!_mapSizeY!*!_mapSizeX!

SET /a _screenSizeX=22
SET /a _menuSizeX=10
SET /a _screenSizeY=!_screenSizeX!/2+1
SET /a _topBlockL=(!_screenSizeX!)+(!_menuSizeX!)+6
REM MODE CON cols=!_topBlockL! lines=36
MODE !_topBlockL!, 36

SET "_screenBorder="
SET "_screenBlank="
SET "_titleBorder="
FOR /l %%A IN (0, 1, !_screenSizeX!) DO (
SET _screenBorder=!_screenBorder!Õ
SET _screenBlank=!_screenBlank!^ 
SET _titleBorder=!_titleBorder!ƒ
)

SET "_menuBorder="
SET "_menuBlank="
SET "_titleMenu="
FOR /l %%A IN (0, 1, !_menuSizeX!) DO (
SET _menuBorder=!_menuBorder!Õ
SET _menuBlank=!_menuBlank!^ 
SET _titleMenu=!_titleMenu!ƒ
)
REM IF !_pX1! EQU !_pRightX! IF !_mapX! NEQ !_mRightX! SET /a _mapX+=1
SET /a _mapX=(!_mapSizeX!/2)-(!_screenSizeX!/2)
SET /a _mRightX=!_mapSizeX!-!_screenSizeX!
SET /a _mapY=(!_mapSizeY!/2)-(!_screenSizeY!/2)
SET /a _mDownY=!_mapSizeY!-!_screenSizeY!-1
SET /A _mPos=!_mapY!*!_mapSizeX!+!_mapx!

SET /a _pLeftX=!_screenSizeX!/4
SET /a _pRightX=!_screenSizeX!-!_pLeftX!
SET /a _pUpY=!_screenSizeX!/6
SET /a _pDownY=!_screenSizeY!-!_pUpY!-1

SET /a _pStartX=(!_mapSizeX!/2)-(!_screenSizeX!/2)+(!_screenSizeX!/2)
SET /a _pStartY=(!_mapSizeY!/2)-(!_screenSizeY!/2)+(!_screenSizeY!/2)
SET /a _pPos=(!_pStartY!*!_mapSizeX!)+!_pStartX!

REM CREATE SOLID OBJECT ARRAY
SET "_solidString=≥ @ ≤ # ‹ › ﬁ ﬂ €"
SET i=0
FOR %%a IN (!_solidString!) DO (
   SET /A i+=1
   SET _solidTile[!i!]=%%a
   SET _solidNum=!i!
)

REM CREATE GROUND OBJECT ARRAY
SET "_visString=∫ ± ∞ € Ô ˘ ˙  "
SET i=0
FOR %%a IN (!_visString!) DO (
   SET /A i+=1
   SET _visTile[!i!]=%%a
   SET _visNum=!i!
)

REM CREATE PLAYER TILE ARRAY
SET "pString= è è è è ß ß -"
SET i=0
FOR %%a IN (è!pString!) DO (
   SET /A i+=1
   SET _pSprite[!i!]=%%a
   SET _pNum=!i!
)



SET /A _tempX=!_pPos!-!_mapX!
SET /A _spriteNum=0
SET _sprite[0]=è,!_pPos!,!_tempX!
REM Mode: 0=Play, 1=Build
SET /A _pMode=0
SET _hold=<NUL
GOTO :EOF



:Play_Screen
REM COMPILES A VISUAL REPRESENTATION OF WORLD + OBJECTS + LIGHTING

REM GET VALUES NEEDED FOR THE SCREEN 
rem SET /a _replace=!_pPos!-1
rem SET _world=!_world:~0,%_replace%!x!_world:~%_pPos%!
rem ECHO.R!_replace! P!_pPos!

SET "_world2=!_world:~%_mapSizeX%!)"
SET /A _mapEnd=!_mPos!+(!_screenSizeY!*!_mapSizeX!)

REM ADDS THE TOP OF THE SCREEN BORDER
SET _screen=!LF! …!_screenBorder:~1!—!_menuBorder!∏!LF!

REM BUILDS THE DISPLAY SCREEN | LIGHTING | AND SPRITES
FOR /l %%A IN (%_mPos%, %_mapSizeX%, %_mapEnd%) DO (
SET "_lastTile="
SET _screen=!_screen! ∫
SET /A _screenEnd=%%A+!_screenSizeX!-1

FOR /l %%B IN (%%A, 1, !_screenEnd!) DO (
SET _tile=!_world:~%%B,1!

REM ADDS A SHADOW TO THE RIGHT OF TALL BLOCKSs
REM "!_lastTile!"=="≤" IF "!_tile!"=="±" SET "_tile=∞"
REM IF "!_lastTile!"=="€" IF "!_tile!"=="±" SET _tile=∞
REM SOLID BLOCKS LOOK THE SAME
IF "!_world:~%%B,1!"=="€" SET _tile=≤
REM MAKES A DOOR WAY IF A PATH CONNCECTS TO A WALL
IF "!_world:~%%B,1!"=="≤" IF "!_world2:~%%B,1!"=="∞" SET _tile= 
IF "!_world:~%%B,1!"=="∞" IF "!_world2:~%%B,1!"=="≤" SET _tile=‹
REM ADDS THE PLAYER SPRITE
IF %%B==!_pPos! SET "_tile=è" 
REM ADDS A WHITE TOP FOR THESE TILES ≤ € ˛ Ô #
IF "!_world2:~%%B,1!"=="≤"  SET _tile=€
IF "!_world2:~%%B,1!"=="#"  SET _tile=€
IF "!_world2:~%%B,1!"=="€"  SET _tile=€
IF "!_world2:~%%B,1!"=="˛"  SET _tile=€
IF "!_world2:~%%B,1!"=="Ô"  SET _tile=€

SET _lastTile=!_world:~%%B,1!
SET _screen=!_screen!!_tile!
)
REM ADDS THE BOTTOM OF THE SCREEN BORDER
SET _screen=!_screen!√!_menuBlank!¥!LF!
)
cls
ECHO !_screen! «!_titleBorder:~1!≈!_titleMenu!¥
ECHO P1:(X!_pX!,Y!_pY!)!_pPos! Map:(X!_mapX!,Y!_mapY!)!_mPos! TILE:!_world:~%_pPos%,1! 

REM CALL :Dungeon1
REM ECHO Player Sprite = !_pSprite[1]!

GOTO :EOF
REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------

:PRINT_SPRITE
SET _rowLeft=!_world:~0,%1!
SET _rowRight=!_world:~%1!
EXIT /B
REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------


:gfx
MODE 80, 80
SET _pTile=!_world%:~%_pPos%,1!
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
MODE !_topBlockL!, 36
GOTO :EOF

:Build_Controls
REM CHANGE PLAYER AND SCREEN POSITION BASED ON 4 DIRECTIONAL PLAYER INPUT
choice /c wasdkl123456789g /n>nul

IF %errorlevel% EQU 16 GOTO :gfx
IF %errorlevel% EQU 15 SET _hold=Í
IF %errorlevel% EQU 14 SET _hold=
IF %errorlevel% EQU 13 SET _hold=#
IF %errorlevel% EQU 12 SET _hold=˛
IF %errorlevel% EQU 11 SET _hold=Ô
IF %errorlevel% EQU 10 SET _hold=±
IF %errorlevel% EQU 9 SET _hold=∞
IF %errorlevel% EQU 8 SET _hold=≤
IF %errorlevel% EQU 7 SET _hold=€
IF %errorlevel% EQU 6 GOTO :sprite
IF %errorlevel% EQU 5 SET /A _pMode=0 & GOTO :EOF
IF %errorlevel% EQU 4 IF "!_hold!"=="" (GOTO :rightB) ELSE (GOTO :rightPlace)
IF %errorlevel% EQU 3 IF "!_hold!"=="" (GOTO :downB) ELSE (GOTO :downPlace)
IF %errorlevel% EQU 2 IF "!_hold!"=="" (GOTO :leftB) ELSE (GOTO :leftPlace) 
IF %errorlevel% EQU 1 IF "!_hold!"=="" (GOTO :upB) ELSE (GOTO :upPlace)
GOTO :EOF

:upB
SET /A _pY=!_pPos!/!_mapSizeX!
IF !_pY! NEQ 0 SET /a _nPos=!_pPos!-!_mapSizeX!
SET _pTile=!_world:~%_pPos%,1!
SET _nTile=!_world:~%_nPos%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
REM PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :upMove)
IF "!_pTile!"=="∞" (GOTO :upMove)
) ELSE (
REM PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :upMove)
)
GOTO :EOF

:downB
SET /A _pY=!_pPos!/!_mapSizeX!
IF !_pY! NEQ !_mapSizeY! SET /A _nPos=!_pPos!+!_mapSizeX!
SET _pTile=!_world:~%_pPos%,1!
SET _nTile=!_world:~%_nPos%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
REM PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :downMove)
) ELSE (
REM PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :downMove)
IF "!_nTile!"=="∞" (GOTO :downMove)
)
GOTO :EOF

:leftB
SET /A _pX=!_pPos! %% !_mapSizeX!
IF !_pX! NEQ 0 SET /A _nPos=!_pPos!-1
SET _pTile=!_world:~%_pPos%,1!
SET _nTile=!_world:~%_nPos%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
REM PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :leftMove)
) ELSE (
REM PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :leftMove)
)
GOTO :EOF

:rightB
SET /A _pX=!_pPos! %% !_mapSizeX!
IF !_pX! NEQ !_mapSizeX! SET /A _nPos=!_pPos!+1
SET _pTile=!_world:~%_pPos%,1!
SET _nTile=!_world:~%_nPos%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
REM PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :rightMove)
) ELSE (
REM PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :rightMove)
)
GOTO :EOF

REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------

:upPlace
SET /a _r1=!_pPos!-!_mapSizeX!
SET /a _r2=!_pPos!-!_mapSizeX!+1
< "level2.txt" (SET /p "_world=")
SET _world=!_world:~0,%_r1%!!_hold!!_world:~%_r2%!
ECHO !_world! >> "temp.txt"
Move /Y "temp.txt" "level2.txt" < nul
SET _hold=<NUL
SET /A _hPos=-1
GOTO :EOF

:downPlace
SET /a _r1=!_pPos!+!_mapSizeX!
SET /a _r2=!_pPos!+!_mapSizeX!+1
< "level2.txt" (SET /p "_world=")
SET _world=!_world:~0,%_r1%!!_hold!!_world:~%_r2%!
ECHO !_world! >> "temp.txt"
Move /Y "temp.txt" "level2.txt" < nul
SET _hold=<NUL
SET /A _hPos=-1
GOTO :EOF

:leftPlace
SET /a _r1=!_pPos!-1
SET /a _r2=!_pPos!
< "level2.txt" (SET /p "_world=")
SET _world=!_world:~0,%_r1%!!_hold!!_world:~%_r2%!
ECHO !_world! >> "temp.txt"
Move /Y "temp.txt" "level2.txt" < nul
SET _hold=<NUL
SET /A _hPos=-1
GOTO :EOF

:rightPlace
SET /a _r1=!_pPos!+1
SET /a _r2=!_pPos!+2
< "level2.txt" (SET /p "_world=")
SET _world=!_world:~0,%_r1%!!_hold!!_world:~%_r2%!
ECHO !_world! >> "temp.txt"
Move /Y "temp.txt" "level2.txt" < nul
SET _hold=<NUL
SET /A _hPos=-1
GOTO :EOF

REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------

:Build_Screen
REM COMPILES A VISUAL REPRESENTATION OF WORLD + OBJECTS + LIGHTING

REM GET VALUES NEEDED FOR THE SCREEN 
SET "_world2=!_world:~%_mapSizeX%!)"
SET /A _mapEnd=!_mPos!+(!_screenSizeY!*!_mapSizeX!)
IF NOT "!_hold!"=="" SET /A _hPos=!_pPos!-!_mapSizeX!

REM ADDS THE TOP OF THE SCREEN BORDER
SET _screen=!LF! …!_screenBorder:~1!—!_menuBorder!∏!LF!

REM BUILDS THE DISPLAY SCREEN | LIGHTING | AND SPRITES
FOR /l %%A IN (%_mPos%, %_mapSizeX%, %_mapEnd%) DO (
SET "_lastTile="
SET _screen=!_screen! ∫
SET /A _screenEnd=%%A+!_screenSizeX!-1

FOR /l %%B IN (%%A, 1, !_screenEnd!) DO (
SET _tile=!_world:~%%B,1!

REM ADDS A SHADOW TO THE RIGHT OF TALL BLOCKS
REM "!_lastTile!"=="≤" IF "!_tile!"=="±" SET "_tile=∞"
REM IF "!_lastTile!"=="€" IF "!_tile!"=="±" SET _tile=∞

REM MAKES A DOOR WAY IF A PATH CONNCECTS TO A WALL
IF "!_world:~%%B,1!"=="≤" IF "!_world2:~%%B,1!"=="∞" SET _tile= 
IF "!_world:~%%B,1!"=="∞" IF "!_world2:~%%B,1!"=="≤" SET _tile=‹
REM ADDS THE PLAYER SPRITE
IF %%B==!_hPos! SET "_tile=!_hold!"
IF %%B==!_pPos! SET "_tile=é"
REM IF %%B==!_pPos! SET "_tile=è" 
REM ADDS A WHITE TOP FOR THESE TILES ≤ € ˛ Ô #
REM IF "!_world2:~%%B,1!"=="≤"  SET _tile=€
REM IF "!_world2:~%%B,1!"=="#"  SET _tile=€
REM IF "!_world2:~%%B,1!"=="€"  SET _tile=€
REM IF "!_world2:~%%B,1!"=="˛"  SET _tile=€
REM IF "!_world2:~%%B,1!"=="Ô"  SET _tile=€

SET _lastTile=!_world:~%%B,1!
SET _screen=!_screen!!_tile!
)
REM ADDS THE BOTTOM OF THE SCREEN BORDER
SET _screen=!_screen!√!_menuBlank!¥!LF!
)
cls
ECHO !_screen! «!_titleBorder:~1!¡!_titleMenu!¥
ECHO  ∫!_screenBlank!!_menuBlank!≥
ECHO  ∫!_screenBlank!!_menuBlank!≥
ECHO  ”!_titleBorder!!_titleMenu!Ÿ
ECHO  1.€ 2.≤ 3.∞ 4.± 5.Ô 6.˛ 7.# 8. 9.Í
ECHO.
ECHO        
ECHO        W               (G)=Graphics
ECHO     A   D
ECHO        S            (K)=Play Mode
ECHO        
ECHO                  (M)=MAP
ECHO %ESC%[03;27H1. €%ESC%[05;27H2. ≤
GOTO :EOF


REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------

:Play_Controls
REM CHANGE PLAYER AND SCREEN POSITION BASED ON 4 DIRECTIONAL PLAYER INPUT
CHOICE /C:wasdgmrklx /N /D:x /T:1 >NUL
IF %errorlevel% EQU 10 GOTO :EOF
IF %errorlevel% EQU 9 GOTO :EOF
IF %errorlevel% EQU 8 SET /A _pMode=1 & GOTO :EOF
IF %errorlevel% EQU 7 GOTO :beginningsddss
IF %errorlevel% EQU 6 GOTO :map2
IF %errorlevel% EQU 5 GOTO :gfx
IF %errorlevel% EQU 4 GOTO :rightP
IF %errorlevel% EQU 3 GOTO :downP
IF %errorlevel% EQU 2 GOTO :leftP
IF %errorlevel% EQU 1 GOTO :upP 
GOTO :EOF

:upP
SET /A _pY=!_pPos!/!_mapSizeX!
IF !_pY! NEQ 0 SET /a _nPos=!_pPos!-!_mapSizeX!
SET _pTile=!_world:~%_pPos%,1!
SET _nTile=!_world:~%_nPos%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
REM PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :upMove)
IF "!_pTile!"=="∞" (GOTO :upMove)
) ELSE (
REM PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :upMove)
)
GOTO :EOF

:downP
SET /A _pY=!_pPos!/!_mapSizeX!
IF !_pY! NEQ !_mapSizeY! SET /A _nPos=!_pPos!+!_mapSizeX!
SET _pTile=!_world:~%_pPos%,1!
SET _nTile=!_world:~%_nPos%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
REM PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :downMove)
) ELSE (
REM PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :downMove)
IF "!_nTile!"=="∞" (GOTO :downMove)
)
GOTO :EOF

:leftP
SET /A _pX=!_pPos! %% !_mapSizeX!

IF !_pX! NEQ 0 SET /A _nPos=!_pPos!-1
SET _pTile=!_world:~%_pPos%,1!
SET _nTile=!_world:~%_nPos%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
REM PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :leftMove)
) ELSE (
REM PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :leftMove)
)
GOTO :EOF

:rightP
SET /A _pX=!_pPos! %% !_mapSizeX!
IF !_pX! NEQ !_mapSizeX! SET /A _nPos=!_pPos!+1
SET _pTile=!_world:~%_pPos%,1!
SET _nTile=!_world:~%_nPos%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
REM PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :rightMove)
) ELSE (
REM PLAYER IS INSIDE
IF NOT "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :rightMove)
)
GOTO :EOF

REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------

:upMove
REM SET /A _pY1=!_pY!-!_mapY! , _pUpY=!_screenSizeX!/6
SET /A _pPos=!_nPos!
SET /A _mapY=!_mPos!/!_mapSizeX!
SET /A _pY1=!_pY!-!_mapY!
IF !_pY1! EQU !_pUpY! IF !_mapY! NEQ 0 SET /a _mPos-=!_mapSizeX!
GOTO :EOF

:downMove
REM
SET /A _pPos=!_nPos!
SET /A _mapY=!_mPos!/!_mapSizeX!
SET /A _pY1=!_pY!-!_mapY!
IF !_pY1! EQU !_pDownY! IF !_mapY! NEQ !_mDownY! SET /a _mPos+=!_mapSizeX!
GOTO :EOF

:leftMove
REM
SET /A _pPos=!_nPos!
SET /A _mapX=!_mPos! %% !_mapSizeX!
SET /A _pX1=!_pX!-!_mapX!
IF !_pX1! EQU !_pLeftX! IF !_mapX! NEQ 0 SET /a _mPos-=1
GOTO :EOF

:rightMove
REM
SET /A _pPos=!_nPos!
SET /A _mapX=!_mPos! %% !_mapSizeX!
SET /A _pX1=!_pX!-!_mapX!
IF !_pX1! EQU !_pRightX! IF !_mapX! NEQ !_mRightX! SET /a _mPos+=1
GOTO :EOF

REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------



:Dungeon1
ECHO. …!_screenBorder:~1!—!_menuBorder!∏
ECHO. ∫                     ‹√!_menuBlank!¥
ECHO. ∫__À                À€€√!_menuBlank!¥
ECHO. ∫≤≤Œ≤À            À≤Œ€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≥_“________“±≥≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≥∞≥∞∞∞∞∞∞∞∞≥±≥≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≥∞≥∞∞∞∞∞∞∞∞≥±≥≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≥∞≥∞∞∞∞∞∞∞∞≥±≥≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≥           ±≥≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≥            ≥≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤              ≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥                ≥€€√!_menuBlank!¥
ECHO. ∫                    €€√!_menuBlank!¥
ECHO. ∫                     €√!_menuBlank!¥
ECHO. «!_titleBorder:~1!≈!_titleMenu!¥
GOTO :EOF

:Dungeon2
ECHO. …!_screenBorder:~1!—!_menuBorder!∏
ECHO. ∫‹                    ‹√!_menuBlank!¥
ECHO. ∫€€À                À€€√!_menuBlank!¥
ECHO. ∫€€Œ_À____________À≤Œ€€√!_menuBlank!¥
ECHO. ∫€€∫±≥±±±±±±±±±±±±≥≤∫€€√!_menuBlank!¥
ECHO. ∫€€∫±≥±±±±±±±±±±±±≥≤∫€€√!_menuBlank!¥
ECHO. ∫€€∫±≥±±±±±±±±±±±±≥≤∫€€√!_menuBlank!¥
ECHO. ∫€€∫±≥±±±±±±±±±±±±≥≤∫€€√!_menuBlank!¥
ECHO. ∫€€∫±≥±±±±±±±±±±±±≥≤∫€€√!_menuBlank!¥
ECHO. ∫€€∫±≥±±±±±±±±±±±±≥≤∫€€√!_menuBlank!¥
ECHO. ∫€€∫               ≤∫€€√!_menuBlank!¥
ECHO. ∫€€∫                ∫€€√!_menuBlank!¥
ECHO. ∫€€                  €€√!_menuBlank!¥
ECHO. ∫€                    €√!_menuBlank!¥
ECHO. «!_titleBorder:~1!≈!_titleMenu!¥
GOTO :EOF

:Dungeon3
ECHO. …!_screenBorder:~1!—!_menuBorder!∏
ECHO. ∫                     ‹√!_menuBlank!¥
ECHO. ∫__À________________À€€√!_menuBlank!¥
ECHO. ∫≤≤Œ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤Œ€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≥€€√!_menuBlank!¥
ECHO. ∫≤≤≥≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≥€€√!_menuBlank!¥
ECHO. ∫                    €€√!_menuBlank!¥
ECHO. ∫                     €√!_menuBlank!¥
ECHO. «!_titleBorder:~1!≈!_titleMenu!¥
GOTO :EOF

:Dungeon4
ECHO. …!_screenBorder:~1!—!_menuBorder!∏
ECHO. ∫‹                    ‹√!_menuBlank!¥
ECHO. ∫€€À                À€€√!_menuBlank!¥
ECHO. ∫€€≥_“            “≤≥€€√!_menuBlank!¥
ECHO. ∫€€≥±≥±¬        ¬±≥≤≥€€√!_menuBlank!¥
ECHO. ∫€€≥±≥±≥≥      ≥≥±≥≤≥€€√!_menuBlank!¥
ECHO. ∫€€≥±≥±≥≥      ≥≥±≥≤≥€€√!_menuBlank!¥
ECHO. ∫€€≥±≥±≥        ≥±≥≤≥€€√!_menuBlank!¥
ECHO. ∫€€≥±≥±          ±≥≤≥€€√!_menuBlank!¥
ECHO. ∫€€≥±≥            ≥≤≥€€√!_menuBlank!¥
ECHO. ∫€€≥               ≤≥€€√!_menuBlank!¥
ECHO. ∫€€≥                ≥€€√!_menuBlank!¥
ECHO. ∫€€                  €€√!_menuBlank!¥
ECHO. ∫€                    €√!_menuBlank!¥
ECHO. «!_titleBorder:~1!≈!_titleMenu!¥
GOTO :EOF

:Dungeon5
ECHO. …!_screenBorder:~1!—!_menuBorder!∏
ECHO. ∫ \ÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀ/ √!_menuBlank!¥
ECHO. ∫  ∂\…ÕÕÕÕÕÕÕÕÕÕÕÕª/«  √!_menuBlank!¥
ECHO. ∫  ∂ ﬁ\“ƒƒƒƒƒƒƒƒ“/› «  √!_menuBlank!¥
ECHO. ∫  ∂ ﬁ ≥        ≥ › «  √!_menuBlank!¥
ECHO. ∫  ∂ ﬁ ≥        ≥ › «  √!_menuBlank!¥
ECHO. ∫  ∂ ﬁ ≥        ≥ › «  √!_menuBlank!¥
ECHO. ∫  ∂ ﬁ            › «  √!_menuBlank!¥
ECHO. ∫  ∂ ﬁ   ∞∞∞∞∞∞   › «  √!_menuBlank!¥
ECHO. ∫  ∂  ∞∞±±±±±±±±∞∞  «  √!_menuBlank!¥
ECHO. ∫  ∂∞±±±≤≤≤≤≤≤≤≤±±±∞«  √!_menuBlank!¥
ECHO. ∫  ±≤≤≤≤≤€€€€€€≤≤≤≤≤±  √!_menuBlank!¥
ECHO. ∫ ±≤≤€€€€€€€€€€€€€€≤≤± √!_menuBlank!¥
ECHO. ∫≤€€€€€€€€€€€€€€€€€€€€≤√!_menuBlank!¥
ECHO. «!_titleBorder:~1!≈!_titleMenu!¥
GOTO :EOF

:Dungeon6
ECHO. …!_screenBorder:~1!—!_menuBorder!∏
ECHO. ∫€\ÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀ/€√!_menuBlank!¥
ECHO. ∫€›∂\“ÕÕÕÕÕÕÕÕÕÕÕÕ“/«ﬁ€√!_menuBlank!¥
ECHO. ∫€›∂±ﬁ\¬ƒƒƒƒƒƒƒƒ¬/›±«ﬁ€√!_menuBlank!¥
ECHO. ∫€›∂≤ﬁ∞≥∞∞∞∞∞∞∞∞≥∞›≤«ﬁ€√!_menuBlank!¥
ECHO. ∫€›∂≤ﬁ±≥∞∞∞∞∞∞∞∞≥±›≤«ﬁ€√!_menuBlank!¥
ECHO. ∫€›∂≤ﬁ±≥∞∞∞∞∞∞∞∞≥±›≤«ﬁ€√!_menuBlank!¥
ECHO. ∫€›∂≤ﬁ∞          ∞›≤«ﬁ€√!_menuBlank!¥
ECHO. ∫€›∂≤ﬁ   ∞∞∞∞∞∞   ›≤«ﬁ€√!_menuBlank!¥
ECHO. ∫€›∂± ∞∞±±±±±±±±∞∞ ±«ﬁ€√!_menuBlank!¥
ECHO. ∫€›∂∞±±≤≤≤≤≤≤≤≤≤≤±±∞«ﬁ€√!_menuBlank!¥
ECHO. ∫€›±≤≤≤≤≤€€€€€€≤≤≤≤≤±ﬁ€√!_menuBlank!¥
ECHO. ∫€±≤≤€€€€€€€€€€€€€€≤≤±€√!_menuBlank!¥
ECHO. ∫≤€€€€€€€€€€€€€€€€€€€€≤√!_menuBlank!¥
ECHO. «!_titleBorder:~1!≈!_titleMenu!¥
GOTO :EOF

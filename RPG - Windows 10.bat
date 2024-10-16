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
CALL :MACROS

:BEGINNING

CALL :Create_Variables

REM THIS IS THE MAIN LOOP
:OVERWORLD
REM ---------  CAPTURE START TIME
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set /A "start_time=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

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


REM ---------  CAPTURE END TIME
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set /A "end_time=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

REM ---------  CALCULATE TIME DIFFERENCE
set /A "elapsed_time=end_time-start_time"

echo %ESC%[00;00H%elapsed_time% ms.
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
SET _screenBorder=!_screenBorder!Í
SET _screenBlank=!_screenBlank!^ 
SET _titleBorder=!_titleBorder!Ä
)

SET "_menuBorder="
SET "_menuBlank="
SET "_titleMenu="
FOR /l %%A IN (0, 1, !_menuSizeX!) DO (
SET _menuBorder=!_menuBorder!Í
SET _menuBlank=!_menuBlank!^ 
SET _titleMenu=!_titleMenu!Ä
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
SET "_solidString=³ @ ² # Ü Ý Þ ß Û"
SET i=0
FOR %%a IN (!_solidString!) DO (
   SET /A i+=1
   SET _solidTile[!i!]=%%a
   SET _solidNum=!i!
)

REM CREATE GROUND OBJECT ARRAY
SET "_visString=º ± ° Û ï ù ú  "
SET i=0
FOR %%a IN (!_visString!) DO (
   SET /A i+=1
   SET _visTile[!i!]=%%a
   SET _visNum=!i!
)

REM CREATE PLAYER TILE ARRAY
SET "pString=     § § -"
SET i=0
FOR %%a IN (!pString!) DO (
   SET /A i+=1
   SET _pSprite[!i!]=%%a
   SET _pNum=!i!
)



SET /A _tempX=!_pPos!-!_mapX!
SET /A _spriteNum=0
SET _sprite[0]=,!_pPos!,!_tempX!
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
ECHO %col:c=161;161;161%
SET "_world2=!_world:~%_mapSizeX%!)"
SET /A _mapEnd=!_mPos!+(!_screenSizeY!*!_mapSizeX!)

REM ADDS THE TOP OF THE SCREEN BORDER
SET _screen=
SET _screen2=
SET /A _screenY=3


REM BUILDS THE DISPLAY SCREEN | LIGHTING | AND SPRITES
FOR /l %%A IN (%_mPos%, %_mapSizeX%, %_mapEnd%) DO (

SET "_lastTile="
SET /A _screenX=3
SET "_screen=!_screen!%ESC%[!_screenY!;03H!_world:~%%A,%_screenSizeX%!"

SET /A _screenEnd=%%A+!_screenSizeX!-1

FOR /l %%B IN (%%A, 1, !_screenEnd!) DO (
REM SET _tile=%col:c=0;161;0%!_world:~%%B,1!

REM ADDS A SHADOW TO THE RIGHT OF TALL BLOCKSs
REM IF "!_lastTile!"=="²" IF "!_tile!"=="±" SET "_tile=°"
REM IF "!_lastTile!"=="Û" IF "!_tile!"=="±" SET _tile=°
REM SOLID BLOCKS LOOK THE SAME
IF "!_world:~%%B,1!"=="Û" SET _screen2=!_screen2!%ESC%[!_screenY!;!_screenX!H%col:c=161;255;161%²
REM MAKES A DOOR WAY IF A PATH CONNCECTS TO A WALL
IF "!_world:~%%B,1!"=="²" SET _screen2=!_screen2!%ESC%[!_screenY!;!_screenX!H%col:c=161;255;161%²&IF "!_world2:~%%B,1!"=="°" SET _screen2=!_screen2!%ESC%[!_screenY!;!_screenX!H%col:c=161;255;161% 
IF "!_world:~%%B,1!"=="°" IF "!_world2:~%%B,1!"=="²" SET _screen2=!_screen2!%ESC%[!_screenY!;!_screenX!H%col:c=161;255;161%Ü
REM ADDS THE PLAYER SPRITE
IF %%B==!_pPos! SET "_tile=%col:c=222;161;133%" 
REM ADDS A WHITE TOP FOR THESE TILES ² Û þ ï #
IF "!_world2:~%%B,1!"=="²"  SET _screen2=!_screen2!%ESC%[!_screenY!;!_screenX!H%col:c=161;255;161%Û
IF "!_world2:~%%B,1!"=="#"  SET _screen2=!_screen2!%ESC%[!_screenY!;!_screenX!H%col:c=161;255;161%Û
IF "!_world2:~%%B,1!"=="Û"  SET _screen2=!_screen2!%ESC%[!_screenY!;!_screenX!H%col:c=161;255;161%Û
IF "!_world2:~%%B,1!"=="þ"  SET _screen2=!_screen2!%ESC%[!_screenY!;!_screenX!H%col:c=161;255;161%Û
IF "!_world2:~%%B,1!"=="ï"  SET _screen2=!_screen2!%ESC%[!_screenY!;!_screenX!H%col:c=161;255;161%Û

SET _lastTile=!_world:~%%B,1!
SET /A _screenX+=1
)
REM ADDS THE BOTTOM OF THE SCREEN BORDER
SET /A _screenY+=1
)
cls
ECHO %ESC%[02;01H%col:c=255;255;255% É!_screenBorder:~1!Ñ!_menuBorder!¸%ESC%[03;01H%col:c=255;255;255% º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! º!_screenBlank:~1!Ã!_menuBlank!´!LF! Ç!_titleBorder:~1!Á!_titleMenu!´!LF! º!_screenBlank!!_menuBlank!³!LF! º!_screenBlank!!_menuBlank!³!LF! Ó!_titleBorder!!_titleMenu!Ù
ECHO %col:c=0;255;0%!_screen!
ECHO !_screen2!

REM CALL :Dungeon1
REM ECHO Player Sprite = !_pSprite[1]!
ECHO %ESC%[03;27H%col:c=222;161;133%1. Û%ESC%[05;27H%col:c=255;255;255%2. ² %ESC%[07;27HP1:!_pPos!%ESC%[09;27HMAP:!_mPos!%ESC%[11;27HTILE:!_world:~%_pPos%,1!

GOTO :EOF
REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------

:PRINT_SPRITE
SET _rowLeft=!_world:~0,%1!
SET _rowRight=!_world:~%1!
EXIT /B
REM ------------------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------------------



:Dungeon1
ECHO. É!_screenBorder:~1!Ñ!_menuBorder!¸
ECHO. º                     ÜÃ!_menuBlank!´
ECHO. º__Ë                ËÛÛÃ!_menuBlank!´
ECHO. º²²Î²Ë            Ë²ÎÛÛÃ!_menuBlank!´
ECHO. º²²³²³_Ò________Ò±³²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²³°³°°°°°°°°³±³²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²³°³°°°°°°°°³±³²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²³°³°°°°°°°°³±³²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²³           ±³²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²³            ³²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²              ²³ÛÛÃ!_menuBlank!´
ECHO. º²²³                ³ÛÛÃ!_menuBlank!´
ECHO. º                    ÛÛÃ!_menuBlank!´
ECHO. º                     ÛÃ!_menuBlank!´
ECHO. Ç!_titleBorder:~1!Å!_titleMenu!´
GOTO :EOF

:Dungeon2
ECHO. É!_screenBorder:~1!Ñ!_menuBorder!¸
ECHO. ºÜ                    ÜÃ!_menuBlank!´
ECHO. ºÛÛË                ËÛÛÃ!_menuBlank!´
ECHO. ºÛÛÎ_Ë____________Ë²ÎÛÛÃ!_menuBlank!´
ECHO. ºÛÛº±³±±±±±±±±±±±±³²ºÛÛÃ!_menuBlank!´
ECHO. ºÛÛº±³±±±±±±±±±±±±³²ºÛÛÃ!_menuBlank!´
ECHO. ºÛÛº±³±±±±±±±±±±±±³²ºÛÛÃ!_menuBlank!´
ECHO. ºÛÛº±³±±±±±±±±±±±±³²ºÛÛÃ!_menuBlank!´
ECHO. ºÛÛº±³±±±±±±±±±±±±³²ºÛÛÃ!_menuBlank!´
ECHO. ºÛÛº±³±±±±±±±±±±±±³²ºÛÛÃ!_menuBlank!´
ECHO. ºÛÛº               ²ºÛÛÃ!_menuBlank!´
ECHO. ºÛÛº                ºÛÛÃ!_menuBlank!´
ECHO. ºÛÛ                  ÛÛÃ!_menuBlank!´
ECHO. ºÛ                    ÛÃ!_menuBlank!´
ECHO. Ç!_titleBorder:~1!Å!_titleMenu!´
GOTO :EOF

:Dungeon3
ECHO. É!_screenBorder:~1!Ñ!_menuBorder!¸
ECHO. º                     ÜÃ!_menuBlank!´
ECHO. º__Ë________________ËÛÛÃ!_menuBlank!´
ECHO. º²²Î²²²²²²²²²²²²²²²²ÎÛÛÃ!_menuBlank!´
ECHO. º²²³²²²²²²²²²²²²²²²²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²²²²²²²²²²²²²²²²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²²²²²²²²²²²²²²²²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²²²²²²²²²²²²²²²²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²²²²²²²²²²²²²²²²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²²²²²²²²²²²²²²²²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²²²²²²²²²²²²²²²²³ÛÛÃ!_menuBlank!´
ECHO. º²²³²²²²²²²²²²²²²²²²³ÛÛÃ!_menuBlank!´
ECHO. º                    ÛÛÃ!_menuBlank!´
ECHO. º                     ÛÃ!_menuBlank!´
ECHO. Ç!_titleBorder:~1!Å!_titleMenu!´
GOTO :EOF

:Dungeon4
ECHO. É!_screenBorder:~1!Ñ!_menuBorder!¸
ECHO. ºÜ                    ÜÃ!_menuBlank!´
ECHO. ºÛÛË                ËÛÛÃ!_menuBlank!´
ECHO. ºÛÛ³_Ò            Ò²³ÛÛÃ!_menuBlank!´
ECHO. ºÛÛ³±³±Â        Â±³²³ÛÛÃ!_menuBlank!´
ECHO. ºÛÛ³±³±³³      ³³±³²³ÛÛÃ!_menuBlank!´
ECHO. ºÛÛ³±³±³³      ³³±³²³ÛÛÃ!_menuBlank!´
ECHO. ºÛÛ³±³±³        ³±³²³ÛÛÃ!_menuBlank!´
ECHO. ºÛÛ³±³±          ±³²³ÛÛÃ!_menuBlank!´
ECHO. ºÛÛ³±³            ³²³ÛÛÃ!_menuBlank!´
ECHO. ºÛÛ³               ²³ÛÛÃ!_menuBlank!´
ECHO. ºÛÛ³                ³ÛÛÃ!_menuBlank!´
ECHO. ºÛÛ                  ÛÛÃ!_menuBlank!´
ECHO. ºÛ                    ÛÃ!_menuBlank!´
ECHO. Ç!_titleBorder:~1!Å!_titleMenu!´
GOTO :EOF

:Dungeon5
ECHO. É!_screenBorder:~1!Ñ!_menuBorder!¸
ECHO. º \ËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍË/ Ã!_menuBlank!´
ECHO. º  ¶\ÉÍÍÍÍÍÍÍÍÍÍÍÍ»/Ç  Ã!_menuBlank!´
ECHO. º  ¶ Þ\ÒÄÄÄÄÄÄÄÄÒ/Ý Ç  Ã!_menuBlank!´
ECHO. º  ¶ Þ ³        ³ Ý Ç  Ã!_menuBlank!´
ECHO. º  ¶ Þ ³        ³ Ý Ç  Ã!_menuBlank!´
ECHO. º  ¶ Þ ³        ³ Ý Ç  Ã!_menuBlank!´
ECHO. º  ¶ Þ            Ý Ç  Ã!_menuBlank!´
ECHO. º  ¶ Þ   °°°°°°   Ý Ç  Ã!_menuBlank!´
ECHO. º  ¶  °°±±±±±±±±°°  Ç  Ã!_menuBlank!´
ECHO. º  ¶°±±±²²²²²²²²±±±°Ç  Ã!_menuBlank!´
ECHO. º  ±²²²²²ÛÛÛÛÛÛ²²²²²±  Ã!_menuBlank!´
ECHO. º ±²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²± Ã!_menuBlank!´
ECHO. º²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²Ã!_menuBlank!´
ECHO. Ç!_titleBorder:~1!Å!_titleMenu!´
GOTO :EOF

:Dungeon6
ECHO. É!_screenBorder:~1!Ñ!_menuBorder!¸
ECHO. ºÛ\ËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍË/ÛÃ!_menuBlank!´
ECHO. ºÛÝ¶\ÒÍÍÍÍÍÍÍÍÍÍÍÍÒ/ÇÞÛÃ!_menuBlank!´
ECHO. ºÛÝ¶±Þ\ÂÄÄÄÄÄÄÄÄÂ/Ý±ÇÞÛÃ!_menuBlank!´
ECHO. ºÛÝ¶²Þ°³°°°°°°°°³°Ý²ÇÞÛÃ!_menuBlank!´
ECHO. ºÛÝ¶²Þ±³°°°°°°°°³±Ý²ÇÞÛÃ!_menuBlank!´
ECHO. ºÛÝ¶²Þ±³°°°°°°°°³±Ý²ÇÞÛÃ!_menuBlank!´
ECHO. ºÛÝ¶²Þ°          °Ý²ÇÞÛÃ!_menuBlank!´
ECHO. ºÛÝ¶²Þ   °°°°°°   Ý²ÇÞÛÃ!_menuBlank!´
ECHO. ºÛÝ¶± °°±±±±±±±±°° ±ÇÞÛÃ!_menuBlank!´
ECHO. ºÛÝ¶°±±²²²²²²²²²²±±°ÇÞÛÃ!_menuBlank!´
ECHO. ºÛÝ±²²²²²ÛÛÛÛÛÛ²²²²²±ÞÛÃ!_menuBlank!´
ECHO. ºÛ±²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²±ÛÃ!_menuBlank!´
ECHO. º²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²Ã!_menuBlank!´
ECHO. Ç!_titleBorder:~1!Å!_titleMenu!´
GOTO :EOF

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
ECHO      127:    128: €   129:    130: ‚   131: ƒ   132: „   133: …   134: †
ECHO.
ECHO      135: ‡   136: ˆ   137: ‰   138: Š   139: ‹   140: Œ   141:    142: Ž
ECHO.
ECHO      143:    144:    145: ‘   146: ’   147: “   148: ”   149: •   150: –
ECHO.
ECHO      151: —   152: ˜   153: ™   154: š   155: ›   156: œ   157:    158: ž
ECHO.
ECHO      159: Ÿ   160:     161: ¡   162: ¢   163: £   164: ¤   165: ¥   166: ¦
ECHO.
ECHO      167: §   168: ¨   169: ©   170: ª   171: «   172: ¬   173: ­   174: ®
ECHO.
ECHO      175: ¯   176: °   177: ±   178: ²   179: ³   180: ´   181: µ   182: ¶
ECHO.
ECHO      183: ·   184: ¸   185: ¹   186: º   187: »   188: ¼   189: ½   190: ¾
ECHO.
ECHO      191: ¿   192: À   193: Á   194: Â   195: Ã   196: Ä   197: Å   198: Æ
ECHO.
ECHO      199: Ç   200: È   201: É   202: Ê   203: Ë   204: Ì   205: Í   206: Î
ECHO.
ECHO      207: Ï   208: Ð   209: Ñ   210: Ò   211: Ó   212: Ô   213: Õ   214: Ö
ECHO.
ECHO      215: ×   216: Ø   217: Ù   218: Ú   219: Û   220: Ü   221: Ý   222: Þ
ECHO.
ECHO      223: ß   224: à   225: á   226: â   227: ã   228: ä   229: å   230: æ
ECHO.
ECHO      231: ç   232: è   233: é   234: ê   235: ë   236: ì   237: í   238: î
ECHO.
ECHO      239: ï   240: ð   241: ñ   242: ò   243: ó   244: ô   245: õ   246: ö
ECHO.
ECHO      247: ÷   248: ø   249: ù   250: ú   251: û   252: ü   253: ý   254: þ
ECHO.
ECHO.
pause
MODE !_topBlockL!, 36
GOTO :EOF

:Build_Controls
REM CHANGE PLAYER AND SCREEN POSITION BASED ON 4 DIRECTIONAL PLAYER INPUT
choice /c wasdkl123456789g /n>nul

IF %errorlevel% EQU 16 GOTO :gfx
IF %errorlevel% EQU 15 SET _hold=ê
IF %errorlevel% EQU 14 SET _hold=
IF %errorlevel% EQU 13 SET _hold=#
IF %errorlevel% EQU 12 SET _hold=þ
IF %errorlevel% EQU 11 SET _hold=ï
IF %errorlevel% EQU 10 SET _hold=±
IF %errorlevel% EQU 9 SET _hold=°
IF %errorlevel% EQU 8 SET _hold=²
IF %errorlevel% EQU 7 SET _hold=Û
IF %errorlevel% EQU 6 GOTO :sprite
IF %errorlevel% EQU 5 SET /A _pMode=0 & GOTO :EOF
IF %errorlevel% EQU 4 IF "!_hold!"=="" (GOTO :rightB) ELSE (GOTO :rightPlace)
IF %errorlevel% EQU 3 IF "!_hold!"=="" (GOTO :downB) ELSE (GOTO :downPlace)
IF %errorlevel% EQU 2 IF "!_hold!"=="" (GOTO :leftB) ELSE (GOTO :leftPlace) 
IF %errorlevel% EQU 1 IF "!_hold!"=="" (GOTO :upB) ELSE (GOTO :upPlace)
GOTO :EOFdidn't ring

:upB
SET /A _pY=!_pPos!/!_mapSizeX!
IF !_pY! NEQ 0 SET /a _nPos=!_pPos!-!_mapSizeX!
SET _pTile=!_world:~%_pPos%,1!
SET _nTile=!_world:~%_nPos%,1!
IF "!_solidString:%_pTile%=!"=="!_solidString!" (
REM PLAYER IS OUTSIDE
IF "!_solidString:%_nTile%=!"=="!_solidString!" (GOTO :upMove)
IF "!_pTile!"=="°" (GOTO :upMove)
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
IF "!_nTile!"=="°" (GOTO :downMove)
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
SET _screen=!LF! É!_screenBorder:~1!Ñ!_menuBorder!¸!LF!

REM BUILDS THE DISPLAY SCREEN | LIGHTING | AND SPRITES
FOR /l %%A IN (%_mPos%, %_mapSizeX%, %_mapEnd%) DO (
SET "_lastTile="
SET _screen=!_screen! º
SET /A _screenEnd=%%A+!_screenSizeX!-1

FOR /l %%B IN (%%A, 1, !_screenEnd!) DO (
SET _tile=!_world:~%%B,1!

REM ADDS A SHADOW TO THE RIGHT OF TALL BLOCKS
REM "!_lastTile!"=="²" IF "!_tile!"=="±" SET "_tile=°"
REM IF "!_lastTile!"=="Û" IF "!_tile!"=="±" SET _tile=°

REM MAKES A DOOR WAY IF A PATH CONNCECTS TO A WALL
IF "!_world:~%%B,1!"=="²" IF "!_world2:~%%B,1!"=="°" SET _tile= 
IF "!_world:~%%B,1!"=="°" IF "!_world2:~%%B,1!"=="²" SET _tile=Ü
REM ADDS THE PLAYER SPRITE
IF %%B==!_hPos! SET "_tile=!_hold!"
IF %%B==!_pPos! SET "_tile=Ž"
REM IF %%B==!_pPos! SET "_tile=" 
REM ADDS A WHITE TOP FOR THESE TILES ² Û þ ï #
REM IF "!_world2:~%%B,1!"=="²"  SET _tile=Û
REM IF "!_world2:~%%B,1!"=="#"  SET _tile=Û
REM IF "!_world2:~%%B,1!"=="Û"  SET _tile=Û
REM IF "!_world2:~%%B,1!"=="þ"  SET _tile=Û
REM IF "!_world2:~%%B,1!"=="ï"  SET _tile=Û

SET _lastTile=!_world:~%%B,1!
SET _screen=!_screen!!_tile!
)
REM ADDS THE BOTTOM OF THE SCREEN BORDER
SET _screen=!_screen!Ã!_menuBlank!´!LF!
)
cls
ECHO !_screen! Ç!_titleBorder:~1!Á!_titleMenu!´
ECHO  º!_screenBlank!!_menuBlank!³
ECHO  º!_screenBlank!!_menuBlank!³
ECHO  Ó!_titleBorder!!_titleMenu!Ù
ECHO  1.Û 2.² 3.° 4.± 5.ï 6.þ 7.# 8. 9.ê
ECHO.
ECHO        
ECHO        W               (G)=Graphics
ECHO     A   D
ECHO        S            (K)=Play Mode
ECHO        
ECHO                  (M)=MAP
ECHO %ESC%[03;27H1. Û%ESC%[05;27H2. ²
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
IF "!_pTile!"=="°" (GOTO :upMove)
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
IF "!_nTile!"=="°" (GOTO :downMove)
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

:MACROS
FOR /F %%A in ('ECHO prompt $E^| cmd') DO SET "ESC=%%A"
SET every="1/((frame %% #)^0)"
SET "col=%ESC%[38;2;cm"
SET "up=%ESC%[nA"
SET "dn=%ESC%[nB"
SET "bk=%ESC%[nD"
SET "nx=%ESC%[nC"
GOTO :EOF
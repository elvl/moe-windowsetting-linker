@echo OFF
setlocal enabledelayedexpansion

set DIR=C:\app\Master of Epic\userdata


openfiles > NUL 2>&1
if not %ERRORLEVEL% equ 0 (
  echo This batch requires administrator privileges.
  pause
  exit /b
)

if not exist "%DIR%" (
  echo userdata directory does not exist: %DIR%
  pause
  exit /b
)

for %%A in (wnd msgopt wnd_docking) do (
  if not exist "%DIR%\window_setting\%%A.ini" (
    echo configuration file does not exist: %DIR%\window_setting\%%A.ini
    pause
    exit /b
  )
)

for /f %%A in ('wmic os get LocalDateTime ^| findstr \.') do set DATE=%%A
set BACKUPDIR=%DIR%\window_setting\backup\!DATE:~0,8!
if not exist "!BACKUPDIR!" (mkdir "!BACKUPDIR!")
cp -f "%DIR%\window_setting\*.ini" "!BACKUPDIR!"


for /d %%A in ("%DIR%\*_") do (
  set WND=
  set MSGOPT=
  set WND_DOCKING=
  set CHRDIR=%%A
  set CHRNAMEDIR=!CHRDIR:%DIR%\=!

  if exist "!CHRDIR!\link-setting.ini" (
    for /f "usebackq tokens=1,2 delims==" %%I in ("!CHRDIR!\link-setting.ini") do set %%I=%%J
  )

  for %%K in (wnd msgopt wnd_docking) do (
    set INI=%%K.ini
    set ALTINI=
    if defined %%K (set ALTINI=%%K-!%%K!.ini)

    if exist "!CHRDIR!\!INI!" (
      for %%N in ("!CHRDIR!\!INI!") do set ATTR=%%~aN

      if "!ATTR:l=!" == "!ATTR!" (
        if not exist "!BACKUPDIR!\!CHRNAMEDIR!" (mkdir "!BACKUPDIR!\!CHRNAMEDIR!")
        cp -f "!CHRDIR!\!INI!" "!BACKUPDIR!\!CHRNAMEDIR!"
      )

      del "!CHRDIR!\!INI!"
    )

    if defined ALTINI (
      if not exist "%DIR%\window_setting\!ALTINI!" (
        cp -f "%DIR%\window_setting\!INI!" "%DIR%\window_setting\!ALTINI!"
      )

      mklink "!CHRDIR!\!INI!" "%DIR%\window_setting\!ALTINI!"
    ) else (
      mklink "!CHRDIR!\!INI!" "%DIR%\window_setting\!INI!"
    )
  )
)

pause
exit
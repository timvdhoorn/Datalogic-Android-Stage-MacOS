@echo off
cd /d %~dp0

::User configurable parameters
set Reset=FALSE
set Log=TRUE
set Debug=FALSE
set Reboot=FALSE
set RebootTimeout=10
set LeaveonUSBDebugging=TRUE


set fwfolder=Firmware
set apkfolder=APK
set cfgfolder=Config
set esprfolder=Espresso
set adbfolder=ADB


set device=%1
set ver=%~n0
set ver=%ver:~-3%
Title Datalogic Android Stage %ver% %device%

:: set adb

if exist %adbfolder% (
	cd %adbfolder%
)

if exist "adb.exe" (
	echo adb.exe found
	set "PATH=%PATH%;%cd%"
	cd /d %~dp0
	goto check
)
cd /d %~dp0

if exist "%PROGRAMFILES(X86)%" (
	set ap="%PROGRAMFILES(X86)%\Datalogic\Android\USB Drivers\bin"
	set "PATH=%PATH%;%PROGRAMFILES(X86)%\Datalogic\Android\USB Drivers\bin"
) else (
	set ap="%PROGRAMFILES%\Datalogic\Android\USB Drivers\bin"
	set "PATH=%PATH%;%PROGRAMFILES%\Datalogic\Android\USB Drivers\bin"
)

::Check if Datalogic USB drivers is installed

if not exist %ap% (
	cls
	COLOR C0
	Echo.Datalogic Android USB drivers not installed. Please install DXU see readme.txt
	pause
	exit
)

:check
:: Check if device is known
color 
cls
if "%device%"=="" (
	goto doublecheck
)else (
	goto checkstatus
)

:doublecheck

FOR /f "skip=1" %%A IN ('adb.exe devices') DO SET device=%%A
if "%device%"=="" (
	cls
	Echo.No device connected to ADB. Please connect a device with USB debugging on. Press a key to try again.
	COLOR C0
	pause
	goto check
) else (
	Echo Device is connected
	goto multiple
)

:multiple

SET count=0
FOR /f "skip=1 tokens=1,2" %%A IN ('adb.exe devices') DO (call :subroutine %%A)
exit /b
echo. %count% devices found! 
timeout -t 5 >nul
GOTO :END


:checkstatus

SET count=0
FOR /f "skip=1 tokens= 1,2,3,4,5,6 delims=" %%A IN ('adb.exe devices -l') DO (call :devicetype %%A %%B %%C %%D %%E %%F)

:device

IF %DEBUG% == TRUE (
echo on
)


::Check connected model
set dn=%devicetype%


if "%dn%" == "JoyaPR" (
	set dn=Joya_Touch_A6
)

if "%dn%" == "jta11" (
	set dn=Joya_Touch_22
)

if "%dn%" == "jta11f" (
	set dn=Joya_Touch_22
)

if "%dn%" == "dl35" (
	set dn=Memor_10
)
if "%dn%" == "m11" (
	set dn=Memor_11
)

if "%dn%" == "Q10" (
	set dn=Memor_20_wwan
)
if "%dn%" == "Q10A" (
	set dn=Memor_20_wlan
)

if "%dn%" == "sx5" (
	set dn=SkorpioX5
)
if "%dn%" == "memor_k" (
	set dn=Memor_K
)

if "%dn%" == "nebula_pda" (
	set dn=Memor_30_35
)

if "%dn%" == "tomcat_pda" (
	set dn=Memor_12_17
)


:: SKU version
for /F %%a in ('adb -s %device% shell getprop ro.vendor.sku') do set sku=%%~na
CALL :LoCase sku

:parameters
set bat=20
set sdl=FALSE
set sdk=TRUE

echo.Connected device %device% is a %dn%
echo.

if "%dn%" == "Joya_Touch_A6" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=0
	set prefix=Joya_Touch_A6
	set sdk=FALSE
)else (

if "%dn%" == "Memor_1" (
	set sd=storage/emulated/0
	set rs=1
	set gr="-g"
	set wfr=0
	set prefix=memor1
	set sdk=FALSE
)else (
if "%dn%" == "Memor_10" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=0
	set prefix=memor10-ota-%sku%
	set sdk=FALSE
)else (
if "%dn%" == "Memor_11" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=0
	set prefix=memor11
	set sdl=TRUE
	set sdk=TRUE
)else (
if "%dn%" == "Memor_20_wwan" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=1
	set prefix=memor20-ota-wwan
	set sdl=TRUE
)else (
if "%dn%" == "Memor_20_wlan" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=1
	set prefix=memor20-ota-wlan
	set sdl=TRUE
)else (
if "%dn%" == "SkorpioX5" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=0
	set prefix=skorpioX5
	set sdl=TRUE
)else (
if "%dn%" == "Memor_30_35" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=0
	set prefix=memor1x_3x
	set prefix2=memor3x
	set sdl=TRUE
)else (
if "%dn%" == "Memor_12_17" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=0
	set prefix=memor1x_3x
	set prefix2=memor1x
	set sdl=TRUE
)else (
if "%dn%" == "Memor_K" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=0
	set prefix=memork
	set sdk=FALSE
)else (
if "%dn%" == "Joya_Touch_22" (
	set sd=sdcard
	set rs=1
	set gr="-g"
	set wfr=0
	set sdl=TRUE
	set prefix=JoyaTouch22_A11
)else (
	set sd=storage/sdcard0
	set rs=1
	set gr=
	set bat=40
	set wfr=0
	set sdk=FALSE
	)
	)
	)
	)
	)
	)
	)
	)
	)
	)
)



:firmwarefiles
Title Datalogic Android Stage %ver% %dn% %device%


:precheckfwfiles
::if there is no firmware it doesn't make sense to disable the lockscreen

for /f "delims=" %%A in ('dir /s /b *.zip 2^>nul') do (
    set "found=true"
)

if not defined found (
   goto espresso
)


:checkforlockscreen

for /f %%a in ('adb -s %device% shell locksettings get-disabled') do (
    if "%%a"=="false" (
        echo Device has lock screen enabled. Disabling for staging
        adb -s %device% shell am broadcast -a datalogic.scan2deploy.intent.action.START_SERVICE -n "com.datalogic.scan2deploy/.S2dServiceReceiver"  -e encoding json -e data "{\"settings\":{\"lock-screen\":\"false\"}}" 
	set restorelockscreen=TRUE
    )
)


:espresso
cd /d %~dp0

::Check on espresso files

set cnf=0
if exist %esprfolder% (
	cd %esprfolder%
) else (
	goto endespresso
)
)



for %%A in (*.zip) do set /a cnf+=1

if %cnf% == 0 (
	goto endespresso
) else (
	Echo.Espresso file found
	Echo.
)
)

if not exist espresso.txt (
echo. > espresso.txt
)

:: Looking in espresso.txt for the serialnumber.
set filename=""
FOR /F "tokens=1,2 delims==, " %%i in (espresso.txt) do (call :espresso %%i %%j)
:contespr

FOR /f "tokens=*" %%A IN ('dir /b *.zip') DO set file=%%A& goto done
:done

if "%filename%"=="%file%" (
	Echo Device %Device% already has %file% installed
	goto endespresso
)

::Installing Espresso file
adb -s %device% push "%file%" "/%sd%/%file%"


::Check if file exist on device.
for /f "delims=" %%A in ('adb -s %DEVICE% shell "[ -f /%sd%/%file% ] && echo EXISTS || echo MISSING"') do set RESULT=%%A

if "%RESULT%"=="EXISTS" (
    echo.
) else (
    echo Espresso file is missing on device. Please reboot device and try again
	pause
 	goto :exit
)

adb -s %device% shell am startservice -n com.datalogic.systemupdate/com.datalogic.systemupdate.SystemUpgradeService --ei action 2 -e path /%sd%/'%file%'

echo Installing espresso file and rebooting the device. Please wait.
timeout -t 10 >nul

::check if disconnected

for /f "skip=1 tokens=1" %%a in ('adb devices') do (
    if "%%a"=="%device%" (
        echo Device still connected. Rebooting.
        adb -s %device% reboot
	goto :wait
    )
)

:: Adding espresso to logfile
echo %device%=%file% >> espresso.txt
set log2=Espresso file: %file%


:wait
set "TIMEOUT=40"  :: seconden

for /l %%i in (1,1,%TIMEOUT%) do (
    for /f "tokens=*" %%a in ('adb -s %device% get-state 2^>nul') do (
        if "%%a"=="device" (
            echo Device %device% is online!
            goto :checkboot
        )
    )
	timeout /t 1 >nul
)
	color C0
	Echo. Device %device% is not coming back online. Please reconnect usb cable!
	adb -s %device% wait-for-device
	color
    	timeout /t 1 >nul
	Echo. Device reconnected!
	goto :checkboot


:checkboot

echo Wait for boot complete on device %device%...

:wait_boot
for /f "delims=" %%a in ('adb -s %device% shell getprop sys.boot_completed 2^>nul') do (
    if "%%a"=="1" (
        echo Android has booted.
        goto :endespresso
    )
)
timeout /t 1 >nul
goto wait_boot



:endespresso

:: Pre-check firmware
::set cnf=0

cd /d %~dp0

if exist %fwfolder% (
	cd %fwfolder%
)

::Check firmware


set cnf=0
for %%A in (*.zip) do set /a cnf+=1

if %cnf% == 0 (
	Echo.No firmware found. Goto config.
	set log1=No Firmware found
	goto config
) else (
	:: Removing spaces from zip file
	start /w /min cmd /e:on /v:on /c "for %%f in ("* *.zip") do (set "n=%%~nxf" & set "n=!n: =_!" & ren "%%~ff" "!n!" )"
)

::timecheck
FOR /f "tokens=1,2" %%A IN ('time /t') DO SET c=%%B
if "%c%"=="" (
	set tk=4
)else (
	set tk=5
)

:searchfirmware
set cnt=0
FOR /f "skip=1 tokens=%tk%" %%A IN ('dir /S *.zip') DO (call :zip %%A)
:END

if defined prefix2 if %cnt% == 0 (
    set prefix=%prefix2%
    set prefix2=
    goto searchfirmware	
)

if defined prefix3 if %cnt% == 0 (
    set prefix=%prefix3%
    set prefix3=
    goto searchfirmware	
)


if %cnt% == 0 (
	Echo.No firmware found. Goto config.
	set log1=No Firmware found
	goto config
) else (
	if %cnt% == 1 (
	Echo.
	Echo.Firmware Found.
	goto :Retrieve_filename
) else (
	Echo.More than one zip file found!!! Selecting the highest one.
	set max=0
)
)

::Selecting highest firmware
setlocal enableDelayedExpansion
for /f "tokens=3* delims=-" %%A in ('dir /S /a-d %prefix%*.zip') do if %%B gtr !max! set max=%%B
set prefix=%max:~-0,-4%


:Retrieve_filename
FOR /f "skip=4 tokens=%tk%" %%A IN ('dir /S *%prefix%*.zip') DO set stre=%%A & goto done
:done
set str=%stre:~-0,-5%


::Retrieve filename incl. Path
FOR /f "tokens=*" %%A IN ('dir /S /B *%prefix%*.zip') DO set file=%%A


if "%dn%" == "Joya_Touch_A6" (
	goto firmwarejoya
)else (

if "%dn%" == "Memor_1" (
	goto firmwarememor_1
)else (
if "%dn%" == "Memor_10" (
	goto firmwarememor10

)else (
if "%dn%" == "Memor_11" (
	goto firmwarememor11

)else (
if "%dn%" == "Memor_20_wwan" (
	goto firmwarememor20

)else (
if "%dn%" == "Memor_20_wlan" (
	goto firmwarememor20

)else (
if "%dn%" == "SkorpioX5" (
	goto firmwareskorpiox5

)else (
if "%dn%" == "Memor_30_35" (
	goto firmwarememor30

)else (
if "%dn%" == "Memor_12_17" (
	goto firmwarememor30

)else (
if "%dn%" == "Memor_K" (
	goto firmwarememork

)else (
if "%dn%" == "Joya_Touch_22" (
	goto firmwarejoya22
)else (

	goto firmwareX4
	)
	)
	)
	)
	)
	)
	)
	)
	)
	)
)


:firmwarejoya

for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a

set inc= %str:~-4%

IF %inc% == FULL (
    set str=%str:~-12%
) ELSE (
    IF %inc% == INCR (
    	set str=%str:~-12%
    ) ELSE (
    set nf=%str:~-16%
    )
)

IF %inc% == FULL (
    	set cf=%cf:~0,7%
	set nf=%str:~0,7%
) ELSE (
    IF %inc% == INCR (
        set cf=%cf:~0,7%
	set nf=%str:~0,7%
    ) ELSE (
    set nf=%str:~-16%
    )
)
goto applyfirmware

:firmwarejoya22

for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a

set inc= %str:~-4%

IF %inc% == FULL (
    set str=%str:~-12%
) ELSE (
    IF %inc% == INCR (
    	set str=%str:~-12%
    ) ELSE (
    set nf=%str:~-17%
    )
)

IF %inc% == FULL (
    	set cf=%cf:~0,7%
	set nf=%str:~0,7%
) ELSE (
    IF %inc% == INCR (
        set cf=%cf:~0,7%
	set nf=%str:~0,7%
    ) ELSE (
    set nf=%str:~-17%
    )
)

goto applyfirmware

:firmwarememor_1

set inc= %str:~-4%
if %inc% == INCR (
	set str=%str:~-12%
	Echo Incremental firmware update
) Else (
	set str=%str:~-16%
)

set nf=%str:~0,16%
for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a
goto applyfirmware

:firmwarememor10

for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a
call :strLen cf len


set inc= %str:~-4%

if %inc% == INCR (
	set str2=%str:~-12%
	set str=%str:~-24%
	Echo Incremental firmware update
) Else (
	set str=%str:~-20%
)

if %inc% == INCR (
	set cf=%cf:~0,7%
	set nf=%str2:~0,7%
)

if %len% == 16 (
	set nf=%str:~-16%
) Else (
	set nf=%str:~-17%
)

:firmwarememor11

for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a
call :strLen cf len


set inc= %str:~-4%

if %inc% == INCR (
	set str2=%str:~-12%
	set str=%str:~-24%
	Echo Incremental firmware update
) Else (
	set str=%str:~-20%
)

if %inc% == INCR (
	set cf=%cf:~0,7%
	set nf=%str2:~0,7%
)

if %len% == 16 (
	set nf=%str:~-16%
) Else (
	set nf=%str:~-17%
)


goto applyfirmware


:firmwarememor20

for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a
call :strLen cf len

set inc= %str:~-4%

if %inc% == INCR (
	set str2=%str:~-12%
	set str=%str:~-29%
	Echo Incremental firmware update
) Else (
	set str=%str:~-25%
	
)

if %inc% == INCR (
	set cf=%cf:~0,7%
	set nf=%str2:~0,7%
)

if %len% == 16 (
	set nf=%str:~-16%
) Else (
	if %len% == 17 (
	set nf=%str:~-17%
	) Else (
	set nf=%str:~-18%
	)
)

goto applyfirmware

:firmwareskorpiox5

for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a
call :strLen cf len
set inc= %str:~-4%

if %inc% == INCR (
	set str=%str:~-13%
	Echo Incremental firmware update
)


if %inc% == INCR (
	set cf=%cf:~0,8%
	set nf=%str:~0,8%
)


if %len% == 17 (
	set nf=%str:~-17%
) Else (
	set nf=%str:~-18%
)

:firmwarememor30

for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a
::call :strLen cf len
set inc= %str:~-4%

if %inc% == INCR (
	set str=%str:~-13%
	Echo Incremental firmware update
)


if %inc% == INCR (
	set cf=%cf:~0,8%
	set nf=%str:~0,8%
)

set nf=%str:~-18%

goto applyfirmware
:firmwarememork

for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a

set inc= %str:~-4%

if %inc% == INCR (
	set str=%str:~-12%
	Echo Incremental firmware update
) Else (
	set str=%str:~-16%
)


if %inc% == INCR (
	set cf=%cf:~0,7%
	set nf=%str:~0,7%
) Else (
	set nf=%str:~0,16%
)
goto applyfirmware



:firmwareX4

set nf=%str:~0,16%
for /F %%a in ('adb -s %device% shell getprop ro.build.id') do set cf=%%a
goto applyfirmware


:applyfirmware


::cleanup NF en CF waardes van - en s
if "%nf:~0,1%"=="-" (
    set "nf=%nf:~1%"
)

:: Als laatste teken een s is, verwijder het
if /I "%nf:~-1%"=="s" (
    set "nf=%nf:~0,-1%"
)

if "%cf:~0,1%"=="-" (
    set "cf=%cf:~1%"
)

:: Als laatste teken een s is, verwijder het
if /I "%cf:~-1%"=="s" (
    set "cf=%cf:~0,-1%"
)







Echo.
Echo.Check firmware
Echo.Current firmware is %cf%
IF %nf% == %cf% ( 
	echo.
	echo.Firmware is equal. Skip Firmware update.
	set log1=Firmware already on %cf%
	goto config
 ) ELSE ( 
	echo.Firmware is different. Update firmware to %nf%
	goto firmware
)


:firmware


echo.
if %Reset% ==FALSE (
	set RP=
	Echo Reset is set to False
)else (
	set RP=--ei reset %rs% 
	Echo Reset is set to True
)

::Battery check
set str=""
set lvl=""
FOR /f "skip=1 tokens=1,2 delims=:" %%A IN ('adb -s %device% shell dumpsys battery') DO (call :battery %%A %%B)
set lvl=%str:~0,3%


if %lvl% LEQ %bat% (
	color C0
	Echo.Batterylevel is only %lvl% percent. Please charge device above %bat% percent before doing a firmware upgrade.
	Pause
	exit
) Else (
	Echo Battery is charged at %lvl% percent. Proceed with upgrade.
)

echo.
echo.Apply firmware %nf%
set Reboot=FALSE
set log1=Update from firmware %cf% to %nf%

if %Reset%==FALSE (
	if %sdl%==TRUE (
		if not %inc% == INCR (
			Echo Sideload will be used because Factory Reset is off and it is supported by the %dn%

			adb -s %device% reboot sideload-auto-reboot
			adb -s %device% wait-for-sideload
			adb -s %device% sideload %stre%

			Echo. 
			Echo Firmware update completed. Wait for the terminal to reboot automaticly.
			Echo. 
			goto wait2
		)
	
	)
)


adb -s %device% push "%file%" /%sd%/%stre%

::Check if file exist on device.
for /f "delims=" %%A in ('adb -s %DEVICE% shell "[ -f /%sd%/%stre% ] && echo EXISTS || echo MISSING"') do set RESULT=%%A

if "%RESULT%"=="EXISTS" (
    echo.
) else (
    echo Firmware file is missing on device. Please reboot device and try again
	pause
 	goto :exit
)


if %sdk%==TRUE (
		Echo Performing update using new firmware intent
			adb -s %device% shell am broadcast -a com.datalogic.systemupdate.action.FIRMWARE_UPDATE -n com.datalogic.systemupdate/.SystemUpgradeReceiver -e path /%sd%/%stre% %RP% --ei reboot 1
		)else (
			adb -s %device% shell am startservice -n com.datalogic.systemupdate/com.datalogic.systemupdate.SystemUpgradeService --ei action 2 -e path /%sd%/%stre% %RP% --ei force_update 1 --ei reboot 1
)

Echo.
Echo.Firmware update started. Wait until unit is updated or connect another device.

goto logfile


:wait2
set "TIMEOUT=120"  :: seconden

for /l %%i in (1,1,%TIMEOUT%) do (
    for /f "tokens=*" %%a in ('adb -s %device% get-state 2^>nul') do (
        if "%%a"=="device" (
            echo Device %device% is online!
            goto :checkboot2
        )
    )
	timeout /t 1 >nul
)
	color C0
	Echo. Device %device% is not coming back online. Please reconnect usb cable!
	adb -s %device% wait-for-device
	color
    	timeout /t 1 >nul
	Echo. Device reconnected!
	goto :checkboot2



:checkboot2

echo Wait for boot complete on device %device%...

:wait_boot2
for /f "delims=" %%a in ('adb -s %device% shell getprop sys.boot_completed 2^>nul') do (
    if "%%a"=="1" (
        echo Android has booted.
	timeout /t 10 >nul
        goto :config
    )
)
timeout /t 1 >nul
goto wait_boot2




:config
echo.


if defined restorelockscreen (
        echo Device had lock screen enabled. Restoring the lockscreen
        adb -s %device% shell am broadcast -a datalogic.scan2deploy.intent.action.START_SERVICE -n "com.datalogic.scan2deploy/.S2dServiceReceiver"  -e encoding json -e data "{\"settings\":{\"lock-screen\":\"true\"}}" 
	set restorelockscreen=FALSE
	timeout /t 3 >nul
)




cd /d %~dp0
::Check on config files



:install
echo.
cd /d %~dp0


::Check on APK files
if exist %apkfolder% (
	cd %apkfolder%
)
set cnd=0
for %%A in (*.apk) do set /a cnd+=1

if %cnd% == 0 (
	Echo.No apk found.
	set log3=No apk installed
	goto options
) else (
	Echo %cnd% apk's found.
	Echo.
)

set log3=Apks installed:

for /F "Tokens=*" %%A in ('dir /b *.apk') do (call :apk %%A)
 
:options   
cd /d %~dp0
if exist %cfgfolder% (
	cd %cfgfolder%
)



:: Visual Formatter files
set cne=0
for %%A in (visual-formatter.*) do set /a cne+=1

if %cne% == 0 (
	echo.
) else (
	Echo.
	Echo Visual formatter file found. Please wait.
	::Copy Visual Formatter files
	adb -s %device% push visual-formatter.zip /%sd%/

	Echo.
	::Import Visual Formatter files
	adb -s %device% shell am broadcast -n \"com.datalogic.service/com.datalogic.provider.VisualFormatterInstallReceiver\" -a \"com.datalogic.decode.visualformatter.INSTALL\" --ez \"enable\" true --es \"install_path\" \"/%sd%/visual-formatter.zip\""
)



:: Scan2Deploy local tar files

set cnf=0
for %%A in (*.tar) do set /a cnf+=1

if %cnf% == 0 (
	echo.
	goto ends2d
) else (
	if %cnf% == 1 (
	Echo.
	Echo Datalogic Scan2Deploy tar file found. Please wait.
	Echo. 
	for /F "Tokens=*" %%A in ('dir /b *.tar') do set tar=%%A
) else (
	COLOR C0
	Echo.More than one tar file found. Please make sure you only have one S2D project!
	goto exit
)
)


:Apply_tar_file
Echo Apply %payload% to device. Please wait
Echo.
adb -s %device% shell am force-stop com.datalogic.scan2deploy
adb -s %device% push "%tar%" /%sd%/

::Check if file exist on device.
for /f "delims=" %%A in ('adb -s %DEVICE% shell "[ -f /%sd%/%tar% ] && echo EXISTS || echo MISSING"') do set RESULT=%%A

if "%RESULT%"=="EXISTS" (
    echo.
) else (
    echo Tar file is missing on device. Please reboot device and try again
	pause
 	goto :exit
)

adb -s %device% shell am broadcast -a datalogic.scan2deploy.intent.action.START_SERVICE -n "com.datalogic.scan2deploy/.S2dServiceReceiver" --es profile-path "'%sd%/%tar%'"    

::hidden service
::adb -s %device% shell am broadcast -a datalogic.scan2deploy.intent.action.START_SERVICE -n "com.datalogic.scan2deploy/.S2dServiceReceiver" --es profile-path "%sd%/%tar%"     
::adb -s %device% shell am start-foreground-service -n com.datalogic.scan2deploy/.S2dService --es profile-path "%sd%/%tar%"  


:ends2d	



:: JSON files

set cnj=0
for %%A in (*.json) do set /a cnj+=1

if %cnj% == 0 (
	echo.
	goto endjson
) else (
	if %cnj% == 1 (
	Echo.
	Echo JSON file found. Please wait.
	Echo. 
	for /F "Tokens=*" %%A in ('dir /b *.json') do set json=%%A
) else (
	COLOR C0
	Echo.More than one json file found. Please make sure you only have one json file.
	goto exit
)
)


:Apply_json_file
Echo Apply %json% to device. Please wait
Echo.
adb -s %device% shell am force-stop com.datalogic.scan2deploy
adb -s %device% push "%json%" /%sd%/
adb -s %device% shell am broadcast -a datalogic.scan2deploy.intent.action.START_SERVICE -n "com.datalogic.scan2deploy/.S2dServiceReceiver" --es json-path "%sd%/%json%"    


:endjson



:logfile
cd /d %~dp0
CALL :GETDATETIME
IF %Log% == TRUE (
echo %LOGDATESTR% %LOGTIMESTR% %device% %dn% %log1% %log2% %log3% %log4%  >> logfile.txt
)


::Add aditional options here 





:exit

if %LeaveonUSBDebugging%==FALSE	(
	adb -s %device% shell settings put global adb_enabled 0
)


echo.Configuration done.
echo.
if %Reboot% == TRUE (
	Echo.
	Echo Rebooting terminal. Please wait
	timeout /NOBREAK -t %RebootTimeout%
	adb -s %device% shell reboot
) else (
	timeout 10
)
exit




::subroutines 
:subroutine

	set dev%count%=%1
	IF %DEBUG% == TRUE (
	Echo Debug mode is on. Output is only send to the log file. Please wait.
	@CALL %~nx0 %1 > %1%.log 2>&1
	) else (
	start %~nx0 %1
	)
	set /a count+=1
	set n=%count%

exit /b

:devicetype



if "%1" NEQ "%device%" (
	exit /b
)


if "%2"=="unauthorized" (
	cls
	Echo.Device is connected to ADB but is not authorized. Please allow USB debugging on the device.
	color C0
	Title Datalogic Android Stage %ver% %1 not authorized
	goto exit
) else if "%2"=="offline" (
	cls
	Echo.Device is connected to ADB but is offline. Please reboot the device and try again.
	color C0
	Title Datalogic Android Stage %ver% %1 Offline
	goto exit
) else if "%2"=="sideload" (
	cls
	Echo.Device is connected to ADB but is in Sideload mode. Please wait.
	color C0
	Title Datalogic Android Stage %ver% %1 Sideload
	goto exit
) else (
	set status=%2
	set product=%3
	set model=%4
	set devicetype=%5
	set id=%6
)
set product=%product:~8%
set model=%model:~6%
set devicetype=%devicetype:~7%
set id=%id:~13%


exit /b

:battery
if "%1%"=="level" (
	set str=%2%
)
exit /b


:firmwarestart
if "%1%"=="R" (
	cls
	Echo Update has started. Please wait.
	timeout -t 10 /NOBREAK
	goto loop2
) else (
	cls
	Echo.Update has not started yet. Please wait.
	timeout -t 10 /NOBREAK
	goto loop
)
exit /b


:reboot
if "%1%"=="S" (
	cls
	Echo Update is done. Rebooting the terminal.
	adb -s %device% reboot
::	timeout -t 10 /NOBREAK
	goto logfile
) else (
	cls
	Echo.Update is still running. Please wait.
	timeout -t 10 /NOBREAK
	goto loop2
)
exit /b

:apk
set apkfile=%*
set log3=%log3% %apkfile%
echo Installing %apkfile%
adb -s %device% install -r %gr% "%apkfile%"
echo.
exit /b

:file
adb -s %device% push %1 /%sd%/%1
exit /b


:espresso
if %1==%device% (
set filename=%2
goto :contespr
)

:serialnumber
if %1==%device% (
set ip=%2
goto :foundserial
)

exit /b

:apkversion
if "%1%"=="versionName" (
	set str=%2%
	goto foundapk
)
exit /b

:apkversion2
if "%1%"=="versionName" (
	set str=%2%
	goto foundapk2
)
exit /b

:zip
set file=%1%
CALL SET _result=%%file:%prefix%=%%
If /i "%_result%"=="%file%" (set test=%_result%) ELSE (set /a cnt+=1)

exit /b

:GetDateTime
SET "HH=%time:~-11,2%"
SET "MM=%time:~-8,2%"
SET "SS=%time:~-5,2%"
SET "NAMETIMESTR=%HH: =0%%MM%"
SET "LOGTIMESTR=%HH: =0%:%MM%:%SS%"
SET "MYDATE=%DATE:~4,11%"
SET "LOGDATESTR=%MYDATE%"

exit /b

:strLen  strVar  [rtnVar]
setlocal disableDelayedExpansion
set len=0
if defined %~1 for /f "delims=:" %%N in (
  '"(cmd /v:on /c echo(!%~1!&echo()|findstr /o ^^"'
) do set /a "len=%%N-3"
endlocal & if "%~2" neq "" (set %~2=%len%) else echo %len%
exit /b

:LoCase
:: Subroutine to convert a variable VALUE to all lower case.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF

:END
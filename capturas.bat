@echo off
echo Iniciando capturas...

echo 1. Tomando captura vertical...
adb -s emulator-5554 shell settings put system accelerometer_rotation 0
adb -s emulator-5554 shell settings put system user_rotation 0
adb -s emulator-5554 shell am start -n ec.edu.uta.fisei.welcomeapp/.ui.welcome.MainActivity
timeout /t 3 /nobreak >nul
adb -s emulator-5554 exec-out screencap -p > docs\img\01_vertical.png

echo 2. Tomando captura horizontal...
adb -s emulator-5554 shell settings put system user_rotation 1
timeout /t 3 /nobreak >nul
adb -s emulator-5554 exec-out screencap -p > docs\img\02_horizontal.png
adb -s emulator-5554 shell settings put system user_rotation 0

echo 3. Tomando captura en espanol...
adb -s emulator-5554 shell cmd locale set-app-locales ec.edu.uta.fisei.welcomeapp --locales es-ES
adb -s emulator-5554 shell am force-stop ec.edu.uta.fisei.welcomeapp
adb -s emulator-5554 shell am start -n ec.edu.uta.fisei.welcomeapp/.ui.welcome.MainActivity
timeout /t 3 /nobreak >nul
adb -s emulator-5554 exec-out screencap -p > docs\img\03_espanol.png
adb -s emulator-5554 shell cmd locale set-app-locales ec.edu.uta.fisei.welcomeapp --locales en-US
adb -s emulator-5554 shell am force-stop ec.edu.uta.fisei.welcomeapp

echo 4. Tomando captura modo oscuro...
adb -s emulator-5554 shell cmd uimode night yes
adb -s emulator-5554 shell am start -n ec.edu.uta.fisei.welcomeapp/.ui.welcome.MainActivity
timeout /t 3 /nobreak >nul
adb -s emulator-5554 exec-out screencap -p > docs\img\04_oscuro.png
adb -s emulator-5554 shell cmd uimode night no

echo 5. Tomando captura fuente grande...
adb -s emulator-5554 shell settings put system font_scale 2.0
adb -s emulator-5554 shell am start -n ec.edu.uta.fisei.welcomeapp/.ui.welcome.MainActivity
timeout /t 3 /nobreak >nul
adb -s emulator-5554 exec-out screencap -p > docs\img\05_fuente_grande.png
adb -s emulator-5554 shell settings put system font_scale 1.0

echo ¡Proceso terminado con exito!
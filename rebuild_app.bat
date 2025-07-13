@echo off
echo -----------------------------
echo Limpiando el proyecto...
flutter clean

echo -----------------------------
echo Instalando dependencias...
flutter pub get

echo -----------------------------
echo Ejecutando en modo offline...
flutter pub get --offline

echo -----------------------------
echo Corriendo app...
flutter run -d chrome --web-renderer html

pause

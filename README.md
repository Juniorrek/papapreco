# premiumprice

  

A new Flutter project.


# Instalamento

## 1 - Instalar Flutter

- https://docs.flutter.dev/get-started/install

## 2 - Instalar Android Studio (infelizmente)

- https://developer.android.com/studio
- Depois que instalar abrir > SDK Manager > SDK Tools > SDK Command Line Tools
- Talvez precise ativar VT na BIOS para funcionar o emulador > google

## 3 - Configurar IDE (VSCode)

- https://docs.flutter.dev/get-started/editor

### Verificar instalamento

- `flutter doctor`

### Caso de problema no Chrome (linux)

- `CHROME_EXECUTABLE=/opt/brave.com/brave/brave` (trocar pro caminho do seu chrome)
- `export CHROME_EXECUTABLE`

## 4 - Instalar emulador

- `sdkmanager "system-images;android-27;google_apis_playstore;x86"`
- `flutter emulators --create Nexus_6`

### Verificar emulador

- `flutter emulators --launch flutter_emulator`

### Flutter secure storage

- `sudo apt install libsecret-1-dev libsecret-tools libsecret-1-0`


# Iniciar

- `flutter run`
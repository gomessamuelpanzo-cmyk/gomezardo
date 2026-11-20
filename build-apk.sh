set -e

echo "== 1/6 ficheiros da app =="
mkdir -p www
for f in index.html manifest.webmanifest sw.js icon.svg logo.png icon-192.png icon-512.png icon-maskable-512.png; do
  if [ -f "$f" ]; then cp "$f" www/; else echo "aviso: falta $f"; fi
done
npm install
npx cap add android

echo "== 2/6 codigo nativo =="
D=android/app/src/main/java/com/gomezardo/app
mkdir -p "$D"
cp DirectCallPlugin.java MainActivity.java "$D/"

echo "== 3/6 chave de assinatura =="
if [ -f gomezardo.keystore ]; then
  mkdir -p "$HOME/.android"
  cp gomezardo.keystore "$HOME/.android/debug.keystore"
else
  echo "aviso: sem gomezardo.keystore, cada APK nova tera uma assinatura diferente"
fi
cat >> android/app/build.gradle <<'GRADLE'

android {
    signingConfigs {
        gomez {
            storeFile file(System.getenv("HOME") + "/.android/debug.keystore")
            storePassword "android"
            keyAlias "androiddebugkey"
            keyPassword "android"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.gomez
        }
    }
}
GRADLE

echo "== 4/6 icone do Gomezardo =="
python3 -c "import PIL" 2>/dev/null || python3 -m pip install pillow
python3 make-icons.py || echo "aviso: ficou o icone por omissao"

npx cap sync android
M=android/app/src/main/AndroidManifest.xml
mkdir -p apks

# constroi uma APK (primeiro a versao "release", assinada; se falhar, a "debug")
build_apk() {
  if (cd android && ./gradlew assembleRelease) && [ -f android/app/build/outputs/apk/release/app-release.apk ]; then
    cp android/app/build/outputs/apk/release/app-release.apk "apks/$1"
  else
    echo "aviso: release falhou, a usar debug"
    (cd android && ./gradlew assembleDebug)
    cp android/app/build/outputs/apk/debug/app-debug.apk "apks/$1"
  fi
}

chmod +x android/gradlew

echo "== 5/6 APK sem permissao de chamadas =="
build_apk gomezardo-sem-chamadas.apk

echo "== 6/6 APK com chamadas diretas =="
sed -i 's#<uses-permission android:name="android.permission.INTERNET" />#&\n    <uses-permission android:name="android.permission.CALL_PHONE" />\n    <uses-feature android:name="android.hardware.telephony" android:required="false" />#' "$M"
grep -q CALL_PHONE "$M"
rm -rf android/app/build/outputs
build_apk gomezardo-com-chamadas.apk

ls -la apks

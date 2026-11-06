set -e
npm install
mkdir -p www
cp index.html manifest.webmanifest icon.svg sw.js www/
npx cap add android
D=android/app/src/main/java/com/gomezardo/app
mkdir -p "$D"
cp DirectCallPlugin.java MainActivity.java "$D/"
M=android/app/src/main/AndroidManifest.xml
sed -i 's#<uses-permission android:name="android.permission.INTERNET" />#&\n    <uses-permission android:name="android.permission.CALL_PHONE" />\n    <uses-feature android:name="android.hardware.telephony" android:required="false" />#' "$M"
grep -q CALL_PHONE "$M"
npx cap sync android
cd android
chmod +x gradlew
./gradlew assembleDebug

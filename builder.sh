# release or debug
# release --> *.aab
# debug --> *.apk

VERSION=""
BUILDOZER_SPEC_LOC=""
BACKUP_LOC=""

MODE="release"

SIGNKEY=""
PASSWD=""
APK_OR_AAB_LOC=""
ALIAS=""

cp $BUILDOZER_SPEC_LOC "$BUILDOZER_SPEC_LOC.$VERSION"
mv "$BUILDOZER_SPEC_LOC.$VERSION" $BACKUP_LOC

buildozer android $MODE
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore $SIGNKEY -storepass $PASSWD $APK_OR_AAB_LOC $ALIAS

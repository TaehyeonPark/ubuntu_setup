jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore {keystore_path} -storepass {passwd} {aab_path} {keystore_alias_name}
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore [서명키] -storepass [비밀번호] [aab 파일] [alias]


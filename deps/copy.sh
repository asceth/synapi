BACK=`pwd`

cd curl/
CFLAGS="-m32" ./configure --without-libidn --without-zlib --without-ssl --disable-ftp --disable-ldap --disable-ldaps --disable-rtsp --disable-procy --disable-dict --disable-telnet --disable-tftp --disable-imap --disable-pop3 --disable-smtp --disable-gopher
make

cd $BACK

cp -r ./curl/include/curl ./include/
cp ./curl/lib/.libs/libcurl.a lib/nix/

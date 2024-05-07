# cat tools | sort | while read aa; do VAR=`echo $aa | sed -r "s,/usr/bin/x86_64-w64-mingw32-,,g;s,-posix|-win32|gcc-,,g" | tr "a-z" "A-Z"`; echo export $VAR=$aa;done


export ADDR2LINE=/usr/bin/x86_64-w64-mingw32-addr2line
export AR=/usr/bin/x86_64-w64-mingw32-ar
export AS=/usr/bin/x86_64-w64-mingw32-as
export DLLTOOL=/usr/bin/x86_64-w64-mingw32-dlltool
export DLLWRAP=/usr/bin/x86_64-w64-mingw32-dllwrap
export ELFEDIT=/usr/bin/x86_64-w64-mingw32-elfedit
export CC=/usr/bin/x86_64-w64-mingw32-gcc
export CXX=/usr/bin/x86_64-w64-mingw32-g++
export AR=/usr/bin/x86_64-w64-mingw32-gcc-ar
export NM=/usr/bin/x86_64-w64-mingw32-gcc-nm
export RANLIB=/usr/bin/x86_64-w64-mingw32-gcc-ranlib
export GCOV=/usr/bin/x86_64-w64-mingw32-gcov
export GPROF=/usr/bin/x86_64-w64-mingw32-gprof
export LD=/usr/bin/x86_64-w64-mingw32-ld
export NM=/usr/bin/x86_64-w64-mingw32-nm
export OBJCOPY=/usr/bin/x86_64-w64-mingw32-objcopy
export OBJDUMP=/usr/bin/x86_64-w64-mingw32-objdump
export PKGCONFIG=/usr/bin/x86_64-w64-mingw32-pkg-config
export RANLIB=/usr/bin/x86_64-w64-mingw32-ranlib
export READELF=/usr/bin/x86_64-w64-mingw32-readelf
export SIZE=/usr/bin/x86_64-w64-mingw32-size
export STRINGS=/usr/bin/x86_64-w64-mingw32-strings
export STRIP=/usr/bin/x86_64-w64-mingw32-strip
export WIDL=/usr/bin/x86_64-w64-mingw32-widl
export MC=/usr/bin/x86_64-w64-mingw32-windmc
export WINDRES=/usr/bin/x86_64-w64-mingw32-windres

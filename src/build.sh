

export CC=/usr/bin/x86_64-w64-mingw32-gcc
export CXX=/usr/bin/x86_64-w64-mingw32-g++
export RANLIB=/usr/bin/x86_64-w64-mingw32-ranlib
export AR=/usr/bin/x86_64-w64-mingw32-ar
export STRIP=/usr/bin/x86_64-w64-mingw32-strip


export PKG_CONFIG_PATH=/dev/shm/win32/lib/pkgconfig/
export CFLAGS="-I/dev/shm/win32/include/ -static -static-libstdc++"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-L/dev/shm/win32/lib/  -lws2_32 -static "


# https://www.zlib.net/zlib-1.3.1.tar.gz
# configure as --prefix=/dev/shm/win32/ --eprefix=/dev/shm/win32/ --static

#protoc linux:
#--prefix=/dev/shm/proto34 --with-zlib --enable-shared --enable-static --disable-silent-rules 
#win32:
#export CFLAGS="-I/dev/shm/win32/include/ -static -static-libstdc++"
#./configure --prefix=/dev/shm/win32 --with-win32 --host=x86_64-w64-mingw32 --with-zlib --enable-shared --enable-static --disable-silent-rules sysroot=/dev/shm/win32/ --with-protoc=/dev/shm/proto34/bin/protoc
# -Dprotobuf_BUILD_SHARED_LIBS=ON ?????

LDFLAGS+=" -lprotobuf -lpthread "

#rm -rf gen
#mkdir gen

#protoc --cpp_out gen -Iosmpbf osmpbf/osmformat.proto
#protoc --cpp_out gen -Iosmpbf osmpbf/fileformat.proto

#$CXX $CXXFLAGS -I/dev/shm/protobuf-3.4.1/src/ -fPIC -std=gnu++11 -c gen/fileformat.pb.cc -o gen/fileformat.pb.o
#$CXX $CXXFLAGS -I/dev/shm/protobuf-3.4.1/src/ -fPIC -std=gnu++11 -c gen/osmformat.pb.cc -o gen/osmformat.pb.o

#exit;

#$CXX -o libosm.so -shared -Wl,-soname,libosm.so -fPIC -std=gnu++11 gen/*o $LDFLAGS
#$AR qc libosm.a gen/*.o
#$RANLIB libosm.a


$CXX $CXXFLAGS -I/dev/shm/protobuf-3.4.1/src/ --static -L. -Igen osm-grep.cpp gen/fileformat.pb.o gen/osmformat.pb.o -o osm-grep.exe $LDFLAGS -lz
$STRIP --strip-all  osm-grep.exe
md5sum osm-grep.exe > osm-grep.exe.md5

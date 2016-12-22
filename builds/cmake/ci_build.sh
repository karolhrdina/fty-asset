#!/usr/bin/env bash
set -ex

mkdir tmp
BUILD_PREFIX=$PWD/tmp

CONFIG_OPTS=()
CONFIG_OPTS+=("CFLAGS=-I${BUILD_PREFIX}/include")
CONFIG_OPTS+=("CPPFLAGS=-I${BUILD_PREFIX}/include")
CONFIG_OPTS+=("CXXFLAGS=-I${BUILD_PREFIX}/include")
CONFIG_OPTS+=("LDFLAGS=-L${BUILD_PREFIX}/lib")
CONFIG_OPTS+=("PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig")
CONFIG_OPTS+=("--prefix=${BUILD_PREFIX}")
CONFIG_OPTS+=("--with-docs=no")
CONFIG_OPTS+=("--quiet")

CMAKE_OPTS=()
CMAKE_OPTS+=("-DCMAKE_INSTALL_PREFIX:PATH=${BUILD_PREFIX}")
CMAKE_OPTS+=("-DCMAKE_PREFIX_PATH:PATH=${BUILD_PREFIX}")
CMAKE_OPTS+=("-DCMAKE_LIBRARY_PATH:PATH=${BUILD_PREFIX}/lib")
CMAKE_OPTS+=("-DCMAKE_INCLUDE_PATH:PATH=${BUILD_PREFIX}/include")

# Clone and build dependencies
git clone --quiet --depth 1 https://github.com/zeromq/libzmq.git libzmq.git
cd libzmq.git
git --no-pager log --oneline -n1
if [ -e autogen.sh ]; then
    ./autogen.sh 2> /dev/null
fi
if [ -e buildconf ]; then
    ./buildconf 2> /dev/null
fi
./configure "${CONFIG_OPTS[@]}"
make -j4
make install
cd ..
git clone --quiet --depth 1 https://github.com/zeromq/czmq.git czmq.git
cd czmq.git
git --no-pager log --oneline -n1
if [ -e autogen.sh ]; then
    ./autogen.sh 2> /dev/null
fi
if [ -e buildconf ]; then
    ./buildconf 2> /dev/null
fi
./configure "${CONFIG_OPTS[@]}"
make -j4
make install
cd ..
git clone --quiet --depth 1 https://github.com/zeromq/malamute.git malamute.git
cd malamute.git
git --no-pager log --oneline -n1
if [ -e autogen.sh ]; then
    ./autogen.sh 2> /dev/null
fi
if [ -e buildconf ]; then
    ./buildconf 2> /dev/null
fi
./configure "${CONFIG_OPTS[@]}"
make -j4
make install
cd ..
git clone --quiet --depth 1 https://github.com/42ity/libmagic magic.git
cd magic.git
git --no-pager log --oneline -n1
if [ -e autogen.sh ]; then
    ./autogen.sh 2> /dev/null
fi
if [ -e buildconf ]; then
    ./buildconf 2> /dev/null
fi
./configure "${CONFIG_OPTS[@]}"
make -j4
make install
cd ..
git clone --quiet --depth 1 https://github.com/42ity/fty-core core.git
cd core.git
git --no-pager log --oneline -n1
if [ -e autogen.sh ]; then
    ./autogen.sh 2> /dev/null
fi
if [ -e buildconf ]; then
    ./buildconf 2> /dev/null
fi
./configure "${CONFIG_OPTS[@]}"
make -j4
make install
cd ..
git clone --quiet --depth 1 https://github.com/42ity/fty-proto fty-proto.git
cd fty-proto.git
git --no-pager log --oneline -n1
if [ -e autogen.sh ]; then
    ./autogen.sh 2> /dev/null
fi
if [ -e buildconf ]; then
    ./buildconf 2> /dev/null
fi
./configure "${CONFIG_OPTS[@]}"
make -j4
make install
cd ..
git clone --quiet --depth 1 -b 42ity https://github.com/42ity/cxxtools cxxtools.git
cd cxxtools.git
git --no-pager log --oneline -n1
if [ -e autogen.sh ]; then
    ./autogen.sh 2> /dev/null
fi
if [ -e buildconf ]; then
    ./buildconf 2> /dev/null
fi
./configure "${CONFIG_OPTS[@]}"
make -j4
make install
cd ..

# Build and check this project
cd ../..
PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig cmake "${CMAKE_OPTS[@]}" .
make all VERBOSE=1 -j4
ctest -V
make install

echo "=== Are GitIgnores good after making the project '$BUILD_TYPE'? (should have no output below)"
git status -s || true
echo "==="

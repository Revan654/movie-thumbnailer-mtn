@echo off

REM download and install MinGW into c:\Mingw from https://sourceforge.net/projects/mingw/files/
REM download and extract ffmpeg into c:\MinGW from https://ffmpeg.zeranoe.com/builds/win32/shared/ and https://ffmpeg.zeranoe.com/builds/win32/dev/
REM download and extract libgd (Binaries, Dependencies and Developer files) from http://gnuwin32.sourceforge.net/packages/gd.htm

REM dependent libraries are located here:
REM     c:\MinGW\bin\AVCODEC-57.DLL
REM     c:\MinGW\bin\AVFORMAT-57.DLL
REM     c:\MinGW\bin\AVUTIL-55.DLL
REM     c:\MinGW\bin\FREETYPE6.DLL
REM     c:\MinGW\bin\JPEG62.DLL
REM     c:\MinGW\bin\LIBGD2.DLL
REM     c:\MinGW\bin\LIBICONV2.DLL
REM     c:\MinGW\bin\LIBPNG13.DLL
REM     c:\MinGW\bin\SWRESAMPLE-2.DLL
REM     c:\MinGW\bin\SWSCALE-4.DLL
REM     c:\MinGW\bin\ZLIB1.DLL


set PATH=c:\MinGW\bin;%PATH%

set CC=gcc
set CFLAGS=-Wall -DWIN32 -O3

set LDFLAGS=-Lc:\MinGW\lib
set INCLUDE=-Ic:\MinGW\include
set LIBS=-lgd -lavutil -lavdevice -lavformat -lavcodec  -lswscale

%CC% -o mtn mtn.c %CFLAGS% %LDFLAGS% %INCLUDE% %LIBS%

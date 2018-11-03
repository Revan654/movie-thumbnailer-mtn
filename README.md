Description
===========
movie thumbnailer (mtn)  
fork from http://moviethumbnail.sourceforge.net/  

Movie Thumbnailer (mtn) saves thumbnails (screenshots) of movie or video files to image files (jpg, png). 
It uses FFmpeg's libavcodec as its engine, so it supports all popular codecs, e.g. h.265/hevc, h.264, mpeg1, mpeg2, mp4, vc1, wmv, xvid, divx...     
mtn was originaly developed by tuit (tuitfun); though most of its magic is actually done 
by FFmpeg libraries.

Dependency
==========
 - ffmpeg (32Bit for Windows)
 - gd

Getting source
==============

git clone https://github.com/Revan654/movie-thumbnailer-mtn.git

**[Ubuntu](https://www.ubuntu.com/)** 17.10, **[Debian](https://www.debian.org/)** 9, **[LinuxMint](https://linuxmint.com)** 19  

  sudo apt-get install libgd-dev libavutil-dev libavcodec-dev libavformat-dev libswscale-dev make  
  sudo make && make install  

**Windows**  

  Make.MinGW.bat or Makefile.Mingw for Cross Compile.
  cmd > Make.MinGW.bat

References
==========
 * [FFmpeg project](http://www.ffmpeg.org)
 * [libgd project](https://libgd.github.io)
 * [libgd library and dependecies](http://gnuwin32.sourceforge.net/packages/gd.htm)
 * [MinGW](http://www.mingw.org/)

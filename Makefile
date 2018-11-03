#CFLAGS=-W -Wall -O3 -s -D_FILE_OFFSET_BITS=64 -mtune=i686 -march=i386 -I/home/tuitfun/include -L/home/tuitfun/lib
#CFLAGS=-W -Wall `pkg-config --cflags libavformat`

#DESTDIR - reserved for rpmbuild
UNAME!=uname -s
CFLAGS=-W -Wall
OUT=../bin
LIBSDIR=../lib

ifeq ($(UNAME),FreeBSD)
LIBS+=-L/usr/local/lib
INCPATH+=-I/usr/local/include
endif

ifeq ($(UNAME),Linux)
INCPATH=-I/usr/include/ffmpeg
endif

LIBS+=-lavcodec -lavformat -lavcodec -lswscale -lavutil -lgd -lfreetype -ljpeg -lz -lm -lpthread
S_INCPATH=-I$(LIBSDIR)/FFmpeg -I$(LIBSDIR)/libgd/src
S_LIBS=\
	$(LIBSDIR)/libgd.a \
	$(LIBSDIR)/libavformat.a \
	$(LIBSDIR)/libavcodec.a \
	$(LIBSDIR)/libswscale.a \
	$(LIBSDIR)/libavutil.a \
	$(LIBSDIR)/libz.a \
	$(LIBSDIR)/libpng.a \
	-lm -lpthread -lbz2 -ldl -ljpeg -lfreetype

mtn: mtn.c outdir
	$(CC) -o $(OUT)/mtn mtn.c $(INCPATH) $(CFLAGS) $(LIBS)

outdir:
	mkdir -p $(OUT)

mtns: mtn.c outdir
	$(CC) -o $(OUT)/mtn mtn.c $(S_INCPATH) $(CFLAGS) $(S_LIBS)

mtnd: mtn.c outdir
	$(CC) -o $(OUT)/mtn mtn.c $(INCPATH) $(CFLAGS) -g $(LIBS)

clean:
	rm -f $(OUT)/mtn

distclean:
	rm -rf $(OUT)

rebuild:  clean mtn
rebuilds: clean mtns

test_bin:
	$(OUT)/mtn -f ../test/font.ttf -O /tmp /home/sample.avi
	test -s /tmp/sample_s.jpg

test:  rebuild  mtn  test_bin
tests: rebuilds mtns test_bin

install: mtn
	mkdir -p $(DESTDIR)/usr/bin/
	install -m 755 $(OUT)/mtn $(DESTDIR)/usr/bin/

uninstall:
	rm -f  $(DESTDIR)/usr/bin/mtn


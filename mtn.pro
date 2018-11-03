/*
	project for building and debuging with QT-Creator
*/

TEMPLATE = app
TARGET = mtn
INCLUDEPATH += .
INCLUDEPATH += /usr/include/ffmpeg
INCLUDEPATH += /usr/include
#LIBS += -L/usr/lib64 -lgd -lavutil -l

HEADERS += fake_tchar.h
SOURCES += mtn.c

@echo off
:: Drag and drop script
::
:: usage: Drag and drop one or more videos (or folders of videos) onto this
:: script (or a shortcut to it).
::
:: setup: Edit the start line below to reflect the location of mtn.exe on
:: your system and your chosen options.
:: Below that, you can also enable pause at finish (remove 'rem')

:: drag-drop code from dbenham
setlocal DisableDelayedExpansion
:: first assume normal call, get args from %*
set args=%*
set "dragDrop="
set MTN_EXE="C:\Program Files\mtn\mtn.exe"
::
:: Now check if drag&drop situation by looking for %0 in !cmdcmdline!
:: if found then set drag&drop flag and get args from !cmdcmdline!
setlocal EnableDelayedExpansion
set "cmd=!cmdcmdline!"
set "cmd2=!cmd:*%~f0=!"
if "!cmd2!" neq "!cmd!" (
  set dragDrop=1
  set "args=!cmd2:~0,-1! "
  set "args=!args:* =!"
)
::
:: Process the args
for %%F in (!args!) do (
  if "!!"=="" endlocal & set "dragDrop=%dragDrop%"
  rem ------------------------------------------------
  rem - Your file processing starts here.
  rem - Each file will be processed one at a time
  rem - The file path will be in %%F
  rem -

  echo Process file "%%~F"

rem Usage:
rem   mtn [options] file_or_dir1 [file_or_dir2] ... [file_or_dirn]
rem Options: (and default values)
rem   -a aspect_ratio : override input file's display aspect ratio
rem   -b 0,80 : skip if % blank is higher; 0:skip all 1:skip really blank >1:off
rem   -B 0,0 : omit this seconds from the beginning
rem   -c 3 : # of column
rem   -C -1 : cut movie and thumbnails not more than the specified seconds; <=0:off
rem   -d #: recursion depth; 0:immediate children files only
rem   -D 12 : edge detection; 0:off >0:on; higher detects more; try -D4 -D6 or -D8
rem   -E 0,0 : omit this seconds at the end
rem   -f tahomabd.ttf : font file; use absolute path if not in usual places
rem   -F RRGGBB:size[:font:RRGGBB:RRGGBB:size] : font format [time is optional]
rem      info_color:info_size[:time_font:time_color:time_shadow:time_size]
rem   -g 0 : gap between each shot
rem   -h 150 : minimum height of each shot; will reduce # of column to fit
rem   -i : info text off
rem   -I : save individual shots too
rem   -j 90 : jpeg quality
rem   -k RRGGBB : background color (in hex)
rem   -L info_location[:time_location] : location of text
rem      1=lower left, 2=lower right, 3=upper right, 4=upper left
rem   -n : run at normal priority
rem   -N info_suffix : save info text to a file with suffix
rem   -o _s.jpg : output suffix
rem   -O directory : save output files in the specified directory
rem   -p : pause before exiting; default on in win32
rem   -P : dont pause before exiting; override -p
rem   -r 0 : # of rows; >0:override -s
rem   -s 120 : time step between each shot
rem   -S #: select specific stream number
rem   -t : time stamp off
rem   -T text : add text above output image
rem   -v : verbose mode (debug)
rem   -w 1024 : width of output image; 0:column * movie width
rem   -W : dont overwrite existing files, i.e. update mode
rem   -X : use full input filename (include extension)
rem   -z : always use seek mode
rem   -Z : always use non-seek mode -- slower but more accurate timing

rem ====================================
rem  Start mtn here.
rem  'start' command priorities: /low /normal /high /realtime /abovenormal /belownormal

start "movie thumbnailer" /b /belownormal /wait %MTN_EXE% -P -h 0 -c 3 -r 4 -w 1280 -g 1 -j 92 -D 12 -L 4:2 -k ffffff -f arial.ttf -F 000000:12:arial.ttf:ffffff:000000:12 "%%~F"

  rem -
  rem - Your file processing ends here
  rem -------------------------------------------------
)
::
:: If drag&drop then must do a hard exit to prevent unwanted execution
:: of any split drag&drop filename argument
if defined dragDrop (
rem  pause
  exit
)

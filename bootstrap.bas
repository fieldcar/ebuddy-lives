CLS
PRINT Time$();" Bootstrap starting..."

LocalScript$ = "/usr/auto_update.bas"  // path to your main script
RemoteUrl$ = "https://raw.githubusercontent.com/yourusername/ewon-auto-firmware-updater/main/auto_update.bas"
RemoteVerUrl$ = "https://raw.githubusercontent.com/yourusername/ewon-auto-firmware-updater/main/script_version.txt"  // e.g., contains "1.5"

GETHTTP RemoteVerUrl$,"/tmp/remote_ver.txt"
OPEN "/tmp/remote_ver.txt" FOR TEXT INPUT AS 1
RemoteVer$ = TRIM$(GET$ 1)
CLOSE 1

// Get local version (assume first line of main script is '// Version: 1.4')
LocalVer$ = "0"
IF FS "isFile", LocalScript$ THEN
  OPEN LocalScript$ FOR TEXT INPUT AS 2
  FirstLine$ = GET$ 2
  CLOSE 2
  IF POS(FirstLine$,"Version:") <> -1 THEN LocalVer$ = TRIM$(MID$(FirstLine$, POS(FirstLine$,":")+1, -1))
ENDIF

PRINT "Local version: "+LocalVer$+" | Remote: "+RemoteVer$

IF RemoteVer$ > LocalVer$ THEN
  PRINT "Updating main script..."
  GETHTTP RemoteUrl$, "/tmp/new_script.bas"
  Size% = GETSYS PRG,"FILESIZ","/tmp/new_script.bas"
  IF Size% > 1000 THEN
    RENAME "/tmp/new_script.bas", LocalScript$
    PRINT "Main script updated!"
  ELSE
    PRINT "Download failed"
  ENDIF
ENDIF

// Now run the (possibly updated) main script
RUN "auto_update"

END

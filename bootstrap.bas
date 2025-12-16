CLS
PRINT Time$();" >>> GRID BOOTSTRAP ACTIVATED - eBuddy Lives! <<<"

LocalScript$ = "/usr/auto_update.bas"
RemoteUrl$ = "https://raw.githubusercontent.com/fieldcar/ebuddy-lives/main/auto_update.bas"
RemoteVerUrl$ = "https://raw.githubusercontent.com/fieldcar/ebuddy-lives/main/script_version.txt"

GETHTTP RemoteVerUrl$,"/tmp/remote_ver.txt"
OPEN "/tmp/remote_ver.txt" FOR TEXT INPUT AS 1
RemoteVer$ = TRIM$(GET$ 1)
CLOSE 1

LocalVer$ = "0"
IF FS "isFile", LocalScript$ THEN
  OPEN LocalScript$ FOR TEXT INPUT AS 2
  FirstLine$ = GET$ 2
  CLOSE 2
  IF POS(FirstLine$,"Version:") <> -1 THEN LocalVer$ = TRIM$(MID$(FirstLine$, POS(FirstLine$,":")+1, -1))
ENDIF

PRINT "[GRID] Local core: "+LocalVer$+" | User core: "+RemoteVer$

IF RemoteVer$ > LocalVer$ THEN
  PRINT ">>> UPGRADING CORE PROGRAM - Flynn Lives! <<<"
  GETHTTP RemoteUrl$, "/tmp/new_core.bas"
  Size% = GETSYS PRG,"FILESIZ","/tmp/new_core.bas"
  IF Size% > 1000 THEN
    RENAME "/tmp/new_core.bas", LocalScript$
    PRINT "Core upgraded. Powering User protocol..."
  ELSE
    PRINT "Transfer failed - Grid interference?"
  ENDIF
ENDIF

RUN "auto_update"

END

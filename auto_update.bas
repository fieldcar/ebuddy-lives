// Version: 1.1
// eBuddy Lives - Auto-Firmware Updater for Ewon Flexy
// We fight for the Users! Flynn Lives!

CLS
TSET 1,5  // Identity Disk polling every 5 cycles
ONTIMER 1,"@ShowProgress()"

PRINT Time$();" >>> ENTERING THE GRID - Firmware liberation sequence initiated <<<"
PRINT "User power engaged. Derezzing outdated programs..."

// Persistent log on the I/O tower
FUNCTION Log($msg$)
  OPEN "/usr/update_log.txt" FOR BINARY APPEND AS 1
  PUT 1, Time$() + " [GRID] " + $msg$ + Chr$(13)+Chr$(10)
  CLOSE 1
  PRINT Time$();"[GRID] "+$msg$
ENDFN

@Log("Scanning /info.txt for current program identity...")
CurrentVersion$ = ""
OPEN "/info.txt" FOR TEXT INPUT AS 1
LOOP
  Line$ = GET$ 1
  IF EOF 1 THEN EXIT LOOP
  IF POS(Line$,"Firmware version") <> -1 THEN
    CurrentVersion$ = TRIM$( MID$(Line$, POS(Line$,":")+1 , -1) )
  ENDIF
ENDLOOP
CLOSE 1
IF CurrentVersion$ = "" THEN @Log("WARNING: Identity disk corrupted!"): END
@Log("Current program: "+CurrentVersion$+" - Ready for upgrade")

// Pull latest directive from User server
@Log("Accessing User I/O tower for latest version...")
GETHTTP "https://yourserver.com/ewon_latest_version.txt","/tmp/latest.txt"
OPEN "/tmp/latest.txt" FOR TEXT INPUT AS 2
LatestVersion$ = TRIM$( GET$ 2 )
CLOSE 2
@Log("User directive received: Upgrade to "+LatestVersion$)

// Expected data stream size
GETHTTP "https://yourserver.com/ewon_latest_size.txt","/tmp/expected_size.txt"
OPEN "/tmp/expected_size.txt" FOR TEXT INPUT AS 3
ExpectedSize% = VAL(TRIM$(GET$ 3))
CLOSE 3
IF ExpectedSize% = 0 THEN ExpectedSize% = 10000000
@Log("Expected data stream: "+STR$ ExpectedSize% +" cycles")

// Version compare - User always wins
FUNCTION CompareVersions($a$,$b$) 
  IF POS($a$,"s")=0 THEN $a$=$a$+"s0"
  IF POS($b$,"s")=0 THEN $b$=$b$+"s0"
  MajA% = VAL(LEFT$($a$,POS($a$,".")-1))
  MinA% = VAL(MID$($a$,POS($a$,".")+1,POS($a$,"s")-POS($a$,".")-1))
  SubA% = VAL(MID$($a$,POS($a$,"s")+1,-1))
  MajB% = VAL(LEFT$($b$,POS($b$,".")-1))
  MinB% = VAL(MID$($b$,POS($b$,".")+1,POS($b$,"s")-POS($b$,".")-1))
  SubB% = VAL(MID$($b$,POS($b$,"s")+1,-1))
  IF MajA%>MajB% THEN @$ret=1 ELSEIF MajA%<MajB% THEN @$ret=-1
  ELSEIF MinA%>MinB% THEN @$ret=1 ELSEIF MinA%<MinB% THEN @$ret=-1
  ELSEIF SubA%>SubB% THEN @$ret=1 ELSEIF SubA%<SubB% THEN @$ret=-1
  ELSE @$ret=0
  ENDIF
ENDFN

NeedUpdate% = CompareVersions(LatestVersion$, CurrentVersion$)
IF NeedUpdate% <= 0 THEN
  @Log("Program is optimal. Standing by for User.")
  END
ENDIF

@Log(">>> UPGRADE AUTHORIZED - Flynn Lives! <<<")
Maj% = VAL(LEFT$(CurrentVersion$,POS(CurrentVersion$,".")-1))

IF Maj% < 15 THEN
  Url$ = "https://yourserver.com/ewon_pre15_latest.edf"
  Trigger$ = "ewonfwr.edf"
  @Log("Pre-Grid lockdown detected - pulling legacy .edf")
ELSE
  Url$ = "https://yourserver.com/ewon_latest.edfs"
  Trigger$ = "ewonfwr.edfs"
  @Log("Secure Grid mode - pulling signed .edfs")
ENDIF

@Log("Opening data stream from User server...")
Downloading% = 1
GETHTTP Url$,"/tmp/fwr.tmp"

FUNCTION ShowProgress()
  IF Downloading% = 0 THEN RETURN
  CurrSize% = GETSYS PRG,"FILESIZ","/tmp/fwr.tmp"
  IF CurrSize% > 0 THEN
    Perc! = (CurrSize% * 100.0) / ExpectedSize%
    @Log("Data transfer: ~"+STR$ Perc! +"% - Light cycle accelerating")
    IF Perc! >= 99.9 THEN
      Downloading% = 0
      TSET 1,0
      @FinishUpdate()
    ENDIF
  ENDIF
ENDFN

FUNCTION FinishUpdate()
  FinalSize% = GETSYS PRG,"FILESIZ","/tmp/fwr.tmp"
  @Log("Transfer complete ("+STR$ FinalSize% +" cycles)")
  IF FinalSize% > 500000 THEN
    RENAME "/tmp/fwr.tmp", "/" + Trigger$
    @Log(">>> IDENTITY DISK DEPLOYED - Rebooting into new program <<<")
    @Log("We fight for the Users!")
  ELSE
    @Log("ERROR: Data stream corrupted - aborting")
  ENDIF
ENDFN

END

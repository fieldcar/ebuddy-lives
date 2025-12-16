// Version: 1.2
// eBuddy Lives - Auto-Firmware Updater for Ewon Flexy
// Restoring User-friendly updates. Flynn Lives!

CLS
TSET 1,5  // Timer for progress polling
ONTIMER 1,"@ShowProgress()"

PRINT Time$();" Firmware auto-update starting..."

// Persistent log
FUNCTION Log($msg$)
  OPEN "/usr/update_log.txt" FOR BINARY APPEND AS 1
  PUT 1, Time$() + " " + $msg$ + Chr$(13)+Chr$(10)
  CLOSE 1
  PRINT Time$();$msg$
ENDFN

@Log("Reading current firmware version...")
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
IF CurrentVersion$ = "" THEN @Log("ERROR: Could not read version"): END
@Log("Current: "+CurrentVersion$)

// Fetch latest version
@Log("Checking for newer firmware...")
GETHTTP "https://yourserver.com/ewon_latest_version.txt","/tmp/latest.txt"
OPEN "/tmp/latest.txt" FOR TEXT INPUT AS 2
LatestVersion$ = TRIM$( GET$ 2 )
CLOSE 2
@Log("Latest available: "+LatestVersion$)

// Expected size for progress
GETHTTP "https://yourserver.com/ewon_latest_size.txt","/tmp/expected_size.txt"
OPEN "/tmp/expected_size.txt" FOR TEXT INPUT AS 3
ExpectedSize% = VAL(TRIM$(GET$ 3))
CLOSE 3
IF ExpectedSize% = 0 THEN ExpectedSize% = 10000000
@Log("Expected file size: "+STR$ ExpectedSize% +" bytes")

// Version compare function
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
  @Log("Firmware is up to date")
  END
ENDIF

@Log("Update required - proceeding")
Maj% = VAL(LEFT$(CurrentVersion$,POS(CurrentVersion$,".")-1))

IF Maj% < 15 THEN
  Url$ = "https://yourserver.com/ewon_pre15_latest.edf"
  Trigger$ = "ewonfwr.edf"
  @Log("Pre-v15 detected - using .edf format")
ELSE
  Url$ = "https://yourserver.com/ewon_latest.edfs"
  Trigger$ = "ewonfwr.edfs"
  @Log("v15+ detected - using signed .edfs format")
ENDIF

@Log("Downloading firmware...")
Downloading% = 1
GETHTTP Url$,"/tmp/fwr.tmp"

FUNCTION ShowProgress()
  IF Downloading% = 0 THEN RETURN
  CurrSize% = GETSYS PRG,"FILESIZ","/tmp/fwr.tmp"
  IF CurrSize% > 0 THEN
    Perc! = (CurrSize% * 100.0) / ExpectedSize%
    @Log("Download progress: ~"+STR$ Perc! +"%")
    IF Perc! >= 99.9 THEN
      Downloading% = 0
      TSET 1,0
      @FinishUpdate()
    ENDIF
  ENDIF
ENDFN

FUNCTION FinishUpdate()
  FinalSize% = GETSYS PRG,"FILESIZ","/tmp/fwr.tmp"
  @Log("Download complete ("+STR$ FinalSize% +" bytes)")
  IF FinalSize% > 500000 THEN
    RENAME "/tmp/fwr.tmp", "/" + Trigger$
    @Log("Firmware deployed - reboot to apply. Flynn Lives!")
  ELSE
    @Log("ERROR: File incomplete or corrupt")
  ENDIF
ENDFN

END

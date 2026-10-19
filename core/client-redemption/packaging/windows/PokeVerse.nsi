; PokeVerse installer for Windows (NSIS 3). It installs the same files as PokeVerse-Windows.zip
; into a folder of the player's own, without administrator rights, so the in-game updater can
; rewrite every file afterwards. It never updates anything itself and keeps no version number:
; the updater compares checksums, so whatever the installer put down is brought up to date on
; the next start.
;
;   makensis -DSOURCE=<windows package dir> -DOUTFILE=<PokeVerse-Setup.exe> PokeVerse.nsi
;
; installer-side.bmp comes from scripts/art/installer_art.py.

!ifndef SOURCE | OUTFILE
  !error "Define SOURCE and OUTFILE"
!endif
!ifndef ICON
  !define ICON "${__FILEDIR__}/../../src/otcicon.ico"
!endif

!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\PokeVerse"
!define UNINSTALLER "Uninstall PokeVerse.exe"

Unicode true
ManifestDPIAware true
SetCompressor /SOLID lzma
RequestExecutionLevel user

Name "PokeVerse"
OutFile "${OUTFILE}"
InstallDir "$LOCALAPPDATA\Programs\PokeVerse"
InstallDirRegKey HKCU "${UNINSTALL_KEY}" "InstallLocation"
BrandingText "PokeVerse"

!include MUI2.nsh
!include FileFunc.nsh
!include LogicLib.nsh

!define MUI_ICON "${ICON}"
!define MUI_UNICON "${ICON}"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${__FILEDIR__}/installer-side.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${__FILEDIR__}/installer-side.bmp"
!define MUI_ABORTWARNING

!define MUI_DIRECTORYPAGE_TEXT_TOP "PokeVerse installs into its own folder and updates itself every time it starts. Pick a folder you own: the game can't update inside Program Files."
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckFolder
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_TITLE "PokeVerse is installed"
!define MUI_FINISHPAGE_TEXT "Start it from the Start menu. The first start downloads the latest update."
!define MUI_FINISHPAGE_RUN "$INSTDIR\PokeVerse.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Play PokeVerse now"
; the finish page's second box adds the desktop shortcut
!define MUI_FINISHPAGE_SHOWREADME ""
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Add a desktop shortcut"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION DesktopShortcut
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Function .onInit
  SetShellVarContext current
FunctionEnd

Function un.onInit
  SetShellVarContext current
FunctionEnd

; The uninstaller removes the whole folder, so the files always go into a folder named PokeVerse
; (also with /D=, which skips the folder page).
Function UsePokeVerseFolder
  StrCpy $0 $INSTDIR 1 -1
  ${If} $0 == "\"
    StrCpy $INSTDIR $INSTDIR -1
  ${EndIf}
  StrCpy $0 $INSTDIR "" -10
  ${If} $0 != "\PokeVerse"
    StrCpy $INSTDIR "$INSTDIR\PokeVerse"
  ${EndIf}
FunctionEnd

Function CheckFolder
  Call UsePokeVerseFolder
  ${ForEach} $1 0 2 + 1
    ${If} $1 == 0
      StrCpy $2 $PROGRAMFILES
    ${ElseIf} $1 == 1
      StrCpy $2 $PROGRAMFILES64
    ${Else}
      StrCpy $2 $WINDIR
    ${EndIf}
    StrLen $3 $2
    StrCpy $4 $INSTDIR $3
    ${If} $3 > 0
    ${AndIf} $4 == $2
      MessageBox MB_ICONEXCLAMATION|MB_OK "PokeVerse can't update itself inside $2. Pick a folder of your own, for example the one suggested."
      Abort
    ${EndIf}
  ${Next}
FunctionEnd

Function DesktopShortcut
  CreateShortCut "$DESKTOP\PokeVerse.lnk" "$INSTDIR\PokeVerse.exe" "" "$INSTDIR\PokeVerse.exe" 0
FunctionEnd

Section "PokeVerse"
  Call UsePokeVerseFolder
  SetOutPath "$INSTDIR"
  File /r "${SOURCE}\*.*"

  WriteUninstaller "$INSTDIR\${UNINSTALLER}"
  CreateShortCut "$SMPROGRAMS\PokeVerse.lnk" "$INSTDIR\PokeVerse.exe" "" "$INSTDIR\PokeVerse.exe" 0

  ; no DisplayVersion: the updater changes the files after this, so it would only be wrong
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "PokeVerse"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "Publisher" "PokeVerse"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "URLInfoAbout" "https://pokeverse.quest"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\PokeVerse.exe"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\${UNINSTALLER}"'
  WriteRegStr HKCU "${UNINSTALL_KEY}" "QuietUninstallString" '"$INSTDIR\${UNINSTALLER}" /S'
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "EstimatedSize" "$0"
SectionEnd

Section "Uninstall"
  StrCpy $0 $INSTDIR "" -10
  ${If} $0 != "\PokeVerse"
  ${OrIfNot} ${FileExists} "$INSTDIR\PokeVerse.exe"
    MessageBox MB_ICONSTOP|MB_OK "$INSTDIR doesn't look like a PokeVerse folder, so nothing was removed."
    Abort
  ${EndIf}

  Delete "$SMPROGRAMS\PokeVerse.lnk"
  Delete "$DESKTOP\PokeVerse.lnk"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKCU "${UNINSTALL_KEY}"

  ${If} ${FileExists} "$APPDATA\PokeVerse\*.*"
    MessageBox MB_YESNO|MB_DEFBUTTON2 "Also delete your settings and hotkeys ($APPDATA\PokeVerse)?" /SD IDNO IDNO keep
    RMDir /r "$APPDATA\PokeVerse"
    keep:
  ${EndIf}
SectionEnd

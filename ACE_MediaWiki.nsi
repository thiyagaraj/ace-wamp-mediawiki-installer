; Installer to install Apache/PHP/MySQL/MediaWiki and help in Configuring the same
; Thiyagaraj Krishna - 08/21/2008
; http://thiya.net 

;Include Modern UI
!include "MUI2.nsh"

Name "AceInstall v1.0"

;Pages Interface Definitions
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "header.bmp" ; optional
  !define MUI_ABORTWARNING
  !define MUI_COMPONENTSPAGE_NODESC
  !define MUI_FINISHPAGE_TEXT "The installer has attempted to install and configure Apache/PHP/MySQL and MediaWiki. The MediaWiki configuration has been successfully launched, please continue installation there. This window can be safely closed. To troubleshoot issues, please view the README"
  !insertmacro MUI_PAGE_WELCOME
  
  !define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\AceInstall\Readme.txt"
  ;Page custom welcomeFunction ;welcome
  
  !insertmacro MUI_PAGE_LICENSE "license.rtf"
  !insertmacro MUI_PAGE_COMPONENTS
  
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH
  
  ;Language
  !insertmacro MUI_LANGUAGE "English"

; Pages required for creating installer
/* Page license
Page components
Page directory
Page instfiles */
;Install pages end

; Default Intall Directory - Set to Program Files
installDir "$PROGRAMFILES\AceInstall"

;Output setup file
OutFile AceInstallv1.0.exe

;Hide Installer details 
ShowInstDetails NeverShow
Icon "orange-install.ico"
;Branding Text update
BrandingText "AceInstall v1.0"
/* LangString PAGE_TITLE ${LANG_ENGLISH} "Title"
LangString PAGE_SUBTITLE ${LANG_ENGLISH} "Subtitle"

Function welcomeFunction
!insermacro MUI_HEADER_TEXT $(PAGE_TITLE) $(PAGE_SUBTITLE)
FunctionEnd  */

Function .onInit
  SetOutPath $TEMP
  File /oname=spltmp.bmp "ace.bmp"

  advsplash::show 5000 600 400 -1 $TEMP\spltmp
  Delete $TEMP\spltmp.bmp
;  Delete $TEMP\spltmp.wav
FunctionEnd

Section
  SetOutPath "$INSTDIR\AceInstall\"
  File Readme.txt
SectionEnd

; Apache Section
Section "Apache HTTP Server 2.2.9"
  SetOutPath "$INSTDIR\AceInstall\temp\"
  File "apache_2.2.9-win32-x86-no_ssl-r2.msi"
  ExecWait 'msiexec.exe -I "$INSTDIR\AceInstall\temp\apache_2.2.9-win32-x86-no_ssl-r2.msi" INSTALLDIR="$INSTDIR\AceInstall\Apache\" SERVERDOMAIN="mediawiki" SERVERNAME="%computername%" SERVERADMIN="mediawiki@mediawiki" SERVERPORT="80" ALLUSERS="1" RebootYesNo="No" /passive'
  SetOutPath "$INSTDIR\AceInstall\"
  File Readme.txt
SectionEnd

; PHP Section
Section "PHP 5.2.6 (Apache Module)"
  SetOutPath "$INSTDIR\AceInstall\temp\"
  File "php-5.2.6-win32-installer.msi"
  ExecWait 'msiexec.exe /i "$INSTDIR\AceInstall\temp\php-5.2.6-win32-installer.msi" /passive ADDLOCAL="ext_php_mysqli,ext_php_mysql,apache22,cgi,MainExecutable" INSTALLDIR="$INSTDIR\AceInstall\php\" APACHEDIR="$INSTDIR\AceInstall\Apache\conf\"'
  ; Doing this to prevent restart required for path update as Apache already has its bin updated in the path :-D
  SetOutPath "$INSTDIR\AceInstall\Apache\bin\"
  ;This file stolen from PHP root
  File "libmysql.dll"
  
  ;Reboot moved down, to take updated path
  ExecWait '$INSTDIR\AceInstall\Apache\bin\httpd.exe -k restart'
SectionEnd

; MySQL Section
Section "MySQL 5.0.67"
  SetOutPath "$INSTDIR\AceInstall\temp\"
  File "mysql-essential-5.0.67-win32.msi"
  ExecWait 'msiexec /i "$INSTDIR\AceInstall\temp\mysql-essential-5.0.67-win32.msi" /qb INSTALLDIR="$INSTDIR\AceInstall\mysql\"'
  ;Configuration should be done separately
  ; Move to bin folder prior to Configuring
  SetOutPath "$INSTDIR\AceInstall\mysql\bin\"
  ExecWait 'MySQLInstanceConfig.exe -i -q "-nMySQL Server 5.0" "-p$INSTDIR\AceInstall\mysql" -v5.0.51b -lC:\mysql_config.log"-t$INSTDIR\AceInstall\mysql\my-template.ini" "-c$INSTDIR\AceInstall\mysql\my.ini" AddBinToPath=no ServerType=DEVELOPMENT DatabaseType=MIXED ConnectionUsage=DSS Charset=utf8 SkipNetworking=no Port=3306 RootPassword=google'
  
  ; Drop our test php page to check connections
  SetOutPath "$INSTDIR\AceInstall\Apache\htdocs\"
  ; File "test.php"
  ; Open our test page to check if everything went fine
  ; ExecShell "open" "http://localhost/test.php"
  
  ; Recursively remove all the directories - if unable, zap them on reboot
  RMDir /r /REBOOTOK "$INSTDIR\AceInstall\temp"
SectionEnd

; MediaWiki Section
Section "MediaWiki 1.13.0"
  ; CreateDirectory "$INSTDIR\AceInstall\Apache\htdocs\mediawiki"
  ; CopyFiles "$EXEDIR\mediawiki\*.*" "$INSTDIR\AceInstall\Apache\htdocs\mediawiki"
  SetOutPath "$INSTDIR\AceInstall\Apache\htdocs\mediawiki\"
  File /r "mediawiki\*.*"
  MessageBox MB_OK "MediaWiki Installation will continue in a new browser window. Please complete installation in the new window. Press OK to launch..."
  ExecShell "open" "http://localhost/mediawiki/config/index.php"
SectionEnd
#define MyAppName "winime_en"
#ifndef MyAppVersion
  #define MyAppVersion "0.1.0"
#endif
#ifndef MyAppChannel
  #define MyAppChannel ""
#endif
#define MyAppPublisher "hdformat"
#define MyAppURL "https://github.com/hdformat/winime_en"
#define MyAppExeName "winime_en.exe"
#define MyAppChannelFileSuffix (MyAppChannel == "" ? "" : "-" + MyAppChannel)
#define MyAppChannelNameSuffix (MyAppChannel == "" ? "" : " " + MyAppChannel)

[Setup]
AppId={{4FEC9FE6-F2E9-4976-ACC3-C55DAAF415BA}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}{#MyAppChannelNameSuffix}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\Programs\winime_en
DisableProgramGroupPage=yes
OutputDir=..\dist
OutputBaseFilename=winime_en-Setup{#MyAppChannelFileSuffix}-{#MyAppVersion}
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
LanguageDetectionMethod=uilanguage
ShowLanguageDialog=auto
SetupLogging=no

[Languages]
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\target\installer\release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

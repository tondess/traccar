[Setup]
AppName=Traccar
AppVersion=1.1
DefaultDirName={pf}\Traccar
AlwaysRestart=yes

[Dirs]
Name: "{app}\bin"
Name: "{app}\conf"
Name: "{app}\data"
Name: "{app}\lib"
Name: "{app}\logs"

[Files]
Source: "wrapper\bin\wrapper.exe"; DestDir: "{app}\bin"
Source: "wrapper\src\bin\App.bat.in"; DestDir: "{app}\bin"; DestName: "Traccar.bat"
Source: "wrapper\src\bin\InstallApp-NT.bat.in"; DestDir: "{app}\bin"; DestName: "InstallTraccar-NT.bat"
Source: "wrapper\src\bin\UninstallApp-NT.bat.in"; DestDir: "{app}\bin"; DestName: "UninstallTraccar-NT.bat"
Source: "wrapper\lib\wrapper.dll"; DestDir: "{app}\lib";
Source: "wrapper\lib\wrapper.jar"; DestDir: "{app}\lib";
Source: "wrapper\src\conf\wrapper.conf.in"; DestDir: "{app}\conf"; DestName: "wrapper.conf"; AfterInstall: ConfigureWrapper

Source: "tracker-server.jar"; DestDir: "{app}"
Source: "lib\*"; DestDir: "{app}\lib"
Source: "windows.cfg"; DestDir: "{app}\conf"; AfterInstall: ConfigureApplication

[Run]
Filename: "{app}\bin\InstallTraccar-NT.bat"

[UninstallRun]
Filename: "{app}\bin\UninstallTraccar-NT.bat"

[Code]
function InitializeSetup(): Boolean;
begin
  if  RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\JavaSoft\Java Runtime Environment') then
  begin
    Result := true;
  end
  else
  begin
    Result := false;
    MsgBox('This application requires Java Runtime Environment version 1.6 or later. Please download and install the JRE and run this setup again.', mbCriticalError, MB_OK);
  end;
end;

procedure ConfigureWrapper();
var
  S: String;
begin
  LoadStringFromFile(ExpandConstant(CurrentFileName), S);
  Insert('wrapper.java.classpath.2=../tracker-server.jar' + #13#10, S, Pos('wrapper.java.classpath.1', S));
  Insert(ExpandConstant('wrapper.app.parameter.2="{app}\conf\windows.cfg"') + #13#10, S, Pos('wrapper.app.parameter.1', S));
  StringChangeEx(S, '<YourMainClass>', 'org.traccar.Main', true);
  StringChangeEx(S, '@app.name@', 'Traccar', true);
  StringChangeEx(S, '@app.long.name@', 'Traccar', true);
  StringChangeEx(S, '@app.description@', 'Traccar', true);
  SaveStringToFile(ExpandConstant(CurrentFileName), S, false);
end;

procedure ConfigureApplication();
var
  S: String;
begin
  LoadStringFromFile(ExpandConstant(CurrentFileName), S);
  StringChangeEx(S, '[DATABASE]', ExpandConstant('{app}\data\database'), true);
  StringChangeEx(S, '[LOG]', ExpandConstant('{app}\logs\tracker-server.log'), true);
  SaveStringToFile(ExpandConstant(CurrentFileName), S, false);
end;

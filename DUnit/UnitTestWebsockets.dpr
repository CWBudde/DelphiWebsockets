program UnitTestWebsockets;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
  {$APPTYPE CONSOLE}
{$ENDIF}

{$IFNDEF USE_JEDI_JCL} {$MESSAGE ERROR 'Must define "USE_JEDI_JCL" for location info of errors'} {$ENDIF}

{$R *.RES}

uses
  DUnitTestRunner,
  TestFramework,
  mtTestWebSockets in 'mtTestWebSockets.pas',
  IdHTTPWebsocketClient in '..\IdHTTPWebsocketClient.pas',
  IdIOHandlerWebsocket in '..\IdIOHandlerWebsocket.pas',
  IdServerBaseHandling in '..\IdServerBaseHandling.pas',
  IdServerIOHandlerWebsocket in '..\IdServerIOHandlerWebsocket.pas',
  IdServerSocketIOHandling in '..\IdServerSocketIOHandling.pas',
  IdServerWebsocketContext in '..\IdServerWebsocketContext.pas',
  IdServerWebsocketHandling in '..\IdServerWebsocketHandling.pas',
  IdSocketIOHandling in '..\IdSocketIOHandling.pas',
  IdWebsocketServer in '..\IdWebsocketServer.pas',
  superobject in '..\superobject\superobject.pas';

begin
  RegisterTest(TTestWebSockets.Suite);

  DUnitTestRunner.RunRegisteredTests;
end.


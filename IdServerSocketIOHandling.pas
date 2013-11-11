unit IdServerSocketIOHandling;

interface

uses
  IdContext, IdCustomTCPServer,
  //IdServerWebsocketContext,
  Classes, Generics.Collections,
  superobject, IdException, IdServerBaseHandling, IdSocketIOHandling;

type
  TIdServerSocketIOHandling = class(TIdBaseSocketIOHandling)
  protected
    procedure ProcessHeatbeatRequest(const AContext: TSocketIOContext; const aText: string); override;
  public
    function  SendToAll(const aMessage: string; const aCallback: TSocketIOMsgJSON = nil): Integer;
    procedure SendTo   (const aContext: TIdServerContext; const aMessage: string; const aCallback: TSocketIOMsgJSON = nil);

    function  EmitEventToAll(const aEventName: string; const aData: ISuperObject; const aCallback: TSocketIOMsgJSON = nil): Integer;
    procedure EmitEventTo   (const aContext: TSocketIOContext;
                             const aEventName: string; const aData: ISuperObject; const aCallback: TSocketIOMsgJSON = nil);overload;
    procedure EmitEventTo   (const aContext: TIdServerContext;
                             const aEventName: string; const aData: ISuperObject; const aCallback: TSocketIOMsgJSON = nil);overload;
  end;

implementation

uses
  SysUtils, StrUtils;

{ TIdServerSocketIOHandling }

procedure TIdServerSocketIOHandling.EmitEventTo(
  const aContext: TSocketIOContext; const aEventName: string;
  const aData: ISuperObject; const aCallback: TSocketIOMsgJSON);
var
  jsonarray: string;
begin
  if aContext.IsDisconnected then
    raise EIdSocketIoUnhandledMessage.Create('socket.io connection closed!');

  if aData.IsType(stArray) then
    jsonarray := aData.AsString
  else if aData.IsType(stString) then
    jsonarray := '["' + aData.AsString + '"]'
  else
    jsonarray := '[' + aData.AsString + ']';

  if not Assigned(aCallback) then
    WriteSocketIOEvent(aContext, ''{no room}, aEventName, jsonarray, nil)
  else
    WriteSocketIOEventRef(aContext, ''{no room}, aEventName, jsonarray,
      procedure(const aData: string)
      begin
        aCallback(aContext, SO(aData), nil);
      end);
end;

procedure TIdServerSocketIOHandling.EmitEventTo(
  const aContext: TIdServerContext; const aEventName: string;
  const aData: ISuperObject; const aCallback: TSocketIOMsgJSON);
var
  context: TSocketIOContext;
begin
  Lock;
  try
    context := FConnections.Items[aContext];
    EmitEventTo(context, aEventName, aData, aCallback);
  finally
    UnLock;
  end;
end;

function TIdServerSocketIOHandling.EmitEventToAll(const aEventName: string; const aData: ISuperObject;
  const aCallback: TSocketIOMsgJSON): Integer;
var
  context: TSocketIOContext;
  jsonarray: string;
begin
  Result := 0;
  if aData.IsType(stArray) then
    jsonarray := aData.AsString
  else if aData.IsType(stString) then
    jsonarray := '["' + aData.AsString + '"]'
  else
    jsonarray := '[' + aData.AsString + ']';

  Lock;
  try
    for context in FConnections.Values do
    begin
      if context.IsDisconnected then Continue;

      if not Assigned(aCallback) then
        WriteSocketIOEvent(context, ''{no room}, aEventName, jsonarray, nil)
      else
        WriteSocketIOEventRef(context, ''{no room}, aEventName, jsonarray,
          procedure(const aData: string)
          begin
            aCallback(context, SO(aData), nil);
          end);
      Inc(Result);
    end;
    for context in FConnectionsGUID.Values do
    begin
      if context.IsDisconnected then Continue;

      if not Assigned(aCallback) then
        WriteSocketIOEvent(context, ''{no room}, aEventName, jsonarray, nil)
      else
        WriteSocketIOEventRef(context, ''{no room}, aEventName, jsonarray,
          procedure(const aData: string)
          begin
            aCallback(context, SO(aData), nil);
          end);
      Inc(Result);
    end;
  finally
    UnLock;
  end;
end;

procedure TIdServerSocketIOHandling.ProcessHeatbeatRequest(
  const AContext: TSocketIOContext; const aText: string);
begin
  inherited ProcessHeatbeatRequest(AContext, aText);
end;

procedure TIdServerSocketIOHandling.SendTo(const aContext: TIdServerContext;
  const aMessage: string; const aCallback: TSocketIOMsgJSON);
var
  context: TSocketIOContext;
begin
  Lock;
  try
    context := FConnections.Items[aContext];
    if context.IsDisconnected then
      raise EIdSocketIoUnhandledMessage.Create('socket.io connection closed!');

    if not Assigned(aCallback) then
      WriteSocketIOMsg(context, ''{no room}, aMessage, nil)
    else
      WriteSocketIOMsg(context, ''{no room}, aMessage,
        procedure(const aData: string)
        begin
          aCallback(context, SO(aData), nil);
        end);
  finally
    UnLock;
  end;
end;

function TIdServerSocketIOHandling.SendToAll(const aMessage: string;
  const aCallback: TSocketIOMsgJSON): Integer;
var
  context: TSocketIOContext;
begin
  Result := 0;
  Lock;
  try
    for context in FConnections.Values do
    begin
      if context.IsDisconnected then Continue;

      if not Assigned(aCallback) then
        WriteSocketIOMsg(context, ''{no room}, aMessage, nil)
      else
        WriteSocketIOMsg(context, ''{no room}, aMessage,
          procedure(const aData: string)
          begin
            aCallback(context, SO(aData), nil);
          end);
      Inc(Result);
    end;
    for context in FConnectionsGUID.Values do
    begin
      if context.IsDisconnected then Continue;

      if not Assigned(aCallback) then
        WriteSocketIOMsg(context, ''{no room}, aMessage, nil)
      else
        WriteSocketIOMsg(context, ''{no room}, aMessage,
          procedure(const aData: string)
          begin
            aCallback(context, SO(aData), nil);
          end);
      Inc(Result);
    end;
  finally
    UnLock;
  end;
end;

end.
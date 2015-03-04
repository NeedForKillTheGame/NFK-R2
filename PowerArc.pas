unit PowerArc;

{| PowerArc 1.3.1  /5 Apr 2001/
 | Copyright (c) 2000,2001 SoftLab MIL-TEC Ltd
 | Web    http://www.softcomplete.com
 | Email  support@softcomplete.com
 | Data compression library for Delphi and C++ Builder
 |}

{-------------------------------------------------------------------------------
 What's new in ver.1.3.1
  + change interface proc names
    RegisterPowerArcModule -> PowerArcRegisterModule
    SetOptions -> PowerArcSetOptions
    Compress -> PowerArcCompress
    Decompress -> PowerArcDecompress
  + change param order in PowerArcCompress
    was:
      function PowerArcCompress(ArcIdx: integer; InStream,OutStream: TStream;
        const ArcOpt: string = ''; ProgressCallback: TProgressCallback = nil): Boolean;
    now:
      function PowerArcCompress(InStream,OutStream: TStream;
        ArcIdx: integer = iPowerBZIP; const ArcOpt: string = '';
        ProgressCallback: TProgressCallback = nil): Boolean;
--------------------------------------------------------------------------------
 What's new in ver.1.3
  + full progress callback support
  + TProgressCallback changed type definition
  + update BZIP core to ver.1.0.1
  + implementation BZIP as default built-in method
  + RegisterPowerArcModule now check for dups
  + fix memory leak: free Options list
  + fix bug in Read/Write methods in implementation of stream interface
-------------------------------------------------------------------------------}

interface

uses SysUtils, Windows, Classes, PowerAcrModuleInfo, bzLib;

type
  EPowerArcError = class(Exception);
  TProgressCallback = procedure (Current: integer) of object;

const // default compression method
  iPowerBZIP = 0;
var   // loadable compression engines
  iPowerZIP: integer = 0;
  iPowerRANK: integer = 0;
  iPowerPPM: integer = 0;

function PowerArcRegisterModule(const Name: string): integer;

procedure PowerArcSetOptions(ArcIdx: integer; const ArcOpt: string);

function PowerArcCompress(InStream,OutStream: TStream;
  ArcIdx: integer = iPowerBZIP; const ArcOpt: string = '';
  ProgressCallback: TProgressCallback = nil): Boolean; overload;

function PowerArcCompress(const Buffer; Size: integer; OutStream: TStream;
  ArcIdx: integer = iPowerBZIP; const ArcOpt: string = '';
  ProgressCallback: TProgressCallback = nil): Boolean; overload;

function PowerArcDecompress(InStream,OutStream: TStream;
  ProgressCallback: TProgressCallback = nil): Boolean;

//============================ Stream interface ================================

type   

{ TPowerArcCompressStream compresses data on the fly as data is written to it,
  and stores the compressed data to another stream.

  TPowerArcCompressStream is write-only and strictly sequential. Reading from the
  stream will raise an exception. Using Seek to move the stream pointer
  will raise an exception.

  Output data is cached internally, written to the output stream only when
  the internal output buffer is full.  All pending output data is flushed
  when the stream is destroyed.

  The Position property returns the number of uncompressed bytes of
  data that have been written to the stream so far.

  The OnProgress event is called each time the output buffer is filled and
  written to the output stream.  This is useful for updating a progress
  indicator when you are writing a large chunk of data to the compression
  stream in a single call.}

  TPowerArcCompressStream = class(TStream)
  private
    Base: TStream;
    ArcIdx: integer;
    ArcOpt: string;
    Thread: TThread;
    hReadPipe,
    hWritePipe: THandle;
    TotalWrited: integer;
    BZCompressionStream: TBZCompressionStream;
    FOnProgress: TProgressCallback;
    procedure DoProgress(Current: integer);
  public
    constructor Create(BaseStream: TStream; FArcIdx: integer = iPowerBZIP;
      const FArcOpt: string = '');
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    property OnProgress: TProgressCallback read FOnProgress write FOnProgress;
  end;

{ TPowerArcDecompressStream decompresses data on the fly as data is read from it.

  Compressed data comes from a separate source stream.  TPowerArcDecompressStream
  is read-only and unidirectional; you can seek forward in the stream, but not
  backwards.  The special case of setting the stream position to zero is
  allowed.  Seeking forward decompresses data until the requested position in
  the uncompressed data has been reached.  Seeking backwards, seeking relative
  to the end of the stream, requesting the size of the stream, and writing to
  the stream will raise an exception.

  The Position property returns the number of bytes of uncompressed data that
  have been read from the stream so far.

  The OnProgress event is called each time the internal input buffer of
  compressed data is exhausted and the next block is read from the input stream.
  This is useful for updating a progress indicator when you are reading a
  large chunk of data from the decompression stream in a single call.}

  TPowerArcDecompressStream = class(TStream)
  private
    Base: TStream;
    ArcIdx: integer;
    Thread: TThread;
    hReadPipe,
    hWritePipe: THandle;
    TotalReaded: integer;
    BZDecompressionStream: TBZDecompressionStream;
    FOnProgress: TProgressCallback;
    procedure DoProgress(Current: integer);
  public
    constructor Create(BaseStream: TStream);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    property OnProgress: TProgressCallback read FOnProgress write FOnProgress;
  end;

//==============================================================================

type
  // callback's
  TReadFunc = function (Data: Pointer; var Buffer; Size: integer): integer; stdcall;
  TWriteFunc = function (Data: Pointer; const Buffer; Size: integer): integer; stdcall;
  // dll entryes
  TPowerArcSetOptions =  procedure (Opt: PChar); stdcall;
  TPowerArcCompress =    procedure (Data: Pointer; Opt: PChar; ReadFunc: TReadFunc;
                                    WriteFunc: TWriteFunc); stdcall;
  TPowerArcCompressMem = procedure (Data: Pointer; Opt: PChar; Mem: Pointer;
                                    MemSize: integer; WriteFunc: TWriteFunc); stdcall;
  TPowerArcDecompress =  function (Data: Pointer; ReadFunc: TReadFunc;
                                   WriteFunc: TWriteFunc): Boolean; stdcall;
  // dll registration info
  TPowerArcModule = record
    Name:        string;
    hLib:        THandle;
    Info:        PPowerArcModuleInfo;
    Options:     TStringList;
    SetOptions:  TPowerArcSetOptions;
    Compress:    TPowerArcCompress;
    CompressMem: TPowerArcCompressMem;
    Decompress:  TPowerArcDecompress;
  end;

var
  PowerArcModules: array of TPowerArcModule;

implementation

const
  PipeSize = 4*4096;

type
  TPowerArcData = record
    InStream,OutStream: TStream;
    Current: integer;
    ProgressCallback: TProgressCallback;
  end;

function ReadFunc(Data: Pointer; var Buffer; Size: integer): integer; stdcall;
begin
  Result:=TPowerArcData(Data^).InStream.Read(Buffer,Size);
  if Assigned(TPowerArcData(Data^).ProgressCallback) then begin
    Inc(TPowerArcData(Data^).Current,Result);
    TPowerArcData(Data^).ProgressCallback(TPowerArcData(Data^).Current);
  end;
end;

function WriteFunc(Data: Pointer; const Buffer; Size: integer): integer; stdcall;
begin
  Result:=TPowerArcData(Data^).OutStream.Write(Buffer,Size);
end;

function ValidArcIdx(ArcIdx: integer): Boolean;
begin
  Result:=(ArcIdx >= 0) and (ArcIdx < Length(PowerArcModules));
end;

procedure PowerArcSetOptions(ArcIdx: integer; const ArcOpt: string);
begin
  // no opt for default method
  if (ArcIdx <> iPowerBZIP) and ValidArcIdx(ArcIdx) then
    PowerArcModules[ArcIdx].SetOptions(PChar(ArcOpt));
end;

function PowerArcCompress(InStream,OutStream: TStream;
  ArcIdx: integer; const ArcOpt: string;
  ProgressCallback: TProgressCallback): Boolean;
var Data: TPowerArcData;
begin
  Result:=False;
  if ArcIdx = iPowerBZIP then begin
    OutStream.Write(PowerArcModules[ArcIdx].Info^.ModuleID[0],8);
    BZCompress(InStream,OutStream,ProgressCallback);
    Result:=True;
  end else if ValidArcIdx(ArcIdx) then try
    Data.InStream:=InStream;
    Data.OutStream:=OutStream;
    Data.ProgressCallback:=ProgressCallback;
    Data.Current:=0;
    OutStream.Write(PowerArcModules[ArcIdx].Info^.ModuleID[0],8);
    PowerArcModules[ArcIdx].Compress(@Data,PChar(ArcOpt),ReadFunc,WriteFunc);
    Result:=True;
  except
  end;
end;

type
  TMapMemoryStream = class (TCustomMemoryStream)
  private
    FReadOnly: Boolean;
  public
    constructor Create(Buf: Pointer; Size: integer; ReadOnly: Boolean);
    function Write(const Buffer; Count: integer): integer; override;
  end;

constructor TMapMemoryStream.Create(Buf: Pointer; Size: integer; ReadOnly: Boolean);
begin
  inherited Create;
  SetPointer(Buf,Size);
  FReadOnly:=ReadOnly;
end;

function TMapMemoryStream.Write(const Buffer; Count: integer): integer;
begin
  if FReadOnly then Result:=0
  else begin
    if Position+Count > Size then Result:=Size-Position
    else Result:=Count;
    Move(Buffer, Pointer(integer(Memory) + Position)^, Result);
    Seek(Result,1);
  end;
end;

function PowerArcCompress(const Buffer; Size: integer; OutStream: TStream;
  ArcIdx: integer; const ArcOpt: string;
  ProgressCallback: TProgressCallback): Boolean;
var Data: TPowerArcData;
    MapMemoryStream: TMapMemoryStream;
begin
  if Assigned(ProgressCallback) then begin
    if ArcIdx = iPowerBZIP then begin
      OutStream.Write(PowerArcModules[ArcIdx].Info^.ModuleID[0],8);
      BZCompress(Buffer,Size,OutStream,ProgressCallback);
      Result:=True;
    end else begin
      MapMemoryStream:=TMapMemoryStream.Create(@Buffer,Size,True);
      try
        Result:=PowerArcCompress(MapMemoryStream,OutStream,ArcIdx,ArcOpt,ProgressCallback);
      finally
        MapMemoryStream.Free;
      end;
    end;
  end else begin
    Result:=False;
    if ArcIdx = iPowerBZIP then begin
      OutStream.Write(PowerArcModules[ArcIdx].Info^.ModuleID[0],8);
      BZCompress(Buffer,Size,OutStream);
      Result:=True;
    end else if ValidArcIdx(ArcIdx) then try
      Data.OutStream:=OutStream;
      OutStream.Write(PowerArcModules[ArcIdx].Info^.ModuleID[0],8);
      PowerArcModules[ArcIdx].CompressMem(@Data,PChar(ArcOpt),@Buffer,Size,WriteFunc);
      Result:=True;
    except
    end;
  end;
end;

function PowerArcDecompress(InStream,OutStream: TStream;
  ProgressCallback: TProgressCallback): Boolean;
var ModuleID: packed array[0..7] of Char;
    j: integer;
    Data: TPowerArcData;
begin
  Result:=False;
  InStream.Read(ModuleID[0],8);
  for j:=0 to Length(PowerArcModules)-1 do
    if PowerArcModules[j].Info^.ModuleID = ModuleID then try
      if j = iPowerBZIP then
        BZDecompress(InStream,OutStream)
      else begin
        Data.InStream:=InStream;
        Data.OutStream:=OutStream;
        Data.ProgressCallback:=ProgressCallback;
        Data.Current:=0;
        PowerArcModules[j].Decompress(@Data,ReadFunc,WriteFunc);
      end;
      Result:=True;
      Exit;
    except
    end;
end;

function PowerArcRegisterModule(const Name: string): integer;
type TGetPowerArcModuleInfo = function: PPowerArcModuleInfo;
var PowerArcModule: TPowerArcModule;
    GetPowerArcModuleInfo: TGetPowerArcModuleInfo;
    POpt: PChar;
    j: integer;
begin
  Result:=-1;
  PowerArcModule.hLib:=LoadLibrary(PChar(Name));
  if PowerArcModule.hLib <> 0 then begin
    PowerArcModule.Name:=Name;
    GetPowerArcModuleInfo:=TGetPowerArcModuleInfo(GetProcAddress(PowerArcModule.hLib,
      'GetPowerArcModuleInfo'));
    PowerArcModule.Info:=GetPowerArcModuleInfo;
    // check that module exists
    for j:=0 to Length(PowerArcModules)-1 do
      if PowerArcModules[j].Info^.ModuleID = PowerArcModule.Info.ModuleID then begin
        Result:=j;
        FreeLibrary(PowerArcModule.hLib);
        Exit;
      end;
    // continue init
    PowerArcModule.SetOptions:=TPowerArcSetOptions(GetProcAddress(PowerArcModule.hLib,'SetOptions'));
    PowerArcModule.Compress:=TPowerArcCompress(GetProcAddress(PowerArcModule.hLib,'Compress'));
    PowerArcModule.CompressMem:=TPowerArcCompressMem(GetProcAddress(PowerArcModule.hLib,'CompressMem'));
    PowerArcModule.Decompress:=TPowerArcDecompress(GetProcAddress(PowerArcModule.hLib,'Decompress'));
    if Assigned(GetPowerArcModuleInfo) and
       (PowerArcModule.Info^.Signature = PowerArcModuleSignature) and
       Assigned(PowerArcModule.SetOptions) and
       Assigned(PowerArcModule.Compress) and
       Assigned(PowerArcModule.CompressMem) and
       Assigned(PowerArcModule.Decompress) then begin
      PowerArcModule.Options:=TStringList.Create;
      POpt:=PowerArcModule.Info^.Options;
      while POpt^ <> #0 do begin
        PowerArcModule.Options.Add(POpt);
        POpt:=POpt+StrLen(POpt)+1;
      end;
      SetLength(PowerArcModules,Length(PowerArcModules)+1);
      PowerArcModules[Length(PowerArcModules)-1]:=PowerArcModule;
      Result:=Length(PowerArcModules)-1;
    end else
      FreeLibrary(PowerArcModule.hLib);
  end;
end;

procedure PowerArcUnregisterModules;
var j: integer;
begin
  for j:=0 to Length(PowerArcModules)-1 do begin
    if PowerArcModules[j].hLib <> 0 then
      FreeLibrary(PowerArcModules[j].hLib);
    PowerArcModules[j].Options.Free;
  end;
  PowerArcModules:=nil;
end;

{ TCompressThread }

type
  TCompressThread = class(TThread)
  private
    Done: Boolean;
    CompressStream: TPowerArcCompressStream;
  protected
    procedure Execute; override;
  end;

{ TCompressThread }

function ReadCompressFunc(Data: Pointer; var Buffer; Size: integer): integer; stdcall;
begin
  if not Windows.ReadFile(TPowerArcCompressStream(Data).hReadPipe,Buffer,Size,DWORD(Result),nil) then
    Result:=-1;
end;

function WriteCompressFunc(Data: Pointer; const Buffer; Size: integer): integer; stdcall;
begin
  Result:=TPowerArcCompressStream(Data).Base.Write(Buffer,Size);
end;

procedure TCompressThread.Execute;
begin
  try
    CompressStream.Base.Write(PowerArcModules[CompressStream.ArcIdx].Info^.ModuleID[0],8);
    PowerArcModules[CompressStream.ArcIdx].Compress(CompressStream,
      PChar(CompressStream.ArcOpt),ReadCompressFunc,WriteCompressFunc);
  except
  end;
  CloseHandle(CompressStream.hReadPipe);
  Done:=True;
end;

{ TPowerArcCompressStream }

constructor TPowerArcCompressStream.Create(BaseStream: TStream;
  FArcIdx: integer; const FArcOpt: string);
begin
  inherited Create;
  Base:=BaseStream;
  ArcIdx:=FArcIdx;
  ArcOpt:=FArcOpt;
  Thread:=nil;
  FOnProgress:=nil;
  TotalWrited:=0;
  if not ValidArcIdx(ArcIdx) then
    raise EPowerArcError.Create('Invalid acrhive index');
  if ArcIdx = iPowerBZIP then begin
    Base.Write(PowerArcModules[ArcIdx].Info^.ModuleID[0],8);
    BZCompressionStream:=TBZCompressionStream.Create(Base);
    BZCompressionStream.OnProgress:=DoProgress;
  end else
    BZCompressionStream:=nil;
end;

destructor TPowerArcCompressStream.Destroy;
begin
  if Thread <> nil then begin
    CloseHandle(hWritePipe);
    while not TCompressThread(Thread).Done do Sleep(0);
    Thread.Free;
  end;
  if BZCompressionStream <> nil then
    BZCompressionStream.Free;
  inherited;
end;

procedure TPowerArcCompressStream.DoProgress(Current: integer);
begin
  if Assigned(FOnProgress) then FOnProgress(Current);
end;

function TPowerArcCompressStream.Read(var Buffer; Count: Integer): Longint;
begin
  raise EPowerArcError.Create('Invalid stream operation');
end;

function TPowerArcCompressStream.Seek(Offset: Integer;
  Origin: Word): Longint;
begin
  if (Offset = 0) and (Origin = soFromCurrent) then
    Result := TotalWrited
  else
    raise EPowerArcError.Create('Invalid stream operation');
end;

function TPowerArcCompressStream.Write(const Buffer;
  Count: Integer): Longint;
var Ret: Boolean;
    ActualWrite: DWORD;
    P: PChar;
begin
  if ArcIdx = iPowerBZIP then
    Result:=BZCompressionStream.Write(Buffer,Count)
  else if Count > 0 then begin
    if Thread = nil then begin
      CreatePipe(hReadPipe,hWritePipe,nil,PipeSize);
      Thread:=TCompressThread.Create(True);
      TCompressThread(Thread).CompressStream:=Self;
      TCompressThread(Thread).Done:=False;
      Thread.FreeOnTerminate:=False;
      Thread.Resume;
    end;
    //Windows.WriteFile(hWritePipe,Buffer,Count,DWORD(Result),nil);
    Result:=0;
    P:=PChar(@Buffer);
    while Count > 0 do begin
      Ret:=Windows.WriteFile(hWritePipe,P^,Count,ActualWrite,nil);
      if not Ret or (Ret and (ActualWrite = 0)) then begin
        if Result = 0 then Result:=-1;
        Break;
      end;
      Dec(Count,ActualWrite);
      Inc(Result,ActualWrite);
      Inc(P,ActualWrite);
      Sleep(0);
    end;
  end else
    Result:=0;
  if Result > 0 then begin
    Inc(TotalWrited,Result);
    if ArcIdx <> iPowerBZIP then
      DoProgress(TotalWrited);
  end;
end;

{ TDecompressThread }

type
  TDecompressThread = class(TThread)
  private
    Done: Boolean;
    DecompressStream: TPowerArcDecompressStream;
  protected
    procedure Execute; override;
  end;

{ TDecompressThread }

function ReadDecompressFunc(Data: Pointer; var Buffer; Size: integer): integer; stdcall;
begin
  Result:=TPowerArcDecompressStream(Data).Base.Read(Buffer,Size);
end;

function WriteDecompressFunc(Data: Pointer; const Buffer; Size: integer): integer; stdcall;
begin
  if not Windows.WriteFile(TPowerArcDecompressStream(Data).hWritePipe,Buffer,Size,DWORD(Result),nil) then
    Result:=-1;
end;

procedure TDecompressThread.Execute;
begin
  try
   PowerArcModules[DecompressStream.ArcIdx].Decompress(DecompressStream,
     ReadDecompressFunc,WriteDecompressFunc);
  except
  end;
  CloseHandle(DecompressStream.hWritePipe);
  Done:=True;
end;

{ TPowerArcDecompressStream }

constructor TPowerArcDecompressStream.Create(BaseStream: TStream);
var ModuleID: packed array[0..7] of Char;
    j: integer;
begin
  inherited Create;
  Base:=BaseStream;
  Thread:=nil;
  FOnProgress:=nil;
  TotalReaded:=0;
  if Base.Read(ModuleID[0],8) = 8 then
    for j:=0 to Length(PowerArcModules)-1 do
      if PowerArcModules[j].Info^.ModuleID = ModuleID then begin
        if j = iPowerBZIP then begin
          BZDecompressionStream:=TBZDecompressionStream.Create(Base);
          BZDecompressionStream.OnProgress:=DoProgress;
        end else
          BZDecompressionStream:=nil;
        ArcIdx:=j;
        Exit;
      end;
  raise EPowerArcError.Create('Invalid acrhive index');
end;

destructor TPowerArcDecompressStream.Destroy;
begin
  if Thread <> nil then begin
    CloseHandle(hReadPipe);
    while not TDecompressThread(Thread).Done do Sleep(0);
    Thread.Free;
  end;
  if BZDecompressionStream <> nil then
    BZDecompressionStream.Free;
  inherited;
end;

procedure TPowerArcDecompressStream.DoProgress(Current: integer);
begin
  if Assigned(FOnProgress) then FOnProgress(Current);
end;

function TPowerArcDecompressStream.Read(var Buffer;
  Count: Integer): Longint;
var Ret: Boolean;
    ActualRead: DWORD;
    P: PChar;
begin
  if ArcIdx = iPowerBZIP then
    Result:=BZDecompressionStream.Read(Buffer,Count)
  else if Count > 0 then begin
    if Thread = nil then begin
      CreatePipe(hReadPipe,hWritePipe,nil,PipeSize);
      Thread:=TDecompressThread.Create(True);
      TDecompressThread(Thread).DecompressStream:=Self;
      TDecompressThread(Thread).Done:=False;
      Thread.FreeOnTerminate:=False;
      Thread.Resume;
    end;
    Result:=0;
    P:=PChar(@Buffer);
    while Count > 0 do begin
      Ret:=Windows.ReadFile(hReadPipe,P^,Count,ActualRead,nil);
      if not Ret or (Ret and (ActualRead = 0)) then begin
        if Result = 0 then Result:=-1;
        Break;
      end;
      Dec(Count,ActualRead);
      Inc(Result,ActualRead);
      Inc(P,ActualRead);
      Sleep(0);
    end;
  end else
    Result:=0;
  if Result > 0 then begin
    Inc(TotalReaded,Result);
    if ArcIdx <> iPowerBZIP then
      DoProgress(TotalReaded);
  end;
end;

function TPowerArcDecompressStream.Seek(Offset: Integer;
  Origin: Word): Longint;
begin
  if (Offset = 0) and (Origin = soFromCurrent) then
    Result := TotalReaded
  else
    raise EPowerArcError.Create('Invalid stream operation');
end;

function TPowerArcDecompressStream.Write(const Buffer;
  Count: Integer): Longint;
begin
  raise EPowerArcError.Create('Invalid stream operation');
end;

// register default compression engine
procedure RegisterBZIP;
var POpt: PChar;
begin
  SetLength(PowerArcModules,1);
  with PowerArcModules[iPowerBZIP] do begin
    Name:='';
    hLib:=0;
    Info:=BZGetPowerArcModuleInfo;
    Options:=TStringList.Create;
    POpt:=Info^.Options;
    while POpt^ <> #0 do begin
      Options.Add(POpt);
      POpt:=POpt+StrLen(POpt)+1;
    end;
    SetOptions:=nil;
    Compress:=nil;
    CompressMem:=nil;
    Decompress:=nil;
  end;
end;

{ TCallbackObj }

initialization
  RegisterBZIP;
  iPowerRANK:=PowerArcRegisterModule('PowerRANK.dll');
  iPowerZIP:=PowerArcRegisterModule('PowerZIP.dll');
  iPowerPPM:=PowerArcRegisterModule('PowerPPM.dll');
finalization
  PowerArcUnregisterModules;
end.

{*******************************************************}
{                                                       }
{     BZIP2 1.0 Data Compression Interface Unit         }
{                                                       }
{*******************************************************}

unit bzLib;

interface

uses SysUtils, Classes, PowerAcrModuleInfo;

type
  TAlloc = function(opaque: Pointer; Items, Size: Integer): Pointer; cdecl;
  TFree = procedure(opaque, Block: Pointer); cdecl;

  // Internal structure.  Ignore.
  TBZStreamRec = packed record
    next_in: PChar; // next input byte
    avail_in: longword; // number of bytes available at next_in
    total_in: int64; // total nb of input bytes read so far

    next_out: PChar; // next output byte should be put here
    avail_out: longword; // remaining free space at next_out
    total_out: int64; // total nb of bytes output so far

    state: Pointer;

    bzalloc: TAlloc; // used to allocate the internal state
    bzfree: TFree; // used to free the internal state
    opaque: Pointer;
  end;

  TProgressEvent = procedure (Current: integer) of object;
  // Abstract ancestor class
  TCustomBZip2Stream = class(TStream)
  private
    FStrm: TStream;
    FStrmPos: Integer;
    FOnProgress: TProgressEvent;
    FBZRec: TBZStreamRec;
    FBuffer: array[Word] of Char;
  protected
    procedure Progress(Sender: TObject); dynamic;
  public
    constructor Create(Strm: TStream);
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
  end;

  TBZCompressionStream = class(TCustomBZip2Stream)
  public
    constructor Create(Dest: TStream);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    property OnProgress;
  end;

  TBZDecompressionStream = class(TCustomBZip2Stream)
  public
    constructor Create(Source: TStream);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    property OnProgress;
  end;

{ CompressBuf compresses data, buffer to buffer, in one call.
   In: InBuf = ptr to compressed data
       InBytes = number of bytes in InBuf
  Out: OutBuf = ptr to newly allocated buffer containing decompressed data
       OutBytes = number of bytes in OutBuf   }
procedure BZCompressBuf(const InBuf: Pointer; InBytes: Integer;
  out OutBuf: Pointer; out OutBytes: Integer);


{ DecompressBuf decompresses data, buffer to buffer, in one call.
   In: InBuf = ptr to compressed data
       InBytes = number of bytes in InBuf
       OutEstimate = zero, or est. size of the decompressed data
  Out: OutBuf = ptr to newly allocated buffer containing decompressed data
       OutBytes = number of bytes in OutBuf   }
procedure BZDecompressBuf(const InBuf: Pointer; InBytes: Integer;
  OutEstimate: Integer; out OutBuf: Pointer; out OutBytes: Integer);

procedure BZCompress(const Buffer; Size: integer; OutStream: TStream; ProgressCallback: TProgressEvent = nil); overload;
procedure BZCompress(InStream,OutStream: TStream; ProgressCallback: TProgressEvent = nil); overload;
procedure BZDecompress(InStream,OutStream: TStream; ProgressCallback: TProgressEvent = nil);


type
  EBZip2Error = class(Exception);
  EBZCompressionError = class(EBZip2Error);
  EBZDecompressionError = class(EBZip2Error);

// -------------------------- PowerArc specific --------------------------------

function BZGetPowerArcModuleInfo: PPowerArcModuleInfo;

implementation

{$L blocksort.obj}
{$L huffman.obj}
{$L compress.obj}
{$L decompress.obj}
{$L bzlib2.obj}
{$L crctable.obj}
{$L randtable.obj}

procedure _BZ2_hbMakeCodeLengths; external;
procedure _BZ2_blockSort; external;
procedure _BZ2_hbCreateDecodeTables; external;
procedure _BZ2_hbAssignCodes; external;
procedure _BZ2_compressBlock; external;
procedure _BZ2_decompress; external;

const
  BZ_RUN = 0;
  BZ_FLUSH = 1;
  BZ_FINISH = 2;
  BZ_OK = 0;
  BZ_RUN_OK = 1;
  BZ_FLUSH_OK = 2;
  BZ_FINISH_OK = 3;
  BZ_STREAM_END = 4;
  BZ_SEQUENCE_ERROR = (-1);
  BZ_PARAM_ERROR = (-2);
  BZ_MEM_ERROR = (-3);
  BZ_DATA_ERROR = (-4);
  BZ_DATA_ERROR_MAGIC = (-5);
  BZ_IO_ERROR = (-6);
  BZ_UNEXPECTED_EOF = (-7);
  BZ_OUTBUFF_FULL = (-8);

  BZ_LEVEL = 9;

procedure _bz_internal_error(errcode: Integer); cdecl;
begin
  raise EBZip2Error.CreateFmt('Compression Error %d', [errcode]);
end;

function _malloc(size: Integer): Pointer; cdecl;
begin
  GetMem(Result, Size);
end;

procedure _free(block: Pointer); cdecl;
begin
  FreeMem(block);
end;

// deflate compresses data

function BZ2_bzCompressInit(var strm: TBZStreamRec; BlockSize: Integer;
  verbosity: Integer; workFactor: Integer): Integer; stdcall; external;

function BZ2_bzCompress(var strm: TBZStreamRec; action: Integer): Integer; stdcall; external;

function BZ2_bzCompressEnd(var strm: TBZStreamRec): Integer; stdcall; external;

function BZ2_bzBuffToBuffCompress(dest: Pointer; var destLen: Integer; source: Pointer;
  sourceLen, BlockSize, verbosity, workFactor: Integer): Integer; stdcall; external;

// inflate decompresses data

function BZ2_bzDecompressInit(var strm: TBZStreamRec; verbosity: Integer;
  small: Integer): Integer; stdcall; external;

function BZ2_bzDecompress(var strm: TBZStreamRec): Integer; stdcall; external;

function BZ2_bzDecompressEnd(var strm: TBZStreamRec): Integer; stdcall; external;

function BZ2_bzBuffToBuffDecompress(dest: Pointer; var destLen: Integer; source: Pointer;
  sourceLen, small, verbosity: Integer): Integer; stdcall; external;


function bzip2AllocMem(AppData: Pointer; Items, Size: Integer): Pointer; cdecl;
begin
  GetMem(Result, Items * Size);
end;

procedure bzip2FreeMem(AppData, Block: Pointer); cdecl;
begin
  FreeMem(Block);
end;

function CCheck(code: Integer): Integer;
begin
  Result := code;
  if code < 0 then
    raise EBZCompressionError.CreateFmt('error %d', [code]); //!!
end;

function DCheck(code: Integer): Integer;
begin
  Result := code;
  if code < 0 then
    raise EBZDecompressionError.CreateFmt('error %d', [code]); //!!
end;


procedure BZCompressBuf(const InBuf: Pointer; InBytes: Integer;
  out OutBuf: Pointer; out OutBytes: Integer);
var
  strm: TBZStreamRec;
  P: Pointer;
begin
  FillChar(strm, sizeof(strm), 0);
  strm.bzalloc := bzip2AllocMem;
  strm.bzfree := bzip2FreeMem;
  OutBytes := ((InBytes + (InBytes div 10) + 12) + 255) and not 255;
  GetMem(OutBuf, OutBytes);
  try
    strm.next_in := InBuf;
    strm.avail_in := InBytes;
    strm.next_out := OutBuf;
    strm.avail_out := OutBytes;
    CCheck(BZ2_bzCompressInit(strm, BZ_LEVEL, 0, 0));
    try
      while CCheck(BZ2_bzCompress(strm, BZ_FINISH)) <> BZ_STREAM_END do
      begin
        P := OutBuf;
        Inc(OutBytes, 256);
        ReallocMem(OutBuf, OutBytes);
        strm.next_out := PChar(Integer(OutBuf) + (Integer(strm.next_out) - Integer(P)));
        strm.avail_out := 256;
      end;
    finally
      CCheck(BZ2_bzCompressEnd(strm));
    end;
    ReallocMem(OutBuf, strm.total_out);
    OutBytes := strm.total_out;
  except
    FreeMem(OutBuf);
    raise
  end;
end;


procedure BZDecompressBuf(const InBuf: Pointer; InBytes: Integer;
  OutEstimate: Integer; out OutBuf: Pointer; out OutBytes: Integer);
var
  strm: TBZStreamRec;
  P: Pointer;
  BufInc: Integer;
begin
  FillChar(strm, sizeof(strm), 0);
  strm.bzalloc := bzip2AllocMem;
  strm.bzfree := bzip2FreeMem;
  BufInc := (InBytes + 255) and not 255;
  if OutEstimate = 0 then
    OutBytes := BufInc
  else
    OutBytes := OutEstimate;
  GetMem(OutBuf, OutBytes);
  try
    strm.next_in := InBuf;
    strm.avail_in := InBytes;
    strm.next_out := OutBuf;
    strm.avail_out := OutBytes;
    DCheck(BZ2_bzDecompressInit(strm, 0, 0));
    try
      while DCheck(BZ2_bzDecompress(strm)) <> BZ_STREAM_END do
      begin
        P := OutBuf;
        Inc(OutBytes, BufInc);
        ReallocMem(OutBuf, OutBytes);
        strm.next_out := PChar(Integer(OutBuf) + (Integer(strm.next_out) - Integer(P)));
        strm.avail_out := BufInc;
      end;
    finally
      DCheck(BZ2_bzDecompressEnd(strm));
    end;
    ReallocMem(OutBuf, strm.total_out);
    OutBytes := strm.total_out;
  except
    FreeMem(OutBuf);
    raise
  end;
end;

// TCustomBZip2Stream

constructor TCustomBZip2Stream.Create(Strm: TStream);
begin
  inherited Create;
  FStrm := Strm;
  FStrmPos := Strm.Position;
  FBZRec.bzalloc := bzip2AllocMem;
  FBZRec.bzfree := bzip2FreeMem;
end;

procedure TCustomBZip2Stream.Progress(Sender: TObject);
begin
  if Assigned(FOnProgress) then FOnProgress(Position);
end;

// TBZCompressionStream

constructor TBZCompressionStream.Create(Dest: TStream);
begin
  inherited Create(Dest);
  FBZRec.next_out := FBuffer;
  FBZRec.avail_out := sizeof(FBuffer);
  CCheck(BZ2_bzCompressInit(FBZRec, BZ_LEVEL, 0, 0));
end;

destructor TBZCompressionStream.Destroy;
begin
  FBZRec.next_in := nil;
  FBZRec.avail_in := 0;
  try
    if FStrm.Position <> FStrmPos then FStrm.Position := FStrmPos;
    while (CCheck(BZ2_bzCompress(FBZRec, BZ_FINISH)) <> BZ_STREAM_END)
      and (FBZRec.avail_out = 0) do
    begin
      FStrm.WriteBuffer(FBuffer, sizeof(FBuffer));
      FBZRec.next_out := FBuffer;
      FBZRec.avail_out := sizeof(FBuffer);
    end;
    if FBZRec.avail_out < sizeof(FBuffer) then
      FStrm.WriteBuffer(FBuffer, sizeof(FBuffer) - FBZRec.avail_out);
  finally
    BZ2_bzCompressEnd(FBZRec);
  end;
  inherited Destroy;
end;

function TBZCompressionStream.Read(var Buffer; Count: Longint): Longint;
begin
  raise EBZCompressionError.Create('Invalid stream operation');
end;

function TBZCompressionStream.Write(const Buffer; Count: Longint): Longint;
begin
  FBZRec.next_in := @Buffer;
  FBZRec.avail_in := Count;
  if FStrm.Position <> FStrmPos then FStrm.Position := FStrmPos;
  while (FBZRec.avail_in > 0) do
  begin
    CCheck(BZ2_bzCompress(FBZRec, BZ_RUN));
    if FBZRec.avail_out = 0 then
    begin
      FStrm.WriteBuffer(FBuffer, sizeof(FBuffer));
      FBZRec.next_out := FBuffer;
      FBZRec.avail_out := sizeof(FBuffer);
      FStrmPos := FStrm.Position;
    end;
    Progress(Self);
  end;
  Result := Count;
end;

function TBZCompressionStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  if (Offset = 0) and (Origin = soFromCurrent) then
    Result := FBZRec.total_in
  else
    raise EBZCompressionError.Create('Invalid stream operation');
end;

// TDecompressionStream

constructor TBZDecompressionStream.Create(Source: TStream);
begin
  inherited Create(Source);
  FBZRec.next_in := FBuffer;
  FBZRec.avail_in := 0;
  DCheck(BZ2_bzDecompressInit(FBZRec, 0, 0));
end;

destructor TBZDecompressionStream.Destroy;
begin
  BZ2_bzDecompressEnd(FBZRec);
  inherited Destroy;
end;

function TBZDecompressionStream.Read(var Buffer; Count: Longint): Longint;
begin
  FBZRec.next_out := @Buffer;
  FBZRec.avail_out := Count;
  if FStrm.Position <> FStrmPos then FStrm.Position := FStrmPos;
  while (FBZRec.avail_out > 0) do
  begin
    if FBZRec.avail_in = 0 then
    begin
      FBZRec.avail_in := FStrm.Read(FBuffer, sizeof(FBuffer));
      if FBZRec.avail_in = 0 then
      begin
        Result := Count - FBZRec.avail_out;
        Exit;
      end;
      FBZRec.next_in := FBuffer;
      FStrmPos := FStrm.Position;
    end;
    CCheck(BZ2_bzDecompress(FBZRec));
    Progress(Self);
  end;
  Result := Count;
end;

function TBZDecompressionStream.Write(const Buffer; Count: Longint): Longint;
begin
  raise EBZDecompressionError.Create('Invalid stream operation');
end;

function TBZDecompressionStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  if (Offset >= 0) and (Origin = soFromCurrent) then
    Result := FBZRec.total_out
  else
    raise EBZDecompressionError.Create('Invalid stream operation');

end;

procedure CopyStream(Src,Dst: TStream);
const BufSize = 4096;
var   Buf: array[0..BufSize-1] of byte;
      readed: integer;
begin
  if (Src <> nil) and (Dst <> nil) then begin
    readed:=Src.Read(Buf[0],BufSize);
    while readed > 0 do begin
      Dst.Write(Buf[0],readed);
      readed:=Src.Read(Buf[0],BufSize);
    end;
  end;
end;

procedure BZCompress(InStream,OutStream: TStream; ProgressCallback: TProgressEvent);
var CompressionStream: TBZCompressionStream;
begin
  CompressionStream:=TBZCompressionStream.Create(OutStream);
  try
    CompressionStream.OnProgress:=ProgressCallback;
    CopyStream(InStream,CompressionStream);
  finally
    CompressionStream.Free;
  end;
end;

procedure BZDecompress(InStream,OutStream: TStream; ProgressCallback: TProgressEvent);
var DecompressionStream: TBZDecompressionStream;
begin
  DecompressionStream:=TBZDecompressionStream.Create(InStream);
  try
    DecompressionStream.OnProgress:=ProgressCallback;
    CopyStream(DecompressionStream,OutStream);
  finally
    DecompressionStream.Free;
  end;
end;

procedure BZCompress(const Buffer; Size: integer; OutStream: TStream; ProgressCallback: TProgressEvent);
var CompressionStream: TBZCompressionStream;
begin
  CompressionStream:=TBZCompressionStream.Create(OutStream);
  try
    CompressionStream.OnProgress:=ProgressCallback;
    CompressionStream.Write(Buffer,Size);
  finally
    CompressionStream.Free;
  end;
end;

// -------------------------- PowerArc specific --------------------------------

const
  BZIPModuleInfo: TPowerArcModuleInfo = (
    Signature:   PowerArcModuleSignature;
    Name:        'BZIP';
    Description: 'BWT Compression engine'+#13#10+
                 'Copyright (c) 2000,2001 SoftLab MIL-TEC Ltd'+#13#10+
                 'http://www.softcomplete.com';
    Options:     #0#0;
    DefaultBPC:  209;
    MaxBPC:      209;
    ModuleID:    'NFKDEMO-';
  );

function BZGetPowerArcModuleInfo: PPowerArcModuleInfo;
begin
  Result:=@BZIPModuleInfo;
end;

end.


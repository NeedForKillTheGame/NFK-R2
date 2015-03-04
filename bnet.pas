unit BNet;
interface

{------------------------------------------------------------------------
Component name: TUDPdemon (Class of TNMUDP, Supplied with Delphi 5).
Created by: 3d[Power]
URL: http://www.3dpower.org
email: haz-3dpower@mail.ru
Version: 1.0

DISCLAIMER
UDPdemon is a mod of component called Black UDP. But it is was
changed at all.

Features:

- flag ttCompressed was removed, cuz UDPdemon manage compression
  automatically. It always find the right decision about compression.
  Now you dont care of it at all.

- Guaranteed packets algorithms was totally rewrited. Now, they
  REALLY work.

- Bug, with two (or more) same packets was solved.

- Size of normal, non guaranteed packets was decreased by 2 bytes.


 ------------------------------------------------------------------------
                         Black UDP Version 1.4
                         Written by Lifepower
                        (kkmaster74@hotmail.com)
 ------------------------------------------------------------------------

                     *** DISCLAIMER OF WARRANTY ***
 The author disclaims all warranties relating to this product,
whenever expressed or implied, including without any limitation,
any implied warranties of merchantability or fitness for a particular
purpose.

 The author will not be liable for any special, incidental, consequential,
indirect or similar damages due to loss of data, damage of hardware or
any other reason, even if the author was advised of the possibility of
such loss or damage.

 In other words, if any program using this unit or this unit itself will
damage or destroy your network, harm your computer and so on - I WILL NOT
BE RESPONSIBLE!
 ------------------------------------------------------------------------
 You can use this library in any freely distributed software (freeware).
However if you want to use the library in commercial software - e-mail the
author for the permission first.
 ------------------------------------------------------------------------
 This unit requires the following units:
  NetHandle   -  Pointer-operations. Supplied with Tudpdemon
  ZLib        -  Compression/Decompression. Supplied with Borland Delphi
  ZInterface  -  Add-ons for ZLib. Supplied with TUDPdemon
  NmUDP       -  UDP Protocol. Supplied with Borland Delphi 4, 5

 The libraries which are supposed to be supplied with Borland Delphi may
not exist on you system. Read the documentation on how and where you can
get them.
 ------------------------------------------------------------------------
 For further information read BNet.html file.
}
uses SYSUtils, Classes, ExtCtrls, NmUDP, WinSock, ZLib, ZInterface, CRC32, Windows;

{ constants to be used with SendData procedure }
const ttGuaranteed = $0001;// confirmation will be required for that data

type CallProc = procedure of Object; // may be changed later
     NetProc = procedure(IP:ShortString;Port:Integer) of Object;

     PWRDataRec = record
                Active          : boolean;
                ResendCount     : Byte;
                Size, UniqueID  : Integer;
                Data            : Pointer;
                DestIP          : ShortString;
                DestPort        : Integer;
                TimeOut         : Integer;
     end;

     NoDpRec = record
                TimeOut : integer;
                CRC32 : cardinal;
                end;

     TUDPdemon = class(TNMUDP)
                  private
                 { Private declarations }
                   ResendBuffer:Array[0..1023] of PWRDataRec;
                   NoDpBuffer:Array[0..1023] of NoDpRec;
                   WriteBuf:Array[0..16393] of Char;
                   ReadBuf:Array[0..16383] of Char;
                   OutBuf:Array[0..16383] of Char;

                   ReadIP:ShortString;
                   ReadPort:Integer;
                   ReadSize:Integer;
                   UserReadSize:Integer;

                   FReceive:TNotifyEvent;

                   Timer:TTimer;
                   FActive:Boolean;

                   CustomID:Cardinal;

                   ResendTime:Integer;
                   ResendMax:Integer;
                   ReceivedBytes,
                   SentBytes:Integer;
                   BReceivedBytes,
                   BSentBytes:Integer;
                   BNextBandWidth : cardinal;
                   FBandWidthIN,FBandWidthOUT:Integer;
                   BitsPerSec:Integer;
                   OldSentBytes,
                   OldReceivedBytes:Integer;
                   LoadCycle:Integer;

                   procedure RemoveSlotByID(ID:Word);
                   procedure SendConfirm;

                   procedure CustomSendData(Var Data;Size,TransType:Integer;DestIP:ShortString;DestPort:Integer);

                   procedure AddToNoDpBuffer(CRC32:cardinal);
                   function PWR_ADDtoBuffer(Var Data;Size,ID:Integer;DestIP:ShortString;DestPort:word):boolean;
                   function FindUniqueID:Word;
                   function  IsInNoDpBuffer (CRC32:cardinal):boolean;
                   procedure TimerCall(Sender:TObject);
                   procedure SetActive(Value:Boolean);
                  protected
                 { Protected declarations }
                   procedure DataReceived(Sender:TComponent;NumberBytes:Integer;FromIP:String;Port:Integer);
                   procedure Update;
                  public
                 { Public declarations }
                   property ReceiveSize:Integer read UserReadSize;
                   property ResendTimes:Integer read ResendMax write ResendMax;
                   property ResendFreq:Integer read ResendTime write ResendTime;
                   property BytesReceived:Integer read ReceivedBytes;
                   property BytesSent:Integer read SentBytes;
                   property Bandwidth:Integer read BitsPerSec;
                   property BandwidthIN:Integer read FBandWidthIN;
                   property BandwidthOUT:Integer read FBandWidthOUT;
                   property Active:Boolean read FActive write SetActive;

                   constructor Create;reintroduce;
                   destructor Destroy;override;

                   procedure SendData(TransType:Integer;Var Data;Size:Integer;DestIP:ShortString;DestPort:Integer);
                   procedure ReadData(Var Data;out FromIP:ShortString;out FromPort:Integer);

                   procedure CleanUp;
                   function ResendSlotsCount:word;

                   function LocalIP:String;
                  published
                 { Published declarations }
                   property onReceive:TNotifyEvent read FReceive write FReceive;
                 end;

implementation
Uses NetHandle, unit1;

const tsStandby = $00000000;
      tsConfirm = $00000001;

      netGuaranteed = $B701;
      netNormal     = $B700;
      netConfirm    = $C701;

constructor TUDPdemon.Create;
Var I:Integer;
begin
// listenpo
// self.RemotePort := BNET_GAMEPORT;
// self.LocalPort := BNET_GAMEPORT;

 inherited Create(nil);
 for I:=0 to 1023 do
  With ResendBuffer[I] do
   begin
    Active := false;
    Size :=0;
    Data :=nil;
    DestIP := '127.0.0.1';
    DestPort :=0;
    TimeOut :=0;
    UniqueID := 0;
    ResendCount := 0;
   end;

//   self.RemotePort := BNET_GAMEPORT;
//   self.LocalPort := BNET_GAMEPORT;

 OnDataReceived := DataReceived;
 CustomID:=0;
 ResendTimes:=8;
 ResendFreq:=300;
 ReceivedBytes:=0;
 SentBytes:=0;
 BReceivedBytes:=0;
 BSentBytes:=0;
 OldSentBytes:=0;
 OldReceivedBytes:=0;
 randomize;
// fillchar(ResendBuffer,sizeof(ResendBuffer),0);
 LoadCycle:=0;
 Timer:=TTimer.Create(Self);
 Timer.Interval:=67;
 Timer.Enabled:=False;
 Timer.OnTimer:=TimerCall;
end;

destructor TUDPdemon.Destroy;
Var I:Integer;
begin
 for I:=0 to high(resendbuffer) do
  if resendbuffer[I].Data<>nil then
   FreeMem(resendbuffer[I].Data);
 inherited;
end;

function TUDPdemon.FindUniqueID:Word;
var i,loops : word;
    found:boolean;

begin
        Result:= Random($FFFF);
        repeat
        Found := false;
        loops := 0;
        for i := 0 to high(ResendBuffer) do begin
                inc(loops);
                if (ResendBuffer[i].Active = true) then // BUG IS HERE.
                        if ResendBuffer[i].UniqueID = Result then Found := true;

                if loops=300 then begin
                        found:=true;
                        result:=0;
                        exit;
                        end;
                end;
        until found=false;
end;

procedure TUDPdemon.RemoveSlotByID(ID:Word);
var i : word;
begin
        for i := 0 to high(ResendBuffer) do
        if (ResendBuffer[i].UniqueID = ID) then
        if (ResendBuffer[i].Active) then begin
//                if ResendBuffer[i].data<>nil then
                FreeMem(ResendBuffer[i].Data, ResendBuffer[i].Size);//, ResendBuffer[i].Size);
                ResendBuffer[i].Active := false;
                ResendBuffer[i].UniqueID := 0;
                ResendBuffer[i].Size := 0;
                ResendBuffer[i].Active := false;
                ResendBuffer[i].DestIP := '127.0.0.1';
                ResendBuffer[i].DestPort := 0;
                ResendBuffer[i].TimeOut := 0;
//                addmessage('^2slot '+inttostr(i)+' removed');
                exit;
        end;
end;

procedure TUDPdemon.CustomSendData(Var Data;Size,TransType:integer;DestIP:ShortString;DestPort:Integer);
Var Write:Pointer;
    SendSize,CSize:Integer;
    ID : Word;
begin
 Write:=@WriteBuf;
 SendSize:=0;

 if TransType and ttGuaranteed=ttGuaranteed then begin
        ID := FindUniqueID;
        if ID <> 0 then begin
                AddWord(Write, netGuaranteed);
                AddWord(Write, ID);
                SendSize:=4;
        end;
 end;

 // Compression auto adjust | 3d[Power]
 CompressArray(Data,Pointer(Integer(Write)+2)^,Size,CSize);
 if size > csize then begin
        AddWord(Write, CSize);
        Write:=Pointer(Integer(Write)+CSize);
        SendSize:=SendSize+2+CSize;
  end else begin
        AddWord(Write,$C000);
        Move(Data,Write^,Size);
        SendSize:=SendSize+Size+2;
 end;

 RemoteHost := DestIP;
 RemotePort := DestPort;
// LocalPort := DestPort;

 if TransType and ttGuaranteed=ttGuaranteed then if ID<>0 then
         PWR_AddToBuffer (WriteBuf, SendSize, ID, DestIP, DestPort);

// addmessage('^6UDPdemon: send to :'+RemoteHost+':'+inttostr(RemotePort));

 SendBuffer(WriteBuf, SendSize);
 Inc(SentBytes, SendSize);
 Inc(BSentBytes, SendSize);
end;

function TUDPdemon.PWR_ADDtoBuffer(Var Data;Size, ID:Integer;DestIP:ShortString;DestPort:word):boolean;
var i : word;
begin
        for i := 0 to high(ResendBuffer) do
        if ResendBuffer[i].Active = false then begin // this is free slot;
                GetMem(ResendBuffer[i].Data, Size);
                move(data, ResendBuffer[i].Data^, size);
                ResendBuffer[i].Active := true;
                ResendBuffer[i].ResendCount := ResendMax;
                ResendBuffer[i].UniqueID := ID;
                ResendBuffer[i].Size := Size;
                ResendBuffer[i].DestIP := DestIP;
                ResendBuffer[i].TimeOut := GetTickCount + ResendTime;
//                addmessage('^2slot '+inttostr(i)+' assigned');
                exit;
        end;
end;

procedure TUDPdemon.SendData(TransType:Integer;Var Data;Size:Integer;DestIP:ShortString;DestPort:Integer);
begin
 if not Active then Exit;// data is not sent when not active
 CustomSendData(Data,Size,TransType,DestIP,DestPort);
end;

procedure TUDPdemon.SendConfirm;
Var Read,Write: Pointer;
    Num       : Cardinal;
begin
 Read:=@ReadBuf;
 Write:=@WriteBuf;
 Inc(Integer(Read),2);
 Num:=ReadWord(Read);
 AddWord(Write,netConfirm);
 AddWord(Write,Num);
 RemoteHost:=ReadIP;
 RemotePort:=ReadPort;
 SendBuffer(WriteBuf,4);
 Inc(SentBytes,4);
 Inc(BSentBytes, 4);
end;

// 3d[Power]: prevent double packets.
procedure TUDPdemon.AddToNoDpBuffer(CRC32:cardinal);
var i : word;
    tick :cardinal;
begin
        tick := gettickcount;
        for i := 0 to high(NoDpBuffer) do
        if NoDpBuffer[i].TimeOut < tick then begin
                NoDpBuffer[i].TimeOut := tick + ResendTime * ResendMax + ResendTime;
                NoDpBuffer[i].CRC32 := CRC32;
                exit;
                end;
end;

function TUDPdemon.IsInNoDpBuffer(CRC32:cardinal) : boolean;
var i : word;
    tick :cardinal;
begin
        result:=false;
        tick := gettickcount;
        for i := 0 to high(NoDpBuffer) do
        if (NoDpBuffer[i].TimeOut >= tick) and (NoDpBuffer[i].CRC32 = CRC32) then begin
                NoDpBuffer[i].TimeOut := tick + ResendTime * ResendMax + ResendTime;
                result := true;
                exit;
                end;
end;

procedure TUDPdemon.DataReceived(Sender:TComponent;NumberBytes:Integer;FromIP:String;Port:Integer);
Var T:Integer;
    ID:Cardinal;
    Compressed:Integer;
    Read:Pointer;
    CRC:Cardinal;
begin
 if not Active then Exit;// ignoring data if not active

 if NumberBytes>16384 then
  raise Exception.Create('TUDPdemon: Too many bytes to receive');
 ReadBuffer(ReadBuf,ReadSize);
 Inc(ReceivedBytes,ReadSize);
 Inc(BReceivedBytes,ReadSize);
 UserReadSize:=ReadSize-2;
 if UserReadSize<=0 then Exit; // wrong data

 ReadIP := FromIP;
 ReadPort := Port;

 Read := @ReadBuf;
 T:=ReadWord(Read);
 if (T=netGuaranteed) then // this is a guaranteed, confirming.
  begin
   ID := ReadWord(Read); // ID;
   CRC := CRC32INIT;
   CRC := CalculateBufferCRC32( CRC, ReadBuf, ReadSize);
   CRC := CRC xor CRC32INIT;

//   addmessage('packet CRC:'+inttostr(CRC));

// if random(2)>0 then
   SendConfirm;
//    else exit;

   If IsInNoDpBuffer (CRC) then begin
//        addmessage('^2IsInNoDpBuffer: rejected');
        exit end else begin
//        addmessage('^2IsInNoDpBuffer: accepted');
        AddToNoDpBuffer (CRC);
        end;

//   Dec(UserReadSize,4);
//   Inc(Integer(Read),4);
  end else

 if T=netConfirm then
  begin
   ID:=ReadWord(Read);
   RemoveSlotByID(ID);
//   addmessage('^2confirmed');
   Exit;
  end else begin // normal...
   inc(UserReadSize,2);
   dec(Integer(Read),2);
   end;

//  else dec(Integer(Read),2);

 Compressed:=ReadWord(Read);
 Dec(UserReadSize,2);
 if Compressed and $C000<>$C000 then
  begin
   DecompressArray(Read^,OutBuf,Compressed,UserReadSize);
  end else
   Move(Read^,OutBuf,UserReadSize);

 if Assigned(FReceive) then FReceive(Sender);
end;

procedure TUDPdemon.ReadData(Var Data;out FromIP:ShortString;out FromPort:Integer);
begin
 FromIP   := ReadIP;
 FromPort := ReadPort;
 Move(OutBuf, Data, UserReadSize);
end;

procedure TUDPdemon.Update;
Var i,Slot:Integer;
    tick : integer;
begin
 tick := GetTickCount;

 // bandwidth
 if BNextBandWidth < tick then begin
        BNextBandWidth := tick+500;
        FBandWidthIN := BReceivedBytes * 2;
        BReceivedBytes := 0;
        FBandWidthOUT := BSentBytes * 2;
        BSentBytes := 0;
        BitsPerSec := (FBandWidthIN + FBandWidthOUT) div 2;
 end;

 // CRITICAL CLEAN UP
 if ResendSlotsCount > 20 then CleanUp else

 for i:=0 to high(resendbuffer) do
 if (resendbuffer[i].Active = true) then begin

        if resendbuffer[i].ResendCount = 0 then begin // kill it.
                RemoveSlotByID(resendbuffer[i].UniqueID);
                exit;
        end;

        if (resendbuffer[i].TimeOut < tick) then begin
                dec(resendbuffer[i].ResendCount);
                resendbuffer[i].TimeOut := tick + ResendTime;

                // send again.
                with resendbuffer[i] do begin
//                      addmessage('ReSending buffer '+inttostr(i));
                        move(Data^, WriteBuf, size);
                        SendBuffer(WriteBuf, Size);
                        Inc(SentBytes, Size);
                        Inc(BSentBytes, Size);
                end;
        end;
 end;

end;

procedure TUDPdemon.CleanUp;
var i : word;
begin
 for I:=0 to high(resendbuffer) do if(resendbuffer[i].active) then begin
  if resendbuffer[I].Data<>nil then
   FreeMem(resendbuffer[I].Data);
   resendbuffer[I].Active := false;
   end;
end;

function TUDPdemon.ResendSlotsCount:word;
var i : word;
begin
        result := 0;
        for I:=0 to high(resendbuffer) do if(resendbuffer[i].active) then
                inc(result);
end;

procedure TUDPdemon.TimerCall(Sender:TObject);
begin
   if Active then Update;
// if Active then addmessage('timer call');
end;

procedure TUDPdemon.SetActive(Value:Boolean);
begin
 FActive:=Value;
 Timer.Enabled:=Active;
end;

function TUDPdemon.LocalIP:String;
type TaPInAddr=array [0..10] of PInAddr;
     PaPInAddr=^TaPInAddr;

var phe:PHostEnt;
    pptr:PaPInAddr;
    Buffer:array [0..63] of char;
    I:Integer;
    GInitData:TWSADATA;
begin
 WSAStartup($101, GInitData);
 Result:='127.0.0.1';
 GetHostName(Buffer, SizeOf(Buffer));
 phe:=GetHostByName(buffer);
 if phe=nil then Exit;
 pptr:=PaPInAddr(Phe^.h_addr_list);
 I:=0;
 While pptr^[I]<>nil do
  begin
   Result:=StrPas(inet_ntoa(pptr^[I]^));
   Inc(I);
  end;
 WSACleanup;
end;


end.

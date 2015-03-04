unit NetHandle;
interface
{------------------------------------------------------------------------
                     Pointer data handler for BNet.Pas
                         Written by Lifepower
                          (arcane@techie.com)
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
 You can use this library in any kind of software, including commercially
distributed software. Since I cannot control who and how uses this unit, I
can't force you do to so, but I ask you to put my name in credits section
if possible.
 ------------------------------------------------------------------------
 For further information read BNet.txt file.
}

procedure AddByte(Var Buffer:Pointer;Value:Byte);
function ReadByte(Var Buffer:Pointer):Byte;
procedure AddWord(Var Buffer:Pointer;Value:Word);
function ReadWord(Var Buffer:Pointer):Word;
procedure AddInt(Var Buffer:Pointer;Value:Integer);
function ReadInt(Var Buffer:Pointer):Integer;
procedure AddCardinal(Var Buffer:Pointer;Value:Cardinal);
function ReadCardinal(Var Buffer:Pointer):Cardinal;
procedure AddSingle(Var Buffer:Pointer;Value:Single);
function ReadSingle(Var Buffer:Pointer):Single;
procedure AddString(Var Buffer:Pointer;Value:ShortString);
function ReadString(Var Buffer:Pointer):ShortString;
implementation

procedure AddByte(Var Buffer:Pointer;Value:Byte);
begin
 Byte(Buffer^):=Value;
 Inc(Integer(Buffer));
end;

function ReadByte(Var Buffer:Pointer):Byte;
begin
 Result:=Byte(Buffer^);
 Inc(Integer(Buffer));
end;

procedure AddWord(Var Buffer:Pointer;Value:Word);
begin
 Word(Buffer^):=Value;
 Inc(Integer(Buffer),2);
end;

function ReadWord(Var Buffer:Pointer):Word;
begin
 Result:=Word(Buffer^);
 Inc(Integer(Buffer),2);
end;

procedure AddInt(Var Buffer:Pointer;Value:Integer);
begin
 Integer(Buffer^):=Value;
 Inc(Integer(Buffer),4);
end;

function ReadInt(Var Buffer:Pointer):Integer;
begin
 Result:=Integer(Buffer^);
 Inc(Integer(Buffer),4);
end;

procedure AddCardinal(Var Buffer:Pointer;Value:Cardinal);
begin
 Cardinal(Buffer^):=Value;
 Inc(Integer(Buffer),4);
end;

function ReadCardinal(Var Buffer:Pointer):Cardinal;
begin
 Result:=Cardinal(Buffer^);
 Inc(Integer(Buffer),4);
end;

procedure AddSingle(Var Buffer:Pointer;Value:Single);
begin
 Single(Buffer^):=Value;
 Inc(Integer(Buffer),4);
end;

function ReadSingle(Var Buffer:Pointer):Single;
begin
 Result:=Single(Buffer^);
 Inc(Integer(Buffer),4);
end;

procedure AddString(Var Buffer:Pointer;Value:ShortString);
begin
 AddByte(Buffer,Byte(Value[0]));
 Move(Value[1],Buffer^,Byte(Value[0]));
 Inc(Integer(Buffer),Byte(Value[0]));
end;

function ReadString(Var Buffer:Pointer):ShortString;
Var Str:ShortString;
begin
 Str[0]:=Char(ReadByte(Buffer));
 Move(Buffer^,Str[1],Byte(Str[0]));
 Inc(Integer(Buffer),Byte(Str[0]));
 Result:=Str;
end;

end.

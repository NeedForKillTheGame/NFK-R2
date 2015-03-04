unit ZInterface;
interface
{------------------------------------------------------------------------
                       ZLib Interfaces for BNet.Pas
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
procedure CompressArray(Var InpArray,OutArray;InpSize:Integer;out OutSize:Integer);
procedure DecompressArray(Var InpArray,OutArray;InpSize:Integer;out OutSize:Integer);
implementation
Uses ZLib;

procedure CompressArray(Var InpArray,OutArray;InpSize:Integer;out OutSize:Integer);
Var OutBuf:Pointer;
begin
 OutBuf:=nil;
 CompressBuf(@InpArray,InpSize,OutBuf,OutSize);
 Move(OutBuf^,OutArray, OutSize);
end;

procedure DecompressArray(Var InpArray,OutArray;InpSize:Integer;out OutSize:Integer);
Var OutBuf:Pointer;
begin
 OutBuf:=nil;
 DecompressBuf(@InpArray,InpSize,0,OutBuf,OutSize);
 Move(OutBuf^,OutArray,OutSize);
end;

end.

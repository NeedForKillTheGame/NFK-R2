// =============================================================================
// Network optimization and speedup module
// Come from Project MOON 2 (c) 3d[Power]
// =============================================================================
unit net_unit;

interface
uses  windows, sysutils, classes, demounit, bnet;

var      QueueBuf : TList;

type TPacketHeader = packed record
         Count : byte;
         Size : byte;
     end;

type PQueue = ^TQueue;
     TQueue = record
         Active : boolean;
         IP : string[15];
         Port : word;
         Data_ : array[0..255] of byte; // dynamic array does not work :\
         Size : word;
         timedout : cardinal;
     end;


// =============================================================================
procedure Network_AddToQueue(var Data; Size: word; IP : shortstring; Port : word);
procedure Network_SendAllQueue;
procedure Network_ParsePackets(IP : shortstring; Port : word);
// =============================================================================
implementation
uses unit1, r2tools;

// =============================================================================
// Send All Queued Tasks. Called once per Frame.
// =============================================================================
procedure Network_SendAllQueue;
var i : word;
        search_ip : string[15];
        search_port : word;
        count, totalsize, highpacket : word;
var     Header : TPacketHeader;
        dat, _dat, __dat : ^byte;
        done : boolean;
        tmparray : array[0..16] of byte;
        sss : string;

const   MAXPACKETSIZE = 250;
begin
        if QueueBuf.Count = 0 then exit;

        while (QueueBuf.Count > 0) do begin
                search_ip   := TQueue( QueueBuf.items[0]^).IP;
                search_port := TQueue( QueueBuf.items[0]^).Port;
                totalsize := 0;
                count := 0;

                // get count of queues, and size
                for i := 0 to QueueBuf.Count - 1 do
                if (TQueue( QueueBuf.items[i]^).IP = search_ip) and (TQueue( QueueBuf.items[i]^).Port = search_port) then begin
                        if totalsize + TQueue(QueueBuf.items[i]^).Size + 1 > MAXPACKETSIZE then break;
                        inc(count);
                        inc(totalsize, TQueue(QueueBuf.items[i]^).Size + 1);
                        highpacket := i; // highest packet number
                end;

                if totalsize > MAXPACKETSIZE then AddMessage('WARNING: network queued size too big');

                // combine packets. write header
                Header.Count := count; // number of packets
                Header.Size := sizeof(header) + totalsize;  // total packet size.
                Getmem(dat, Header.Size);
                _dat := dat;
//                __dat := dat;
                CopyMemory(_dat, @Header, sizeof(header));
                inc(_dat, sizeof(Header));

                // combine packets
                for i := 0 to highpacket do
                if (TQueue( QueueBuf.items[i]^).IP = search_ip) and (TQueue( QueueBuf.items[i]^).Port = search_port) then begin
                        byte(_dat^) := TQueue(QueueBuf.items[i]^).Size;
                        inc(_dat);
                        CopyMemory(_dat, @TQueue( QueueBuf.items[i]^ ).Data_, TQueue( QueueBuf.items[i]^).Size);
                        inc(_dat, TQueue( QueueBuf.items[i]^).Size);
                        TQueue( QueueBuf.items[i]^).Active := false;
                end;

                // send this HUGE packet.
{                AddMessage('^5('+inttostr(Count)+') Packed send to: ' + search_ip +'. Size:'+inttostr(Header.Size));


                sss := '';
                for i := 0 to Header.Size-1 do begin
                        sss := sss + inttostr(byte(__dat^))+' ';
                        inc(__dat);
                end;
                AddMessage('^3S '+sss);
}
                // Debug Info
//                if Header.Size >=15 then CopyMemory(dat, @tmparray, 15) else
//                CopyMemory(dat, @tmparray, Header.Size);


//                dec(_dat, Header.Size);
                BNET1.SendData (0, dat^, Header.Size, search_ip, search_port);
                FreeMem(dat);

                // dead removal.
                done := false;
                repeat
                if QueueBuf.count = 0 then done := true else
                for i := 0 to QueueBuf.count-1 do begin
                        if TQueue(QueueBuf.items[i]^).Active = false then begin
                                QueueBuf.Delete(i);
                                break;
                        end;
                        if i = QueueBuf.count-1 then done := true;
                        end;
                until done;
        end;
end;


// =============================================================================
// Add queued task
// =============================================================================
procedure Network_AddToQueue(var Data; Size: word; IP : shortstring; Port : word);
var q : PQueue;
begin
        New(q);
        q^.Active := true;
        q^.IP := IP;
        q^.Port := Port;
        q^.Size := Size;

        move(Data, q^.data_, Size);
//        AddMessage('!!!!! AddedToQueue !!!!!! + '+inttostr(q^.data_[0])+'. size: '+inttostr(Size));
        r2_debuglog('!!!!! AddedToQueue !!!!!! + '+inttostr(q^.data_[0])+'. size: '+inttostr(Size));

        q^.timedout := GAMETIME + 5000; // deleted after this period.
        QueueBuf.Add(q);
end;

// =============================================================================
// Parse combined packets
// =============================================================================
procedure Network_ParsePackets(IP : shortstring; Port : word);
var count, i,z , PacketSize : byte;
    totalsize : byte;
    Data:Pointer;
    __dat : ^byte;
    sss : string;
begin
//        exit;
        if (IP=MainForm.GlobalIP) or (IP=MainForm.LocalIP) then exit;

        Data := @ReadBuf;

//        __dat := Data;
        sss := '';

        count := byte(Data^);   // conn: first byte is packet series size
        inc(integer(data), 2);  // conn: move pointer.. integer?
        totalsize := 2;         // conn: so totalsize is at least 2
        inc(__dat,2);           // conn: __dat?

        for i := 0 to count-1 do begin
                PacketSize := byte(Data^); // conn: again?

                if PacketSize = 0 then begin
                        SND.ErrorSound;
                        AddMessage('^1NETUNIT ERROR: ZERO SIZED DATA!');
                end;

                inc(totalsize, PacketSize); // conn: size counter++
                inc(integer(data));         // conn: move pointer by ?
//                __dat := Data;
                mainform.BNET_NFK_ReceiveData(Data, IP, Port, PacketSize); // conn: grab packet content
                inc(integer(data), PacketSize); // conn: move pointer by PacketSize


{                // debug HEX print.
                sss := '';
                for z := 0 to PacketSize-1 do begin
                 sss := sss + inttostr(byte(__dat^))+' ';
                 inc(__dat, 1);
                end;
                AddMessage('^5 (#'+inttostr(i+1)+') packet received from '+IP+'. Size:'+inttostr(PacketSize));
                AddMessage('^2R '+sss);
}
        end;


end;

end.

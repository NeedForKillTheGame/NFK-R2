{*******************************************************************************

    NFK [R2]
    Render Library / Menu object

    Implementation

    Contains:

    ...

*******************************************************************************}


{*******************************************************************************
    r2menu
*******************************************************************************}
function r2menu.lastIndex(): shortint;
var
    i:shortint;
begin
    for i:= 0 to 99 do begin
        if (Screens[i].Caption = '') then begin
            result:= i;
            break;
        end;
    end;
end;
//------------------------------------------------------------------------------
procedure r2menu.AddScreen(var Caption: string; scriptFile: string);
var
    i:shortint;
begin
    if ((Caption = '') or (scriptFile = '')) then exit;
    if (not FileExists(scriptFile)) then exit;

    i:= lastIndex;
    Screens[i].Caption:= Caption;
    Screens[i].Script.LoadFromFile(scriptFile);
end;
//------------------------------------------------------------------------------
procedure r2menu.DrawMenu(menuIndex: byte);
var
    i: byte;
    //m: r2;
begin
    //

  with Screens[menuIndex] do begin
    for i:= 0 to ItemsCount-1 do begin
        if ItemOrder[i].mType = mLabel then begin
          with mLabels[i] do
            case Font of
                1: mainform.Font1.TextOut(Text, Left, Top, Color);
                2: mainform.Font2.TextOut(Text, Left, Top, Color);
                21: mainform.Font2b.TextOut(Text, Left, Top, Color);
                22: mainform.Font2s.TextOut(Text, Left, Top, Color);
                23: mainform.Font2ss.TextOut(Text, Left, Top, Color);
                3: mainform.Font3.TextOut(Text, Left, Top, Color);
                4: mainform.Font4.TextOut(Text, Left, Top, Color);
                6: mainform.Font6.TextOut(Text, Left, Top, Color);

                7:  begin
                        nfkFont1.drawString(Text,Left,Top,$FF0000CC,1);
                        nfkFont1.drawString(Text,Left,Top,(menu1_alpha shl 24)+$0000FF,2);
                    end;
                8:  begin
                        nfkFont2.drawString(Text,Left,Top,$ffffffff,1);
                    end;
            end;
        end; // else
    end;
  end;

end;

{*******************************************************************************
    r2menuItem
*******************************************************************************}

procedure r2menuItem.OnClick(Sender: r2menuLabel);
begin
    // dummy
end;

procedure r2menuItem.OnMouseIn(Sender: r2menuLabel);
begin
    // dummy
end;

procedure r2menuItem.OnMouseOut(Sender: r2menuLabel);
begin
    // dummy
end;

{*******************************************************************************
    r2menuScreen
*******************************************************************************}

procedure r2menuScreen.AddItem(Text: string; Font: string; Color: cardinal; Effect: cardinal; Region: TRect; Stete: byte);
begin
    //
end;


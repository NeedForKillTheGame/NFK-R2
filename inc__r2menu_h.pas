{*******************************************************************************

    NFK [R2]
    Render Library / Menu object

    Header

    Contains:

    ...

*******************************************************************************}

const
    mLabel = 1;
    mPicture = 2;
//------------------------------------------------------------------------------
type
    r2menuLabel = class
  public
	Text: string; // title aka caption
	Font: byte;
	Color: cardinal;
	Effect: cardinal;
	Left : integer; //[Left;Top;Width;Height]
    Top: integer;
    State: byte;
end;
//------------------------------------------------------------------------------
type
    r2menuItem = class

  public
	mType: byte;        //[mLabel;mPicture]
	mState: byte;       //[Pressed;Hover;Normal]

    procedure OnClick(Sender: r2menuLabel);
	procedure OnMouseIn(Sender: r2menuLabel);
	procedure OnMouseOut(Sender: r2menuLabel);
end;
//------------------------------------------------------------------------------
type
    r2menuScreen = class

  public
    script: TStringList;
    Caption: string;
    mLabels: array [0..100] of r2menuLabel;
    ItemOrder: array [0..100] of r2menuItem;
    itemsCount: byte;

    procedure AddItem(Text: string; Font: string; Color: cardinal; Effect: cardinal; Region: TRect; Stete: byte);
end;
//------------------------------------------------------------------------------
type
    r2menu = class

  public
    Screens: array [0..99] of r2menuScreen;

    procedure AddScreen(var Caption: string; scriptFile: string);
    procedure DrawMenu(menuIndex: byte);

  private
    function lastIndex(): shortint;


end;

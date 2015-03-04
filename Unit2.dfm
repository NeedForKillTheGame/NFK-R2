object loader: Tloader
  Left = 256
  Top = 166
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'NFK R2 Console'
  ClientHeight = 448
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cns: TMemo
    Left = 4
    Top = 40
    Width = 529
    Height = 353
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    Color = clNavy
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clYellow
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
  object Button1: TButton
    Left = 460
    Top = 424
    Width = 71
    Height = 22
    Caption = 'quit'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'System'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button1Click
    OnMouseDown = Button1MouseDown
  end
  object Edit1: TEdit
    Left = 3
    Top = 400
    Width = 529
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
  end
  object Button2: TButton
    Left = 3
    Top = 424
    Width = 72
    Height = 22
    Caption = 'copy'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'System'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
  end
  object Button3: TButton
    Left = 81
    Top = 424
    Width = 72
    Height = 22
    Caption = 'clear'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'System'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
  end
end

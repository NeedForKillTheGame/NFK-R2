object mainform: Tmainform
  Left = 639
  Top = 315
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsNone
  Caption = 'Need For Kill - R2'
  ClientHeight = 84
  ClientWidth = 167
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnMouseDown = FormMouseDown
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 13
  object PowerGraph: TPowerGraph
    Antialias = True
    Dithering = False
    Hardware = True
    FullScreen = True
    Width = 640
    Height = 480
    BackBufferCount = 1
    BitDepth = bd_Low
    ZBuffer = zb_None
    VSync = False
    RefreshRate = rr_default
    CustomRefreshRate = 0
    OnDeviceLost = PowerGraphDeviceLost
    Top = 28
  end
  object Font1: TPowerFont
    PowerGraph = PowerGraph
    Left = 28
    Top = 28
  end
  object Font2: TPowerFont
    PowerGraph = PowerGraph
    Left = 56
    Top = 28
  end
  object Font3: TPowerFont
    PowerGraph = PowerGraph
    Left = 84
    Top = 28
  end
  object VTDb: TVTDb
    OpenMode = opReadOnly
    Left = 84
  end
  object DXInput: TDXInput
    ActiveOnly = True
    Joystick.BindInputStates = True
    Joystick.Effects.Effects = {
      FF0A0044454C50484958464F524345464545444241434B454646454354003010
      7F000000545046301D54466F726365466565646261636B456666656374436F6D
      706F6E656E74025F3107456666656374730E01044E616D650607456666656374
      730A45666665637454797065070665744E6F6E6506506572696F64023205506F
      7765720310270454696D6503E8030E537461727444656C617954696D65020000
      000000}
    Joystick.Enabled = True
    Joystick.ForceFeedback = False
    Joystick.AutoCenter = True
    Joystick.DeadZoneX = 50
    Joystick.DeadZoneY = 50
    Joystick.DeadZoneZ = 50
    Joystick.ID = 0
    Joystick.RangeX = 1000
    Joystick.RangeY = 1000
    Joystick.RangeZ = 1000
    Keyboard.BindInputStates = True
    Keyboard.Effects.Effects = {
      FF0A0044454C50484958464F524345464545444241434B454646454354003010
      7F000000545046301D54466F726365466565646261636B456666656374436F6D
      706F6E656E74025F3107456666656374730E01044E616D650607456666656374
      730A45666665637454797065070665744E6F6E6506506572696F64023205506F
      7765720310270454696D6503E8030E537461727444656C617954696D65020000
      000000}
    Keyboard.Enabled = True
    Keyboard.ForceFeedback = False
    Keyboard.Assigns = {
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000071000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000}
    Mouse.BindInputStates = True
    Mouse.Effects.Effects = {
      FF0A0044454C50484958464F524345464545444241434B454646454354003010
      7F000000545046301D54466F726365466565646261636B456666656374436F6D
      706F6E656E74025F3107456666656374730E01044E616D650607456666656374
      730A45666665637454797065070665744E6F6E6506506572696F64023205506F
      7765720310270454696D6503E8030E537461727444656C617954696D65020000
      000000}
    Mouse.Enabled = True
    Mouse.ForceFeedback = False
    UseDirectInput = True
    Left = 56
  end
  object Font4: TPowerFont
    PowerGraph = PowerGraph
    Left = 112
    Top = 28
  end
  object Font2ss: TPowerFont
    PowerGraph = PowerGraph
    Left = 140
    Top = 28
  end
  object Font6: TPowerFont
    PowerGraph = PowerGraph
    Left = 56
    Top = 56
  end
  object font2s: TPowerFont
    PowerGraph = PowerGraph
    Left = 28
    Top = 56
  end
  object Font2b: TPowerFont
    PowerGraph = PowerGraph
    Top = 56
  end
  object DXTimer: TPowerTimer
    FPS = 50
    MayProcess = False
    MayRender = False
    MayRealTime = False
    OnProcess = DXTimerTimer
    Left = 140
  end
  object lobby: TClientSocket
    Active = False
    Address = 'conn.ee/nfk/live'
    ClientType = ctNonBlocking
    Host = 'conn.ee'
    Port = 80
    OnConnecting = LOBBYConnecting
    OnConnect = LOBBYConnect
    OnDisconnect = LOBBYDisconnect
    OnRead = LOBBYRead
  end
  object NMHTTP1: TNMHTTP
    Port = 0
    ReportLevel = 0
    Body = 'Default.htm'
    Header = 'Head.txt'
    InputFileMode = True
    OutputFileMode = False
    ProxyPort = 0
    Left = 116
    Top = 56
  end
  object nfkplanet_idle: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = nfkplanet_idleTimer
    Left = 28
  end
  object VTDb2: TVTDb
    OpenMode = opReadOnly
    Left = 112
  end
end

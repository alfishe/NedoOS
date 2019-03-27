object Form1: TForm1
  Left = 217
  Top = 214
  Width = 1057
  Height = 768
  VertScrollBar.Visible = False
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbCaretPos: TLabel
    Left = 483
    Top = 600
    Width = 3
    Height = 13
  end
  object memoIn: TMemo
    Left = 0
    Top = 0
    Width = 471
    Height = 741
    Anchors = [akLeft, akTop, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    OnChange = memoInChange
    OnClick = memoInChange
    OnKeyDown = memoInKeyDown
    OnKeyUp = memoInKeyDown
    OnMouseDown = memoInMouseDown
  end
  object memoOut: TMemo
    Left = 576
    Top = 0
    Width = 471
    Height = 645
    Anchors = [akTop, akRight]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Button1: TButton
    Left = 488
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Compile'
    TabOrder = 2
    OnClick = Button1Click
  end
  object cbHints: TCheckBox
    Left = 488
    Top = 192
    Width = 73
    Height = 17
    Caption = 'Hints'
    TabOrder = 3
  end
  object cbComments: TCheckBox
    Left = 488
    Top = 160
    Width = 73
    Height = 17
    Caption = 'Comments'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object cbAuto: TCheckBox
    Left = 488
    Top = 16
    Width = 73
    Height = 17
    Caption = 'Auto'
    TabOrder = 5
  end
  object memoErr: TMemo
    Left = 576
    Top = 644
    Width = 471
    Height = 101
    Anchors = [akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object rgTarget: TRadioGroup
    Left = 472
    Top = 368
    Width = 105
    Height = 81
    Caption = 'Target'
    ItemIndex = 0
    Items.Strings = (
      'Z80'
      'ARM Thumb')
    TabOrder = 7
  end
end

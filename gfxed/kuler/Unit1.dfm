object Form1: TForm1
  Left = 192
  Top = 107
  Width = 1088
  Height = 750
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 24
    Top = 16
    Width = 384
    Height = 512
    OnClick = Image1Click
    OnMouseMove = Image1MouseMove
  end
  object lbR: TLabel
    Left = 584
    Top = 72
    Width = 8
    Height = 13
    Caption = 'R'
  end
  object lbG: TLabel
    Left = 584
    Top = 96
    Width = 8
    Height = 13
    Caption = 'G'
  end
  object lbB: TLabel
    Left = 584
    Top = 120
    Width = 7
    Height = 13
    Caption = 'B'
  end
  object curColor: TImage
    Left = 560
    Top = 160
    Width = 105
    Height = 105
    OnClick = curColorClick
  end
  object changV: TImage
    Left = 736
    Top = 16
    Width = 105
    Height = 512
    OnClick = changVClick
    OnMouseMove = changVMouseMove
  end
  object curColorChunky: TImage
    Left = 560
    Top = 280
    Width = 105
    Height = 105
  end
  object Memo1: TMemo
    Left = 440
    Top = 416
    Width = 209
    Height = 241
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
end

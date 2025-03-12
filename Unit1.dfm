object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 464
  ClientWidth = 773
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object OpenFileButton: TButton
    Left = 8
    Top = 16
    Width = 153
    Height = 25
    Caption = 'Open MIB File'
    TabOrder = 0
    OnClick = OpenFileButtonClick
  end
  object MIBStringTree: TVirtualStringTree
    Left = 8
    Top = 47
    Width = 753
    Height = 410
    AccessibleName = 'OID'
    DefaultNodeHeight = 19
    Header.AutoSizeIndex = 0
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    TabOrder = 1
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnGetText = MIBStringTreeGetText
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <
      item
        Position = 0
        Text = 'Name'
        Width = 400
      end
      item
        Position = 1
        Text = 'OID'
        Width = 150
      end
      item
        Position = 2
        Text = 'Syntax'
        Width = 150
      end>
  end
  object ConsoleButton: TButton
    Left = 360
    Top = 16
    Width = 121
    Height = 25
    Caption = 'Console'
    TabOrder = 2
    OnClick = ConsoleButtonClick
  end
end

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.StdCtrls, Generics.Collections,
  SNMPParserMIB, VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree,
  VirtualTrees.AncestorVCL;

type
  pTRMIBTreeNode = ^TRMIBTreeNode;
  TRMIBTreeNode = record
    obj: TRAddressObject;
  end;

  TRForEachCallback = reference to function(Tree: TVirtualStringTree; node: PVirtualNode): Boolean;

  TForm1 = class(TForm)
    OpenFileButton: TButton;
    MIBStringTree: TVirtualStringTree;
    ConsoleButton: TButton;
    procedure OpenFileButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MIBStringTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure ConsoleButtonClick(Sender: TObject);
  private
    parser: TRMIBParser;

    procedure ViewTree;

    procedure ForEach(Tree: TVirtualStringTree; Callback: TRForEachCallback);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.OpenFileButtonClick(Sender: TObject);
var
  od: TOpenDialog;
begin
  try
    od := TOpenDialog.Create(nil);
    od.InitialDir := ExtractFilePath(application.ExeName);
    od.Filter := 'MIB files (*.mib)|*.mib';
    if od.Execute = false then
        exit;

    parser.Parse(od.FileName);

  finally
    FreeAndNil(od);
  end;

  ViewTree;
end;

procedure TForm1.ConsoleButtonClick(Sender: TObject);
var
  stl: TStringList;
  str: String;
  addresses: TList<TObjectList<TRAddressObject>>;
  objlist: TObjectList<TRAddressObject>;
  obj: TRAddressObject;
begin
  AllocConsole;

  // список адресов
  WriteLn('+++++++++++++++++++++++++++++++');
  WriteLn('Adresses:');
  addresses := TList<TObjectList<TRAddressObject>>.Create;
  try
    parser.GetAddressObjects(addresses);
    if addresses = nil then
      exit;

    for objlist in addresses do
    begin
      for obj in objlist do
      begin
        WriteLn(String(obj.name) + ' ' + obj.ToString);
      end;
    end;

  finally
    FreeAndNil(addresses);
  end;

  WriteLn('+++++++++++++++++++++++++++++++');
  WriteLn('Unknown files:');

  stl := TStringList.Create;
  try
    parser.GetUnknownFiles(stl);

    for str in stl do
      WriteLn(str);
  finally
    FreeAndNil(stl);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  MIBStringTree.NodeDataSize := sizeof(TRMIBTreeNode);

  parser := TRMIBParser.Create;
  parser.AddSearchFolder(IncludeTrailingPathDelimiter(ExtractFilePath(application.ExeName)) + 'mibs\');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(parser);
end;

procedure TForm1.MIBStringTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  rec: pTRMIBTreeNode;
begin
  rec := Sender.GetNodeData(Node);
  if rec = nil then
    exit;

  case Column of
    0:
      CellText := String(rec.obj.Name);
    1:
      CellText := rec.obj.ToString;
    2:
      begin
        if rec.obj is TRObjectType then
          CellText := String(TRObjectType(rec.obj).syntax)
        else
          CellText := '';
      end;
  end;
end;

procedure TForm1.ForEach(Tree: TVirtualStringTree; Callback: TRForEachCallback);

  function ScanTreeLevel(Tree: TVirtualStringTree; Callback: TRForEachCallback; node: PVirtualNode): Boolean;
  var
    n: PVirtualNode;
  begin
    result := false;

    n := node.FirstChild;

    while n <> nil do
    begin
      if Callback(Tree, n) = true then
        exit(true);

      if ScanTreeLevel(Tree, Callback, n) = true then
        exit(true);

      n := n.NextSibling;
    end;
  end;

begin
  ScanTreeLevel(Tree, Callback, Tree.RootNode);
end;

procedure TForm1.ViewTree;

  procedure AddObjectToTree(newobject: TRAddressObject; tree: TBaseVirtualTree);
  var
    findparentnode: PVirtualNode;
    node: PVirtualNode;
    rec: pTRMIBTreeNode;
  begin
    findparentnode := nil;

    ForEach(MIBStringTree,
      function(Tree: TVirtualStringTree; node: PVirtualNode): Boolean

        // проверка вхождения stl1 в stl2
        function Contains(stl1, stl2: TStringList): Boolean;
        var
          i: Integer;
        begin

          result := false;
          if stl1.Count > stl2.Count then
            exit;

          for i := 0 to stl1.Count - 1 do
          begin
            if stl1[i] <> stl2[i] then
              exit;
          end;

          result := true;
        end;

      var
        rec: pTRMIBTreeNode;
      begin
        result := false;

        rec := Tree.GetNodeData(node);
        if rec.obj = nil then
          exit;

        if newobject.address.Equals(rec.obj.address) then
          findparentnode := node.Parent
        else
        begin
          if Contains(rec.obj.address, newobject.address) then
            findparentnode := node;
        end;
      end
    );

    node := tree.AddChild(findparentnode);
    if node <> nil then
    begin
      rec := tree.GetNodeData(node);
      if rec <> nil then
        rec.obj := newobject;
    end;
  end;

var
  obj: TRAddressObject;
  objlist: TObjectList<TRAddressObject>;
  addresses: TList<TObjectList<TRAddressObject>>;
begin
  addresses := TList<TObjectList<TRAddressObject>>.Create;
  try
    parser.GetAddressObjects(addresses);
    if addresses = nil then
      exit;

    MIBStringTree.Clear;
    MIBStringTree.BeginUpdate;

    for objlist in addresses do
    begin
      for obj in objlist do
      begin
        AddObjectToTree(obj, MIBStringTree);
      end;
    end;

    MIBStringTree.EndUpdate;
  finally
    FreeAndNil(addresses);
  end;
end;

end.

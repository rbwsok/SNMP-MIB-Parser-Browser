unit SNMPParserMIB;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
System.Generics.Defaults, System.Math;

type
  pTRKnownOID = ^TRKnownOID;
  TRKnownOID = record
    Name: String;
    OID: String;
  end;

const
  // ���������������� ������
  // ���� ����� ��������� ������ ��� ������ �� � ���. ������
  KnownOIDsArray: array [0..3] of TRKnownOID = (
    ( Name: 'ccitt'; OID: '0' ),
    ( Name: 'iso'; OID: '1' ),
    ( Name: 'org'; OID: '3' ),
    ( Name: 'dod'; OID: '6' )
  );

type
  // ���� ������
  TRLexemType = (
    ltUnknown, // �� ��������
    ltText,     // ����� (�������� � �.�. - ��, ��� ��������� � ��������)
    ltSemicolon, // ����� � �������
    ltLeftBracer, // ����� �������� ������
    ltRightBracer // ������ �������� ������
  );

  // ����������� ����� �� ����� + �������� ����������� � ������ ������
  TRMIBTokenizer = class
  protected
    FPosition: NativeInt;
    FData: RawByteString;

    function isSpace(ch: AnsiChar): Boolean; // �������� �� ������� � �.�.
    function isEndLine(ch: AnsiChar): Boolean; // �������� �� ����� ������
    function isQuoted(ch: AnsiChar): Boolean; // �������� �� �������
    function isComment: Boolean; // �������� �� ����������
    function isSemicolon(ch: AnsiChar): Boolean; // �������� �� ����� � �������
    function isLeftBracer(ch: AnsiChar): Boolean; // �������� �� ����� �������� ������
    function isRightBracer(ch: AnsiChar): Boolean; // �������� �� ������ �������� ������
    procedure skipSpaces;
    procedure skipComment;
    procedure skipEndLine;
    function getQuotedText: RawByteString; // ����� ����� � ��������

    function findChar(ch: AnsiChar): NativeInt; // ����� �������
    function findCharInLine(ch: AnsiChar): NativeInt; // ����� ������� � ����� ������
    function findEndLineBack: NativeInt; // ����� ������ ������ (� �������� �����������)
    function findEndLine: NativeInt; // ����� ����� ������ (� ������ �����������)

    function getWord(var str: RawByteString; var lexemtype: TRLexemType): Boolean;
  public
    function Process(const str: RawByteString; list: TList<TPair<RawByteString, TRLexemType>>): Boolean;
  end;

  // ������� ������ � ������� (�������� ����������� �� ������)
  TRAddressObject = class
  public
    // �����. ������ ����� - ��������� ������.
    // ����� 1.3.6.1.4.1 ����� �������� �� 6 ����� � ������� ����� �����
    // ����� ����� ��������� ����� ����� (������ �� ������ �����) - �������� mikrotik.1 - 2 ������

    name: RawByteString;
    address: TStringList;

    function ToString: String; override;

    constructor Create;
    destructor Destroy; override;
  end;

  TRModuleIdentity = class(TRAddressObject)
    // MODULE-IDENTITY
  end;

  TRModuleCompliance = class(TRAddressObject)
    // MODULE-COMPLIANCE
  end;

  TRObjectIdentifier = class(TRAddressObject)
    // OBJECT IDENTIFIER
  end;

  TRAgentCapabilites = class(TRAddressObject)
    // AGENT-CAPABILITIES
  end;

  TRObjectIdentity = class(TRAddressObject)
    // OBJECT-IDENTITY
  end;

  TRObjectType = class(TRAddressObject)
  public
    // OBJECT-TYPE

    syntax: RawByteString; // ������� ��� (��� ��������� ����������� ����)

    // ��� ��������� ��������, �� �� ������������
    maxaccess: RawByteString; // ����
    status: RawByteString; // ������
    description: RawByteString; // ��������
    treference: RawByteString;
    index: TStringList;

    constructor Create;
    destructor Destroy; override;
  end;

  TRObjectGroup = class(TRAddressObject)
  public
    // OBJECT-GROUP

    objects: TStringList;

    // ��� ��������� ��������, �� �� ������������
    status: RawByteString; // ������
    description: RawByteString; // ��������

    constructor Create;
    destructor Destroy; override;
  end;

  TRNotificationGroup = class(TRAddressObject)
  public
    // NOTIFICATION-GROUP

    notifications: TStringList;

    // ��� ��������� ��������, �� �� ������������
    status: RawByteString; // ������
    description: RawByteString; // ��������

    constructor Create;
    destructor Destroy; override;
  end;

  TRNotificationType = class(TRAddressObject)
  public
    // NOTIFICATION-TYPE

    objects: TStringList;

    // ��� ��������� ��������, �� �� ������������
    status: RawByteString; // ������
    description: RawByteString; // ��������
    treference: RawByteString;

    constructor Create;
    destructor Destroy; override;
  end;

  TRTextualConvention = class
  public
    // TEXTUAL-CONVENTION

    // ���� �������� �� ������� ����� (�� ����) �� SNMPv2-SMI � �.�.

    name: RawByteString; // ��� ������ ����
    syntax: RawByteString; // ������� ��� (��� ��������� ����������� ����)

    enumvalues: TStringList; // ��� ������������� ����� - ��������� ��������

    // ��� ��������� ��������, �� �� ������������
    displayhint: RawByteString; // ����
    status: RawByteString; // ������
    description: RawByteString; // ��������
    treference: RawByteString;

    constructor Create;
    destructor Destroy; override;
  end;

  TRSequence = class
  public
    // SEQUENCE

    name: RawByteString;
    sequences: TList<TPair<RawByteString, RawByteString>>;

    constructor Create;
    destructor Destroy; override;
  end;

  TRMIBFile = class;

  TRMIBLexer = class
  protected
    FPosition: NativeInt;
    FList: TList<TPair<RawByteString, TRLexemType>>;
    FMIBFile: TRMIBFile;

    procedure Clear;

    function findBeginMIB: NativeInt; // ����� ������ ������ mib
    function isEndMIB: Boolean; // �������� �� ����� ������
    function isModuleIdentity: Boolean; // �������� �� �������� ������
    function isImports: Boolean; // �������� �� ���� �������
    function isObjectIdentifier: Boolean; // �������� �� ���� ������
    function isTextualConvention: Boolean; // �������� �� ���� ���� ������
    function isObjectType: Boolean; // �������� �� ���� ����
    function isSequence: Boolean; // �������� �� ������������������
    function isObjectGroup: Boolean; // �������� �� ������ ��������
    function isNotificationGroup: Boolean; // �������� �� ������ �����������
    function isNotificationType: Boolean; // �������� �� �����������
    function isMacro: Boolean; // �������� �� ������
    function isChoice: Boolean;
    function isModuleCompliance: Boolean;
    function isAgentCapabilites: Boolean;
    function isObjectIdentity: Boolean;

    function getImports: Boolean; // ������ ����� �������
    function getModuleIdentity: Boolean; // ������ ����� �������������
    function getObjectIdentifier: Boolean; // ������ ����� ������
    function getTextualConvention: Boolean; // ������ ����� ���� ������
    function getObjectType: Boolean; // ������ ����� ����
    function getSequence: Boolean; // ������ ����� ������������������
    function getObjectGroup: Boolean; // ������ ������ ��������
    function getNotificationGroup: Boolean; // ������ ������ �����������
    function getNotificationType: Boolean; // ������ �����������
    function getMacro: Boolean; // ������ �������
    function getChoice: Boolean;
    function getModuleCompliance: Boolean;
    function getAgentCapabilites: Boolean;
    function getObjectIdentity: Boolean;

    function getEnumsWithNumbers(leftBracerPosition, rightBracerPosition: NativeInt; var values: TStringList): Boolean; // ���������� �������������� ����
    function getEnumsWithoutNumbers(leftBracerPosition, rightBracerPosition: NativeInt; var values: TStringList): Boolean; // ���������� �������������� ����
    function getEnumsStringPairs(leftBracerPosition, rightBracerPosition: NativeInt; var values: TList<TPair<RawByteString, RawByteString>>): Boolean; // ���������� �������������� ����
    function getAddress(leftBracerPosition, rightBracerPosition: NativeInt; var values: TStringList): Boolean; // ���������� � ������ ������

    // ����� ���������� ��������.
    function findItem(const value: RawByteString; const breakvalue: RawByteString): NativeInt;
  public
    function Process(var MIBFile: TRMIBFile): Boolean;

    constructor Create;
    destructor Destroy; override;
  end;

  // ������ ������ �����
  TRMIBFile = class
  private
    FTokenizer: TRMIBTokenizer;
    FLexer: TRMIBLexer;
    FList: TList<TPair<RawByteString, TRLexemType>>;
    FKnownOIDsDict: TDictionary<String, String>;

    FIsMainFile: Boolean; // true - ������������� ����, false - �������������� ���� (����������� �� ������ IMPORTS)

    FName: String; // ��� �����

    procedure Clear;

    function FindAddressFromAddresses(const name: RawByteString): TRAddressObject;
    function FindTypeFromTextualConvention(const name: RawByteString): TRTextualConvention;
    function FindSequenceFromType(const name: RawByteString): TRSequence;

    function BuildAddresses(allfiles: TObjectList<TRMIBFile>): Boolean;
    function ChangeTypes(allfiles: TObjectList<TRMIBFile>): Boolean;

    procedure ReplaceItemFromStringList(const dst, src: TStringList; index: NativeInt);
    procedure ReplaceItemFromString(const dst: TStringList; const src: String; index: NativeInt);

    procedure SortAddressObjects;
  public
    // ��������� �������
    Name: RawByteString; // ��� ������ mib
    Imports: TList<TPair<RawByteString, RawByteString>>; // ������ ������������� ������� (1 - ���, 2 - ��� ������). ��� ������ ����� ���� ������
    AddressObjects: TObjectList<TRAddressObject>; // ������ �������� � �������� (��� ��� ������� � ��������)
    TextualConventions: TObjectList<TRTextualConvention>; // ������ �����
    Sequences: TObjectList<TRSequence>; // ������ �������������������

    // ������ �����
    function Parse(const body: RawByteString): Boolean;
    // ������ ������ �������������� ������
    procedure GetAdditionalFiles(stl: TStringList);
    // ������ ����� (���������� �������) � ������ �������������� ������
    function Analyze(allfiles: TObjectList<TRMIBFile>): Boolean;

    constructor Create;
    destructor Destroy; override;
  end;

  TRMIBParser = class
  private
    FFileFolders: TStringList; // ����� ��� ������ �������������� ������

    FMIBFiles: TObjectList<TRMIBFile>;

    FUnknownFiles: TStringList; // ������ ����������� ������. ��� ��� ������������ ������� ����������

    function ParseFile(const filename: String; mibfile: TRMIBFile): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    // ���������� ����� ��� ������ �������������� ������
    procedure AddSearchFolder(const folder: String);

    // �������� �����
    procedure Parse(const filename: String; ismainfile: Boolean = true);

    // ������� ���� ������ (����� ����� ��������)
    procedure Clear;

    // �������� ��� ����������� �����
    procedure GetUnknownFiles(var stl: TStringList);

    // ��������� ������ ������� �������
    function GetAddressObjects(list: TList<TObjectList<TRAddressObject>>): Boolean;

    // �������� ������������� ����� �� �������
    function Remove(index: NativeInt): Boolean;
  end;

implementation

{ TRObjectAddress }

constructor TRAddressObject.Create;
begin
  address := TStringList.Create;
end;

destructor TRAddressObject.Destroy;
begin
  FreeAndNil(address);
  inherited;
end;

// ��������� ��� ������
function TRAddressObject.ToString: String;
var
  i: NativeInt;
begin
  result := '';
  if address.Count = 0 then
    exit;

  result := address[0];

  i := 1;
  while i < address.Count do
  begin
    result := result + '.' + address[i];
    inc(i);
  end;
end;

{ TRMIBParser }

function TRMIBParser.GetAddressObjects(list: TList<TObjectList<TRAddressObject>>): Boolean;
var
  i: NativeInt;
begin
  if FMIBFiles.Count = 0 then
    exit(false);

  i := 0;
  while i < FMIBFiles.Count do
  begin
    if FMIBFiles[i].FIsMainFile then
      list.Add(FMIBFiles[i].AddressObjects);

    inc(i);
  end;

  result := true;
end;

procedure TRMIBParser.AddSearchFolder(const folder: String);
var
  str, path: String;
  findfile: Boolean;
begin
  findfile := false;
  path := LowerCase(IncludeTrailingPathDelimiter(folder));
  for str in FFileFolders do
  begin
    if path = str then
    begin
      findfile := true;
      break;
    end;
  end;

  if not findfile then
    FFileFolders.Add(path);
end;

procedure TRMIBParser.Clear;
begin
  FMIBFiles.Clear;
  FUnknownFiles.Clear;
end;

constructor TRMIBParser.Create;
begin
  FFileFolders := TStringList.Create; // ����� ��� ������ �������������� ������
  FFileFolders.Duplicates := dupIgnore;

  FMIBFiles := TObjectList<TRMIBFile>.Create;

  FUnknownFiles := TStringList.Create;
end;

destructor TRMIBParser.Destroy;
begin
  FreeAndNil(FMIBFiles);

  FreeAndNil(FFileFolders);

  FreeAndNil(FUnknownFiles);

  inherited;
end;

procedure TRMIBParser.GetUnknownFiles(var stl: TStringList);
begin
  stl.Assign(FUnknownFIles);
end;

procedure TRMIBParser.Parse(const filename: String; ismainfile: Boolean = true);
var
  mibfile: TRMIBFile;
  stl: TStringList;
  findfile: Boolean;
  mibfilename: TRMibFile;
  name: String;
begin
  // ���� ���� ��� ��������� - �� ���������� ���
  findfile := false;
  for mibfilename in FMIBFiles do
  begin
    if filename = mibfilename.FName then
    begin
      findfile := true;
      break;
    end;
  end;

  if findfile = true then
    exit;

  mibfile := TRMIBFile.Create;
  mibfile.FIsMainFile := ismainfile;
  mibfile.FName := filename;

  // ��������� ����� �������� ����� � ����� ��� ������ �������������� ������
  if mibfile.FIsMainFile then
  begin
    AddSearchFolder(ExtractFilePath(filename));
    FUnknownFiles.Clear;
  end;

  if ParseFile(filename, mibfile) then
  begin
    FMIBFiles.Add(mibfile);

    stl := TStringList.Create;
    stl.Sorted := true;
    stl.Duplicates := dupIgnore;

    try
      mibfile.GetAdditionalFiles(stl);
      for name in stl do
        Parse(name, false);
    finally
      FreeAndNil(stl);
    end;

    mibfile.Analyze(FMIBFiles);
  end
  else
    FreeAndNil(mibfile);
end;

function TRMIBParser.ParseFile(const filename: String; mibfile: TRMIBFile): Boolean;
var
  ms: TMemoryStream;
  str: RawByteString;
  name: String;
begin
  ms := TMemoryStream.Create;
  try
    if ExtractFilePath(filename) <> '' then
    begin
      if not FileExists(filename) then
      begin
        FUnknownFiles.Add(filename);
        exit(false);
      end;
      ms.LoadFromFile(filename)
    end
    else
    begin
      // ������ ���. ������
      for name in self.FFileFolders do
      begin
        if FileExists(name + filename + '.mib') then
        begin
          ms.LoadFromFile(name + filename + '.mib');
          break;
        end
        else
        if FileExists(name + filename + '.txt') then
        begin
          ms.LoadFromFile(name + filename + '.txt');
          break;
        end
        else
        if FileExists(name + filename) then
        begin
          ms.LoadFromFile(name + filename);
          break;
        end
      end;
    end;

    // ���� �� ������
    if ms.Size = 0 then
    begin
      FUnknownFiles.Add(filename);
      exit(false);
    end;

    SetLength(str, ms.Size);
    CopyMemory(@str[1], ms.Memory, ms.Size);

    result := mibfile.Parse(str);
  finally
    FreeAndNil(ms);
  end;
end;

function TRMIBParser.Remove(index: NativeInt): Boolean;
begin
  result := false;

  if (index < 0) or (index >= FMIBFiles.Count) then
    exit;

  FMIBFiles.Delete(index);

  result := true;
end;

procedure TRMIBFile.ReplaceItemFromStringList(const dst, src: TStringList; index: NativeInt);
var
  i: NativeInt;
begin
  // ������� ������ TStringList � ������ TStringList � �������� ������ ������
  dst.Delete(index);
  i := 0;
  while i < src.Count do
  begin
    dst.Insert(i + index, src[i]);
    inc(i);
  end;
end;

procedure TRMIBFile.SortAddressObjects;
begin
  AddressObjects.Sort(TComparer<TRAddressObject>.Construct(
    function(const Item1, Item2: TRAddressObject): NativeInt
    var
      i, v1, v2: NativeInt;
    begin
      result := 0;

      i := 0;
      while i < min(Item1.address.Count, Item2.address.Count) do
      begin
        v1 := StrToIntDef(Item1.address[i], 0);
        v2 := StrToIntDef(Item2.address[i], 0);
        result := CompareValue(v1, v2);
        if result <> 0 then
          break;

        inc(i);
      end;

      if result = 0 then
      begin
        result := CompareValue(Item1.address.Count, Item2.address.Count);
      end;
    end
  ));
end;

procedure TRMIBFile.ReplaceItemFromString(const dst: TStringList; const src: String; index: NativeInt);
var
  stl: TStringList;
begin
  // ������� ������ ������, ����������� ������� � ������ TStringList � �������� ������ ������
  stl := TStringList.Create;
  try
    stl.Delimiter := '.';
    stl.StrictDelimiter := true;
    stl.DelimitedText := src;

    ReplaceItemFromStringList(dst, stl, index);
  finally
    FreeAndNil(stl);
  end;
end;

function TRMIBFile.BuildAddresses(allfiles: TObjectList<TRMIBFile>): Boolean;

  // �������� ������ ������
  function BuildOneAddress(obj: TRAddressObject; allfiles: TObjectList<TRMIBFile>): Boolean;
  var
    i: NativeInt;
    elementaddress, value: String;
    findaddress: TRAddressObject;

    additionalfile: TRMIBFile;
  begin
    // ���������� ��� ����� ������
    i := 0;
    while i < obj.address.Count do
    begin
      elementaddress := obj.address[i];
      if StrToIntDef(elementaddress, -1) = -1 then
      begin
        // ���� ����� � ������ �������
        findaddress := FindAddressFromAddresses(RawByteString(elementaddress));
        if findaddress <> nil then
        begin // ���� � �������� �����
          BuildOneAddress(findaddress, allfiles); // ������� ����������� �����
          ReplaceItemFromStringList(obj.address, findaddress.address, i);
        end
        else
        begin // ����� �� ������
          // ���� � ���������������� �������
          if FKnownOIDsDict.TryGetValue(elementaddress, value) then
          begin
            ReplaceItemFromString(obj.address, value, i);
          end
          else
          begin
            // ���� � ������ ������
            for additionalfile in allfiles do
            begin
              if self.Name = additionalfile.Name then // ���� �� ����
                continue;

              findaddress := additionalfile.FindAddressFromAddresses(RawByteString(elementaddress));
              if findaddress <> nil then
              begin
                ReplaceItemFromStringList(obj.address, findaddress.address, i);
                break;
              end;
            end;
          end;
        end;
      end;
      inc(i);
    end;

    result := true;
  end;

var
  obj: TRAddressObject;
begin
  // �������� ������� �� ������������� �����

  for obj in self.AddressObjects do
    BuildOneAddress(obj, allfiles);

  result := true;
end;

function TRMIBFile.ChangeTypes(allfiles: TObjectList<TRMIBFile>): Boolean;

  // ������ ������ �������� ������ ������
  function ChangeType(obj: TRAddressObject; allfiles: TObjectList<TRMIBFile>): Boolean;

    function IsBaseType(const value: RawByteString): Boolean;
    const
      // ������ ������� ����� (SNMPv2-SMI)
      BaseTypes: array [0..10] of RawByteString = ('INTEGER', 'OCTET STRING', 'OBJECT IDENTIFIER',
        'Integer32', 'IpAddress', 'Counter32', 'Gauge32', 'Unsigned32', 'TimeTicks', 'Opaque', 'Counter64');
    var
      str: RawByteString;
    begin
      result := true;

      for str in BaseTypes do
      begin
        if value = str then
          exit;
      end;

      result := false;
    end;

  var
    additionalfile: TRMIBFile;
    t: TRTextualConvention;
    findtype: Boolean;
  begin
    result := false;

    if IsBaseType(TRObjectType(obj).syntax) then
      exit;

    findtype := false;
    t := FindTypeFromTextualConvention(TRObjectType(obj).syntax);
    if t = nil then
    begin
      // ���� � ������ ������
      for additionalfile in allfiles do
      begin
        t := additionalfile.FindTypeFromTextualConvention(TRObjectType(obj).syntax);
        if t <> nil then
        begin
          findtype := true;
          break;
        end;
      end;

      // �� ����� ��� - ���� sequence
      if findtype = false then
      begin
        if FindSequenceFromType(TRObjectType(obj).syntax) <> nil then
        begin
          TRObjectType(obj).syntax := 'Integer32';
          exit(true);
        end
        else
          exit;
      end;
    end;

    TRObjectType(obj).syntax := t.syntax;

    ChangeType(obj, allfiles);

    result := true;
  end;

var
  obj: TRAddressObject;
begin
  // �������� ������� �� ������������� �����
  for obj in self.AddressObjects do
  begin
    if obj is TRObjectType then
      ChangeType(obj, allfiles);
  end;

  result := true;
end;

procedure TRMIBFile.Clear;
begin
  Imports.Clear;
  AddressObjects.Clear;
  TextualConventions.Clear;
  Sequences.Clear;
end;

constructor TRMIBFile.Create;
var
  known: TRKnownOID;
begin
  FList := TList<TPair<RawByteString, TRLexemType>>.Create;

  FTokenizer := TRMIBTokenizer.Create;
  FLexer := TRMIBLexer.Create;

  Imports := TList<TPair<RawByteString, RawByteString>>.Create;
  AddressObjects := TObjectList<TRAddressObject>.Create;
  TextualConventions := TObjectList<TRTextualConvention>.Create;
  Sequences := TObjectList<TRSequence>.Create;

  FKnownOIDsDict := TDictionary<String, String>.Create;
  for known in KnownOIDsArray do
    FKnownOIDsDict.Add(known.Name, known.OID);

  FIsMainFile := false;
end;

destructor TRMIBFile.Destroy;
begin
  FreeAndNil(FTokenizer);
  FreeAndNil(FLexer);

  FreeAndNil(FList);

  FreeAndNil(Imports);
  FreeAndNil(AddressObjects);
  FreeAndNil(TextualConventions);
  FreeAndNil(Sequences);

  FreeAndNil(FKnownOIDsDict);
  inherited;
end;

function TRMIBFile.FindAddressFromAddresses(const name: RawByteString): TRAddressObject;
begin
  for result in self.AddressObjects do
  begin
    if name = result.name then
      exit;
  end;

  result := nil;
end;

function TRMIBFile.FindSequenceFromType(const name: RawByteString): TRSequence;
begin
  for result in self.Sequences do
  begin
    if name = result.name then
      exit;
  end;

  result := nil;
end;

function TRMIBFile.FindTypeFromTextualConvention(
  const name: RawByteString): TRTextualConvention;
begin
  for result in self.TextualConventions do
  begin
    if name = result.name then
      exit;
  end;

  result := nil;
end;

function TRMIBFile.Parse(const body: RawByteString): Boolean;
begin
  // ������ �����

  // ��������� �� �����, ������� ����������, �������� ����� (������)
  result := FTokenizer.Process(body, FList);
  if not result then
    exit;

  // ����������� ��� ������
  result := FLexer.Process(self);
  if not result then
    exit;
end;

procedure TRMIBFile.GetAdditionalFiles(stl: TStringList);
var
  obj: TPair<RawByteString, RawByteString>;
begin
  // ������ ������ �������������� ������
  for obj in self.Imports do
    stl.Add(String(obj.Value));
end;

function TRMIBFile.Analyze(allfiles: TObjectList<TRMIBFile>): Boolean;
begin
  // ���������� ������� � ������ �������������� ������
  result := BuildAddresses(allfiles);
  if result = false then
    exit;

  // ���������� ����� � �������
  result := ChangeTypes(allfiles);

  // ���������� �������
  SortAddressObjects;
end;

{ TRMIBTokenizer }

procedure TRMIBTokenizer.skipComment;
var
  c: AnsiChar;
begin
  // ������� ���������� (�� ����� ������)

  while True do
  begin
    if FPosition > Length(FData) then
      exit;

    c := FData[FPosition];

    inc(FPosition);

    if isEndLine(c) then
      break;
  end;
end;

procedure TRMIBTokenizer.skipEndLine;
var
  c: AnsiChar;
begin
  // ������� �������� ������

  while True do
  begin
    if FPosition > Length(FData) then
      exit;

    c := FData[FPosition];

    if not isEndLine(c) then
      break;

    inc(FPosition);
  end;
end;

procedure TRMIBTokenizer.skipSpaces;
var
  c: AnsiChar;
begin
  // ������� ��������

  while True do
  begin
    if FPosition > Length(FData) then
      exit;

    c := FData[FPosition];

    if not isSpace(c) then
      break;

    inc(FPosition);
  end;
end;

function TRMIBTokenizer.isSemicolon(ch: AnsiChar): Boolean;
begin
  result := ch in [';'];
end;

function TRMIBTokenizer.isSpace(ch: AnsiChar): Boolean;
begin
  result := ch in [' ', #8, #9, #10, #13];
end;

function TRMIBTokenizer.isComment: Boolean;
var
  ch: AnsiChar;
begin
  // FPosition �� ��������

  // ����������� ��� ������ (--)
  ch := FData[FPosition];

  result := ch in ['-'];
  if result then
  begin
    if FPosition + 1 > Length(FData) then
      exit(false);

    ch := FData[FPosition + 1];
    result := ch in ['-'];
  end;
end;

function TRMIBTokenizer.isEndLine(ch: AnsiChar): Boolean;
begin
  result := ch in [#10, #13];
end;

function TRMIBTokenizer.isLeftBracer(ch: AnsiChar): Boolean;
begin
  result := ch in ['{'];
end;

function TRMIBTokenizer.isQuoted(ch: AnsiChar): Boolean;
begin
  result := ch in ['"'];
end;

function TRMIBTokenizer.isRightBracer(ch: AnsiChar): Boolean;
begin
  result := ch in ['}'];
end;

function TRMIBTokenizer.findChar(ch: AnsiChar): NativeInt;
var
  c: AnsiChar;
  p: NativeInt;
begin
  p := FPosition;
  while True do
  begin
    if p > Length(FData) then
      exit(-1);

    c := FData[p];

    if c = ch then
      break;

    inc(p);
  end;

  result := p;
end;

function TRMIBTokenizer.findCharInLine(ch: AnsiChar): NativeInt;
var
  c: AnsiChar;
  p: NativeInt;
begin
  p := FPosition;
  while True do
  begin
    if p > Length(FData) then
      exit(-1);

    c := FData[p];

    if isEndLine(c) then
      exit(-1);

    if c = ch then
      break;

    inc(p);
  end;

  result := p;
end;

function TRMIBTokenizer.findEndLine: NativeInt;
var
  p: NativeInt;
begin
  p := FPosition;
  while True do
  begin
    if p > Length(FData) then
      exit(-1);

    if isEndLine(FData[p]) then
      break;

    inc(p);
  end;

  result := p;
end;

function TRMIBTokenizer.findEndLineBack: NativeInt;
var
  p: NativeInt;
begin
  p := FPosition;
  while True do
  begin
    if Length(FData) = 0 then
      exit(-1);

    if p <= 0 then
      exit(-1);

    if isEndLine(FData[p]) then
      break;

    dec(p);
  end;

  result := p;
end;

function TRMIBTokenizer.getQuotedText: RawByteString;
var
  removedchars, beginline, endline, p: NativeInt;
begin
  if FData[FPosition] <> '"' then
    exit('');

  // �������� ����� � ��������
  inc(FPosition);

  // ��������� - ������������ �� ����� (����� �� ������� �����)
  p := findCharInLine('"');
  if p > 0 then
  begin
    // ����� ����������� - ����� ��� ����
    result := copy(FData, FPosition, p - FPosition);
    FPosition := p + 1;
  end
  else
  begin
    // ����� �������������.
    // ���� ������� ������ ������ �������� ���������� ��������, ������ ������� ������� + 1 �� ������ ������

    beginline := findEndLineBack;
    if beginline < 0 then
    begin
      if FPosition = 2 then
        removedchars := 0
      else
        removedchars := FPosition - 1;
    end
    else
    begin
      if FPosition - beginline = 2 then
        removedchars := 0
      else
        removedchars := FPosition - beginline - 1; // ���������� ���������� ��������
    end;

    p := FPosition;
    endline := findEndLine;
    if endline < 0 then
      endline := Length(FData) - 1;
    FPosition := endline;
    skipEndLine;
    // ������ ������
    result := copy(FData, p, FPosition - p);

    while True do
    begin
      p := findCharInLine('"'); // ���� � ������ �������
      if p < 0 then // ������� ���
      begin
        p := FPosition;
        endline := findEndLine;
        if endline < 0 then
        begin
          result := result + copy(FData, p + removedchars, Length(FData) - p + 1);
          break;
        end;
        FPosition := endline;
        skipEndLine;

        result := result + copy(FData, p + removedchars, FPosition - p - removedchars);
      end
      else
      begin
        result := result + copy(FData, FPosition + removedchars, p - FPosition - removedchars);
        FPosition := p + 1;
        break;
      end;
    end;

  end;
end;

function TRMIBTokenizer.getWord(var str: RawByteString; var lexemtype: TRLexemType): Boolean;
var
  w: RawByteString;
  c: AnsiChar;
begin
  // �������� �����, ������� �����������, ��������� ����� � ��������

  lexemtype := ltUnknown;

  skipSpaces; // ���������� �������

  while True do
  begin
    if FPosition > Length(FData) then
    begin
      if w = '' then // ����� ������
        exit(false);

      str := w;
      break;
    end;

    c := FData[FPosition];

    if isSpace(c) then
    begin // ����� �����
      if w <> '' then
      begin
        str := w;
        inc(FPosition);
        break;
      end;
    end
    else
    begin
      // ���� ������������ ���������� - ���������� �� ����� ������
      if isComment then
      begin
        skipComment;
        if w = '' then
        begin
          skipSpaces;
          continue;
        end;

        str := w;
        break;
      end
      else
      begin
        if isQuoted(c) then // �������
        begin
          if w = '' then
            w := getQuotedText;
          str := w;
          lexemtype := ltText;
          break;
        end
        else
        if isSemicolon(c) then // ����� � �������
        begin
          if w <> '' then
          begin
            str := w;
            break;
          end
          else
          begin
            str := c;
            lexemtype := ltSemicolon;
            inc(FPosition);
            break;
          end;
        end
        else
        if isLeftBracer(c) then // ����� �������� ������
        begin
          if w <> '' then
          begin
            str := w;
            break;
          end
          else
          begin
            str := c;
            lexemtype := ltLeftBracer;
            inc(FPosition);
            break;
          end;
        end
        else
        if isRightBracer(c) then // ������ �������� ������
        begin
          if w <> '' then
          begin
            str := w;
            break;
          end
          else
          begin
            str := c;
            lexemtype := ltRightBracer;
            inc(FPosition);
            break;
          end;
        end
        else
          w := w + c;
      end;
    end;

    inc(FPosition);
  end;

  result := true;
end;

function TRMIBTokenizer.Process(const str: RawByteString; list: TList<TPair<RawByteString, TRLexemType>>): Boolean;
var
  s: RawByteString;
  lexemtype: TRLexemType;
begin
  FPosition := 1;
  FData := str;

  while true do
  begin
    if not getWord(s, lexemtype) then
      break;

    list.Add(TPair<RawByteString, TRLexemType>.Create(s, lexemtype));
  end;

  result := list.Count <> 0;
end;

{ TRMIBLexer }

procedure TRMIBLexer.Clear;
begin
  FPosition := 0;
  FList.Clear;
  FMIBFile.Clear;
end;

constructor TRMIBLexer.Create;
begin

end;

destructor TRMIBLexer.Destroy;
begin

  inherited;
end;

function TRMIBLexer.findBeginMIB: NativeInt;
var
  i: NativeInt;
begin
  // ����� ������ ������
  if FPosition >= FList.Count - 2 then
    exit(-1);

  i := FPosition;
  while i < FList.Count - 2 do
  begin
    if (FList[i + 0].Key = 'DEFINITIONS') and
       (FList[i + 1].Key = '::=') and
       (FList[i + 2].Key = 'BEGIN') then
    begin
      exit(i);
    end;

    inc(i);
  end;

  exit(-1);
end;

function TRMIBLexer.findItem(const value: RawByteString; const breakvalue: RawByteString): NativeInt;
var
  i: NativeInt;
begin
  i := FPosition;
  while i < FList.Count do
  begin
    if (FList[i].Key = breakvalue) and (FList[i].Value <> ltText) then
      exit(-1);

    if FList[i].Key = value then
      exit(i);

    inc(i);
  end;

  exit(-1);
end;

function TRMIBLexer.getAddress(leftBracerPosition,
  rightBracerPosition: NativeInt; var values: TStringList): Boolean;
var
  i, value, p1, p2: NativeInt;
  prevname, str: RawByteString;
begin
//result := false;

  // ������ ������
  i := leftBracerPosition + 1;
  while i < rightBracerPosition do
  begin
    // ��-�� ����������� ������  iso(1) org(3) ieee(111) ������ �������������� ���������
    value := StrToIntDef(String(FList[i].Key), -1);
    if value >= 0 then // ������� �����
    begin
      if prevname <> '' then // ��������� ���������� ��������
      begin
        values.Add(String(prevname));
        prevname := '';
      end;

      values.Add(IntToStr(value))
    end
    else
    if (Length(FList[i].Key) > 0) and // ����� � �������
       (FList[i].Key[1] = '(') and
       (FList[i].Key[Length(FList[i].Key)] = ')') then
    begin
      str := copy(FList[i].Key, 2, Length(FList[i].Key) - 2);
      value := StrToIntDef(String(str), -1);
      prevname := '';
      values.Add(IntToStr(value));
    end
    else
    begin
      p1 := pos('(', String(FList[i].Key));
      p2 := pos(')', String(FList[i].Key));
      if (p1 > 0) and (p2 > 0) then // ����� � �� ��� ����� � �������
      begin
        str := copy(FList[i].Key, p1 + 1, p2 - p1 - 1);
        value := StrToIntDef(String(str), -1);

        if prevname <> '' then // ��������� ���������� ��������
        begin
          values.Add(String(prevname));
          prevname := '';
        end;

        values.Add(IntToStr(value))
      end
      else
      begin // ������ �����
        if prevname = '' then // ��������� ���������� ��������
          prevname := FList[i].Key
        else
        begin
          values.Add(String(prevname));
          prevname := '';
        end;
      end;
    end;

    inc(i);
  end;

  result := true;
end;

function TRMIBLexer.getAgentCapabilites: Boolean;
var
  p, leftBracer, rightBracer: NativeInt;
  name: RawByteString;
  obj: TRAgentCapabilites;
begin
  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit(false);

  if FPosition - 1 < 0 then
    exit(false);

  name := FList[FPosition - 1].Key;
  p := findItem('::=', '');
  if p = -1 then // ������������ ���������
    exit(false);
  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := rightBracer + 1;

  obj := TRAgentCapabilites.Create;
  obj.name := name;
  FMIBFile.AddressObjects.Add(obj);

  result := getAddress(leftBracer, rightBracer, obj.address);
end;

function TRMIBLexer.getChoice: Boolean;
var
  p: NativeInt;
begin
  // choice ���������� ���
  result := false;

  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit;

  if FPosition - 1 < 0 then
    exit;

//  name := list[FPosition - 1].Key;
  p := findItem('}', '');
  if p = -1 then // ������������ ���������
    exit;
  FPosition := p + 1;

  result := true;
end;

function TRMIBLexer.getEnumsStringPairs(leftBracerPosition,
  rightBracerPosition: NativeInt; var values: TList<TPair<RawByteString, RawByteString>>): Boolean;
var
  i: NativeInt;
  str1, str2: RawByteString;
begin
  // ������������ ������������
  // leftBracerPosition, rightBracerPosition - ������ ��������� �� ���������� { }

  result := false;

  if (leftBracerPosition < 0) or
     (rightBracerPosition < 0) or
     (rightBracerPosition - leftBracerPosition <= 0) or
     (rightBracerPosition >= FList.Count) then
    exit;

  i := leftBracerPosition + 1;
  while i < rightBracerPosition do
  begin
    str1 := FList[i + 0].Key;
    str2 := FList[i + 1].Key;

    if (Length(str2) > 0) and (str2[Length(str2)] = ',') then
      str2 := copy(str2, 1, Length(str2) - 1);

    values.Add(TPair<RawByteString, RawByteString>.Create(str1, str2));
    inc(i, 2);
  end;

  result := true;
end;

function TRMIBLexer.getEnumsWithNumbers(leftBracerPosition, rightBracerPosition: NativeInt;
  var values: TStringList): Boolean;
var
  i, value, p1, p2: NativeInt;
  prevname: String;
  name: String;
  str: RawByteString;
begin
  // ������������ ������������
  // leftBracerPosition, rightBracerPosition - ������ ��������� �� ���������� { }

  if (leftBracerPosition < 0) or
     (rightBracerPosition < 0) or
     (rightBracerPosition - leftBracerPosition <= 0) or
     (rightBracerPosition >= FList.Count) then
    exit(false);

  // ������ ������
  i := leftBracerPosition + 1;
  while i < rightBracerPosition do
  begin
    // ��-�� ����������� ������  name(1) ��� name (1) ������ �������������� ���������
    value := StrToIntDef(String(FList[i].Key), -1);
    if value >= 0 then // ������� �����
    begin
      if prevname <> '' then
      begin
        values.AddObject(prevname, TObject(value));
        prevname := '';
      end;
    end
    else
    if (Length(FList[i].Key) > 0) and // ����� � �������
       (FList[i].Key[1] = '(') and
       (
         (FList[i].Key[Length(FList[i].Key)] = ')') or
         (
           (FList[i].Key[Length(FList[i].Key)] = ',') and
           (FList[i].Key[Length(FList[i].Key) - 1] = ')')
         )
       )
       then
    begin
      p2 := pos(')', String(FList[i].Key));
      str := copy(FList[i].Key, 2, p2 - 2);
      value := StrToIntDef(String(str), -1);
      if prevname <> '' then
      begin
        values.AddObject(prevname, TObject(value));
        prevname := '';
      end;
    end
    else
    begin
      p1 := pos('(', String(FList[i].Key));
      p2 := pos(')', String(FList[i].Key));
      if (p1 > 0) and (p2 > 0) then // ����� � �� ��� ����� � �������
      begin
        str := copy(FList[i].Key, p1 + 1, p2 - p1 - 1);
        value := StrToIntDef(String(str), -1);

        if prevname <> '' then
          exit(false) // �������� ��������� - ����� ������ ���� ������ � ������
        else
        begin
          str := copy(FList[i].Key, 0, p1 - 1);
          values.AddObject(String(str), TObject(value));
        end;
      end
      else
      begin // ������ �����
        if prevname = '' then // ��������� ���������� ��������
          prevname := String(FList[i].Key)
        else
          exit(false); // �������� ��������� - ��� ������ ������
      end;
    end;

    inc(i);
  end;

  // �������� ��������� - ������������� ������� ��� �����
  result := prevname = '';
end;

function TRMIBLexer.getEnumsWithoutNumbers(leftBracerPosition,
  rightBracerPosition: NativeInt; var values: TStringList): Boolean;
var
  i: NativeInt;
  str: RawByteString;
begin
  // ������������ ������������
  // leftBracerPosition, rightBracerPosition - ������ ��������� �� ���������� { }

  if (leftBracerPosition < 0) or
     (rightBracerPosition < 0) or
     (rightBracerPosition - leftBracerPosition <= 0) or
     (rightBracerPosition >= FList.Count) then
    exit(false);

  i := leftBracerPosition + 1;
  while i < rightBracerPosition do
  begin
    str := FList[i].Key;
    if (Length(str) > 0) and (str[Length(str)] = ',') then
      str := copy(str, 1, Length(str) - 1);

    values.Add(String(str));
    inc(i);
  end;

  result := true;
end;

function TRMIBLexer.getImports: Boolean;
var
  i, p: NativeInt;
  valuetype, modulename: RawByteString;
begin
  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit(false);

  result := true;

  while true do
  begin
    if FPosition >= FList.Count then
      exit(false);

    if FList[FPosition].Value = ltSemicolon then
      exit;

    p := findItem('FROM', ';');
    if p = -1 then // ��� ����� from - ������ �� ������ ������
      exit(false);
    if p + 1 >= FList.Count then // ����� ����� from ��� ������
      exit(false);
    modulename := FList[p + 1].Key;

    i := FPosition;
    while i < p do
    begin
      if FList[i].Value = ltSemicolon then
        exit;

      valuetype := FList[i].Key;
      if valuetype[Length(valuetype)] = ',' then
        valuetype := copy(valuetype, 1, Length(valuetype) - 1);

      FMIBFile.Imports.Add(TPair<RawByteString, RawByteString>.Create(valuetype, modulename));
      inc(i);
    end;

    FPosition := p + 2;
  end;
end;

function TRMIBLexer.getMacro: Boolean;
var
  p: NativeInt;
begin
  // ������� ���������� ���
  result := false;

  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit;

  if FPosition - 1 < 0 then
    exit;

//  name := FList[FPosition - 1].Key;
  p := findItem('END', '');
  if p = -1 then // ������������ ���������
    exit;
  FPosition := p + 1;

  result := true;
end;

function TRMIBLexer.getModuleCompliance: Boolean;
var
  p, leftBracer, rightBracer: NativeInt;
  name: RawByteString;
  obj: TRModuleCompliance;
begin
  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit(false);

  if FPosition - 1 < 0 then
    exit(false);

  name := FList[FPosition - 1].Key;
  p := findItem('::=', '');
  if p = -1 then // ������������ ���������
    exit(false);
  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := rightBracer + 1;

  obj := TRModuleCompliance.Create;
  obj.name := name;
  FMIBFile.AddressObjects.Add(obj);

  result := getAddress(leftBracer, rightBracer, obj.address);
end;

function TRMIBLexer.getModuleIdentity: Boolean;
var
  p, leftBracer, rightBracer: NativeInt;
  name: RawByteString;
  obj: TRModuleIdentity;
begin
  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit(false);

  if FPosition - 1 < 0 then
    exit(false);

  name := FList[FPosition - 1].Key;
  p := findItem('::=', '');
  if p = -1 then // ������������ ���������
    exit(false);
  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := rightBracer + 1;

  obj := TRModuleIdentity.Create;
  obj.name := name;
  FMIBFile.AddressObjects.Add(obj);

  result := getAddress(leftBracer, rightBracer, obj.address);
end;

function TRMIBLexer.getNotificationGroup: Boolean;
var
  p, leftBracer, rightBracer: NativeInt;
  obj: TRNotificationGroup;
begin
  result := false;

  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit;

  if FPosition - 1 < 0 then
    exit;

  obj := TRNotificationGroup.Create;
  obj.name := FList[FPosition - 1].Key;

  p := findItem('STATUS', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.status := FList[p + 1].Key;

  p := findItem('DESCRIPTION', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.description := FList[p + 1].Key;

  p := findItem('NOTIFICATIONS', '::=');
  if p = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := rightBracer + 1;

  getEnumsWithoutNumbers(leftBracer, rightBracer, obj.notifications);

  p := findItem('::=', '');
  if (p < 0) or (p + 1 >= FList.Count) then
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;
  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  result := getAddress(leftBracer, rightBracer, obj.address);

  if result then
    FMIBFile.AddressObjects.Add(obj)
  else
    FreeAndNil(obj);

  result := true;
end;

function TRMIBLexer.getNotificationType: Boolean;
var
  p, leftBracer, rightBracer: NativeInt;
  obj: TRNotificationType;
begin
  result := false;

  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit;

  if FPosition - 1 < 0 then
    exit;

  obj := TRNotificationType.Create;
  obj.name := FList[FPosition - 1].Key;

  p := findItem('STATUS', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.status := FList[p + 1].Key;

  p := findItem('DESCRIPTION', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.description := FList[p + 1].Key;

  p := findItem('REFERENCE', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.treference := FList[p + 1].Key;

  p := findItem('OBJECTS', '::=');
  if p = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := rightBracer + 1;

  getEnumsWithoutNumbers(leftBracer, rightBracer, obj.objects);

  p := findItem('::=', '');
  if (p < 0) or (p + 1 >= FList.Count) then
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;
  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  result := getAddress(leftBracer, rightBracer, obj.address);

  if result then
    FMIBFile.AddressObjects.Add(obj)
  else
    FreeAndNil(obj);

  result := true;
end;

function TRMIBLexer.getObjectGroup: Boolean;
var
  p, leftBracer, rightBracer: NativeInt;
  obj: TRObjectGroup;
begin
  result := false;

  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit;

  if FPosition - 1 < 0 then
    exit;

  obj := TRObjectGroup.Create;
  obj.name := FList[FPosition - 1].Key;

  p := findItem('STATUS', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.status := FList[p + 1].Key;

  p := findItem('DESCRIPTION', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.description := FList[p + 1].Key;

  p := findItem('OBJECTS', '::=');
  if p = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := rightBracer + 1;

  getEnumsWithoutNumbers(leftBracer, rightBracer, obj.objects);

  p := findItem('::=', '');
  if (p < 0) or (p + 1 >= FList.Count) then
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;
  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  result := getAddress(leftBracer, rightBracer, obj.address);

  if result then
    FMIBFile.AddressObjects.Add(obj)
  else
    FreeAndNil(obj);

  result := true;
end;

function TRMIBLexer.getObjectIdentifier: Boolean;
var
  p, leftBracer, rightBracer: NativeInt;
  name: RawByteString;
  obj: TRObjectIdentifier;
begin
  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit(false);

  if FPosition - 1 < 0 then
    exit(false);

  name := FList[FPosition - 1].Key;
  p := findItem('::=', '');
  if p = -1 then // ������������ ���������
    exit(false);
  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := rightBracer + 1;

  obj := TRObjectIdentifier.Create;
  obj.name := name;
  FMIBFile.AddressObjects.Add(obj);

  result := getAddress(leftBracer, rightBracer, obj.address);
end;

function TRMIBLexer.getObjectIdentity: Boolean;
var
  p, leftBracer, rightBracer: NativeInt;
  name: RawByteString;
  obj: TRObjectIdentity;
begin
  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit(false);

  if FPosition - 1 < 0 then
    exit(false);

  name := FList[FPosition - 1].Key;
  p := findItem('::=', '');
  if p = -1 then // ������������ ���������
    exit(false);
  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
    exit(false);
  FPosition := rightBracer + 1;

  obj := TRObjectIdentity.Create;
  obj.name := name;
  FMIBFile.AddressObjects.Add(obj);

  result := getAddress(leftBracer, rightBracer, obj.address);
end;

function TRMIBLexer.getObjectType: Boolean;
var
  p, p1, p2: NativeInt;
  name, valuetype: RawByteString;
  leftBracer, rightBracer: NativeInt;
  obj: TRObjectType;
begin
  result := false;

  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit(false);

  if FPosition - 1 < 0 then
    exit(false);

  name := FList[FPosition - 1].Key;

  inc(FPosition);

  // SYNTAX - ������������ ����������� ��������
  p := findItem('SYNTAX', '::=');
  if p = -1 then // ������������ ��������� - ��� ����
    exit;

  if (p + 1 >= FList.Count) then
    exit;

  obj := TRObjectType.Create;
  obj.name := name;

  if (p + 2 < FList.Count) and
     (FList[p + 1].Key = 'OCTET') and
     (FList[p + 2].Key = 'STRING') then
    obj.syntax := 'OCTET STRING'
  else
  if (p + 2 < FList.Count) and
     (FList[p + 1].Key = 'OBJECT') and
     (FList[p + 2].Key = 'IDENTIFIER') then
    obj.syntax := 'OBJECT IDENTIFIER'
  else
  if  (p + 3 < FList.Count) and
      (FList[p + 1].Key = 'SEQUENCE') and
      (FList[p + 2].Key = 'OF') then
    obj.syntax := 'SEQUENCE OF ' // + FList[p + 3].Key
  else
  begin
    obj.syntax := FList[p + 1].Key;
    p := pos('(', String(obj.syntax));
    if p > 0 then
      obj.syntax := copy(obj.syntax, 1, p - 1);
  end;

  p := findItem('MAX-ACCESS', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.maxaccess := FList[p + 1].Key;

  p := findItem('STATUS', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.status := FList[p + 1].Key;

  p := findItem('DESCRIPTION', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.description := FList[p + 1].Key;

  p := findItem('REFERENCE', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.treference := FList[p + 1].Key;

  p := findItem('INDEX', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
  begin // INDEX - ��� ������� ������������
    if FList[p + 1].Value = ltLeftBracer then
    begin
      FPosition := p + 1;
      rightBracer := findItem('}', '::=');
      if rightBracer >= 0 then
      begin
        getEnumsWithoutNumbers(p + 1, rightBracer, obj.index);
      end;
    end;
  end;

  p := findItem('::=', '');
  if (p < 0) or (p + 1 >= FList.Count) then
  begin
    FreeAndNil(obj);
    exit;
  end;

  FPosition := p + 1;

  leftBracer := findItem('{', '}');
  if leftBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;
  FPosition := leftBracer + 1;

  rightBracer := findItem('}', '');
  if rightBracer = -1 then // ������������ ���������
  begin
    FreeAndNil(obj);
    exit;
  end;

  result := getAddress(leftBracer, rightBracer, obj.address);

  if result then
    FMIBFile.AddressObjects.Add(obj)
  else
    FreeAndNil(obj);
end;

function TRMIBLexer.getSequence: Boolean;
var
  rightBracer: NativeInt;
  obj: TRSequence;
begin
  result := false;

  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit;

  if FPosition - 1 < 0 then
    exit;

  obj := TRSequence.Create;
  obj.name := FList[FPosition - 1].Key;

  inc(FPosition, 2);

  rightBracer := findItem('}', '');
  if rightBracer >= 0 then
    getEnumsStringPairs(FPosition, rightBracer, obj.sequences)
  else
  begin
    FreeAndNil(obj);
    exit;
  end;

  FMIBFile.Sequences.Add(obj);

  result := true;
end;

function TRMIBLexer.getTextualConvention: Boolean;
var
  p, p1, p2: NativeInt;
  name: RawByteString;

  obj: TRTextualConvention;
begin
  result := false;

  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit;

  if FPosition - 1 < 0 then
    exit;

  name := FList[FPosition - 1].Key;

  inc(FPosition, 2);

  // SYNTAX - ������������ ����������� ��������
  p := findItem('SYNTAX', '::=');
  if p = -1 then // ������������ ���������
    exit;

  if (p + 1 >= FList.Count) then
    exit;

  obj := TRTextualConvention.Create;
  FMIBFile.TextualConventions.Add(obj);
  obj.name := name;
  if (p + 2 < FList.Count) and
     (FList[p + 1].Key = 'OCTET') and
     (FList[p + 2].Key = 'STRING') then
    obj.syntax := 'OCTET STRING'
  else
  if (p + 2 < FList.Count) and
     (FList[p + 1].Key = 'OBJECT') and
     (FList[p + 2].Key = 'IDENTIFIER') then
    obj.syntax := 'OBJECT IDENTIFIER'
  else
    obj.syntax := FList[p + 1].Key;

  // �������� �� ������������� ��� INTEGER { false(0), true(1) }
  if (FList[p + 1].Key = 'INTEGER') and
     (FList[p + 2].Value = ltLeftBracer) then
  begin
    // ��������� ������������
    //p1 := p + 2;
    p2 := findItem('}', '::=');
    if p2 >= 0 then
      getEnumsWithNumbers(p + 2, p2, obj.enumvalues);
  end;

  p := findItem('DISPLAY-HINT', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.displayhint := FList[p + 1].Key;

  p := findItem('STATUS', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.status := FList[p + 1].Key;

  p := findItem('DESCRIPTION', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.description := FList[p + 1].Key;

  p := findItem('REFERENCE', '::=');
  if (p >= 0) and (p + 1 < FList.Count) then
    obj.treference := FList[p + 1].Key;

  result := true;
end;

function TRMIBLexer.isAgentCapabilites: Boolean;
begin
  if (FPosition < 0) or
     (FPosition >= FList.Count - 1) or
     (FList[FPosition + 1].Key = 'MACRO') then
    exit(false);

  result := FList[FPosition].Key = 'AGENT-CAPABILITIES';
end;

function TRMIBLexer.isChoice: Boolean;
begin
  result := false;
  if (FPosition < 0) or (FPosition >= FList.Count - 2) then
    exit;

  if (FList[FPosition + 0].Key = '::=') and
     (FList[FPosition + 1].Key = 'CHOICE') and
     (FList[FPosition + 2].Key = '{') then
    exit(true)
end;

function TRMIBLexer.isEndMIB: Boolean;
begin
  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit(false);

  result := FList[FPosition].Key = 'END';
end;

function TRMIBLexer.isImports: Boolean;
begin
  if (FPosition < 0) or (FPosition >= FList.Count) then
    exit(false);

  result := FList[FPosition].Key = 'IMPORTS';
end;

function TRMIBLexer.isMacro: Boolean;
begin
  result := false;
  if (FPosition < 0) or (FPosition >= FList.Count - 2) then
    exit;

  if (FList[FPosition + 0].Key = 'MACRO') and
     (FList[FPosition + 1].Key = '::=') and
     (FList[FPosition + 2].Key = 'BEGIN') then
    exit(true)
end;

function TRMIBLexer.isModuleCompliance: Boolean;
begin
  if (FPosition < 0) or
     (FPosition >= FList.Count - 1) or
     (FList[FPosition + 1].Key = 'MACRO') then
    exit(false);

  result := FList[FPosition].Key = 'MODULE-COMPLIANCE';
end;

function TRMIBLexer.isModuleIdentity: Boolean;
begin
  if (FPosition < 0) or
     (FPosition >= FList.Count - 1) or
     (FList[FPosition + 1].Key = 'MACRO') then
    exit(false);

  result := FList[FPosition].Key = 'MODULE-IDENTITY';
end;

function TRMIBLexer.isNotificationGroup: Boolean;
begin
  if (FPosition < 0) or
     (FPosition >= FList.Count - 1) or
     (FList[FPosition + 1].Key = 'MACRO') then
    exit(false);

  result := FList[FPosition].Key = 'NOTIFICATION-GROUP';
end;

function TRMIBLexer.isNotificationType: Boolean;
begin
  if (FPosition < 0) or
     (FPosition >= FList.Count - 1) or
     (FList[FPosition + 1].Key = 'MACRO') then
    exit(false);

  result := FList[FPosition].Key = 'NOTIFICATION-TYPE';
end;

function TRMIBLexer.isObjectGroup: Boolean;
begin
  if (FPosition < 0) or
     (FPosition >= FList.Count - 1) or
     (FList[FPosition + 1].Key = 'MACRO') then
    exit(false);

  result := FList[FPosition].Key = 'OBJECT-GROUP';
end;

function TRMIBLexer.isObjectIdentifier: Boolean;
begin
  result := false;
  if (FPosition < 0) or
     (FPosition >= FList.Count - 4) then
    exit;

  if (FList[FPosition + 0].Key = 'OBJECT') and
     (FList[FPosition + 1].Key = 'IDENTIFIER') and
     (FList[FPosition + 2].Key = '::=') and
     (FList[FPosition + 3].Key = '{')  then
     exit(true)
end;

function TRMIBLexer.isObjectIdentity: Boolean;
begin
  if (FPosition < 0) or
     (FPosition >= FList.Count - 1) or
     (FList[FPosition + 1].Key = 'MACRO') then
    exit(false);

  result := FList[FPosition].Key = 'OBJECT-IDENTITY';
end;

function TRMIBLexer.isObjectType: Boolean;
begin
  if (FPosition < 0) or
     (FPosition >= FList.Count - 1) or
     (FList[FPosition + 1].Key = 'MACRO') then
    exit(false);

  result := FList[FPosition].Key = 'OBJECT-TYPE';
end;

function TRMIBLexer.isSequence: Boolean;
begin
  result := false;
  if (FPosition < 0) or (FPosition >= FList.Count - 2) then
    exit;

  if (FList[FPosition + 0].Key = '::=') and
     (FList[FPosition + 1].Key = 'SEQUENCE') and
     (FList[FPosition + 2].Key = '{') then
    exit(true)
end;

function TRMIBLexer.isTextualConvention: Boolean;
begin
  result := false;
  if (FPosition < 0) or (FPosition >= FList.Count - 1) then
    exit;

  if (FList[FPosition + 0].Key = '::=') and
     (FList[FPosition + 1].Key = 'TEXTUAL-CONVENTION') then
     exit(true)
end;

function TRMIBLexer.Process(var MIBFile: TRMIBFile): Boolean;
begin
  result := false;

  FList := MIBFile.FList;
  FMIBFile := MIBFile;
  FPosition := 0;

  // ����� ������ ������ mib
  FPosition := findBeginMIB;
  if FPosition < 0 then
    exit;
  MIBFile.Name := FList[FPosition - 1].Key;
  inc(FPosition, 3);

  // ����� ������� ������
  while FPosition < FList.Count do
  begin
    // ����� ������
    if isEndMIB then
      break;

    // ���� �������
    if isImports then
    begin
      inc(FPosition);
      getImports;
      inc(FPosition);
    end;

    // ���� �������
    if isModuleIdentity then
      getModuleIdentity;

    // ����� �������
    if isObjectIdentifier then
      getObjectIdentifier;

    if isTextualConvention then
      getTextualConvention;

    if isObjectType then
      getObjectType;

    if isSequence then
      getSequence;

    if isObjectGroup then
      getObjectGroup;

    if isNotificationGroup then
      getNotificationGroup;

    if isNotificationType then
      getNotificationType;

    if isMacro then
      getMacro;

    if isChoice then
      getChoice;

    if isModuleCompliance then
      getModuleCompliance;

    if isAgentCapabilites then
      getAgentCapabilites;

    if isObjectIdentity then
      getObjectIdentity;

    inc(FPosition);
  end;

  result := true;
end;

{ TRTextualConversion }

constructor TRTextualConvention.Create;
begin
  enumvalues := TStringList.Create
end;

destructor TRTextualConvention.Destroy;
begin
  FreeAndNil(enumvalues);
  inherited;
end;

{ TRObjectType }

constructor TRObjectType.Create;
begin
  inherited;

  index := TStringList.Create;
end;

destructor TRObjectType.Destroy;
begin

  FreeAndNil(index);

  inherited;
end;

{ TRSequence }

constructor TRSequence.Create;
begin
  sequences := TList<TPair<RawByteString, RawByteString>>.Create;
end;

destructor TRSequence.Destroy;
begin
  FreeAndNIl(sequences);
  inherited;
end;

{ TRObjectGroup }

constructor TRObjectGroup.Create;
begin
  inherited;
  objects := TStringList.Create;
end;

destructor TRObjectGroup.Destroy;
begin
  FreeAndNil(objects);

  inherited;
end;

{ TRNotificationGroup }

constructor TRNotificationGroup.Create;
begin
  inherited;
  notifications := TStringList.Create;
end;

destructor TRNotificationGroup.Destroy;
begin
  FreeAndNil(notifications);
  inherited;
end;

{ TRNotificationType }

constructor TRNotificationType.Create;
begin
  inherited;
  objects := TStringList.Create;
end;

destructor TRNotificationType.Destroy;
begin
  FreeAndNil(objects);
  inherited;
end;

end.

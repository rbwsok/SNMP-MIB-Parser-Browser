unit testmib;

interface

uses System.SysUtils, System.Classes, Generics.Collections, DUnitX.TestFramework, DUnitX.RUtils, SNMPParserMIB;

type
  TRTextMIBTokenizer = class(TRMIBTokenizer)
  public
    procedure SetData(const text: RawByteString);

    procedure TestEmpty;
    procedure TestisSpace;
    procedure TestisEndLine;
    procedure TestisQuoted;
    procedure TestisComment;
    procedure TestskipSpaces;
    procedure TestskipComment;
    procedure TestskipEndLine;
    procedure TestfindChar;
    procedure TestfindCharInLine;
    procedure TestfindEndLineBack;
    procedure TestfindEndLine;
    procedure TestgetQuotedText;
    procedure TestisSemicolon;
    procedure TestisLeftBracer;
    procedure TestisRightBracer;
  end;

  TRTextMIBLexer = class(TRMIBLexer)
  public
    procedure TestfindItem;
    procedure TestfindBeginMIB;

    procedure TestisEndMIB;
    procedure TestisModuleIdentity;
    procedure TestisImports;
    procedure TestisTextualConvention;
    procedure TestisSequence;
    procedure TestisObjectType;
    procedure TestisObjectGroup;
    procedure TestisNotificationGroup;
    procedure TestisNotificationType;
    procedure TestisMacro;
    procedure TestisChoice;
    procedure TestisModuleCompliance;
    procedure TestisAgentCapabilites;
    procedure TestisObjectIdentity;

    procedure TestgetEnumsWithNumbers;
    procedure TestgetEnumsWithoutNumbers;
    procedure TestgetImports;
    procedure TestgetModuleIdentity;
    procedure TestgetObjectIdentifier;
    procedure TestgetTextualConvention;
    procedure TestgetObjectType;
    procedure TestgetSequence;
    procedure TestgetEnumsStringPairs;
    procedure TestgetObjectGroup;
    procedure TestgetNotificationGroup;
    procedure TestgetNotificationType;
    procedure TestgetMacro;
    procedure TestgetChoice;
    procedure TestgetModuleCompliance;
    procedure TestgetAgentCapabilites;
    procedure TestgetObjectIdentity;

    constructor Create;
    destructor Destroy; override;
  end;

  [TestFixture]
  TMibTest = class
  public
    [Test]
    procedure TestTokenizer;

    [Test]
    procedure TestLexer;
  end;

implementation

{ TMibTest }

procedure TMibTest.TestLexer;
var
  lexer: TRTextMIBLexer;
begin
  lexer := TRTextMIBLexer.Create;
  try
    lexer.TestfindBeginMIB;
    lexer.TestfindItem;

    lexer.TestisEndMIB;
    lexer.TestisModuleIdentity;
    lexer.TestisImports;
    lexer.TestisTextualConvention;
    lexer.TestisObjectType;
    lexer.TestisSequence;
    lexer.TestisObjectGroup;
    lexer.TestisNotificationGroup;
    lexer.TestisMacro;
    lexer.TestisChoice;
    lexer.TestisAgentCapabilites;
    lexer.TestisModuleCompliance;
    lexer.TestisObjectIdentity;

    lexer.TestgetEnumsWithNumbers;
    lexer.TestgetEnumsWithoutNumbers;
    lexer.TestgetImports;
    lexer.TestgetModuleIdentity;
    lexer.TestgetObjectIdentifier;
    lexer.TestgetTextualConvention;
    lexer.TestgetObjectType;
    lexer.TestgetEnumsStringPairs;
    lexer.TestgetSequence;
    lexer.TestgetObjectGroup;
    lexer.TestgetNotificationGroup;
    lexer.TestgetNotificationType;
    lexer.TestgetMacro;
    lexer.TestgetChoice;
    lexer.TestgetAgentCapabilites;
    lexer.TestgetModuleCompliance;
    lexer.TestgetObjectIdentity;

  finally
    FreeAndNil(lexer);
  end;
end;

procedure TMibTest.TestTokenizer;
var
  tokenizer: TRTextMIBTokenizer;
begin
  tokenizer := TRTextMIBTokenizer.Create;
  try
    tokenizer.TestEmpty;
    tokenizer.TestisSpace;
    tokenizer.TestisEndLine;
    tokenizer.TestisQuoted;
    tokenizer.TestisComment;
    tokenizer.TestisSemicolon;
    tokenizer.TestisLeftBracer;
    tokenizer.TestisRightBracer;
    tokenizer.TestskipSpaces;
    tokenizer.TestskipComment;
    tokenizer.TestskipEndLine;
    tokenizer.TestfindChar;
    tokenizer.TestfindCharInLine;
    tokenizer.TestfindEndLineBack;
    tokenizer.TestfindEndLine;
    tokenizer.TestgetQuotedText;
  finally
    FreeAndNil(tokenizer);
  end;
end;

{ TRTextMIBTokenizer }

procedure TRTextMIBTokenizer.TestfindChar;
begin
  SetData('');
  TRTest.CheckEqual('findChar 1', findChar('a'), -1);
  SetData('a');
  TRTest.CheckEqual('findChar 2', findChar('a'), 1);
  SetData('  a');
  TRTest.CheckEqual('findChar 3', findChar('a'), 3);
  SetData('  '#13#10'  ffa');
  TRTest.CheckEqual('findChar 4', findChar('a'), 9);
end;

procedure TRTextMIBTokenizer.TestfindCharInLine;
begin
  SetData('');
  TRTest.CheckEqual('findCharInLine 1', findCharInLine('a'), -1);
  SetData('a');
  TRTest.CheckEqual('findCharInLine 2', findCharInLine('a'), 1);
  SetData('  a');
  TRTest.CheckEqual('findCharInLine 3', findCharInLine('a'), 3);
  SetData('  '#13#10'  ffa');
  TRTest.CheckEqual('findCharInLine 4', findCharInLine('a'), -1);
end;

procedure TRTextMIBTokenizer.TestfindEndLine;
begin
  SetData('');
  TRTest.CheckEqual('findEndLine 1', findEndLine, -1);
  SetData('a');
  TRTest.CheckEqual('findEndLine 2', findEndLine, -1);
  SetData('  a');
  TRTest.CheckEqual('findEndLine 3', findEndLine, -1);
  SetData('  '#13#10'  ffa');
  TRTest.CheckEqual('findEndLine 4', findEndLine, 3);
  SetData('  '#13'  ffa');
  TRTest.CheckEqual('findEndLine 5', findEndLine, 3);
  SetData('  '#10'  ffa');
  TRTest.CheckEqual('findEndLine 6', findEndLine, 3);
end;

procedure TRTextMIBTokenizer.TestfindEndLineBack;
begin
  SetData('');
  TRTest.CheckEqual('findEndLineBack 1', findEndLineBack, -1);
  SetData('a');
  TRTest.CheckEqual('findEndLineBack 2', findEndLineBack, -1);
  SetData('  '#10'  ffa'); FPosition := 5;
  TRTest.CheckEqual('findEndLineBack 3', findEndLineBack, 3);
  SetData('  '#10#13'  ffa'); FPosition := 6;
  TRTest.CheckEqual('findEndLineBack 4', findEndLineBack, 4);
end;

procedure TRTextMIBTokenizer.TestgetQuotedText;
begin
  SetData('ffff -- ffff');
  TRTest.CheckEqual('getQuotedText 1', getQuotedText, RawByteString(''));
  SetData('"ffff -- ffff"');
  TRTest.CheckEqual('getQuotedText 2', getQuotedText, RawByteString('ffff -- ffff'));
  SetData('"ffff" -- ffff');
  TRTest.CheckEqual('getQuotedText 3', getQuotedText, RawByteString('ffff'));
  SetData('"ffff -- '#13#13'ff"ff');
  TRTest.CheckEqual('getQuotedText 4', getQuotedText, RawByteString('ffff -- '#13#13'ff'));
  SetData('"ffff -- '#13#13'ffff');
  TRTest.CheckEqual('getQuotedText 5', getQuotedText, RawByteString('ffff -- '#13#13'ffff'));
  SetData('"ffff -- '#13#13'ffff'#13'aaa');
  TRTest.CheckEqual('getQuotedText 6', getQuotedText, RawByteString('ffff -- '#13#13'ffff'#13'aaa'));
  SetData('"ffff -');
  TRTest.CheckEqual('getQuotedText 7', getQuotedText, RawByteString('ffff -'));
  SetData('   "ffff -'#10'    aaaa -'#10'    bbbb"'); FPosition := 4;
  TRTest.CheckEqual('getQuotedText 8', getQuotedText, RawByteString('ffff -'#10'aaaa -'#10'bbbb'));
  SetData('   ffff -'#10'  " aaaa -'#10'    bbbb"'); FPosition := 13;
  TRTest.CheckEqual('getQuotedText 9', getQuotedText, RawByteString(' aaaa -'#10' bbbb'));
  SetData('   ffff -'#10'  " aaaa -'#10'    bbbb'); FPosition := 13;
  TRTest.CheckEqual('getQuotedText 10', getQuotedText, RawByteString(' aaaa -'#10' bbbb'));
  SetData('   '#10'"ffff -'#10'    aaaa -'#10'    bbbb"'); FPosition := 5;
  TRTest.CheckEqual('getQuotedText 11', getQuotedText, RawByteString('ffff -'#10'    aaaa -'#10'    bbbb'));
end;

procedure TRTextMIBTokenizer.TestisComment;
begin
  SetData('ffff -- ffff');
  TRTest.CheckEqual('isComment 1', isComment, false);
  SetData('-- ffff');
  TRTest.CheckEqual('isComment 2', isComment, true);
  SetData('--');
  TRTest.CheckEqual('isComment 2', isComment, true);
  SetData('-');
  TRTest.CheckEqual('isComment 2', isComment, false);
end;

procedure TRTextMIBTokenizer.TestisEndLine;
begin
  TRTest.CheckEqual('isEndLine 1', isEndLine(' '), false);
  TRTest.CheckEqual('isEndLine 2', isEndLine(#10), true);
  TRTest.CheckEqual('isEndLine 3', isEndLine(#13), true);
  TRTest.CheckEqual('isEndLine 4', isEndLine('z'), false);
  TRTest.CheckEqual('isEndLine 5', isEndLine(#$ff), false);
end;

procedure TRTextMIBTokenizer.TestisLeftBracer;
begin
  TRTest.CheckEqual('isLeftBracer 1', isLeftBracer('{'), true);
  TRTest.CheckEqual('isLeftBracer 2', isLeftBracer(#10), false);
  TRTest.CheckEqual('isLeftBracer 3', isLeftBracer(#13), false);
end;

procedure TRTextMIBTokenizer.TestisQuoted;
begin
  TRTest.CheckEqual('isQuoted 1', isQuoted('"'), true);
  TRTest.CheckEqual('isQuoted 2', isQuoted(#10), false);
  TRTest.CheckEqual('isQuoted 3', isQuoted(#13), false);
end;

procedure TRTextMIBTokenizer.TestisRightBracer;
begin
  TRTest.CheckEqual('isRightBracer 1', isRightBracer('}'), true);
  TRTest.CheckEqual('isRightBracer 2', isRightBracer(#10), false);
  TRTest.CheckEqual('isRightBracer 3', isRightBracer(#13), false);
end;

procedure TRTextMIBTokenizer.SetData(const text: RawByteString);
begin
  FData := text;
  FPosition := 1;
end;

procedure TRTextMIBTokenizer.TestEmpty;
var
  list: TList<TPair<RawByteString, TRLexemType>>;
begin
  list := TList<TPair<RawByteString, TRLexemType>>.Create;
  try
    TRTest.CheckEqual('Empty data', Process('', list), false);
  finally
    FreeAndNil(list);
  end;
end;

procedure TRTextMIBTokenizer.TestisSemicolon;
begin
  TRTest.CheckEqual('isSemicolon 1', isSemicolon(';'), true);
  TRTest.CheckEqual('isSemicolon 2', isSemicolon(#10), false);
  TRTest.CheckEqual('isSemicolon 3', isSemicolon(#13), false);
end;

procedure TRTextMIBTokenizer.TestisSpace;
begin
  TRTest.CheckEqual('isSpace 1', isSpace(' '), true);
  TRTest.CheckEqual('isSpace 2', isSpace(#8), true);
  TRTest.CheckEqual('isSpace 3', isSpace(#10), true);
  TRTest.CheckEqual('isSpace 4', isSpace(#13), true);
  TRTest.CheckEqual('isSpace 5', isSpace('z'), false);
  TRTest.CheckEqual('isSpace 6', isSpace(#$ff), false);
end;

procedure TRTextMIBTokenizer.TestskipSpaces;
begin
  SetData('-- ffff'); skipSpaces;
  TRTest.CheckEqual('skipSpaces 1', FPosition, 1);
  SetData('   -- ffff'); skipSpaces;
  TRTest.CheckEqual('skipSpaces 2', FPosition, 4);
  SetData('   '#10'-- ffff'); skipSpaces;
  TRTest.CheckEqual('skipSpaces 3', FPosition, 5);
  SetData('   '#10#13'-- ffff'); skipSpaces;
  TRTest.CheckEqual('skipSpaces 4', FPosition, 6);
  SetData('   '#13#10'-- ffff'); skipSpaces;
  TRTest.CheckEqual('skipSpaces 5', FPosition, 6);
  SetData('   '#8#8'-- ffff'); skipSpaces;
  TRTest.CheckEqual('skipSpaces 6', FPosition, 6);
  SetData('  '#13#10' '#8#8' -- ffff'); skipSpaces;
  TRTest.CheckEqual('skipSpaces 7', FPosition, 9);
  SetData(''); skipSpaces;
  TRTest.CheckEqual('skipSpaces 8', FPosition, 1);
end;

procedure TRTextMIBTokenizer.TestskipComment;
begin
  SetData(''); skipComment;
  TRTest.CheckEqual('skipComment 1', FPosition, 1);
  SetData('rrr'); skipComment;
  TRTest.CheckEqual('skipComment 2', FPosition, 4);
  SetData('12345678'#13#10'   ererte'); skipComment;
  TRTest.CheckEqual('skipComment 3', FPosition, 10);
  SetData('123'#13#10); skipComment;
  TRTest.CheckEqual('skipComment 4', FPosition, 5);
  SetData('123'#10); skipComment;
  TRTest.CheckEqual('skipComment 5', FPosition, 5);
  SetData('123'#13); skipComment;
  TRTest.CheckEqual('skipComment 6', FPosition, 5);
end;

procedure TRTextMIBTokenizer.TestskipEndLine;
begin
  SetData(''); skipEndLine;
  TRTest.CheckEqual('skipEndLine 1', FPosition, 1);
  SetData('rrr'); skipEndLine;
  TRTest.CheckEqual('skipEndLine 2', FPosition, 1);
  SetData(#13#10'1234'); skipEndLine;
  TRTest.CheckEqual('skipEndLine 3', FPosition, 3);
  SetData(#10'1234'); skipEndLine;
  TRTest.CheckEqual('skipEndLine 4', FPosition, 2);
  SetData(#13#10#13#10'1234'); skipEndLine;
  TRTest.CheckEqual('skipEndLine 5', FPosition, 5);
  SetData(#13#10#13#10); skipEndLine;
  TRTest.CheckEqual('skipEndLine 6', FPosition, 5);
end;

{ TRTextMIBLexer }

constructor TRTextMIBLexer.Create;
begin
  inherited;
  FPosition := 0;
  FList := TList<TPair<RawByteString, TRLexemType>>.Create;

  FMIBFile := TRMIBFile.Create;
end;

destructor TRTextMIBLexer.Destroy;
begin
  FreeAndNil(FList);
  FreeAndNil(FMIBFile);
  inherited;
end;

procedure TRTextMIBLexer.TestfindBeginMIB;
begin
  Clear;
  TRTest.CheckEqual('findBeginMIB 1', findBeginMIB, -1);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('DEFINITIONS', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('findBeginMIB 2', findBeginMIB, -1);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  TRTest.CheckEqual('findBeginMIB 3', findBeginMIB, 1);
  FPosition := 2;
  TRTest.CheckEqual('findBeginMIB 4', findBeginMIB, -1);
end;

procedure TRTextMIBLexer.TestfindItem;
begin
  Clear;
  TRTest.CheckEqual('findItem 1', findItem('a', 'b'), -1);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('3', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('4', ltUnknown));
  TRTest.CheckEqual('findItem 2', findItem('5', '4'), -1);
  TRTest.CheckEqual('findItem 3', findItem('a', 'b'), -1);
  TRTest.CheckEqual('findItem 4', findItem('3', '4'), 2);
  TRTest.CheckEqual('findItem 5', findItem('3', '2'), -1);
end;

procedure TRTextMIBLexer.TestgetAgentCapabilites;
begin
  Clear;
  TRTest.CheckEqual('getAgentCapabilites 1', getAgentCapabilites, false);

  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getAgentCapabilites 2', getAgentCapabilites, false);

  FPosition := 1;
  TRTest.CheckEqual('getAgentCapabilites 3', getAgentCapabilites, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('AGENT-CAPABILITIES', ltUnknown));
  TRTest.CheckEqual('getAgentCapabilites 4', getAgentCapabilites, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  TRTest.CheckEqual('getAgentCapabilites 5', getAgentCapabilites, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getAgentCapabilites 6', getAgentCapabilites, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getAgentCapabilites 7', getAgentCapabilites, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getAgentCapabilites 8', getAgentCapabilites, true);
  TRTest.CheckEqual('getAgentCapabilites 9', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getAgentCapabilites 10', FMIBFile.AddressObjects[0].address.Count, 0);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('AGENT-CAPABILITIES', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('3', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('6', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getAgentCapabilites 11', getAgentCapabilites, true);
  TRTest.CheckEqual('getAgentCapabilites 12', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getAgentCapabilites 13', FMIBFile.AddressObjects[0].address.Count, 3);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('AGENT-CAPABILITIES', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('iso', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getAgentCapabilites 14', getAgentCapabilites, true);
  TRTest.CheckEqual('getAgentCapabilites 15', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getAgentCapabilites 16', FMIBFile.AddressObjects[0].address.Count, 2);
  TRTest.CheckEqual('getAgentCapabilites 17', FMIBFile.AddressObjects[0].ToString, 'iso.1');
end;

procedure TRTextMIBLexer.TestgetChoice;
begin
  Clear;
  TRTest.CheckEqual('getChoice 1', getChoice, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getChoice 2', getChoice, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getChoice 3', getChoice, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('CHOICE', ltUnknown));
  TRTest.CheckEqual('getChoice 4', getChoice, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getChoice 5', getChoice, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('q1', ltUnknown));
  TRTest.CheckEqual('getChoice 6', getChoice, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getChoice 7', getChoice, true);
end;

procedure TRTextMIBLexer.TestgetEnumsStringPairs;
var
  stl: TList<TPair<RawByteString, RawByteString>>;
begin
  stl := TList<TPair<RawByteString, RawByteString>>.Create;
  Clear;
  TRTest.CheckEqual('getEnumsStringPairs 1', getEnumsStringPairs(-1, 0, stl), false);
  TRTest.CheckEqual('getEnumsStringPairs 2', getEnumsStringPairs(0, -1, stl), false);
  TRTest.CheckEqual('getEnumsStringPairs 3', getEnumsStringPairs(0, 0, stl), false);
  TRTest.CheckEqual('getEnumsStringPairs 4', getEnumsStringPairs(5, 1, stl), false);
  TRTest.CheckEqual('getEnumsStringPairs 5', getEnumsStringPairs(0, 10, stl), false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getEnumsStringPairs 6', getEnumsStringPairs(0, 1, stl), false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('name,', ltUnknown));
  TRTest.CheckEqual('getEnumsStringPairs 7', getEnumsStringPairs(0, 2, stl), false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('name2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getEnumsStringPairs 8', getEnumsStringPairs(0, 3, stl), true);
  TRTest.CheckEqual('getEnumsStringPairs 9', stl.Count, 1);

  FreeAndNil(stl);
end;

procedure TRTextMIBLexer.TestgetEnumsWithNumbers;
var
  stl: TStringList;
begin
  stl := TStringList.Create;
  Clear;
  TRTest.CheckEqual('getEnumsWithNumbers 1', getEnumsWithNumbers(-1, 0, stl), false);
  TRTest.CheckEqual('getEnumsWithNumbers 2', getEnumsWithNumbers(0, -1, stl), false);
  TRTest.CheckEqual('getEnumsWithNumbers 3', getEnumsWithNumbers(0, 0, stl), false);
  TRTest.CheckEqual('getEnumsWithNumbers 4', getEnumsWithNumbers(5, 1, stl), false);
  TRTest.CheckEqual('getEnumsWithNumbers 5', getEnumsWithNumbers(0, 10, stl), false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getEnumsWithNumbers 6', getEnumsWithNumbers(0, 1, stl), false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('name', ltUnknown));
  TRTest.CheckEqual('getEnumsWithNumbers 7', getEnumsWithNumbers(0, 2, stl), false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('name2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getEnumsWithNumbers 8', getEnumsWithNumbers(0, 3, stl), false);

  stl.Clear;
  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('false', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('(0)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('true', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('(1)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getEnumsWithNumbers 9', getEnumsWithNumbers(0, 5, stl), true);
  TRTest.CheckEqual('getEnumsWithNumbers 10', stl.Count, 2);

  stl.Clear;
  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('false(0)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('true(1)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getEnumsWithNumbers 11', getEnumsWithNumbers(0, 3, stl), true);
  TRTest.CheckEqual('getEnumsWithNumbers 12', stl.Count, 2);

  stl.Clear;
  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('false(0)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('true', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getEnumsWithNumbers 13', getEnumsWithNumbers(0, 3, stl), false);

  FreeAndNil(stl);
end;

procedure TRTextMIBLexer.TestgetEnumsWithoutNumbers;
var
  stl: TStringList;
begin
  stl := TStringList.Create;
  Clear;
  TRTest.CheckEqual('getEnumsWithoutNumbers 1', getEnumsWithoutNumbers(-1, 0, stl), false);
  TRTest.CheckEqual('getEnumsWithoutNumbers 2', getEnumsWithoutNumbers(0, -1, stl), false);
  TRTest.CheckEqual('getEnumsWithoutNumbers 3', getEnumsWithoutNumbers(0, 0, stl), false);
  TRTest.CheckEqual('getEnumsWithoutNumbers 4', getEnumsWithoutNumbers(5, 1, stl), false);
  TRTest.CheckEqual('getEnumsWithoutNumbers 5', getEnumsWithoutNumbers(0, 10, stl), false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getEnumsWithoutNumbers 6', getEnumsWithoutNumbers(0, 1, stl), false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('name,', ltUnknown));
  TRTest.CheckEqual('getEnumsWithoutNumbers 7', getEnumsWithoutNumbers(0, 2, stl), false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('name2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getEnumsWithoutNumbers 8', getEnumsWithoutNumbers(0, 3, stl), true);

  FreeAndNil(stl);
end;

procedure TRTextMIBLexer.TestgetImports;
begin
  Clear;
  TRTest.CheckEqual('getImports 1', getImports, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('3', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('4', ltUnknown));
  FPosition := 0;
  TRTest.CheckEqual('getImports 2', getImports, false);
  TRTest.CheckEqual('getImports 3', FMIBFile.Imports.Count, 0);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('FROM', ltUnknown));
  FPosition := 0;
  TRTest.CheckEqual('getImports 4', getImports, false);
  TRTest.CheckEqual('getImports 5', FMIBFile.Imports.Count, 0);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('5', ltUnknown));
  FMIBFile.Imports.Clear;
  FPosition := 0;
  TRTest.CheckEqual('getImports 6', getImports, false);
  TRTest.CheckEqual('getImports 7', FMIBFile.Imports.Count, 4);
  FList.Add(TPair<RawByteString, TRLexemType>.Create(';', ltSemicolon));
  FMIBFile.Imports.Clear;
  FPosition := 0;
  TRTest.CheckEqual('getImports 8', getImports, true);
  TRTest.CheckEqual('getImports 9', FMIBFile.Imports.Count, 4);

  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('3', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('4', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('FROM', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('5', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('11', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('12', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('13', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('14', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('FROM', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('35', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create(';', ltSemicolon));
  TRTest.CheckEqual('getImports 10', getImports, true);
  TRTest.CheckEqual('getImports 11', FMIBFile.Imports.Count, 8);
end;

procedure TRTextMIBLexer.TestgetMacro;
begin
  Clear;
  TRTest.CheckEqual('getMacro 1', getMacro, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getMacro 2', getMacro, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MACRO', ltUnknown));
  TRTest.CheckEqual('getMacro 3', getMacro, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getMacro 4', getMacro, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  TRTest.CheckEqual('getMacro 5', getMacro, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('q1', ltUnknown));
  TRTest.CheckEqual('getMacro 6', getMacro, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END', ltUnknown));
  TRTest.CheckEqual('getMacro 7', getMacro, true);
end;

procedure TRTextMIBLexer.TestgetModuleCompliance;
begin
  Clear;
  TRTest.CheckEqual('getModuleCompliance 1', getModuleCompliance, false);

  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getModuleCompliance 2', getModuleCompliance, false);

  FPosition := 1;
  TRTest.CheckEqual('getModuleCompliance 3', getModuleCompliance, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-COMPLIANCE', ltUnknown));
  TRTest.CheckEqual('getModuleCompliance 4', getModuleCompliance, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  TRTest.CheckEqual('getModuleCompliance 5', getModuleCompliance, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getModuleCompliance 6', getModuleCompliance, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getModuleCompliance 7', getModuleCompliance, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getModuleCompliance 8', getModuleCompliance, true);
  TRTest.CheckEqual('getModuleCompliance 9', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getModuleCompliance 10', FMIBFile.AddressObjects[0].address.Count, 0);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-COMPLIANCE', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('3', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('6', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getModuleCompliance 11', getModuleCompliance, true);
  TRTest.CheckEqual('getModuleCompliance 12', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getModuleCompliance 13', FMIBFile.AddressObjects[0].address.Count, 3);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-COMPLIANCE', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('iso', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getModuleCompliance 14', getModuleCompliance, true);
  TRTest.CheckEqual('getModuleCompliance 15', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getModuleCompliance 16', FMIBFile.AddressObjects[0].address.Count, 2);
  TRTest.CheckEqual('getModuleCompliance 17', FMIBFile.AddressObjects[0].ToString, 'iso.1');
end;

procedure TRTextMIBLexer.TestgetModuleIdentity;
begin
  Clear;
  TRTest.CheckEqual('getModuleIdentity 1', getModuleIdentity, false);

  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getModuleIdentity 2', getModuleIdentity, false);

  FPosition := 1;
  TRTest.CheckEqual('getModuleIdentity 3', getModuleIdentity, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-IDENTITY', ltUnknown));
  TRTest.CheckEqual('getModuleIdentity 4', getModuleIdentity, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  TRTest.CheckEqual('getModuleIdentity 5', getModuleIdentity, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getModuleIdentity 6', getModuleIdentity, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getModuleIdentity 7', getModuleIdentity, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getModuleIdentity 8', getModuleIdentity, true);
  TRTest.CheckEqual('getModuleIdentity 9', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getModuleIdentity 10', FMIBFile.AddressObjects[0].address.Count, 0);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-IDENTITY', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('3', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('6', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getModuleIdentity 11', getModuleIdentity, true);
  TRTest.CheckEqual('getModuleIdentity 12', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getModuleIdentity 13', FMIBFile.AddressObjects[0].address.Count, 3);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-IDENTITY', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('iso(1)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('org(3)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('ieee(111)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('standards-association-numbered-series-standards', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('(2)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('lan-man-stds', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('(802)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('ieee802dot1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('(1)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('ieee802dot1mibs', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('(1)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('8', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getModuleIdentity 14', getModuleIdentity, true);
  TRTest.CheckEqual('getModuleIdentity 15', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getModuleIdentity 16', FMIBFile.AddressObjects[0].address.Count, 8);
  TRTest.CheckEqual('getModuleIdentity 17', FMIBFile.AddressObjects[0].ToString, '1.3.111.2.802.1.1.8');
end;

procedure TRTextMIBLexer.TestgetNotificationGroup;
begin
  Clear;
  TRTest.CheckEqual('getNotificationGroup 1', getNotificationGroup, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getNotificationGroup 2', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('NOTIFICATIONS', ltUnknown));
  TRTest.CheckEqual('getNotificationGroup 3', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECTS', ltUnknown));
  TRTest.CheckEqual('getNotificationGroup 4', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getNotificationGroup 5', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('q1,', ltUnknown));
  TRTest.CheckEqual('getNotificationGroup 6', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('q2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getNotificationGroup 7', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('STATUS', ltUnknown));
  TRTest.CheckEqual('getNotificationGroup 8', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('deprecated', ltUnknown));
  TRTest.CheckEqual('getNotificationGroup 9', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getNotificationGroup 10', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getNotificationGroup 11', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('awe1', ltUnknown));
  TRTest.CheckEqual('getNotificationGroup 12', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  TRTest.CheckEqual('getNotificationGroup 13', getNotificationGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getNotificationGroup 14', getNotificationGroup, true);
  TRTest.CheckEqual('getNotificationGroup 15', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getNotificationGroup 16', FMIBFile.AddressObjects[0].address.Count, 2);
  TRTest.CheckEqual('getNotificationGroup 17', FMIBFile.AddressObjects[0].ToString, 'awe1.2');
end;

procedure TRTextMIBLexer.TestgetNotificationType;
begin
  Clear;
  TRTest.CheckEqual('getNotificationType 1', getNotificationType, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getNotificationType 2', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('NOTIFICATION-TYPE', ltUnknown));
  TRTest.CheckEqual('getNotificationType 3', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECTS', ltUnknown));
  TRTest.CheckEqual('getNotificationType 4', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getNotificationType 5', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('q1,', ltUnknown));
  TRTest.CheckEqual('getNotificationType 6', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('q2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getNotificationType 7', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('STATUS', ltUnknown));
  TRTest.CheckEqual('getNotificationType 8', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('deprecated', ltUnknown));
  TRTest.CheckEqual('getNotificationType 9', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getNotificationType 10', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getNotificationType 11', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('awedd', ltUnknown));
  TRTest.CheckEqual('getNotificationType 12', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  TRTest.CheckEqual('getNotificationType 13', getNotificationType, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getNotificationType 14', getNotificationType, true);
  TRTest.CheckEqual('getNotificationType 15', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getNotificationType 16', FMIBFile.AddressObjects[0].address.Count, 2);
  TRTest.CheckEqual('getNotificationType 17', FMIBFile.AddressObjects[0].ToString, 'awedd.2');
end;

procedure TRTextMIBLexer.TestgetObjectGroup;
begin
  Clear;
  TRTest.CheckEqual('getObjectGroup 1', getObjectGroup, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getObjectGroup 2', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT-GROUP', ltUnknown));
  TRTest.CheckEqual('getObjectGroup 3', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECTS', ltUnknown));
  TRTest.CheckEqual('getObjectGroup 4', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getObjectGroup 5', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('q1,', ltUnknown));
  TRTest.CheckEqual('getObjectGroup 6', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('q2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getObjectGroup 7', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('STATUS', ltUnknown));
  TRTest.CheckEqual('getObjectGroup 8', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('deprecated', ltUnknown));
  TRTest.CheckEqual('getObjectGroup 9', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getObjectGroup 10', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getObjectGroup 11', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('aaaa', ltUnknown));
  TRTest.CheckEqual('getObjectGroup 12', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  TRTest.CheckEqual('getObjectGroup 13', getObjectGroup, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getObjectGroup 14', getObjectGroup, true);
  TRTest.CheckEqual('getObjectGroup 15', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getObjectGroup 16', FMIBFile.AddressObjects[0].address.Count, 2);
  TRTest.CheckEqual('getObjectGroup 17', FMIBFile.AddressObjects[0].ToString, 'aaaa.2');
end;

procedure TRTextMIBLexer.TestgetObjectIdentifier;
begin
  Clear;
  TRTest.CheckEqual('getObjectIdentifier 1', getObjectIdentifier, false);

  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getObjectIdentifier 2', getObjectIdentifier, false);

  FPosition := 1;
  TRTest.CheckEqual('getObjectIdentifier 3', getObjectIdentifier, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT', ltUnknown));
  TRTest.CheckEqual('getObjectIdentifier 4', getObjectIdentifier, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('IDENTIFIER', ltUnknown));
  TRTest.CheckEqual('getObjectIdentifier 5', getObjectIdentifier, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getObjectIdentifier 6', getObjectIdentifier, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getObjectIdentifier 7', getObjectIdentifier, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getObjectIdentifier 8', getObjectIdentifier, true);
  TRTest.CheckEqual('getObjectIdentifier 9', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getObjectIdentifier 10', FMIBFile.AddressObjects[0].address.Count, 0);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('IDENTIFIER', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('ieee8021CfmMib', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('5', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getObjectIdentifier 11', getObjectIdentifier, true);
  TRTest.CheckEqual('getObjectIdentifier 12', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getObjectIdentifier 13', FMIBFile.AddressObjects[0].address.Count, 2);
  TRTest.CheckEqual('getObjectIdentifier 14', FMIBFile.AddressObjects[0].ToString, 'ieee8021CfmMib.5');
end;

procedure TRTextMIBLexer.TestgetObjectIdentity;
begin
  Clear;
  TRTest.CheckEqual('getObjectIdentity 1', getObjectIdentity, false);

  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getObjectIdentity 2', getObjectIdentity, false);

  FPosition := 1;
  TRTest.CheckEqual('getObjectIdentity 3', getObjectIdentity, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('AGENT-CAPABILITIES', ltUnknown));
  TRTest.CheckEqual('getObjectIdentity 4', getObjectIdentity, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  TRTest.CheckEqual('getObjectIdentity 5', getObjectIdentity, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getObjectIdentity 6', getObjectIdentity, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getObjectIdentity 7', getObjectIdentity, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getObjectIdentity 8', getObjectIdentity, true);
  TRTest.CheckEqual('getObjectIdentity 9', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getObjectIdentity 10', FMIBFile.AddressObjects[0].address.Count, 0);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('AGENT-CAPABILITIES', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('3', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('6', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getObjectIdentity 11', getObjectIdentity, true);
  TRTest.CheckEqual('getObjectIdentity 12', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getObjectIdentity 13', FMIBFile.AddressObjects[0].address.Count, 3);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('AGENT-CAPABILITIES', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('ff', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('6', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getObjectIdentity 14', getObjectIdentity, true);
  TRTest.CheckEqual('getObjectIdentity 15', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getObjectIdentity 16', FMIBFile.AddressObjects[0].address.Count, 2);
  TRTest.CheckEqual('getObjectIdentity 17', FMIBFile.AddressObjects[0].ToString, 'ff.6');
end;

procedure TRTextMIBLexer.TestgetObjectType;
begin
  Clear;
  TRTest.CheckEqual('getObjectType 1', getObjectType, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getObjectType 2', getObjectType, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT-TYPE', ltUnknown));
  TRTest.CheckEqual('getObjectType 3', getObjectType, false);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SYNTAX', ltUnknown));
  TRTest.CheckEqual('getObjectType 4', getObjectType, false);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SEQUENCE', ltUnknown));
  TRTest.CheckEqual('getObjectType 5', getObjectType, false);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OF', ltUnknown));
  TRTest.CheckEqual('getObjectType 6', getObjectType, false);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT-TYPE', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SYNTAX', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('ObjectIndex', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getObjectType 7', getObjectType, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('getObjectType 8', getObjectType, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('mtxrWlStatEntry', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('1', ltUnknown));
  TRTest.CheckEqual('getObjectType 9', getObjectType, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getObjectType 10', getObjectType, true);
  TRTest.CheckEqual('getObjectType 11', FMIBFile.AddressObjects.Count, 1);
  TRTest.CheckEqual('getObjectType 12', FMIBFile.AddressObjects[0].address.Count, 2);
  TRTest.CheckEqual('getObjectType 13', FMIBFile.AddressObjects[0].ToString, 'mtxrWlStatEntry.1');
end;

procedure TRTextMIBLexer.TestgetSequence;
begin
  Clear;
  TRTest.CheckEqual('getSequence 1', getSequence, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getSequence 2', getSequence, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getSequence 3', getSequence, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SEQUENCE', ltUnknown));
  TRTest.CheckEqual('getSequence 4', getSequence, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltleftBracer));
  TRTest.CheckEqual('getSequence 5', getSequence, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('testname', ltUnknown));
  TRTest.CheckEqual('getSequence 6', getSequence, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('testtype, ', ltUnknown));
  TRTest.CheckEqual('getSequence 7', getSequence, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('testname2', ltUnknown));
  TRTest.CheckEqual('getSequence 8', getSequence, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('testtype2', ltUnknown));
  TRTest.CheckEqual('getSequence 9', getSequence, false);

  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getSequence 10', getSequence, true);
  TRTest.CheckEqual('getSequence 11', FMIBFile.Sequences.Count, 1);
  TRTest.CheckEqual('getSequence 12', FMIBFile.Sequences[0].sequences.Count, 2);
end;

procedure TRTextMIBLexer.TestgetTextualConvention;
begin
  Clear;
  TRTest.CheckEqual('getTextualConvention 1', getTextualConvention, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('getTextualConvention 2', getTextualConvention, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('getTextualConvention 3', getTextualConvention, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('TEXTUAL-CONVENTION', ltUnknown));
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SYNTAX', ltUnknown));
  TRTest.CheckEqual('getTextualConvention 4', getTextualConvention, false);
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('Integer32', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('(0..2147483647)', ltUnknown));
  TRTest.CheckEqual('getTextualConvention 5', getTextualConvention, true);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test2', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('TEXTUAL-CONVENTION', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SYNTAX', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('Gauge32', ltUnknown));
  TRTest.CheckEqual('getTextualConvention 6', getTextualConvention, true);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test3', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('TEXTUAL-CONVENTION', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SYNTAX', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('INTEGER', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltleftBracer));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('v1(0)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('v2(1)', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  TRTest.CheckEqual('getTextualConvention 7', getTextualConvention, true);
  TRTest.CheckEqual('getTextualConvention 8', FMIBFile.TextualConventions.Count, 1);
  TRTest.CheckEqual('getTextualConvention 9', FMIBFile.TextualConventions[0].enumvalues.Count, 2);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test4', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('TEXTUAL-CONVENTION', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SYNTAX', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OCTET', ltUnknown));
  TRTest.CheckEqual('getTextualConvention 10', getTextualConvention, true);

  Clear;
  FPosition := 1;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test5', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('TEXTUAL-CONVENTION', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SYNTAX', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('INTEGER', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('STATUS', ltUnknown));
  TRTest.CheckEqual('getTextualConvention 11', getTextualConvention, true);
  TRTest.CheckEqual('getTextualConvention 12', FMIBFile.TextualConventions.Count, 1);
end;

procedure TRTextMIBLexer.TestisAgentCapabilites;
begin
  Clear;
  TRTest.CheckEqual('isAgentCapabilites 1', isAgentCapabilites, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isAgentCapabilites 2', isAgentCapabilites, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('AGENT-CAPABILITIES', ltUnknown));
  TRTest.CheckEqual('isAgentCapabilites 3', isAgentCapabilites, false);
  FPosition := 1;
  TRTest.CheckEqual('isAgentCapabilites 4', isAgentCapabilites, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('DESCRIPTION', ltUnknown));
  FPosition := 1;
  TRTest.CheckEqual('isAgentCapabilites 5', isAgentCapabilites, true);
  FPosition := 2;
  TRTest.CheckEqual('isAgentCapabilites 6', isAgentCapabilites, false);

  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('AGENT-CAPABILITIES', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MACRO', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END;', ltUnknown));
  TRTest.CheckEqual('isAgentCapabilites 7', isAgentCapabilites, false);
end;

procedure TRTextMIBLexer.TestisChoice;
begin
  Clear;
  TRTest.CheckEqual('isChoice 1', isChoice, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isChoice 2', isChoice, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('isChoice 3', isChoice, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('CHOICE', ltUnknown));
  TRTest.CheckEqual('isChoice 4', isChoice, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('isChoice 5', isChoice, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('}', ltRightBracer));
  FPosition := 1;
  TRTest.CheckEqual('isChoice 6', isChoice, true);
  FPosition := 2;
  TRTest.CheckEqual('isChoice 7', isChoice, false);
end;

procedure TRTextMIBLexer.TestisEndMIB;
begin
  Clear;
  TRTest.CheckEqual('isEndMIB 1', isEndMIB, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END', ltUnknown));
  TRTest.CheckEqual('isEndMIB 2', isEndMIB, false);
  FPosition := 1;
  TRTest.CheckEqual('isEndMIB 3', isEndMIB, true);
  FPosition := 2;
  TRTest.CheckEqual('isEndMIB 4', isEndMIB, false);
end;

procedure TRTextMIBLexer.TestisImports;
begin
  Clear;
  TRTest.CheckEqual('isImports 1', isImports, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('IMPORTS', ltUnknown));
  TRTest.CheckEqual('isImports 2', isImports, false);
  FPosition := 1;
  TRTest.CheckEqual('isImports 3', isImports, true);
  FPosition := 2;
  TRTest.CheckEqual('isImports 4', isImports, false);
end;

procedure TRTextMIBLexer.TestisMacro;
begin
  Clear;
  TRTest.CheckEqual('isMacro 1', isMacro, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isMacro 2', isMacro, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MACRO', ltUnknown));
  TRTest.CheckEqual('isMacro 3', isMacro, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  TRTest.CheckEqual('isMacro 4', isMacro, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  TRTest.CheckEqual('isMacro 5', isMacro, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END', ltUnknown));
  FPosition := 1;
  TRTest.CheckEqual('isMacro 6', isMacro, true);
  FPosition := 2;
  TRTest.CheckEqual('isMacro 7', isMacro, false);
end;

procedure TRTextMIBLexer.TestisModuleCompliance;
begin
  Clear;
  TRTest.CheckEqual('isModuleCompliance 1', isModuleCompliance, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isModuleCompliance 2', isModuleCompliance, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-COMPLIANCE', ltUnknown));
  TRTest.CheckEqual('isModuleCompliance 3', isModuleCompliance, false);
  FPosition := 1;
  TRTest.CheckEqual('isModuleCompliance 4', isModuleCompliance, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('DESCRIPTION', ltUnknown));
  FPosition := 1;
  TRTest.CheckEqual('isModuleCompliance 5', isModuleCompliance, true);
  FPosition := 2;
  TRTest.CheckEqual('isModuleCompliance 6', isModuleCompliance, false);

  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-COMPLIANCE', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MACRO', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END;', ltUnknown));
  TRTest.CheckEqual('isModuleCompliance 7', isModuleCompliance, false);
end;

procedure TRTextMIBLexer.TestisModuleIdentity;
begin
  Clear;
  TRTest.CheckEqual('isModuleIdentity 1', isModuleIdentity, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isModuleIdentity 2', isModuleIdentity, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-IDENTITY', ltUnknown));
  TRTest.CheckEqual('isModuleIdentity 3', isModuleIdentity, false);
  FPosition := 1;
  TRTest.CheckEqual('isModuleIdentity 4', isModuleIdentity, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('DESCRIPTION', ltUnknown));
  FPosition := 1;
  TRTest.CheckEqual('isModuleIdentity 5', isModuleIdentity, true);
  FPosition := 2;
  TRTest.CheckEqual('isModuleIdentity 6', isModuleIdentity, false);

  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MODULE-IDENTITY', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MACRO', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END;', ltUnknown));
  TRTest.CheckEqual('isModuleIdentity 7', isModuleIdentity, false);
end;

procedure TRTextMIBLexer.TestisNotificationGroup;
begin
  Clear;
  TRTest.CheckEqual('isNotificationGroup 1', isNotificationGroup, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isNotificationGroup 2', isNotificationGroup, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('NOTIFICATION-GROUP', ltUnknown));
  TRTest.CheckEqual('isNotificationGroup 3', isNotificationGroup, false);
  FPosition := 1;
  TRTest.CheckEqual('isNotificationGroup 4', isNotificationGroup, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('NOTIFICATIONS', ltUnknown));
  FPosition := 1;
  TRTest.CheckEqual('isNotificationGroup 5', isNotificationGroup, true);
  FPosition := 2;
  TRTest.CheckEqual('isNotificationGroup 6', isNotificationGroup, false);

  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('NOTIFICATION-GROUP', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MACRO', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END;', ltUnknown));
  TRTest.CheckEqual('isNotificationGroup 7', isNotificationGroup, false);
end;

procedure TRTextMIBLexer.TestisNotificationType;
begin
  Clear;
  TRTest.CheckEqual('isNotificationType 1', isNotificationType, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isNotificationType 2', isNotificationType, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('NOTIFICATION-TYPE', ltUnknown));
  TRTest.CheckEqual('isNotificationType 3', isNotificationType, false);
  FPosition := 1;
  TRTest.CheckEqual('isNotificationType 4', isNotificationType, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('STATUS', ltUnknown));
  TRTest.CheckEqual('isNotificationType 5', isNotificationType, true);
  FPosition := 2;
  TRTest.CheckEqual('isNotificationType 6', isNotificationType, false);

  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('NOTIFICATION-TYPE', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MACRO', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END;', ltUnknown));
  TRTest.CheckEqual('isNotificationType 7', isNotificationType, false);
end;

procedure TRTextMIBLexer.TestisObjectGroup;
begin
  Clear;
  TRTest.CheckEqual('isObjectGroup 1', isObjectGroup, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isObjectGroup 2', isObjectGroup, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT-GROUP', ltUnknown));
  TRTest.CheckEqual('isObjectGroup 3', isObjectGroup, false);
  FPosition := 1;
  TRTest.CheckEqual('isObjectGroup 4', isObjectGroup, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECTS', ltUnknown));
  TRTest.CheckEqual('isObjectGroup 5', isObjectGroup, true);
  FPosition := 2;
  TRTest.CheckEqual('isObjectGroup 6', isObjectGroup, false);

  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT-GROUP', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MACRO', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END;', ltUnknown));
  TRTest.CheckEqual('isObjectGroup 7', isObjectGroup, false);
end;

procedure TRTextMIBLexer.TestisObjectIdentity;
begin
  Clear;
  TRTest.CheckEqual('isObjectIdentity 1', isObjectIdentity, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isObjectIdentity 2', isObjectIdentity, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT-IDENTITY', ltUnknown));
  TRTest.CheckEqual('isObjectIdentity 3', isObjectIdentity, false);
  FPosition := 1;
  TRTest.CheckEqual('isObjectIdentity 4', isObjectIdentity, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('DESCRIPTION', ltUnknown));
  FPosition := 1;
  TRTest.CheckEqual('isObjectIdentity 5', isObjectIdentity, true);
  FPosition := 2;
  TRTest.CheckEqual('isObjectIdentity 6', isObjectIdentity, false);

  Clear;
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT-IDENTITY', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('MACRO', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('BEGIN', ltUnknown));
  FList.Add(TPair<RawByteString, TRLexemType>.Create('END;', ltUnknown));
  TRTest.CheckEqual('isObjectIdentity 7', isObjectIdentity, false);
end;

procedure TRTextMIBLexer.TestisObjectType;
begin
  Clear;
  TRTest.CheckEqual('isObjectType 1', isObjectType, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isObjectType 2', isObjectType, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('OBJECT-TYPE', ltUnknown));
  TRTest.CheckEqual('isObjectType 3', isObjectType, false);
end;

procedure TRTextMIBLexer.TestisSequence;
begin
  Clear;
  TRTest.CheckEqual('isSequence 1', isSequence, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isSequence 2', isSequence, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FPosition := 1;
  TRTest.CheckEqual('isSequence 3', isSequence, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('SEQUENCE', ltUnknown));
  TRTest.CheckEqual('isSequence 4', isSequence, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('{', ltLeftBracer));
  TRTest.CheckEqual('isSequence 5', isSequence, true);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('qqq', ltUnknown));
  TRTest.CheckEqual('isSequence 6', isSequence, true);
end;

procedure TRTextMIBLexer.TestisTextualConvention;
begin
  Clear;
  TRTest.CheckEqual('isTextualConvention 1', isTextualConvention, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('test', ltUnknown));
  TRTest.CheckEqual('isTextualConvention 2', isTextualConvention, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('::=', ltUnknown));
  FPosition := 1;
  TRTest.CheckEqual('isTextualConvention 3', isTextualConvention, false);
  FList.Add(TPair<RawByteString, TRLexemType>.Create('TEXTUAL-CONVENTION', ltUnknown));
  TRTest.CheckEqual('isTextualConvention 4', isTextualConvention, true);
end;

initialization
  TDUnitX.RegisterTestFixture(TMibTest);

end.

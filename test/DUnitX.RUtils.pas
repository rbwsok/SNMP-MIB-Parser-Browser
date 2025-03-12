unit DUnitX.RUtils;

interface

uses Winapi.Windows, System.SysUtils, System.SyncObjs, System.StrUtils, System.Classes, DUnitX.TestFramework;

type
  // небольшая надстройка над DUnitX
  // счетчик Assert
  TRTest = class
  private
    class var FLogCriticalSection: TCriticalSection;

    class var FCharOffset: NativeInt;
    class var FSuccessCount: NativeInt;
    class var FFailedCount: NativeInt;

    class function Check(value: Boolean): String;

    class procedure ConsoleWriteLn(const value: String = '');
  public
    class procedure Init;
    class procedure Result;

    class procedure CheckEqual(const name: String; value1, value2: Boolean); overload;
    class procedure CheckEqual(const name: String; const value1, value2: RawByteString); overload;
    class procedure CheckEqual(const name, value1, value2: String); overload;
    class procedure CheckEqual(const name: String; value1, value2: NativeInt); overload;
  end;

implementation

{ TRTest }

class procedure TRTest.ConsoleWriteLn(const value: String);
begin
  FLogCriticalSection.Enter;
  System.WriteLn(DupeString(' ', FCharOffset) + value);
  FLogCriticalSection.Leave;
end;

class function TRTest.Check(value: Boolean): String;
begin
  if value = false then
  begin
    result := 'false';
    inc(FFailedCount);
  end
  else
  begin
    result := 'true';
    inc(FSuccessCount);
  end;
end;

class procedure TRTest.CheckEqual(const name: String; value1, value2: Boolean);
var
  res: Boolean;
begin
  res := value1 = value2;
  ConsoleWriteLn(name + ' - ' + Check(res));

  Assert.AreEqual<Boolean>(res, true, name);
end;

class procedure TRTest.CheckEqual(const name: String; value1, value2: NativeInt);
var
  res: Boolean;
begin
  res := value1 = value2;
  ConsoleWriteLn(name + ' - ' + Check(res));

  Assert.AreEqual<Boolean>(res, true, name);
end;

class procedure TRTest.CheckEqual(const name, value1, value2: String);
var
  res: Boolean;
begin
  res := value1 = value2;
  ConsoleWriteLn(name + ' - ' + Check(res));

  Assert.AreEqual<Boolean>(res, true, name);
end;

class procedure TRTest.CheckEqual(const name: String; const value1, value2: RawByteString);
var
  res: Boolean;
begin
  res := value1 = value2;
  ConsoleWriteLn(name + ' - ' + Check(res));

  Assert.AreEqual<Boolean>(res, true, name);
end;

class procedure TRTest.Init;
begin
  TRTest.FCharOffset := 9;
  TRTest.FSuccessCount := 0;
  TRTest.FFailedCount := 0;
  if TRTest.FLogCriticalSection = nil then
    TRTest.FLogCriticalSection := TCriticalSection.Create;
end;

class procedure TRTest.Result;
begin
  TRTest.FCharOffset := 0;
  ConsoleWriteLn('Assert Sussess: ' + IntToStr(FSuccessCount));
  ConsoleWriteLn('Assert Failed: ' + IntToStr(FFailedCount));
end;

initialization

finalization
  FreeAndNil(TRTest.FLogCriticalSection);


end.

tableextension 71500 "CSV Buffer My" extends "CSV Buffer"
{
    var
        DotNet_StreamReader: Codeunit DotNet_StreamReader;
        Separator: Text[1];
        CharactersToTrim: Text;


    procedure LoadDataFromStreamNew(CSVInStream: InStream; CSVFieldSeparator: Text[1]; CSVCharactersToTrim: Text)
    begin
        InitializeReaderFromStream(CSVInStream, CSVFieldSeparator, CSVCharactersToTrim);
        ReadLinesNew(0);
        DotNet_StreamReader.Close();
    end;

    local procedure InitializeReaderFromStream(CSVInStream: InStream; CSVFieldSeparator: Text[1]; CSVCharactersToTrim: Text)
    var
        DotNet_Encoding: Codeunit DotNet_Encoding;
    begin
        DotNet_Encoding.UTF8();
        DotNet_StreamReader.StreamReader(CSVInStream, DotNet_Encoding);
        Separator := CSVFieldSeparator;
        CharactersToTrim := CSVCharactersToTrim;
    end;

    local procedure ReadLinesNew(NumberOfLines: Integer): Boolean
    var
        Str: Codeunit DotNet_String;
        CurrentLineNo: Integer;
        CurrentFieldNo: Integer;
        CurrentIndex: Integer;
        NextIndex: Integer;
        Length: Integer;
    begin
        if DotNet_StreamReader.EndOfStream() then
            exit(false);

        repeat
            Str.Set(DotNet_StreamReader.ReadLine());
            CurrentLineNo += 1;
            CurrentIndex := 0;
            repeat
                CurrentFieldNo += 1;

                Rec.Init();
                Rec."Line No." := CurrentLineNo;
                Rec."Field No." := CurrentFieldNo;

                NextIndex := Str.IndexOfString(Separator, CurrentIndex);
                if NextIndex = -1 then
                    Length := Str.Length() - CurrentIndex
                else
                    Length := NextIndex - CurrentIndex;

                if Length > 250 then
                    Length := 250;
                Rec.Value := Str.Substring(CurrentIndex, Length);
                Rec.Value := DelChr(Rec.Value, '<>', CharactersToTrim);

                CurrentIndex := NextIndex + 1;

                Rec.Insert();
            until NextIndex = -1;
            CurrentFieldNo := 0;
        until DotNet_StreamReader.EndOfStream() or (CurrentLineNo = NumberOfLines);

        exit(true);
    end;

    procedure CalcNextValueLength(Line: Text): Integer
    var
        Index: Integer;
        QuotesInARow: Integer;
    begin
        if StrLen(Line) < 1 then
            exit(0);

        if not IsValueStartFromQuotes(Line) then begin
            if Line.IndexOf(',') > 0 then
                exit(Line.IndexOf(',') - 1);
            exit(StrLen(Line));
        end;

        Index := Line.IndexOf('"') + 1;
        repeat
            Index := Line.IndexOf('"', Index);
            QuotesInARow := CalcDoubleQuotesInARow(Line, Index);
            Index += QuotesInARow;
            if QuotesInARow mod 2 <> 0 then
                exit(Index - 1);
        until Index >= StrLen(Line);
    end;

    procedure CalcDoubleQuotesInARow(Line: Text; StartIndex: Integer): Integer
    var
        Counter: Integer;
    begin
        if StartIndex < 1 then
            Error('StartIndex can''t be less than 1.');
        if StartIndex > StrLen(Line) then
            Error('StartIndex can''t be greater than string length.');
        Counter := 0;

        while Line[StartIndex + Counter] = '"' do begin
            Counter += 1;
            if StartIndex + Counter >= StrLen(Line) then
                exit(Counter);
        end;

        exit(Counter);
    end;

    local procedure IsValueStartFromQuotes(Line: Text): Boolean
    begin
        if Line.Trim().StartsWith('"') then
            exit(true);
        exit(false);
    end;

    procedure ClearValue(ValueLine: Text): Text
    var
        Result: Text;
    begin
        Result := ValueLine.Trim();
        Result := DelChr(Result, '<>', '"');
        Result := Result.Replace('""', '"');
        exit(Result);
    end;

    procedure GetNextValue(Line: Text): Text
    begin
        exit(Line.Substring(1, CalcNextValueLength(Line)));
    end;

    procedure GetAllValues(Line: Text): List of [Text]
    var
        Values: List of [Text];
        NextValue: Text;
        i: Integer;
    begin
        i := 1;
        if StrLen(Line) < 1 then
            exit;

        while StrLen(Line) > 0 do begin
            NextValue := GetNextValue(Line);
            Values.Add(ClearValue(NextValue));
            Line := Line.Substring(StrLen(NextValue) + 1).Trim();
            if Line.StartsWith(',') then
                Line := Line.Substring(2);
            i += 1;
            if i > 10 then
                break;
        end;
        exit(Values);
    end;
}


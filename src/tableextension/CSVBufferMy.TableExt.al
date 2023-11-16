tableextension 71500 "CSV Buffer My" extends "CSV Buffer"
{
    var
        DotNet_StreamReader: Codeunit DotNet_StreamReader;
        Separator: Text[1];
        CharactersToTrim: Text;


    procedure LoadDataFromStreamHB(CSVInStream: InStream; CSVFieldSeparator: Text[1]; CSVCharactersToTrim: Text)
    begin
        InitializeReaderFromStream(CSVInStream, CSVFieldSeparator, CSVCharactersToTrim);
        ReadLines(0);
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

    local procedure ReadLines(NumberOfLines: Integer): Boolean
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
}


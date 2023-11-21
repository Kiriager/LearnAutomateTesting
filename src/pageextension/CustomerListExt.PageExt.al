
pageextension 71500 CustomerListExt extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
            action(ImportCSV)
            {
                Caption = 'Import CSV';
                ApplicationArea = All;

                trigger OnAction()
                var
                    TempCSVBuffer: Record "CSV Buffer" temporary;
                    InStream: InStream;
                    FromFileName: Text;
                    Col: Integer;
                    Values: Text;
                begin
                    if File.UploadIntoStream('Import', '', 'All Files (*.*)|*.*',
                                FromFileName, InStream) then begin
                        TempCSVBuffer.LoadDataFromStream(InStream, ',');
                        for Col := 1 to TempCSVBuffer.GetNumberOfColumns() do
                            Values += '/' + TempCSVBuffer.GetValue(1, Col);

                        Message(Values);
                    end;
                end;
            }

            action(ImportCSVHB)
            {
                Caption = 'Import CSV HB';
                ApplicationArea = All;

                trigger OnAction()
                var
                    TempCSVBuffer: Record "CSV Buffer" temporary;
                    InStream: InStream;
                    FromFileName: Text;
                    Col: Integer;
                    Values: Text;
                begin
                    if File.UploadIntoStream('Import', '', 'All Files (*.*)|*.*',
                                FromFileName, InStream) then begin
                        TempCSVBuffer.LoadDataFromStreamHB(InStream, ',', '');
                        for Col := 1 to TempCSVBuffer.GetNumberOfColumns() do
                            Values += '/' + TempCSVBuffer.GetValue(1, Col);

                        Message(Values);
                    end;
                end;
            }

            action(RunTestCodeunit)
            {
                Caption = 'Run Test Codeunit';
                ApplicationArea = All;
                ToolTip = ' ';
                RunObject = Codeunit MyFirstTestCodeunit;
            }
        }

        addlast(Promoted)
        {
            actionref(ImportCSV_Promoted; ImportCSV)
            {
            }

            actionref(ImportCSVHB_Promoted; ImportCSVHB)
            {
            }

            actionref(RunTestCodeunit_Promoted; RunTestCodeunit)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        CSVBuffer: Record "CSV Buffer";
        i: Integer;
        TestLines: array[10] of Text;
        MessageText: Text;
    begin
        TestLines[1] := 'apple,"cat","do,g",""';
        TestLines[2] := '"apple",cat';
        TestLines[3] := '"""apple""",cat';
        TestLines[4] := '   """apple""",txt';
        TestLines[5] := '"""""",txt';
        TestLines[6] := ',cat';
        TestLines[7] := 'apple';
        TestLines[8] := ',';
        TestLines[9] := '';
        TestLines[10] := '"""""death""""",txt';


        // for i := 1 to ArrayLen(TestLines) do begin
        //     MessageText += StrSubstNo('Line = %1 | Value length = %2 | Value = %3 \',
        //             TestLines[i], CSVBuffer.CalcNextValueLength(TestLines[i]),
        //             // CSVBuffer.ClearValue(CSVBuffer.GetNextValue(TestLines[i]))),
        //             Format(CSVBuffer.GetAllValues(TestLines[i])));
        // end;

        // Message('%1 %2', TestLines[1], ListToText(CSVBuffer.GetAllValues(TestLines[1])));

        for i := 1 to ArrayLen(TestLines) do
            MessageText += StrSubstNo('Line = %1 Values = %2 \', TestLines[i], ListToText(CSVBuffer.GetAllValues(TestLines[i])));



        // ValueLength := CalcNextValueLength('"""text""",txt');
        // Message('Value Length: %1', ValueLength);
        // Message('Next Value: %1', GetNextValue('"""text""",txt'));
        // Message(Format(CSVBuffer.GetNextValueEndIndex(TestLine)));

        // Message('%1, %2, %3', CSVBuffer.CalcDoubleQuotesInARow(TestLine, 1),
        //         CSVBuffer.CalcDoubleQuotesInARow(TestLine, 5), CSVBuffer.CalcDoubleQuotesInARow(TestLine, 9));
        Message(MessageText);
    end;

    local procedure CalcNextValueLength(Line: Text): Integer
    var
        Str: Codeunit DotNet_String;
        Index: Integer;
        QuotesInARow: Integer;
    begin
        Str.Set(Line);
        if not Str.StartsWith('"') then
            exit(Str.IndexOfString(',', 1));
        Str.Set(Str.Substring(1, Str.Length() - 1));
        // Message(Str.ToString());
        // repeat
        //     Index := Str.IndexOfString('"', Index);
        //     Index += 1;
        // until IsSingeDoubleQuote(Str, Index);
        // Message(Format(Index));

        // for Index := 0 to Str.Length() - 1 do
        //     Message('%1 %2', Index, IsSingeDoubleQuote(Str, Index));

        repeat
            Index := Str.IndexOfString('"', Index);
            if Index = -1 then
                break;
            QuotesInARow := CalcDoubleQuotesInARow(Str, Index);
            Message('Index: %1 Quotes: %2', Index, QuotesInARow);
            Index += CalcDoubleQuotesInARow(Str, Index);
            if QuotesInARow mod 2 <> 0 then
                exit(Index);
        until Index >= Str.Length() - 1;

        // for Index := 0 to Str.Length() - 1 do
        //     Message('Index: %1 Quotes: %2', Index, CalcDoubleQuotesInARow(Str, Index));
    end;

    local procedure CalcDoubleQuotesInARow(var Str: Codeunit DotNet_String; Index: Integer): Integer
    var
        Counter: Integer;
    begin
        Counter := 0;
        while Str.Substring(Index + Counter, 1) = '"' do
            Counter += 1;
        exit(Counter);
    end;

    local procedure GetNextValue(Line: Text): Text
    var
        Value: Text;
    begin
        Value := Line.Substring(2, CalcNextValueLength(Line) - 1);
        Value := Value.Replace('""', '"');
        exit(Value);
    end;

    local procedure ListToText(TextList: List of [Text]): Text
    var
        Result: Text;
        Value: Text;
    begin
        Result := '|';
        foreach Value in TextList do
            Result += Value + '|';
        exit(Result);
    end;
}
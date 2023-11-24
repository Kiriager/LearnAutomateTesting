codeunit 71502 CSVBufferAutoTest
{
    Subtype = Test;

    [Test]
    procedure ReadStreamWithAllValueTypes()
    var
    // CSVBuffer: Integer;
    begin
        //[SCENARIO #0001] Read stream with correct lines
        //[GIVEN] An InStream with correct lines
        CreateCSVValidInStream();

        //[WHEN] Read Lines from stream with 
        ReadLinesWithSCVBuffer();

        //[THEN] CSV Buffer record contains correct values read from InStream
        VerifyCSVBufferContainsCorrectValues();
    end;

    local procedure ReadLinesWithSCVBuffer()
    begin
        TempCSVBuffer.LoadDataFromStream(InStream, ',');
    end;

    local procedure VerifyCSVBufferContainsCorrectValues()
    var
        ValueDoesntMatchErr: Label 'Value #%1 doesn''t match correct value';
        Value: Text;
        i: Integer;
    begin
        Assert.AreEqual(TempCSVBuffer.GetNumberOfLines(), 1, 'Wrong number of lines read.');
        Assert.AreEqual(TempCSVBuffer.GetNumberOfColumns(), CorrectValuesList.Count(), 'Wrong number of columns read.');

        for i := 1 to CorrectValuesList.Count() do
            Assert.AreEqual(CorrectValuesList.Get(i), TempCSVBuffer.GetValue(1, i),
                StrSubstNo(ValueDoesntMatchErr, i));
    end;

    local procedure FillTestLinesList()
    begin
        TestLines.Add(TestLines1Txt);
        TestLines.Add(TestLines2Txt);
        TestLines.Add(TestLines3Txt);
        TestLines.Add(TestLines4Txt);
        TestLines.Add(TestLines5Txt);
        TestLines.Add(TestLines6Txt);
        TestLines.Add(TestLines7Txt);
        TestLines.Add(TestLines8Txt);
        TestLines.Add(TestLines9Txt);
        TestLines.Add(TestLines10Txt);
    end;

    local procedure CreateLineValuesList(): List of [Text]
    var
        ListOfValues: List of [Text];
    begin
        ListOfValues.Add(SimpleValueTxt);
        ListOfValues.Add(ValueWithComasQuotedTxt);
        ListOfValues.Add(ValueWithQuotesOnlyQuotedTxt);
        ListOfValues.Add(ValueWithQuotesQuotedTxt);
        ListOfValues.Add(ValueWithSpacesInsideOnlyTxt);
        ListOfValues.Add(EmptyLineValueTxt);
        ListOfValues.Add(EmptyLineWithSpacesValueTxt);
        ListOfValues.Add(ValueWithSpacesTxt);
        ListOfValues.Add(ValueWithSpacesQuotedTxt);
        exit(ListOfValues);
    end;

    local procedure CreateLineFromListOfValues(Values: List of [Text]): Text
    var
        Line: Text;
        Value: Text;
    begin
        foreach Value in Values do
            Line += ',' + Value;
        exit(DelChr(Line, '<', ','));
    end;

    local procedure CreateCSVValidInStream()
    begin
        CorrectValuesList := CreateLineValuesList();
        OutStream := TempBlob.CreateOutStream();
        OutStream.WriteText(CreateLineFromListOfValues(CorrectValuesList));
        InStream := TempBlob.CreateInStream();
    end;

    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        Assert: Codeunit "Library Assert";
        InStream: Instream;
        OutStream: OutStream;
        CorrectValuesList: List of [Text];

        SimpleValueTxt: Label 'apple';
        ValueWithSpacesInsideOnlyTxt: Label 'sword and shield';
        ValueWithSpacesTxt: Label '   sword and shield   ';
        ValueWithSpacesQuotedTxt: Label '"   sword and shield   "';
        ValueWithComasQuotedTxt: Label '",cat, bird, turtle,"';
        ValueWithComasTxt: Label ',cat, bird, turtle,';
        ValueWithQuotesQuotedTxt: Label '"""Erik"""';
        ValueWithQuotesTxt: Label '"Erik"';
        ValueWithQuotesOnlyQuotedTxt: Label '""""""""';
        ValueWithQuotesOnlyTxt: Label '"""';
        EmptyLineValueTxt: Label '';
        EmptyLineWithSpacesValueTxt: Label '      ';


        TestLines: List of [Text];
        TestLines1Txt: Label 'apple,  "cat","do,g"    , "",fish,,,bird';
        TestLines2Txt: Label 'apple,cat,dog,fish,,bird';
        TestLines3Txt: Label '"""apple""",cat,"""""",,""",,""",   ';
        TestLines4Txt: Label '   """apple""",txt';
        TestLines5Txt: Label '"""""",txt';
        TestLines6Txt: Label ',cat';
        TestLines7Txt: Label 'apple';
        TestLines8Txt: Label ',';
        TestLines9Txt: Label '';
        TestLines10Txt: Label '"""""death""""",txt';
}
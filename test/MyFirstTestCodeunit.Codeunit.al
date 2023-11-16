codeunit 71500 MyFirstTestCodeunit
{
    Subtype = Test;
    // trigger OnRun()
    // begin

    // end;

    // [Test]
    // [HandlerFunctions('MyMessageHandler')]
    // procedure MyFirstTestFunction()
    // begin
    //     Message('MyFirstTestFunction');
    // end;

    [Test]
    procedure MySecondTestFunction()
    begin
        Error('');
    end;

    [Test]
    procedure MyPostiveNegativeTestFunction()
    begin
        asserterror Error('');
    end;

    //     [MessageHandler]
    //     procedure MyMessageHandler(Message: Text[1024])
    //     begin
    //     end;
}
program ZenFont;

{$mode objfpc}{$H+}

uses
  {$IFDEF LINUX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  uMain, uProcessing;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.


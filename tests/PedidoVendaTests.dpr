program PedidoVendaTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  uModels in '..\src\Model\uModels.pas',
  uPedidoService in '..\src\Service\uPedidoService.pas',
  uPedidoRepository in '..\src\Repository\uPedidoRepository.pas',
  uTestPedidoService in 'uTestPedidoService.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
  NUnitLogger: ITestLogger;

begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  Exit;
{$ENDIF}
  try
    TDUnitX.CheckCommandLine;
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;
    Runner.FailsOnNoAsserts := False;

    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      Logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      Runner.AddLogger(Logger);
    end;
    NUnitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    Runner.AddLogger(NUnitLogger);

    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

{$IFNDEF CI}
    Write('Pressione ENTER para sair.');
    ReadLn;
{$ENDIF}
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

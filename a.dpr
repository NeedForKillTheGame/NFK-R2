{
        game NEED FOR KILL
        dpr file
		Continue from 062B as R2 by [KoD]connect
        Originally created by 3d[Power]

        http://www.3dpower.org
        http://powersite.narod.ru

        kod.connect@gmail.com
		haz-3dpower@mail.ru
        3dpower@3dpower.org
}

program a;

uses
  Forms,
  Unit1 in 'Unit1.pas' {mainform},
  Unit2 in 'Unit2.pas' {loader},
  demounit in 'demounit.pas',
  net_unit in 'net_unit.pas',
  r2tools in 'r2tools.pas',
  r2nfkLive in 'r2nfkLive.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Need For Kill - R2';
  Loader := TLoader.Create(Application);
  Loader.Show;
  Loader.Update;
  Application.CreateForm(Tmainform, mainform);
  Loader.hide;
  Application.Run;
end.

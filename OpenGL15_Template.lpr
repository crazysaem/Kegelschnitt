program OpenGL15_Template;

{$AppType Gui}

{$mode delphi}{$H+}

uses
  Forms, LResources, Interfaces,
  OpenGL15_MainForm in 'OpenGL15_MainForm.pas' {GLForm},
  Kamera in 'Kamera.pas', render_kegel, trigonom, render_ebene, kegel_funktion,
  render_kegel_funktion_ellipse;

{$IFDEF WINDOWS}{$R OpenGL15_Template.rc}{$ENDIF}

begin
  {$I OpenGL15_Template.lrs}
  Application.Title:='Kegelschnitt';
  Application.Initialize;
  Application.CreateForm(TGLForm, GLForm);
  Application.Run;
end.

// =============================================================================
//   OpenGL1.5 - VCL Template (opengl15_vcl_template.zip)
// =============================================================================
//   Copyright © 2003 by DGL - http://www.delphigl.com
// =============================================================================
//   Contents of this file are subject to the GNU Public License (GPL) which can
//   be obtained here : http://opensource.org/licenses/gpl-license.php
// =============================================================================
//   History :
//    Version 1.0 - Initial Release                            (Sascha Willems)
// =============================================================================

unit OpenGL15_MainForm;

{$MODE Delphi}{$H+}

interface

uses
  LCLIntf, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, dglOpenGL, StdCtrls, LResources, ExtCtrls, Menus, ComCtrls, {SDL,
  SDL_Image,} render_kegel, render_ebene, trigonom, kegel_funktion, render_kegel_schnitt,
  render_kegel_schnitt_top;

type

  { TGLForm }

  TGLForm = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    Popengl: TPanel;
    TBEbeneY: TTrackBar;
    TBwaagr: TTrackBar;
    TBsenkr: TTrackBar;
    TBEbenedreh: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure TBEbenedrehChange(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    RC        : HGLRC;
    DC        : HDC;
    ShowFPS   : Boolean;
    StartTick : Cardinal;
    FPS       : Single;
    procedure GoToFullScreen(pWidth, pHeight, pBPP, pFrequency : Word);
  end;

const
  NearClipping = 0.1;
  FarClipping  = 10000;
  Worldsize = 30;

var
  GLForm: TGLForm;
  texid:gluint;
  zoom,StartTime,DrawTime,TimeCount,TimeCount2,FrameCount,wait,x,y,z:extended;
  Frames,AVGFrames,RAVGFrames,AVGCOUNT,ammo:integer;

  FontBase  : GLUInt;
  RKegelSchnitt:boolean;
  t1, t2,xt1,xt2,time1,time2, Res: int64;

  AccTimeSlice  : Single;
  TimeLastFrame : Cardinal;
  Time          : Single;

implementation


procedure Light(ambientonly:boolean);
const
    light0_ambient  : Array[0..3] of GlFloat = (0.4, 0.4, 0.4, 1.0);
    lightcolor1     : Array[0..3] of GlFloat = (1, 1, 1, 1.0);
  var
    LightDirection : Array[0..2] of GlFloat;
    lightpos1       : Array[0..3] of GlFloat;
    lauf:integer;
  begin
  lightpos1[0]:=-10;
  lightpos1[1]:=20;
  lightpos1[2]:=5;
  lightpos1[3]:=1;

  glPushMatrix();
    if (ambientonly=true) then begin
      //glTranslatef(lightpos1[0],lightpos1[1],lightpos1[2]);

      gllightmodelfv(GL_LIGHT_MODEL_AMBIENT, @light0_ambient);

      gllightfv(GL_LIGHT0, GL_AMBIENT, @lightcolor1);
      //gllightfv(GL_LIGHT0, GL_POSITION, @lightpos1);
    end else begin
      gllightmodelfv(GL_LIGHT_MODEL_AMBIENT, @light0_ambient);

      gllightfv(GL_LIGHT0, GL_DIFFUSE, @lightcolor1);
      gllightfv(GL_LIGHT0, GL_POSITION, @lightpos1);
    end;
  glPopMatrix();
end;

procedure RenderViewPort1;
var height:double;
    Punkt0:TPunkt;
    Egrad,Eheight:double;
    Color:TKColor;
begin
  //Alles weiter wegrücken:
  glTranslatef(0, -2, -14);

  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);

  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  height:=4;
  Light(false);

  glPushMatrix();

    //Wagrecht drehen:
    glTranslatef(0, 2, 0);
    glrotatef( (GLForm.TBwaagr.position-(GLForm.TBwaagr.max/2))/(GLForm.TBwaagr.max/2)*360,0,1,0);

    //Sekrecht drehen:
    glrotatef(GLForm.TBsenkr.position/GLForm.TBsenkr.max*360,1,0,0);
    glTranslatef(0, -2, 0);

    Punkt0[0]:=0;
    Punkt0[1]:=0;
    Punkt0[2]:=0;

    Egrad:=((GLForm.TBEbenedreh.position-50)/50)*-90;
    Eheight:=(GLForm.TBEbeneY.position+1)/(GLForm.TBEbeneY.max+2);

    if RKegelSchnitt=false then begin
      RenderKegel(Punkt0,1.8,height,24);
      glPushMatrix();
        gltranslatef(0,4,0);
        glscalef(-1,-1,1);
        RenderKegel(Punkt0,1.8,height,24);
      glPopMatrix();
    end else begin

      RenderKegelSchnitt(Punkt0,1.8,Eheight,Egrad,96);
      glPushMatrix();
        gltranslatef(0,4,0);
        glscalef(-1,-1,1);
        RenderKegelSchnittTop(Punkt0,1.8,-Eheight,Egrad,96);
      glPopMatrix();
      //RenderKegelSchnittTop(Punkt0,1.8,-Eheight,Egrad,96);
    end;

    //Ebene verschieben:
    //gltranslatef(0,(GLForm.TBEbeneY.position-(GLForm.TBsenkr.max/2))/(GLForm.TBsenkr.max/2)*-height,0);
    gltranslatef(0,GLForm.TBEbeneY.position/(GLForm.TBEbeneY.max+1)*-height+2,0);

    //Ebene um die Z-Achse drehen:
    glrotatef(((GLForm.TBEbenedreh.position-50)/50)*-90,0,0,1);

    //Licht für die Ebene deaktivieren (sieht sonst einfach nur Sche*sse aus)
    glDisable(GL_LIGHTING);

    if RKegelSchnitt=false then begin
      glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
      renderebene(8);
      glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
      renderebene(8);
    end;

  glPopMatrix();

end;

procedure Render;
var Matrix:TArrMatrix;
    gr,Egrad,Eheight:double;
    Color:TKColor;
begin
  // Farb- und Tiefenpuffer löschen
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  // In die Projektionsmatrix wechseln
  glMatrixMode(GL_PROJECTION);
  // Identitätsmatrix laden
  glLoadIdentity;
  // Viewport an Clientareal des Fensters anpassen
  //glViewPort(0, 0, ClientWidth, ClientHeight);
  // Perspective, FOV und Tiefenreichweite setzen
  //gluPerspective(60, ClientWidth/ClientHeight, 1, 128);

  //ViewPort1: (Kegel + Ebene)
    glEnable(GL_LIGHTING);
    //glClearColor(0.3, 0.4, 0.7, 0.0);

    glViewport(0, 0, trunc(GLForm.Popengl.width/2), GLForm.Popengl.height);
    glMatrixMode (GL_PROJECTION);
    glLoadIdentity;

    gluPerspective(45.0, (GLForm.Popengl.Width/2)/GLForm.Popengl.Height, NearClipping, FarClipping);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;

    glPushMatrix();
      RenderViewPort1;
    glPopMatrix();

  //ViewPort2: (Ebene mit Funktion):
    //glClearColor(1,1, 0, 0.0);

    glDisable(GL_LIGHTING);

    glViewport(trunc(GLForm.Popengl.width/2), 0, trunc(GLForm.Popengl.width/2), GLForm.Popengl.height);
    glMatrixMode (GL_PROJECTION);
    glLoadIdentity;

    gluPerspective(45.0, (GLForm.Popengl.Width/2)/GLForm.Popengl.Height, NearClipping, FarClipping);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;

    light(false);

    glBegin(GL_QUADS);
      glColor4f(1,1,0,0.5);
      glNormal3f(0,0,-1);

      gr:=1;

      glVertex3f(-gr,gr,-2);
      glVertex3f(gr,gr,-2);
      glVertex3f(gr,-gr,-2);
      glVertex3f(-gr,-gr,-2);
    glEnd;

    Egrad:=((GLForm.TBEbenedreh.position-50)/50)*-90;

    Eheight:=GLForm.TBEbeneY.position/(GLForm.TBEbeneY.max+1);
    //if Eheight<0 then Eheight:=Eheight*-1;

    Color.r:=1;
    Color.g:=0;
    Color.b:=0;

    kegelfunktion(Eheight,Egrad,Color);

end;

// =============================================================================
//  TForm1.GoToFullScreen
// =============================================================================
//  Wechselt in den mit den Parametern angegebenen Vollbildmodus
// =============================================================================
procedure TGLForm.GoToFullScreen(pWidth, pHeight, pBPP, pFrequency : Word);
var
 dmScreenSettings : DevMode;
begin
// Fenster vor Vollbild vorbereiten
WindowState := wsMaximized;
BorderStyle := bsNone;
ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
with dmScreenSettings do
 begin
 dmSize              := SizeOf(dmScreenSettings);
 dmPelsWidth         := pWidth;                    // Breite
 dmPelsHeight        := pHeight;                   // Höhe
 dmBitsPerPel        := pBPP;                      // Farbtiefe
 dmDisplayFrequency  := pFrequency;                // Bildwiederholfrequenz
 dmFields            := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL or DM_DISPLAYFREQUENCY;
 end;
if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
 begin
 MessageBox(0, 'Konnte Vollbildmodus nicht aktivieren!', 'Error', MB_OK or MB_ICONERROR);
 exit
 end;
end;

procedure Init;
var lauf:integer;
begin
  glEnable(GL_DEPTH_TEST);
	glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
	glEnable(GL_NORMALIZE);
	glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_POINT_SMOOTH);
  glEnable(GL_LINE_SMOOTH);
  glEnable(GL_POLYGON_SMOOTH);
	glShadeModel(GL_SMOOTH); //GL_SMOOTH oder GL_FLAT
  glDisable(GL_CULL_FACE);
  glEnable(GL_BLEND);
  //glFrontFace(GL_CW); GL_CCW Standart
  //glShadeModel(GL_Flat);
  //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

  //Programm in die Mitte des Bildschirms platzieren:
  GLForm.Left:=trunc(screen.Width/2-GLForm.Width/2);
  GLForm.top:=trunc(screen.Height/2-GLForm.Height/2);

  StartTime:=0;
  DrawTime:=0;
  TimeCount:=0;
  FrameCount:=0;
  TimeCount2:=0;

  // In die Modelansichtsmatrix wechseln
  glMatrixMode(GL_MODELVIEW);
  // Identitätsmatrix laden
  glLoadIdentity;

  GLFORM.KeyPreview:=true;
end;

// =============================================================================
//  TForm1.FormCreate
// =============================================================================
//  OpenGL-Initialisierungen kommen hier rein
// =============================================================================
procedure TGLForm.FormCreate(Sender: TObject);
begin
// Wenn gewollt, dann hier in den Vollbildmodus wechseln
// Muss vorm Erstellen des Kontextes geschehen, da durch den Wechsel der
// Gerätekontext ungültig wird!
// GoToFullscreen(1600, 1200, 32, 75);
randomize;
x:=0;y:=0;z:=0;
zoom:=0;
ammo:=7;

//GoToFullScreen(1680,1050,32,60);
                     
// OpenGL-Funtionen initialisieren
InitOpenGL;
// Gerätekontext holen
DC := GetDC(Popengl.Handle);
// Renderkontext erstellen (32 Bit Farbtiefe, 24 Bit Tiefenpuffer, Doublebuffering)
RC := CreateRenderingContext(DC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0);
// Erstellten Renderkontext aktivieren
ActivateRenderingContext(DC, RC);
// Tiefenpuffer aktivieren
glEnable(GL_DEPTH_TEST);
// Nur Fragmente mit niedrigerem Z-Wert (näher an Betrachter) "durchlassen"
glDepthFunc(GL_Less);
// Löschfarbe für Farbpuffer setzen
glClearColor(0.3, 0.4, 0.7, 0.0);
// Displayfont erstellen
//BuildFont('MS Sans Serif');

init;
RKegelSchnitt:=false;

AVGCOUNT:=0;
AVGFrames:=0;
//TimeLastFrame := SDL_GetTicks;
//Time          := TimeLastFrame;
//xt2 := SDL_GetTicks;
//time2 := SDL_GetTicks;

// Idleevent für Rendervorgang zuweisen
Application.OnIdle := ApplicationEventsIdle;
// Zeitpunkt des Programmstarts für FPS-Messung speichern
StartTick := GetTickCount;
end;

procedure TGLForm.Button1Click(Sender: TObject);
begin
  if RKegelSchnitt=false then begin
    Button1.Caption:='Zurück';
    RKegelSchnitt:=true;
    TBEbeneY.Enabled:=false;
    TBEbenedreh.Enabled:=false;
  end else begin
    Button1.Caption:='Abschneiden';
    RKegelSchnitt:=false;
    TBEbeneY.Enabled:=true;
    TBEbenedreh.Enabled:=true;
  end;
end;

// =============================================================================
//  TForm1.FormDestroy
// =============================================================================
//  Hier sollte man wieder alles freigeben was man so im Speicher belegt hat
// =============================================================================
procedure TGLForm.FormDestroy(Sender: TObject);
begin
// Renderkontext deaktiveren
DeactivateRenderingContext;
// Renderkontext "befreien"
wglDeleteContext(RC);
// Erhaltenen Gerätekontext auch wieder freigeben
ReleaseDC(Handle, DC);
// Falls wir im Vollbild sind, Bildschirmmodus wieder zurücksetzen
//ChangeDisplaySettings(devmode(nil^), 0);
end;

// =============================================================================
//  TForm1.ApplicationEventsIdle
// =============================================================================
//  Hier wird gerendert. Der Idle-Event wird bei Done=False permanent aufgerufen
// =============================================================================
procedure TGLForm.ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
var fp:single;
begin

  Render;

  // Hinteren Puffer nach vorne bringen
  SwapBuffers(DC);

  // Windows denken lassen, das wir noch nicht fertig wären
  Done := False;
end;

// =============================================================================
//  TForm1.FormKeyPress
// =============================================================================
procedure TGLForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #27 : Close;
  end;
end;

procedure TGLForm.MenuItem2Click(Sender: TObject);
begin
  GLForm.close;
end;

procedure TGLForm.MenuItem4Click(Sender: TObject);
begin
  showmessage('Programmiert von:'+#10#13+
              'Samuel Schneider'+#10#13+
              'für:'+#10#13+
              'Mathe LK 13'+#10#13+
              'Herr Käufer');

end;

procedure TGLForm.TBEbenedrehChange(Sender: TObject);
begin
  TBEbenedreh.Hint:=floattostr(((GLForm.TBEbenedreh.position-50)/50)*-90)+'°';
end;

initialization
  {$i OpenGL15_MainForm.lrs}
  {$i OpenGL15_MainForm.lrs}

end.

initialization
{$I OpenGL15_MainForm.lrs}

unit render_kegel;

{$MODE Delphi}{$H+}

interface

uses
  dialogs, dglOpenGL, Classes, SysUtils,trigonom;

type
  TPunkt = array [0..2] of GLdouble;
  TArrMatrix = array [0..15] of GLdouble;

procedure RenderKegel(Punkt0:TPunkt;Radius,height:GLdouble;PCount:GLint);

implementation

uses
  OpenGL15_MainForm;

procedure RenderKegel(Punkt0:TPunkt;Radius,height:GLdouble;PCount:GLint);
var lauf:integer;
    gradstuck:double;
    Punktx:array of TPunkt;
begin
  gradstuck:=360/PCount;
  setlength(Punktx,PCount);

  for lauf:=0 to PCount-1 do begin
    Punktx[lauf][0]:=cosinus(gradstuck*lauf)*Radius;
    Punktx[lauf][2]:=sinus(gradstuck*lauf)*Radius;
  end;

  glColor4f(1,0,0,1);

  //Kegel1:
  glBegin(GL_TRIANGLES);
    for lauf:=0 to PCount-1 do begin
      //Mantel:
      glNormal3f(0,1,0);
      glVertex3f(Punkt0[0],height/2,Punkt0[2]);

      glNormal3f(Punktx[lauf][0],0,Punktx[lauf][2]);
      glVertex3f(Punktx[lauf][0],-height/2,Punktx[lauf][2]);

      if lauf<(PCount-1) then begin
        glNormal3f(Punktx[lauf+1][0],0,Punktx[lauf+1][2]);
        glVertex3f(Punktx[lauf+1][0],-height/2,Punktx[lauf+1][2]);
      end else  begin
        glNormal3f(Punktx[0][0],0,Punktx[0][2]);
        glVertex3f(Punktx[0][0],-height/2,Punktx[0][2]);
      end;
      //Boden:
      glNormal3f(Punktx[lauf][0],0,Punktx[lauf][2]);
      glVertex3f(Punktx[lauf][0],-height/2,Punktx[lauf][2]);

      if lauf<(PCount-1) then begin
        glNormal3f(Punktx[lauf+1][0],0,Punktx[lauf+1][2]);
        glVertex3f(Punktx[lauf+1][0],-height/2,Punktx[lauf+1][2]);
      end else  begin
        glNormal3f(Punktx[0][0],0,Punktx[0][2]);
        glVertex3f(Punktx[0][0],-height/2,Punktx[0][2]);
      end;

      glNormal3f(0,-1,0);
      glVertex3f(Punkt0[0],Punkt0[1]-height/2,Punkt0[2]);
    end;
  glEnd;
  (*
  //Kegel2:
  glBegin(GL_TRIANGLES);
    for lauf:=0 to PCount-1 do begin
      //Mantel:
      glNormal3f(0,-1,0);
      glVertex3f(Punkt0[0],Punkt0[1],Punkt0[2]);

      glNormal3f(Punktx[lauf][0],0,Punktx[lauf][2]);
      glVertex3f(Punktx[lauf][0],height,Punktx[lauf][2]);

      if lauf<(PCount-1) then begin
        glNormal3f(Punktx[lauf+1][0],0,Punktx[lauf+1][2]);
        glVertex3f(Punktx[lauf+1][0],height,Punktx[lauf+1][2]);
      end else  begin
        glNormal3f(Punktx[0][0],0,Punktx[0][2]);
        glVertex3f(Punktx[0][0],height,Punktx[0][2]);
      end;

      //Boden:
      glNormal3f(Punktx[lauf][0],0,Punktx[lauf][2]);
      glVertex3f(Punktx[lauf][0],height,Punktx[lauf][2]);

      if lauf<(PCount-1) then begin
        glNormal3f(Punktx[lauf+1][0],0,Punktx[lauf+1][2]);
        glVertex3f(Punktx[lauf+1][0],height,Punktx[lauf+1][2]);
      end else  begin
        glNormal3f(Punktx[0][0],0,Punktx[0][2]);
        glVertex3f(Punktx[0][0],height,Punktx[0][2]);
      end;

      glNormal3f(0,1,0);
      glVertex3f(Punkt0[0],Punkt0[1]+height,Punkt0[2]);
    end;
  glEnd;*)

end;

end.


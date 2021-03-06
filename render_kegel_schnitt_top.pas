﻿unit render_kegel_schnitt_top;

{$MODE Delphi}{$H+}

interface

uses
  dialogs, dglOpenGL, Classes, SysUtils,trigonom, render_kegel, render_kegel_funktion_ellipse,
  render_kegel_funktion, kegel_funktion;

procedure RenderKegelSchnittTop(Punkt0:TPunkt;Radius,height,grad:GLdouble;PCount:GLint);

implementation

uses
  OpenGL15_MainForm;

function Ebene(x,grad,hoehe:double):double;
var y:double;
begin
  y:=(1/tangens(grad))*x - (1/tangens(grad))*hoehe;
  Ebene:=y;
end;

function Ebene_umkehr(x,grad,hoehe:double):double;
var y:double;
begin
  hoehe:=-(hoehe-1);
  y:=-(1/tangens(grad))*hoehe - x;
  y:=y/(-(1/tangens(grad)));
  Ebene_umkehr:=y;
end;

function KegelBreite(x:double):double;
var y:double;
begin
  y:=1.8*x;
  KegelBreite:=y;
end;

function KegelHoehe(x:double):double;
var y:double;
begin
  y:=(-(4/(1.8)))*x + 4;
  KegelHoehe:=y;
end;

function KegelHoehe_(x:double):double;
var y:double;
begin
  y:=(x - 4)/(-(4/(1.8)));
  KegelHoehe_:=y;
end;

function KegelTiefe(lauf,laufmax,a,b:double):double;  // EllipsenFunktion modifiziert.
var y,x:double;
begin

  if (lauf<(laufmax/2)) then x:=a - 2*a*(lauf/(laufmax*0.5))
    else x:=-a + 2*a*((lauf-(laufmax*0.5))/(laufmax*0.5));

  y:=(sqr(b)*(-1))*(-1+(sqr(x)/sqr(a)));
  if y<=0 then begin
    y:=0;
  end else y:=sqrt(y);

  if (lauf+1)=((laufmax+1)/2) then begin
    KegelTiefe:=0;
    exit;
  end;

  if (lauf<(laufmax/2)) then KegelTiefe:=y
    else KegelTiefe:=-y;

end;

function NullEinsNull(lauf,laufmax:double):double;
begin
  if lauf<=(laufmax*0.5) then begin
    NullEinsNull:=lauf/(laufmax*0.5)
  end else begin
    NullEinsNull:=2-lauf/(laufmax*0.5)
  end;
end;

procedure RenderKegelSchnittTop(Punkt0:TPunkt;Radius,height,grad:GLdouble;PCount:GLint);
var lauf:integer;
    gradstuck,xschnitt1,xschnitt2,xtemp,schnitt,xmax,yber,xber,zber,xbla,yschnitt1,yschnitt2,faktor,
    BreiteL,BreiteL2,BreiteR,BreiteR2,Breite,KegTiefe,zfaktor:double;
    Punktx:array of TPunkt;
begin
  gradstuck:=360/PCount;
  setlength(Punktx,PCount);

  //xschnitt1: von Links unten nach rechts oben:

  xschnitt1:=1/tangens(grad)*height;
  xschnitt1:=-xschnitt1/((0.45)-1/tangens(grad));

  //xschnitt2: von rechts unten nach links oben:

  xschnitt2:=1/tangens(grad)*height;
  xschnitt2:=-xschnitt2/((-0.45)-1/tangens(grad));
  (*
  if xschnitt1>1 then begin
    xschnitt1:=1;
  end;
  if xschnitt1<0 then xschnitt1:=0;

  if xschnitt2>1 then begin
    xschnitt2:=1;
  end;
  if xschnitt2<0 then xschnitt2:=0;*)

  if grad=0 then begin
    xschnitt1:=height;
    xschnitt2:=height;
    schnitt:=0;
  end;

  xtemp:=xschnitt1;

  if xtemp>1 then begin
    xtemp:=1;
  end;
  if xtemp<0 then xtemp:=0;

  BreiteL:=KegelBreite(xtemp);
  if BreiteL<0.001 then BreiteL:=0;

  xtemp:=xschnitt2;

  if xtemp>1 then begin
    xtemp:=1;
  end;
  if xtemp<0 then xtemp:=0;

  xmax:=-Ebene(1,grad,height)*4;

  BreiteR:=KegelBreite(xtemp);
  Breite :=BreiteL+BreiteR;

  BreiteR2:=BreiteR/(sinus(90+grad));
  BreiteL2:=BreiteL/(sinus(90+grad));

  yschnitt1:=Ebene_umkehr(-BreiteL/4,grad,height);
  if yschnitt1<0 then yschnitt1:=0;
  //if BreiteR>xmax then yschnitt2:=Ebene_umkehr(xmax/4,grad,height)
  //  else yschnitt2:=Ebene_umkehr(BreiteR/4,grad,height);
  yschnitt2:=Ebene_umkehr(BreiteR/4,grad,height);

  //Bodenstück des Kegels wird abgehackt:
  if (Ebene(1,grad,height)<=0.45) and (Ebene(1,grad,height)>=-0.45) and (grad<>0) and (grad<>-0) then begin
    (*
    if grad>0 then begin
      grad:=abs(grad);
      xmax:=abs(xmax);
      xschnitt1:=xschnitt2;
      BreiteL:=BreiteR;
      glscalef(-1,1,1);
    end;*)

    if grad>0 then begin
      xschnitt2:=xschnitt1;
      grad:=abs(grad);
      xmax:=abs(xmax);
      //glscalef(-1,1,1);
    end;

    //xbla:=BreiteL/cosinus(abs(grad)) + xmax/cosinus(abs(grad));
    //P1((1.8-KegelHoehe_(xschnitt2*4))|xschnitt2)
    //P2(xmax|0)
    xbla:=sqrt(sqr((1.8-KegelHoehe_(xschnitt2*4)) - xmax) + sqr((1-xschnitt2)*4));
    if xbla>x_y0glob then xbla:=x_y0glob;
    if (abs(grad)=90) then begin
      xbla:=4;
    end;

    glBegin(GL_QUADS);

    if abs(xmax)>0 then begin

      for lauf:=0 to PCount-1 do begin //PCount-1

        //glColor4f(0,lauf/(PCount-1),0,1);
        glColor4f(1,0,0,1);

        //Mantel (Teil1):
        //glNormal3f(Punktx[lauf][0],0,Punktx[lauf][2]*Radius);
        //xber:=1.8-(1.8-xmax)*NullEinsNull(lauf,PCount-1);
        xber:=xmax+(1.8-xmax)*NullEinsNull(lauf,PCount-1);
        zber:=sqrt(sqr(1.8)-sqr(xber));
        if ((lauf+1)/PCount)>0.5 then zber:=-zber;
        if xber>1.79 then zber:=0;
        glNormal3f(xber,0,zber);
        glVertex3f(xber,-2,zber);

        if lauf<(PCount-1) then begin
          //glNormal3f(Punktx[lauf+1][0],0,Punktx[lauf+1][2]*Radius);
          //xber:=1.8-(1.8-xmax)*NullEinsNull(lauf+1,PCount-1);
          xber:=xmax+(1.8-xmax)*NullEinsNull(lauf+1,PCount-1);
          zber:=sqrt(sqr(1.8)-sqr(xber));
          if ((lauf+2)/PCount)>0.5 then zber:=-zber;
          if xber>1.79 then zber:=0;
          glNormal3f(xber,0,zber);
          glVertex3f(xber,-2,zber);
        end else  begin
          glNormal3f(xmax,0,1.8);
          glVertex3f(xmax,-2,1.8);
        end;

        zfaktor:=sqrt(sqr(1.8)-sqr(xmax))/KegSchnitt(radiusglob,eglob,xbla);
        if (KegSchnitt(radiusglob,eglob,(xbla-xbla*0.5))*zfaktor)>1.8 then zfaktor:=1;

        //xber:=(xmax-(1.8-KegelHoehe_(xschnitt2*4)));

        //Mantel (Teil2):

          if lauf<(PCount-1) then begin
            //glNormal3f(BreiteR - Breite*NullEinsNull(lauf+1,PCount-1),0,KegelTiefe(lauf+1,PCount-1,Breite/2,KegTiefe));
            (*
            yber:=( (1-xschnitt1)*NullEinsNull(lauf+1,PCount-1) )*4-2;
            xber:=xmax-(BreiteL+xmax)*NullEinsNull(lauf+1,PCount-1);*)
            zber:=KegSchnitt(radiusglob,eglob,xbla-xbla*NullEinsNull(lauf+1,PCount-1));
            if ((lauf+2)/PCount)>0.5 then zber:=-zber;
            zber:=zber*zfaktor;
            xber:=xmax-(xmax-(1.8-KegelHoehe_(xschnitt2*4)))*NullEinsNull(lauf+1,PCount-1);
            yber:=-2+((1-xschnitt2)*4)*NullEinsNull(lauf+1,PCount-1);
            //zber:=0;
            glNormal3f(0,yber+2,zber);
            glVertex3f(xber,yber,zber);
          end else  begin
            (*
            glNormal3f(BreiteR,0,KegelTiefe(0,PCount-1,Breite/2,KegTiefe));
            yber:=-2; *)
            zber:=KegSchnitt(radiusglob,eglob,xbla);
            zber:=zber*zfaktor;
            xber:=xmax;
            yber:=-2;
            //zber:=0;
            glNormal3f(0,yber+2,zber);
            glVertex3f(xmax,yber,zber);
          end;

          //glNormal3f(BreiteR - Breite*NullEinsNull(lauf,PCount-1),0,KegelTiefe(lauf,PCount-1,Breite/2,KegTiefe));
          (*
          yber:=( (1-xschnitt1)*NullEinsNull(lauf,PCount-1) )*4-2;
          xber:=xmax-(BreiteL+xmax)*NullEinsNull(lauf,PCount-1); *)
          zber:=KegSchnitt(radiusglob,eglob,xbla-xbla*NullEinsNull(lauf,PCount-1));
          if ((lauf+1)/PCount)>0.5 then zber:=-zber;
          zber:=zber*zfaktor;
          xber:=xmax-(xmax-(1.8-KegelHoehe_(xschnitt2*4)))*NullEinsNull(lauf,PCount-1);
          yber:=-2+((1-xschnitt2)*4)*NullEinsNull(lauf,PCount-1);
          //zber:=0;
          glNormal3f(0,yber+2,zber);
          glVertex3f(xber,yber,zber);

      end;

    end;

    glEnd;

    glBegin(GL_TRIANGLES);
      for lauf:=0 to PCount-1 do begin //PCount-1

        //Boden:

        glColor4f(1,0,0,1);

        xber:=xmax;
        glNormal3f(0,-1,0);
        glVertex3f(xber,-2,0);

        xber:=xmax+(1.8-xmax)*NullEinsNull(lauf,PCount-1);
        zber:=sqrt(sqr(1.8)-sqr(xber));
        if ((lauf+1)/PCount)>0.5 then zber:=-zber;
        if xber>1.79 then zber:=0;
        glNormal3f(xber,0,zber);
        glVertex3f(xber,-2,zber);

        if lauf<(PCount-1) then begin
          //glNormal3f(Punktx[lauf+1][0],0,Punktx[lauf+1][2]*Radius);
          //xber:=1.8-(1.8-xmax)*NullEinsNull(lauf+1,PCount-1);
          xber:=xmax+(1.8-xmax)*NullEinsNull(lauf+1,PCount-1);
          zber:=sqrt(sqr(1.8)-sqr(xber));
          if ((lauf+2)/PCount)>0.5 then zber:=-zber;
          if xber>1.79 then zber:=0;
          glNormal3f(xber,0,zber);
          glVertex3f(xber,-2,zber);
        end else  begin
          glNormal3f(xmax,0,1.8);
          glVertex3f(xmax,-2,1.8);
        end;

        //Deckel:

        glColor4f(0,0,1,1);

        glNormal3f(-1,0,0);
        xber:=xmax-(xmax-(1.8-KegelHoehe_(xschnitt2*4)))*0.25;
        yber:=-2+((1-xschnitt2)*4)*0.25;
        glVertex3f(xber,yber,0);

        if lauf<(PCount-1) then begin
            //glNormal3f(BreiteR - Breite*NullEinsNull(lauf+1,PCount-1),0,KegelTiefe(lauf+1,PCount-1,Breite/2,KegTiefe));
            (*
            yber:=( (1-xschnitt1)*NullEinsNull(lauf+1,PCount-1) )*4-2;
            xber:=xmax-(BreiteL+xmax)*NullEinsNull(lauf+1,PCount-1);*)
            zber:=KegSchnitt(radiusglob,eglob,xbla-xbla*NullEinsNull(lauf+1,PCount-1));
            if ((lauf+2)/PCount)>0.5 then zber:=-zber;
            zber:=zber*zfaktor;
            xber:=xmax-(xmax-(1.8-KegelHoehe_(xschnitt2*4)))*NullEinsNull(lauf+1,PCount-1);
            yber:=-2+((1-xschnitt2)*4)*NullEinsNull(lauf+1,PCount-1);
            //zber:=0;
            glNormal3f(0,yber+2,zber);
            glVertex3f(xber,yber,zber);
          end else  begin
            (*
            glNormal3f(BreiteR,0,KegelTiefe(0,PCount-1,Breite/2,KegTiefe));
            yber:=-2; *)
            zber:=KegSchnitt(radiusglob,eglob,xbla);
            zber:=zber*zfaktor;
            xber:=xmax;
            yber:=-2;
            //zber:=0;
            glNormal3f(0,yber+2,zber);
            glVertex3f(xmax,yber,zber);
          end;

          //glNormal3f(BreiteR - Breite*NullEinsNull(lauf,PCount-1),0,KegelTiefe(lauf,PCount-1,Breite/2,KegTiefe));
          (*
          yber:=( (1-xschnitt1)*NullEinsNull(lauf,PCount-1) )*4-2;
          xber:=xmax-(BreiteL+xmax)*NullEinsNull(lauf,PCount-1); *)
          zber:=KegSchnitt(radiusglob,eglob,xbla-xbla*NullEinsNull(lauf,PCount-1));
          if ((lauf+1)/PCount)>0.5 then zber:=-zber;
          zber:=zber*zfaktor;
          xber:=xmax-(xmax-(1.8-KegelHoehe_(xschnitt2*4)))*NullEinsNull(lauf,PCount-1);
          yber:=-2+((1-xschnitt2)*4)*NullEinsNull(lauf,PCount-1);
          //zber:=0;
          glNormal3f(0,yber+2,zber);
          glVertex3f(xber,yber,zber);

      end;
    glEnd;
  end;

end;

end.


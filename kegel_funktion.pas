unit kegel_funktion;

{$mode objfpc}{$H+}

interface

uses
  dglOpenGL, Classes, SysUtils, render_kegel_funktion_ellipse, render_kegel_funktion, trigonom;

type
  TKColor = record
    r,g,b:double;
  end;

procedure kegelfunktion(hoehe,grad:double;Color:TKColor);

var
  radiusglob,eglob,x_y0glob:double;

implementation

procedure kegelfunktion(hoehe,grad:double;Color:TKColor);
var radius,xschnitt1,yschnitt1,xschnitt2,yschnitt2,rmax1,rmax2,alpha,
    BL2,BR2:double;
begin
  //hoehemax=1 ! wichtig
  //Viewport 2 Breite 1.6, Hoehe 1.6 ! auch wichtig,
  //  damit ist Rmax=0.8
  (*
  glBegin(GL_POINTS);
    //Mittelpunkt markieren:
    glColor4f(0,0,0,1);
    glVertex3f(0,0,-1.99);
  glEnd;*)

  glColor4f(Color.r,Color.g,Color.b,1);

  //Grad = 0, Sonderfall Kreis:
  (*
  radius:=hoehe*0.8;
  if (grad=0) then begin
    RenderEllipse(radius,radius,radius);
    exit;
  end;*)

  //Wenn die Ebene Gerdreht ist Schnittpunkt berechnen:
  //if grad<0 then alpha:=grad*-1 else alpha:=grad;
  alpha:=abs(grad);

  xschnitt1:=1/tangens(alpha)*hoehe;
  xschnitt1:=-xschnitt1/((0.45)-1/tangens(alpha));

  xschnitt2:=1/tangens(alpha)*hoehe;
  xschnitt2:=-xschnitt2/((-0.45)-1/tangens(alpha));

  if alpha=0 then xschnitt1:=hoehe;
  if alpha=0 then xschnitt2:=hoehe;

  //Wenn xschnitt zwichen 0 und 1, so "verlässt" die Ebene den Kegel nicht, als haben wir eine Ellipse:
  //if ((xschnitt1<=1) and (xschnitt1>=0)) and ((xschnitt2<=1) and (xschnitt2>=0)) then begin
    yschnitt1:=0.8*xschnitt1;
    yschnitt2:=0.8*xschnitt2;

    rmax1:=sqrt(sqr(xschnitt1-hoehe)+sqr(yschnitt1));
    rmax2:=sqrt(sqr(xschnitt2-hoehe)+sqr(yschnitt2));

    if xschnitt2<0 then xschnitt2:=0;
    if xschnitt1<0 then xschnitt1:=0;

    BL2:=(xschnitt2*1.8)/cosinus(abs(grad));
    BR2:=(xschnitt1*1.8)/cosinus(abs(grad));

    radiusglob:=abs(BL2);
    if (abs(grad)=90) then begin
      radiusglob:=0;
    end;

    eglob:=grad/63.08;
    eglob:=abs(eglob);
    if eglob<1 then begin
      x_y0glob:=(2*radiusglob)/(1-sqr(eglob));
    end else x_y0glob:=3.6;
    if x_y0glob>3.6 then x_y0glob:=3.6;

    if abs(grad)=90 then begin
      BL2:=0;
      BR2:=0;
    end;

    BL2:=xschnitt2*1.8;
    BR2:=xschnitt1*1.8;

    //RenderEllipse(rmax1,rmax2,radius);
    RenderKegelfunktion(BL2,BR2,grad,63.08);
    exit;
 // end;

end;

end.


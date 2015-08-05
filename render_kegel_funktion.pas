unit render_kegel_funktion;

{$mode objfpc}{$H+}

interface

uses
  dglOpenGL, Classes, SysUtils;

procedure RenderKegelfunktion(radius,radius_,grad,grad_e:double);
function KegSchnitt(radius,e,x:double):double;

implementation
uses
  OpenGL15_MainForm;

function KegSchnitt(radius,e,x:double):double;
var y:double;
begin
  y:=2*radius*x-(1-sqr(e))*sqr(x);
  if y>0 then y:=sqrt(y)
    else y:=0;
  KegSchnitt:=y;
end;

procedure RenderKegelfunktion(radius,radius_,grad,grad_e:double);
var a,x,step,y,
    x_y0,x_y0_,e,ymax:double;
begin
  //Die gemalte Ebene ist immer auf Z=-2, daher "dünn obendrübermalen"
  //Formel: y^2 = 2*p*x-(1-e^2)*x^2

  x:=0;
  step:=0.04;

  radius:=abs(radius);
  radius_:=abs(radius_);

  //radiusglob:=radius;

  radius_:=radius;

  e:=grad/grad_e;
  e:=abs(e);
  //eglob:=e;

  if e<1 then begin
    x_y0:=(2*radius)/(1-sqr(e));
  end else x_y0:=3.6;
  if x_y0>3.6 then x_y0:=3.6;

  //x_y0glob:=x_y0;

  if e<1 then begin
    x_y0_:=(2*radius_)/(1-sqr(e));
  end else x_y0_:=3.6;
  if x_y0_>3.6 then x_y0_:=3.6;

  ymax:=KegSchnitt(radius,e,x_y0);

  glTranslatef(0, 0, -1.99);
  glscalef(0.22,0.22,1);

  GLForm.Label2.Caption:='p = '+floattostr(radius);
  GLForm.Label3.Caption:='e = '+floattostr(e);
  if radius<0.01 then GLForm.Label2.Caption:='p = 0';

  glBegin(GL_LINES);

    while x<x_y0 do begin

      //Funktion oben:
      glVertex3f(x,KegSchnitt(radius,e,x),0);
      glVertex3f(x+step,KegSchnitt(radius,e,x+step),0);

      //Funtkion unten:
      glVertex3f(x,-KegSchnitt(radius,e,x),0);
      glVertex3f(x+step,-KegSchnitt(radius,e,x+step),0);

      x:=x+step;
    end;

      x:=x-step;

      glVertex3f(x,KegSchnitt(radius,e,x),0);
      glVertex3f(x_y0,KegSchnitt(radius,e,x_y0),0);

      glVertex3f(x,-KegSchnitt(radius,e,x),0);
      glVertex3f(x_y0,-KegSchnitt(radius,e,x_y0),0);

  glEnd;

  x:=0;

  if e>1 then begin
     glBegin(GL_LINES);

      while x<=x_y0_ do begin

        //Funktion oben:
        glVertex3f(-x,KegSchnitt(radius_,e,x),0);
        glVertex3f(-(x+step),KegSchnitt(radius_,e,x+step),0);

        //Funtkion unten:
        glVertex3f(-x,-KegSchnitt(radius_,e,x),0);
        glVertex3f(-(x+step),-KegSchnitt(radius_,e,x+step),0);

        x:=x+step;
      end;

        glVertex3f(-(x+step),KegSchnitt(radius_,e,x+step),0);
        glVertex3f(-x_y0,KegSchnitt(radius_,e,x_y0),0);

        glVertex3f(-(x+step),-KegSchnitt(radius_,e,x+step),0);
        glVertex3f(-x_y0,-KegSchnitt(radius_,e,x_y0),0);

    glEnd;
  end;

end;

end.


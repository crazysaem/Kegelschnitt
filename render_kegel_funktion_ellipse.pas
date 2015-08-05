unit render_kegel_funktion_ellipse;

{$mode objfpc}{$H+}

interface

uses
  dglOpenGL, Classes, SysUtils;

procedure RenderEllipse(ar,al,b:double);
function Ellipse(x,a,b:double):double;

implementation

function Ellipse(x,a,b:double):double;
var y:double;
begin
  y:=(sqr(b)*(-1))*(-1+(sqr(x)/sqr(a)));
  if y<=0 then begin
    y:=0;
  end else y:=sqrt(y);
  Ellipse:=y;
end;

procedure RenderEllipse(ar,al,b:double);
var a,x,step,y:double;
begin
  //Die gemalte Ebene ist immer auf Z=-2, daher "dünn obendrübermalen"
  //Formel: x^2/a^2 + y^2/b^2 = 1

  x:=0;
  step:=0.01;

  a:=(ar+al)/2;

  glTranslatef((ar-al)/2.25, 0, -1.99);

  glBegin(GL_LINES);

    while (x+step)<a do begin

      //Ellipse oben Rechts:
      glVertex3f(x,Ellipse(x,a,b),0);
      glVertex3f(x+step,Ellipse(x+step,a,b),0);

      //Ellipse unten Rechts:
      glVertex3f(x,-Ellipse(x,a,b),0);
      glVertex3f(x+step,-Ellipse(x+step,a,b),0);

      //Ellipse oben Links:
      glVertex3f(-x,Ellipse(-x,a,b),0);
      glVertex3f(-(x+step),Ellipse(-(x+step),a,b),0);

      //Ellipse unten Links:
      glVertex3f(-x,-Ellipse(-x,a,b),0);
      glVertex3f(-(x+step),-Ellipse(-(x+step),a,b),0);

      x:=x+step;
    end;

    //Ellipse oben Rechts schliesen
    glVertex3f(x,Ellipse(x,a,b),0);
    glVertex3f(a,0,0);

    //Ellipse unten Rechts schliesen
    glVertex3f(x,-Ellipse(x,a,b),0);
    glVertex3f(a,0,0);

    //Ellipse oben Links:
    glVertex3f(-x,Ellipse(-x,a,b),0);
    glVertex3f(-a,0,0);

    //Ellipse unten Links:
    glVertex3f(-x,-Ellipse(-x,a,b),0);
    glVertex3f(-a,0,0);

  glEnd;
end;

end.


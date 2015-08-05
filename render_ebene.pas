unit render_ebene;

{$mode objfpc}{$H+}

interface

uses
  dglOpenGL, Classes, SysUtils, trigonom;

procedure renderebene(grose:double);

implementation

procedure renderebene(grose:double);
begin

  glBegin(GL_QUADS);
    glColor4f(1,1,0,0.4);
    glNormal3f(0,1,0);

    glVertex3f(grose,0,grose);
    glVertex3f(grose,0,-grose);
    glVertex3f(-grose,0,-grose);
    glVertex3f(-grose,0,grose);
  glEnd;

end;

end.


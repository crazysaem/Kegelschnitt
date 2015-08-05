unit trigonom;

{$MODE Delphi}{$H+}

interface

uses
  Classes, SysUtils;

function sinus(grad:double):double;
function cosinus(grad:double):double;
function tangens(grad:double):double;

const
  pi = 3.14159265;

implementation

function sinus(grad:double):double;
begin
  sinus:=sin(2*pi/(360/grad));
end;

function cosinus(grad:double):double;
begin
  cosinus:=cos(2*pi/(360/grad));
end;

function tangens(grad:double):double;
begin
  tangens:=sinus(grad)/cosinus(grad);
end;

end.


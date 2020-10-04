unit LCL_OpenGL;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ComCtrls, zgl_screen, zgl_main//,
  //gtk2, Gtk2Proc//, X, xlib//, xrandr//, unixtype//, xutil//,
   //dglOpenGL//, GLEngine
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    UpDownX: TUpDown;
    UpDownY: TUpDown;
    UpDownW: TUpDown;
    UpDownH: TUpDown;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
{  winOn: Boolean = false;

  winDefault: cint;
  winEventBase, winErrorBase: cint;
  winDisplay: PDisplay;
  rootWin: TWindow;
  winModeList: PXRRScreenSize;
  winSettings: Pointer;
  winDesctop, winModeCount: LongInt;
  winRotation: Word;     }

  // glcontext
{  myGlContext: GLXContext;
  _glVisualInfo: PXVisualInfo;
  glErrorBase, glEventBase: PGLint;
  _glStencil: Byte = 0;
  _glFSAA: byte = 0;
  _glzDepth: Byte = 24;
  _glAttr: array[0..17] of Integer;   }

//  widget: PGtkWidget;
//  GLE: TGLEngine;

implementation

{$R *.frm}

{ TForm1 }
procedure TForm1.Button1Click(Sender: TObject);
begin
{  if Assigned(winDisplay) then                                        // если существует окно - закрываем
     XCloseDisplay(winDisplay);
  winDisplay := XOpenDisplay(nil);                                    // заново создаём
  if not(Assigned(winDisplay)) then
  begin
    winOn := false;
    exit;
  end
  else
    winOn := true;

  winDefault := DefaultScreen(winDisplay);                            // типо хендл?
  rootWin := DefaultRootWindow(winDisplay);

  XRRSelectInput(winDisplay, rootWin, RRScreenChangeNotifyMask);      // выбор окна???
  XRRQueryExtension(winDisplay, @winEventBase, @winErrorBase);

  winModeList := XRRSizes(winDisplay, XRRRootToScreen(winDisplay, rootWin), @winModeCount);
  winSettings := XRRGetScreenInfo(winDisplay, rootWin);
  winDesctop := XRRConfigCurrentConfiguration(winSettings, @winRotation);

  if not InitOpenGL() then
  begin
    winOn := False;
    exit;
  end;
  if not glXQueryExtension(winDisplay, glErrorBase, glEventBase) then
  begin
    winOn := false;
    exit;
  end;

  // создаём формат пикселей
  repeat
    FillChar(_glAttr[0], Length(_glAttr) * 4, 0);
    _glAttr[0] := GLX_RGBA;
    _glAttr[1] := 1;
    _glAttr[2] := GLX_RED_SIZE;
    _glAttr[3] := 8;
    _glAttr[4] := GLX_GREEN_SIZE;
    _glAttr[5] := 8;
    _glAttr[6] := GLX_BLUE_SIZE;
    _glAttr[7] := 8;
    _glAttr[8] := GLX_ALPHA_SIZE;
    _glAttr[9] := 0;//8 * Byte(not appInitedToHandle);
    _glAttr[10] := GLX_DOUBLEBUFFER;
    _glAttr[11] := 1;
    _glAttr[12] := GLX_DEPTH_SIZE;
    _glAttr[13] := _glzDepth;
    if _glStencil > 0 Then
    begin
      _glAttr[14] := GLX_STENCIL_SIZE;
      _glAttr[15] := _glStencil;
    end;
    if _glFSAA > 0 Then
    begin
      _glAttr[16] := GLX_SAMPLES;
      _glAttr[17] := _glFSAA;
    end;
    _glVisualInfo := glXChooseVisual(winDisplay, winDefault, @_glAttr[0]);
    if (not Assigned(_glVisualInfo)) and (_glzDepth = 1) then
    begin
      if _glFSAA = 0 then
        break
      else
      begin
        _glzDepth := 24;
        dec(_glFSAA, 2);
      end;
    end
    else begin
      if not Assigned(_glVisualInfo) then
        dec(_glzDepth, 8);
    end;
    if _glzDepth = 0 then _glzDepth := 1;
  until Assigned(_glVisualInfo);

  if not Assigned(_glVisualInfo) then
  begin
    winOn := false;
    exit;
  end;

  myGlContext := glXCreateContext(winDisplay, _glVisualInfo, nil, true);
  if not Assigned(myGlContext) then
  begin
    myGlContext := glXCreateContext(winDisplay, _glVisualInfo, nil, False);
    if not Assigned(myGlContext) then
    begin
      winOn := false;
      exit;
    end;
  end;
  if not glXMakeCurrent(winDisplay, Panel1.Handle, myGlContext) then
  begin
    winOn := False;
    exit;
  end;
  // всё инициализировали, теперь прогружаем функции OpenGL
  ReadExtensions;
  ReadImplementationProperties;         }

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
{  // проверки будут лишними???
  // уничтожаем openGL
  glXMakeCurrent(winDisplay, 0, nil);
  glXDestroyContext(winDisplay, myGlContext);
  FreeOpenGL;

  // уничтожаем окно
  XRRFreeScreenConfigInfo(winSettings);
  XSync(winDisplay, FALSE);         }
end;


end.
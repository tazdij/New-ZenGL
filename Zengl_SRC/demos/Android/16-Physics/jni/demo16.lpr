// RU: ВНИМАНИЕ! Т.к. на данный момент Chipmunk собран с soft float - производительность довольно низкая.
// EN: WARNING! Chipmunk is built with soft float and because of this performance is not good.
library demo16;

{$I zglCustomConfig.cfg}
{$I zgl_config.cfg}

uses
  zgl_application,
  zgl_file,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_mouse,
  zgl_touch,
  zgl_textures,
  zgl_textures_png,
  zgl_render_2d,
  zgl_font,
  zgl_text,
  zgl_primitives_2d,
  zgl_math_2d,
  zglChipmunk,
  zgl_utils;

var
  dirRes  : UTF8String = 'assets/';
  fntMain : LongWord;
  space   : PcpSpace;
  bCount  : Integer;
  Bodies  : array of PcpBody;
  Shapes  : array of PcpShape;
  balls   : Boolean = false;

// RU: Добавить объект "шар"
//     x, y - координаты центра
//     mass - масса
//     r    - радиус
//     e    - коэффициент эластичности
//     u    - коэффициент трения
//
// EN: Add new object "ball"
//     x, y - coordinates
//     mass - mass
//     r    - radius
//     e    - coefficient of restitution. (elasticity)
//     u    - coefficient of friction
procedure cpAddBall(x, y, r, mass, e, u: cpFloat);
begin
  INC(bCount);
  SetLength(Bodies, bCount);
  SetLength(Shapes, bCount);

  Bodies[bCount - 1]   := cpBodyNew(mass, cpMomentForCircle(mass, 0, r, cpvzero));
  Bodies[bCount - 1]^.p := cpv(x, y);
  cpSpaceAddBody(space, Bodies[bCount - 1]);

  Shapes[bCount - 1]   := cpCircleShapeNew(Bodies[bCount - 1], r, cpvzero);
  Shapes[bCount - 1]^.e := e;
  Shapes[bCount - 1]^.u := u;
  cpSpaceAddShape(space, Shapes[bCount - 1]);
end;

// RU: Добавить объект "коробка"
//     Схож с процедурой cpAddBall по аргументам
//     x, y - координаты центра
//     w, h - ширина и высота
//
// EN: Add bew object "box"
//     Arguments are similar to arguments of procedure cpAddBall
//     x, y - coordinates of center
//     w, h - width and height
procedure cpAddBox(x, y, w, h, mass, e, u: cpFloat);
  var
    points : array[0..3] of cpVect;
    f      : cpFloat;
begin
  INC(bCount);
  SetLength(Bodies, bCount);
  SetLength(Shapes, bCount);

  points[ 0 ].x := - w / 2;
  points[ 0 ].y := - h / 2;
  points[ 1 ].x := - w / 2;
  points[ 1 ].y := h / 2;
  points[ 2 ].x := w / 2;
  points[ 2 ].y := h / 2;
  points[ 3 ].x := w / 2;
  points[ 3 ].y := - h / 2;

  f := cpMomentForPoly(mass, 4, @points[0], cpvzero);
  Bodies[bCount - 1]   := cpBodyNew(mass, f);
  Bodies[bCount - 1]^.p := cpv(x + w / 2, y + h / 2);
  cpSpaceAddBody(space, Bodies[bCount - 1]);

  Shapes[bCount - 1]   := cpPolyShapeNew(Bodies[bCount - 1], 4, @points[0], cpvzero);
  Shapes[bCount - 1]^.e := e;
  Shapes[bCount - 1]^.u := u;
  cpSpaceAddShape(space, Shapes[bCount - 1]);
end;

procedure Init;
  var
    staticBody : PcpBody;
    ground     : PcpShape;
    e, u       : cpFloat;
begin
  zgl_Enable(CORRECT_RESOLUTION);
  scr_CorrectResolution(800, 600);

  file_OpenArchive(PAnsiChar(zgl_Get(DIRECTORY_APPLICATION)));

  fntMain := font_LoadFromFile(dirRes + 'font.zfi');

  file_CloseArchive();

  cpInitChipmunk();

  // RU: Создаем новый "мир".
  // EN: Create new world.
  space            := cpSpaceNew();
  // RU: Задаем количество итераций обработки(рекомендуется 10).
  // EN: Set count of iterations of processing(recommended is 10).
  space^.iterations := 10;
  space^.elasticIterations := 10;
  // RU: Задаем силу гравитации.
  // EN: Set the gravity.
  space^.gravity    := cpv(0, 256);
  // RU: Задаем коэффициент "затухания" движения объектов.
  // EN: Set the damping for moving of objects.
  space^.damping    := 0.9;

  e := 1;
  u := 0.9;
  // RU: Создадим статичное "тело".
  // EN: Create a static "body".
  staticBody := cpBodyNew(INFINITY, INFINITY);
  // RU: Добавим три отрезка для ограничения мира. Первый параметр - указатель на созданное тело, два последующих - координаты точек отрезка, последний - толщина отрезка.
  // EN: Add three segments for restriction of world. First parameter - pointer of created body, next two - coordinates of segment points, the last one - width of segment.
  ground := cpSegmentShapeNew(staticBody, cpv(5, 0), cpv(5, 590), 1);
  ground^.e := e;
  ground^.u := u;
  cpSpaceAddStaticShape(space, ground);
  ground := cpSegmentShapeNew(staticBody, cpv(795, 0), cpv(795, 590), 1);
  ground^.e := e;
  ground^.u := u;
  cpSpaceAddStaticShape(space, ground);
  ground := cpSegmentShapeNew(staticBody, cpv(0, 590), cpv(800, 590), 1);
  ground^.e := e;
  ground^.u := u;
  cpSpaceAddStaticShape(space, ground);
  // RU: Добавим треугольник.
  // EN: Add the triangle.
  staticBody := cpBodyNew(INFINITY, INFINITY);
  ground := cpSegmentShapeNew(staticBody, cpv(400, 300), cpv(200, 350), 1);
  ground^.e := e;
  ground^.u := u;
  cpSpaceAddStaticShape(space, ground);
  ground := cpSegmentShapeNew(staticBody, cpv(200, 350), cpv(700, 350), 1);
  ground^.e := e;
  ground^.u := u;
  cpSpaceAddStaticShape(space, ground);
  ground := cpSegmentShapeNew(staticBody, cpv(700, 350), cpv(400, 300), 1);
  ground^.e := e;
  ground^.u := u;
  cpSpaceAddStaticShape(space, ground);

  setFontTextScale(20, fntMain);
end;

procedure Draw;
begin
  batch2d_Begin();

  // RU: Рендерим объекты указанного "мира". Второй аргумент функции отвечает за показ точек соприкосновения.
  // EN: Render objects for specified "world". Second argument responsible for rendering of collision points.
  cpDrawSpace(space, TRUE);

  text_Draw(fntMain, 10, 5,  'FPS: ' + u_IntToStr(zgl_Get(RENDER_FPS)));
  text_Draw(fntMain, 10, 25, 'Double tap to change the shape type');
  batch2d_End();
end;

procedure KeyMouseEvent;
begin
  if touch_Tap(0) Then
  begin
    if not balls Then
    begin
      cpAddBox(touch_X(0) - 10, touch_Y(0) - 10, 48, 32, 1, 0.5, 0.5);
      balls := not balls;
    end
    else begin
      cpAddBall(touch_X(0), touch_Y(0), 16, 1, 0.5, 0.9);
      balls := not balls;
    end;
  end;
end;

procedure Update(dt : Double);
begin
  cpSpaceStep(space, 1 / (1000 / dt));
end;

procedure Restore;
begin
  file_OpenArchive(PAnsiChar(zgl_Get(DIRECTORY_APPLICATION)));
  font_RestoreFromFile(fntMain, dirRes + 'font.zfi');
  file_CloseArchive();
end;

procedure Quit;
begin
  // не надеемся, что массивы сами освободятся
  Bodies := nil;
  Shapes := nil;
  // RU: Очистка объектов и "мира".
  // EN: Free objects and "world".
  cpSpaceFreeChildren(space);
  cpSpaceFree(space);
end;

procedure Java_zengl_android_ZenGL_Main(var env; var thiz); cdecl;
begin
  randomize();

  zgl_Reg(SYS_EVENTS, @KeyMouseEvent);
  zgl_Reg(SYS_LOAD, @Init);
  zgl_Reg(SYS_DRAW, @Draw);
  zgl_Reg(SYS_UPDATE, @Update);
  zgl_Reg(SYS_ANDROID_RESTORE, @Restore);
  zgl_Reg(SYS_EXIT, @Quit);

  scr_SetOptions();
end;

exports
  Java_zengl_android_ZenGL_Main,
  {$I android_export.inc}
End.

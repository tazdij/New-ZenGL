library demo08;

{$I zglCustomConfig.cfg}
{$I zgl_config.cfg}

uses
  zgl_application,
  zgl_file,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_touch,
  zgl_mouse,
  zgl_render_2d,
  zgl_fx,
  zgl_textures,
  zgl_textures_png,
  zgl_sprite_2d,
  zgl_sengine_2d,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_types,
  {$IfNDef OLD_METHODS}
  gegl_color,
  {$EndIf}
  zgl_utils
  ;

type
  zglPMikuSprite = ^zglTMikuSprite;
  zglTMikuSprite = record
    // RU: Обязательная часть нового типа спрайта.
    // EN: New type should start with this.
    Sprite : zglTSprite2D;

    // RU: Новые параметры.
    // EN: New params.
    Speed  : zglTPoint2D;
  end;

var
  dirRes    : UTF8String = 'assets/';
  fntMain   : LongWord;
  texLogo   : zglPTexture;
  texMiku   : zglPTexture;
  time      : Integer;
  sengine2d : zglTSEngine2D;
  TimeStart : Byte;
  TimeMiku  : Byte;
  {$IfNDef OLD_METHODS}
  newColor  : LongWord;
  correctColor: LongWord;
  {$EndIf}

// Miku
procedure MikuInit( var Miku : zglTMikuSprite );
begin
  with Miku, Miku.Sprite do
    begin
      X := 800 + random( 800 );
      Y := random( 600 - 128 );

      // RU: Задаем скорость движения.
      // EN: Set the moving speed.
      Speed.X := -random( 10 ) / 5 - 0.5;
      Speed.Y := ( random( 10 ) - 5 ) / 5;
    end;
end;

procedure MikuDraw( var Miku : zglTMikuSprite );
begin
  with Miku.Sprite do
    asprite2d_Draw( Texture, X, Y, W, H, Angle, Round( Frame ), Alpha, FxFlags );
end;

procedure MikuProc( var Miku : zglTMikuSprite );
begin
  with Miku, Miku.Sprite do
    begin
      X := X + Speed.X;
      Y := Y + Speed.Y;
      Frame := Frame + ( abs( speed.X ) + abs( speed.Y ) ) / 25;
      if Frame > 8 Then
        Frame := 1;

      // RU: Если спрайт выходит за пределы по X, сразу же удаляем его.
      // EN: Delete the sprite if it goes beyond X.
      if X < -128 Then sengine2d_DelSprite( ID );

      // RU: Если спрайт выходит за пределы по Y, ставим его в очередь на удаление.
      // EN: Add sprite to queue for delete if it goes beyond Y.
      if Y < -128 Then Destroy := TRUE;
      if Y > 600  Then Destroy := TRUE;
    end;
end;

procedure MikuFree( var Miku : zglTMikuSprite );
begin
end;

// RU: Добавить 100 спрайтов.
// EN: Add 100 sprites.
procedure AddMiku;
  var
    i : Integer;
begin
  // RU: При добавлении спрайта в менеджер спрайтов указывается текстура, слой(положение по Z) и указатели на основные функции - Инициализация, Рендер, Обработка и Уничтожение.
  // EN: For adding sprite to sprite engine must be set next parameters: texture, layer(Z-coordinate) and pointers to Initialization, Render, Process and Destroy functions.
  for i := 1 to 100 do
    sengine2d_AddCustom( texMiku, SizeOf( zglTMikuSprite ), random( 10 ), @MikuInit, @MikuDraw, @MikuProc, @MikuFree );
end;

// RU: Удалить 100 спрайтов.
// EN: Delete 100 sprites.
procedure DelMiku;
  var
    i : Integer;
begin
  // RU: Удалим 100 спрайтов со случайным ID.
  // EN: Delete 100 sprites with random ID.
  for i := 1 to 100 do
    sengine2d_DelSprite( random( sengine2d.Count ) );
end;

procedure Init;
begin
  zgl_Enable( CORRECT_RESOLUTION );
  scr_CorrectResolution( 800, 600 );

  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );

  texLogo := tex_LoadFromFile( dirRes + 'zengl.png' );

  texMiku := tex_LoadFromFile( dirRes + 'miku.png' );
  tex_SetFrameSize( texMiku, 128, 128 );

  // RU: Устанавливаем текущим менеджером спрайтов свой.
  // EN: Set own sprite engine as current.
  sengine2d_Set( @sengine2d );

  // RU: Создадим 1000 спрайтов Miku-chan :)
  // EN: Create 1000 sprites of Miku-chan :)
//  for i := 0 to 9 do
//    AddMiku();

  fntMain := font_LoadFromFile( dirRes + 'font.zfi' );

  file_CloseArchive();
  setFontTextScale(15, fntMain);
  {$IfNDef OLD_METHODS}
  newColor := Color_FindOrAdd($80A080FF - 55);
  correctColor := Color_FindOrAdd($AFAFAFFF);
  {$EndIf}
end;

procedure Draw;
begin
  batch2d_Begin();
  // RU: Рисуем все спрайты находящиеся в текущем спрайтовом менеджере.
  // EN: Render all sprites contained in current sprite engine.
  if time > 255 Then
    sengine2d_Draw();

  if time <= 255 Then
    ssprite2d_Draw( texLogo, 400 - 256, 300 - 128, 512, 256, 0, time )
  else
    if time < 510 Then
      begin
        pr2d_Rect( 0, 0, 800, 600, {$IfDef OLD_METHODS}$AFAFAF, 510 - time,{$Else}correctColor,{$EndIf} PR2D_FILL );
        {$IfDef OLD_METHODS}
        i := Get_Color(correctColor);
        dec(i);
        if i < $AFAFAF00 then
          i := $AFAFAF00;
        Correct_Color(correctColor, i);
        {$EndIf}
        ssprite2d_Draw( texLogo, 400 - 256, 300 - 128, 512, 256, 0, 510 - time );
      end;

  if time > 255 Then
    begin
      pr2d_Rect( 0, 0, 256, 64, {$IfDef OLD_METHODS} $80A080, 200,{$Else}newColor,{$EndIf} PR2D_FILL );
      text_Draw( fntMain, 0, 0, 'FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) );
      text_Draw( fntMain, 0, 20, 'Sprites: ' + u_IntToStr( sengine2d.Count ) );
      text_Draw( fntMain, 0, 40, 'Up/Down - Add/Delete Miku :)' );
    end;

  batch2d_End();
end;

procedure Timer;
begin
  INC( time, 2 );

  // RU: Выполняем обработку всех спрайтов в текущем спрайтовом менеджере.
  // EN: Process all sprites contained in current sprite engine.
  sengine2d_Proc();
end;

procedure KeyMouseEvent;
begin
  // RU: По двойному тапу очистить все спрайты.
  // EN: Delete all sprites if there was double tap.
  if touch_DoubleTap(0) then
    sengine2d_ClearAll()
  else
    begin
      if touch_Tap( 0 ) Then
        begin
          if touch_Y( 0 ) < 300 Then
            AddMiku()
          else
            DelMiku();
        end;
    end;
  mouse_ClearState;
  touch_ClearState();
end;

procedure Restore;
begin
  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );

  tex_RestoreFromFile( texLogo, dirRes + 'zengl.png' );
  tex_RestoreFromFile( texMiku, dirRes + 'miku.png' );

  font_RestoreFromFile( fntMain, dirRes + 'font.zfi' );

  file_CloseArchive();
end;

procedure Quit;
begin
  // RU: Очищаем память от созданных спрайтов.
  // EN: Free allocated memory for sprites.
  sengine2d_Set( @sengine2d );
  sengine2d_ClearAll();
end;

procedure Java_zengl_android_ZenGL_Main( var env; var thiz ); cdecl;
begin
  randomize();

  TimeStart := timer_Add( @Timer, 16, t_Start );
  TimeMiku := timer_Add( @AddMiku, 2000, t_SleepToStart, 8 );

  zgl_Reg(SYS_EVENTS, @KeyMouseEvent);
  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );
  zgl_Reg( SYS_ANDROID_RESTORE, @Restore );
  zgl_Reg( SYS_EXIT, @Quit );

  scr_SetOptions();
end;

exports
  Java_zengl_android_ZenGL_Main,
  {$I android_export.inc}
End.

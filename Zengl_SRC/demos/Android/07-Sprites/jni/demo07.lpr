library demo07;

{$I zglCustomConfig.cfg}
{$I zgl_config.cfg}

uses
  zgl_application,
  zgl_file,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_camera_2d,
  zgl_render_2d,
  zgl_fx,
  zgl_textures,
  zgl_textures_png,
  zgl_textures_jpg,
  zgl_sprite_2d,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_types,
  zgl_log,
  {$IfNDef OLD_METHODS}
  gegl_color,
  {$EndIf}
  zgl_utils
  ;
type
  TTux = record
    Texture : zglPTexture;
    Frame   : Integer;                          // указатель на "подтекстуру"
    Pos     : zglTPoint2D;
end;

var
  dirRes      : UTF8String = 'assets/';
  fntMain     : LongWord;
  texLogo     : zglPTexture;
  texBack     : zglPTexture;
  texGround   : zglPTexture;
  texTuxWalk  : zglPTexture;
  texTuxStand : zglPTexture;
  tux         : array[ 0..20 ] of TTux;
  time        : Integer;
  camMain     : zglTCamera2D;
  {$IfNDef OLD_METHODS}
  newColor    : LongWord;
  correctColor: LongWord;
  {$ENDIF}
  TimeStart: LongWord;

procedure Init;
  var
    i : Integer;
begin
  zgl_Enable( CORRECT_RESOLUTION );
  scr_CorrectResolution( 800, 600 );

  // RU: Т.к. по умолчанию вся структура камеры заполняется нулями, следует инициализировать её стандартными значениями.
  // EN: Camera must be initialized, because camera structure is zero-filled by default.
  cam2d_DefInit( camMain );

  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );

  // RU: Загружаем текстуру.
  //     $FF000000 - указывает на то, что бы использовать альфа-канал из изображения.
  //     TEX_DEFAULT_2D - комплекс флагов, необходимых для 2D-спрайтов. Описание есть в справке.
  // EN: Load the texture.
  //     $FF000000 - means that alpha channel must be used from file, without colorkey.
  //     TEX_DEFAULT_2D - complex of flags that needed for 2D sprites. Description can be found in help.
  texLogo := tex_LoadFromFile( dirRes + 'zengl.png', $FF000000, TEX_DEFAULT_2D );

  texBack := tex_LoadFromFile( dirRes + 'back01.jpg' );

  texGround := tex_LoadFromFile( dirRes + 'ground.png' );
  // RU: Указываем размер кадра в текстуре.
  // EN: Set the size of single frame for texture.
  tex_SetFrameSize( texGround, 32, 32 );

  texTuxWalk := tex_LoadFromFile( dirRes + 'tux_walking.png' );
  tex_SetFrameSize( texTuxWalk, 64, 64 );
  texTuxStand := tex_LoadFromFile( dirRes + 'tux_stand.png' );
  tex_SetFrameSize( texTuxStand, 64, 64 );

  for i := 0 to 9 do
    begin
      tux[ i ].Texture := texTuxWalk;
      tux[ i ].Frame   := random( 19 ) + 2;
      tux[ i ].Pos.X   := i * 96;
      tux[ i ].Pos.Y   := 32;
    end;
  for i := 10 to 19 do
    begin
      tux[ i ].Texture := texTuxWalk;
      tux[ i ].Frame   := random( 19 ) + 2;
      tux[ i ].Pos.X   := ( i - 9 ) * 96;
      tux[ i ].Pos.Y   := 600 - 96;
    end;
  tux[ 20 ].Texture := texTuxStand;
  tux[ 20 ].Frame   := random( 19 ) + 2;
  tux[ 20 ].Pos.X   := 400 - 32;
  tux[ 20 ].Pos.Y   := 300 - 64 - 4;

  // RU: Загружаем шрифт.
  // EN: Load the font.
  fntMain := font_LoadFromFile( dirRes + 'font.zfi' );

  file_CloseArchive();

  setFontTextScale(20, fntMain);
  {$IfNDef OLD_METHODS}
  // Rus: задаём новый цвет. Это чёрный и немного прозрачный.
  // Eng: set a new color. It is black and slightly transparent.
  newColor := Color_FindOrAdd(200);
  // Rus: задаём новый цвет, без проверки на существование. Это чёрный не прозрачный.
  // Eng: we set a new color, without checking for existence. It's black and not transparent.
  correctColor := Color_UAdd(255);
  {$ENDIF}
end;

procedure Draw;
  var
    i : Integer;
    t : Single;
    ScaleF: LongWord;
begin
  ScaleF := 20;      // условно указываем размеры фонта, но можно использовать -> ScaleF := getTextScale(fntMain)
  batch2d_Begin();
  if time > 255 Then
    begin
      // RU: Рисуем задний фон с размерами 800х600 используя текстуру back.
      // EN: Render the background with size 800x600 and using texture "back".
      ssprite2d_Draw( texBack, 0, 0, 800, 600, 0 );

      // RU: Установить текущую камеру.
      // EN: Set the current camera.
      cam2d_Set( @camMain );

      // RU: Рисуем землю.
      // EN: Render the ground.
      for i := -2 to 800 div 32 + 1 do
        asprite2d_Draw( texGround, i * 32, 96 - 12, 32, 32, 0, 2 );
      for i := -2 to 800 div 32 + 1 do
        asprite2d_Draw( texGround, i * 32, 600 - 32 - 12, 32, 32, 0, 2 );

      // RU: Рисуем шагающих пингвинов.
      // EN: Render penguins
      for i := 0 to 9 do
        if i = 2 Then
          begin
            // RU: Рисуем надпись в "рамочке" над пингвином.
            // EN: Render the text in frame over penguins.
            t := text_GetWidth( fntMain, 'I''m so red...' ) * 0.75;
            pr2d_Rect( tux[ i ].Pos.X - 2, tux[ i ].Pos.Y - ScaleF + 4, t, ScaleF, {$IfDef OLD_METHODS}$000000, 200,{$Else}newColor,{$EndIf} PR2D_FILL );
            pr2d_Rect( tux[ i ].Pos.X - 2, tux[ i ].Pos.Y - ScaleF + 3, t + 2, ScaleF + 2, {$IfDef OLD_METHODS}$FFFFFF,{$Else}cl_White{$EndIf} );
            text_DrawEx( fntMain, tux[ i ].Pos.X, tux[ i ].Pos.Y - ScaleF + 5, 1, 0, 'I''m so red...' );
            // RU: Рисуем красного пингвина используя fx2d-функцию и флаг FX_COLOR.
            // EN: Render red penguin using fx2d-function and flag FX_COLOR.
            fx2d_SetColor( $FF0000 );
            asprite2d_Draw( tux[ i ].Texture, tux[ i ].Pos.X, tux[ i ].Pos.Y, 64, 64, 0, tux[ i ].Frame div 2, 255, FX_BLEND or FX_COLOR );
          end else
            if i = 7 Then
              begin
                t := text_GetWidth( fntMain, '???' )+ 4;
                pr2d_Rect( tux[ i ].Pos.X + 32 - t / 2, tux[ i ].Pos.Y - ScaleF + 4, t, ScaleF, {$IfDef OLD_METHODS}$000000, 200,{$Else}newColor,{$EndIf} PR2D_FILL );
                pr2d_Rect( tux[ i ].Pos.X + 32 - t / 2 - 1, tux[ i ].Pos.Y - ScaleF + 3, t + 2, ScaleF + 2, {$IfDef OLD_METHODS}$FFFFFF{$Else}cl_White{$EndIf} );
                text_DrawEx( fntMain, tux[ i ].Pos.X + 32, tux[ i ].Pos.Y - ScaleF + 5, 1, 0, '???', {$IfDef OLD_METHODS}255, $FFFFFF,{$Else}cl_White,{$EndIf} TEXT_HALIGN_CENTER );
                // RU: Рисуем пингвина приведение используя флаг FX_COLOR установив режим в FX_COLOR_SET :)
                // EN: Render penguin ghost using flag FX_COLOR and mode FX_COLOR_SET :)
                fx_SetColorMode( FX_COLOR_SET );
                fx2d_SetColor( $FFFFFF );
                asprite2d_Draw( tux[ i ].Texture, tux[ i ].Pos.X, tux[ i ].Pos.Y, 64, 64, 0, tux[ i ].Frame div 2, 155, FX_BLEND or FX_COLOR );
                // RU: Возвращаем обычный режим.
                // EN: Return default mode.
                fx_SetColorMode( FX_COLOR_MIX );
              end else
                asprite2d_Draw( tux[ i ].Texture, tux[ i ].Pos.X, tux[ i ].Pos.Y, 64, 64, 0, tux[ i ].Frame div 2 );

      // RU: Рисуем пингвинов шагающих в обратную сторону используя флаг отражения текстуры FX2D_FLIPX.
      // EN: Render penguins, that go another way using special flag for flipping texture - FX2D_FLIPX.
      for i := 10 to 19 do
        if i = 13 Then
          begin
            t := text_GetWidth( fntMain, 'I''m so big...' ) * 0.75;
            pr2d_Rect( tux[ i ].Pos.X - 2, tux[ i ].Pos.Y - ScaleF - 10, t, ScaleF, {$IfDef OLD_METHODS}$000000, 200,{$Else}newColor,{$EndIf} PR2D_FILL );
            pr2d_Rect( tux[ i ].Pos.X - 2, tux[ i ].Pos.Y - ScaleF - 11, t + 2, ScaleF + 2, {$IfDef OLD_METHODS}$FFFFFF{$Else}cl_White{$EndIf} );
            text_DrawEx( fntMain, tux[ i ].Pos.X, tux[ i ].Pos.Y - ScaleF - 9, 1, 0, 'I''m so big...' );
            // RU: Рисуем "большего" пингвина. Т.к. FX2D_SCALE увеличивает спрайт относительно центра, то пингвина следует немного "поднять".
            // EN: Render "big" penguin. It must be shifted up, because FX2D_SCALE scale sprite relative to the center.
            fx2d_SetScale( 1.25, 1.25 );
            asprite2d_Draw( tux[ i ].Texture, tux[ i ].Pos.X, tux[ i ].Pos.Y - 8, 64, 64, 0, tux[ i ].Frame div 2, 255, FX_BLEND or FX2D_FLIPX or FX2D_SCALE );
          end else
            if i = 17 Then
              begin
                // RU: Рисуем "высокого" пингвина используя вместо флага FX2D_SCALE флаг FX2D_VCHANGE и функцию fx2d_SetVertexes для смещения координат двух верхних вершин спрайта.
                // EN: Render "tall" penguin using flag FX2D_VCHANGE instead of FX2D_SCALE, and function fx2d_SetVertexes for shifting upper vertexes of sprite.
                fx2d_SetVertexes( 0, -16, {0, -16, 0, 0,} 0, 0 );
                asprite2d_Draw( tux[ i ].Texture, tux[ i ].Pos.X, tux[ i ].Pos.Y, 64, 64, 0, tux[ i ].Frame div 2, 255, FX_BLEND or FX2D_FLIPX or FX2D_VCHANGE );
              end else
                asprite2d_Draw( tux[ i ].Texture, tux[ i ].Pos.X, tux[ i ].Pos.Y, 64, 64, 0, tux[ i ].Frame div 2, 255, FX_BLEND or FX2D_FLIPX );

      // RU: Сбросить камеру.
      // EN: Reset the camera.
      cam2d_Set( nil );

      // RU: Рисуем участок земли по центру экрана.
      // EN: Render piece of ground in the center of screen.
      asprite2d_Draw( texGround, 11 * 32, 300 - 16, 32, 32, 0, 1 );
      asprite2d_Draw( texGround, 12 * 32, 300 - 16, 32, 32, 0, 2 );
      asprite2d_Draw( texGround, 13 * 32, 300 - 16, 32, 32, 0, 3 );

      t := text_GetWidth( fntMain, 'o_O' ) * 0.75;
      pr2d_Rect( tux[ 20 ].Pos.X + 32 - t / 2, tux[ 20 ].Pos.Y - ScaleF + 3, t + 2, ScaleF + 2, {$IfDef OLD_METHODS}$000000, 200,{$Else}newColor,{$EndIf} PR2D_FILL );
      pr2d_Rect( tux[ 20 ].Pos.X + 32 - t / 2, tux[ 20 ].Pos.Y - ScaleF + 2, t + 4, ScaleF + 4, {$IfDef OLD_METHODS}$FFFFFF,{$Else}cl_White{$EndIf} );
      text_DrawEx( fntMain, tux[ 20 ].Pos.X + 32, tux[ 20 ].Pos.Y - ScaleF + 5, 1, 0, 'o_O', {$IfDef OLD_METHODS}255, $FFFFFF,{$Else}cl_White,{$EndIf} TEXT_HALIGN_CENTER );
      asprite2d_Draw( tux[ 20 ].Texture, tux[ 20 ].Pos.X, tux[ 20 ].Pos.Y, 64, 64, 0, tux[ 20 ].Frame div 2 );
    end;

  if time <= 255 Then
    ssprite2d_Draw( texLogo, 400 - 256, 300 - 128, 512, 256, 0, time )
  else
    if time < 510 Then
      begin
        {$IfNDef OLD_METHODS}
        // Rus: получаем значение цвета.
        // Eng: Get the color value.
        i := Get_Color(correctColor);
        {$EndIf}
        pr2d_Rect( 0, 0, 800, 600,{$IfDef OLD_METHODS} $000000, 510 - time,{$Else} correctColor,{$EndIf} PR2D_FILL );
        {$IfNDef OLD_METHODS}
        dec(i);
        if i < 0 then
          i := 0;
        // Rus: корректируем значение цвета.
        // Eng: adjusting the color value.
        Correct_Color(correctColor, i);
        {$EndIf}
        ssprite2d_Draw( texLogo, 400 - 256, 300 - 128, 512, 256, 0, 510 - time );
      end;

  if time > 255 Then
    text_Draw( fntMain, 0, 0, 'FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) );

  batch2d_End();
end;

procedure Timer;
  var
    i : Integer;
begin
  INC( time, 2 );

  camMain.Angle := camMain.Angle + cos( time / 1000 ) / 10;

  for i := 0 to 20 do
    begin
      INC( tux[ i ].Frame );
      if tux[ i ].Frame > 20 Then
        tux[ i ].Frame := 2;
    end;
  for i := 0 to 9 do
    begin
      tux[ i ].Pos.X := tux[ i ].Pos.X + 1.5;
      if tux[ i ].Pos.X > 864 Then
        tux[ i ].Pos.X := -96;
    end;
  for i := 10 to 19 do
    begin
      tux[ i ].Pos.X := tux[ i ].Pos.X - 1.5;
      if tux[ i ].Pos.X < -96 Then
        tux[ i ].Pos.X := 864;
    end;
end;

procedure Restore;
begin
  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );

  tex_RestoreFromFile( texLogo, dirRes + 'zengl.png' );
  tex_RestoreFromFile( texBack, dirRes + 'back01.jpg' );
  tex_RestoreFromFile( texGround, dirRes + 'ground.png' );
  tex_RestoreFromFile( texTuxWalk, dirRes + 'tux_walking.png' );
  tex_RestoreFromFile( texTuxStand, dirRes + 'tux_stand.png' );

  font_RestoreFromFile( fntMain, dirRes + 'font.zfi' );

  file_CloseArchive();
end;

procedure Java_zengl_android_ZenGL_Main( var env; var thiz ); cdecl;
begin
  randomize();

  TimeStart := timer_Add( @Timer, 16, t_Start );

  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );
  zgl_Reg( SYS_ANDROID_RESTORE, @Restore );

  scr_SetOptions();
end;

exports
  Java_zengl_android_ZenGL_Main,
  {$I android_export.inc}
End.


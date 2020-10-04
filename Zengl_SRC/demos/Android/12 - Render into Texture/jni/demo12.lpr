library demo12;

{$I zglCustomConfig.cfg}

uses
  zgl_application,
  zgl_main,
  zgl_file,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_render_2d,
  zgl_fx,
  zgl_textures,
  zgl_textures_png,
  zgl_render_target,
  zgl_sprite_2d,
  zgl_font,
  zgl_text,
  zgl_math_2d,
  zgl_utils
  ;

var
  dirRes    : UTF8String = 'assets/';
  fntMain   : zglPFont;
  texTux    : zglPTexture;
  rtFull    : zglPRenderTarget;
  rtDefault : zglPRenderTarget;

procedure Init;
begin
  zgl_Enable( CORRECT_RESOLUTION );
  scr_CorrectResolution( 800, 600 );

  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );

  texTux := tex_LoadFromFile( dirRes + 'tux_stand.png' );
  tex_SetFrameSize( texTux, 64, 64 );

  fntMain := font_LoadFromFile( dirRes + 'font.zfi' );

  // RU: Создаем RenderTarget и "цепляем" пустую текстуру. В процессе текстуру можно сменить присвоив rtarget.Surface другую zglPTexture, главное что бы совпадали размеры с теми, что указаны в
  //     tex_CreateZero. Таргету также указан флаг RT_FULL_SCREEN, отвечающий за то, что бы в текстуру помещалось все содержимое экрана а не область 256x256(как с флагом RT_DEFAULT).
  // EN: Create a RenderTarget and "bind" empty texture to it. Later texture can be changed via changing rtarget.Surface to another zglPTexture, the only requirement - the same size, that was
  //     set in tex_CreateZero. Also target use flag RT_FULL_SCREEN that responsible for rendering whole content of screen into target, not only region 256x256(like with flag RT_DEFAULT).
  rtFull := rtarget_Add( tex_CreateZero( 256, 256 ), RT_FULL_SCREEN );

  // RU: Для сравнения создадим ещё один RenderTarget с флагом RT_DEFAULT.
  // EN: Create one more RenderTarget with flag RT_DEFAULT for comparison.
  rtDefault := rtarget_Add( tex_CreateZero( 256, 256 ), RT_DEFAULT );

  file_CloseArchive();
  setTextScale(1.5);
end;

procedure Draw;
begin
  // RU: Устанавливаем текущий RenderTarget.
  // EN: Set current RenderTarget.
  rtarget_Set( rtFull );
  // RU: Рисуем в него.
  // EN: Render to it.
  asprite2d_Draw( texTux, random( 800 - 64 ), random( 600 - 64 ), 64, 64, 0, random( 9 ) + 1 );
  // RU: Возвращаемся к обычному рендеру.
  // EN: Return to default rendering.
  rtarget_Set( nil );

  rtarget_Set( rtDefault );
  asprite2d_Draw( texTux, random( 800 - 64 ), random( 600 - 64 ), 64, 64, 0, random( 9 ) + 1 );
  rtarget_Set( nil );

  // RU: Теперь рисуем содержимое RenderTarget'ов.
  // EN: Render content of RenderTargets.
  ssprite2d_Draw( rtFull^.Surface, ( 400 - 256 ) / 2, ( 600 - 256 ) / 2, 256, 256, 0 );
  ssprite2d_Draw( rtDefault^.Surface, ( 400 - 256 ) / 2 + 400, ( 600 - 256 ) / 2, 256, 256, 0 );

  text_Draw( fntMain, 0, 0, 'FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) );
end;

procedure Restore;
begin
  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );

  tex_RestoreFromFile( texTux, dirRes + 'tux_stand.png' );

  font_RestoreFromFile( fntMain, dirRes + 'font.zfi' );

  rtarget_Restore( rtFull );
  rtarget_Restore( rtDefault );

  file_CloseArchive();
end;

procedure Java_zengl_android_ZenGL_Main( var env; var thiz ); cdecl;
begin
  randomize();

  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );
  zgl_Reg( SYS_ANDROID_RESTORE, @Restore );

  scr_SetOptions();
end;

exports
  Java_zengl_android_ZenGL_Main,
  {$I android_export.inc}
End.

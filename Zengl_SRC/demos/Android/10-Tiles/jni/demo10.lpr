library demo11;

{$I zglCustomConfig.cfg}
{$I zgl_config.cfg}

uses
  zgl_application,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_keyboard,
  zgl_fx,
  zgl_file,
  zgl_textures,
  zgl_textures_png,
  zgl_tiles_2d,
  zgl_font,
  zgl_text,
  zgl_types,
  zgl_utils,
  zgl_render_2d
  ;

var
  dirRes   : UTF8String = 'assets/';
  fntMain  : LongWord;
  map      : zglTTiles2D;
  texTiles : zglPTexture;

procedure Init;
  var
    i, j : Integer;
    f    : zglTFile;
begin
  zgl_Enable( CORRECT_RESOLUTION );
  scr_CorrectResolution( 800, 600 );

  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );

  fntMain := font_LoadFromFile( dirRes + 'font.zfi' );

  texTiles := tex_LoadFromFile( dirRes + 'tiles.png' );
  tex_SetFrameSize( texTiles, 32, 32 );

  // RU: Инициализация тайлов размером 32x32. Параметр Count указывает на количество тайлов по X и Y. Массив Tiles содержит кадры для каждого тайла.
  // EN: Initialization of tiles with size 32x32. Parameter Count set amount of tiles on X and Y. Array Tiles contains frames for every tile.
  map.Width  := 32;
  map.Height  := 32;
  map.X := 25;
  map.Y := 19;
  SetLength( map.Tiles, map.X, map.Y );
  // RU: Заполняем карту "травой", 19 кадр.
  // EN: Fill the map by "grass", 19 frame.
  for i := 0 to map.X - 1 do
    for j := 0 to map.Y - 1 do
      map.Tiles[ i, j ] := 19;

  // RU: Загружаем карту из бинарного файла.
  // EN: Load map from binary file.
  file_Open( f, dirRes + 'ground.map', FOM_OPENR );
  for i := 0 to map.X - 1 do
    file_Read( f, map.Tiles[ i, 0 ], map.Y * SizeOf( Integer ) );
  file_Close( f );

  file_CloseArchive();
  setFontTextScale(20, fntMain);
end;

procedure Draw;
begin
  // RU: Рендерим тайлы в координатах 0,0.
  // EN: Render tiles in coordinates 0,0.
  tiles2d_Draw( texTiles, 0, 0, @map );


  text_Draw( fntMain, 0, 0, 'FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) );

  text_Draw( fntMain, 180, 30, 'This is a tarrible example of tile map, but main idea should be clear :)' );
end;

procedure Restore;
begin
  file_OpenArchive( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );

  font_RestoreFromFile( fntMain, dirRes + 'font.zfi' );

  tex_RestoreFromFile( texTiles, dirRes + 'tiles.png' );

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

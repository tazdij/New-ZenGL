﻿program demo15;

{$I zglCustomConfig.cfg}
{$I zgl_config.cfg}

{$IFDEF WINDOWS}
  {$R *.res}
{$ENDIF}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF USE_ZENGL_STATIC}
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_keyboard,
  zgl_mouse,
  zgl_textures,
  zgl_textures_png,
  zgl_font,
  zgl_text,
  zgl_primitives_2d,
  zgl_sprite_2d,
  zgl_video,
  zgl_video_theora,
  zgl_utils,
  zgl_types
  {$IfNDef OLD_METHODS}
  , gegl_color
  {$EndIf}
  {$ELSE}
  zglHeader
  {$ENDIF}
  ;

var
  dirRes    : UTF8String {$IFNDEF MACOSX} = '../data/' {$ENDIF};
  fntMain   : LongWord;
  video     : zglPVideoStream;
  videoSeek : Boolean;
  {$IfNDef OLD_METHODS}
  newColor  : LongWord;
  {$EndIf}

procedure Init;
begin
  fntMain := font_LoadFromFile( dirRes + 'font.zfi' );

  // EN: Open the video file.
  // RU: Открыть видео файл.
  video := video_OpenFile( dirRes + 'video.ogv' );

  setFontTextScale(15, fntMain);
  {$IfNDef OLD_METHODS}
  newColor := Color_FindOrAdd($00FF0090);
  {$EndIf}
end;

procedure Draw;
begin
  if Assigned( video ) Then
    begin
      // EN: Rendering the current video frame in the center of screen using parameters of it from video.Info.
      // RU: Рендеринг текущего кадра видео в центре экрана используя параметры из video.Info.
      ssprite2d_Draw( video.Texture, ( 800 - video.Info.Width ) / 2, ( 600 - video.Info.Height ) / 2, video.Info.Width, video.Info.Height, 0 );

      // EN: Rendering of progress bar.
      // RU: Рендеринг полосы прогресса.
      pr2d_Rect( 0, 600 - 100, 800, 20, {$IfNDef OLD_METHODS}cl_Green{$Else}$00FF00, 255{$EndIf} );
      pr2d_Rect( 0, 600 - 100, ( 800 / video.Info.Duration ) * video.Time, 20, {$IfDef OLD_METHODS}$00FF00, 155,{$Else}newColor,{$EndIf}PR2D_FILL );

      text_Draw( fntMain, 0, 0, 'FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) );
      text_Draw( fntMain, 0, 20, 'Frame: ' + u_IntToStr( video.Frame ) );
      text_Draw( fntMain, 100, 0, 'Duration: ' + u_FloatToStr( video.Info.Duration / 1000 ) );
      text_Draw( fntMain, 100, 20, 'Frames: ' + u_IntToStr( video.Info.Frames ) );
      text_Draw( fntMain, 230, 0, 'Time: ' + u_FloatToStr( video.Time / 1000 ) );
    end;
end;

procedure KeyMouseEvent;
begin
  // EN: If left mouse button is down on progress bar, then seek the video.
  // RU: Если зажата левая кнопка мыши над полосой прогресса - перемещаться по видео.
  if mouseBDown(M_BLEFT) and ( mouse_Y() > 500 ) and ( mouse_Y() < 520 ) Then
    begin
      videoSeek := TRUE;
      video_Seek( video, ( mouse_X() / 800 ) * video.Info.Duration );
    end else
      videoSeek := FALSE;
end;

procedure Update( dt : Double );
begin
  if not videoSeek Then
    video_Update( video, dt, TRUE );
end;

Begin
  {$IFNDEF USE_ZENGL_STATIC}
  if not zglLoad( libZenGL ) Then exit;
  {$ENDIF}

  randomize();

  zgl_Reg(SYS_EVENTS, @KeyMouseEvent);

  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );
  zgl_Reg( SYS_UPDATE, @Update );

  wnd_SetCaption(utf8_Copy('15 - Video'));

  zgl_Init();
End.

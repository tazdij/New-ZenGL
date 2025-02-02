program demo13;

{$I zglCustomConfig.cfg}
{$I zgl_config.cfg}

{$R *.res}

uses
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_keyboard,
  zgl_render_2d,
  zgl_fx,
  zgl_types,
  zgl_textures,
  zgl_textures_png,
  zgl_textures_jpg,
  zgl_sprite_2d,
  zgl_particles_2d,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_math_2d,
  zgl_utils;

var
  dirRes        : UTF8String {$IFNDEF MACOSX} = '../data/' {$ENDIF};
  fntMain       : LongWord;
  texBack       : zglPTexture;
  debug         : Boolean;
  particles     : zglTPEngine2D;
  emitterFire   : array[0..2] of zglPEmitter2D;
  emitterDiamond: zglPEmitter2D;
  emitterRain   : zglPEmitter2D;

procedure Init;
begin
  texBack := tex_LoadFromFile(dirRes + 'back02.png');

  fntMain := font_LoadFromFile(dirRes + 'font.zfi');

  // EN: Load three types of fire emitters.
  // RU: �������� ��� ������ ����� ��������� ����.
  emitterFire[0] := emitter2d_LoadFromFile(dirRes + 'emitter_fire00.zei');
  emitterFire[1] := emitter2d_LoadFromFile(dirRes + 'emitter_fire01.zei');
  emitterFire[2] := emitter2d_LoadFromFile(dirRes + 'emitter_fire02.zei');

  // EN: Set own particels engine.
  // RU: ��������� ������������ ������ ���������.
  pengine2d_Set(@particles);

  // EN: Add 6 fire emitters to particles engine. Second parameter of function returns pointer to instance of new emitter, which can be processed manually.
  //     This instance will be nil after the death, so check everything.
  // RU: ��������� � ������ 6 ��������� ����. ������ �������� ������� ��������� �������� ��������� �� ���������� ��������� ��������, ������� ����� ����� ������������ �������.
  //     ������ ��������� ����� ������ ����� ��������� nil, ������� ����������� ��������.
  pengine2d_AddEmitter(emitterFire[0], nil, 642, 190);
  pengine2d_AddEmitter(emitterFire[0], nil, 40, 368);
  pengine2d_AddEmitter(emitterFire[0], nil, 246, 368);
  pengine2d_AddEmitter(emitterFire[1], nil, 532, 244);
  pengine2d_AddEmitter(emitterFire[1], nil, 318, 422);
  pengine2d_AddEmitter(emitterFire[1], nil, 583, 420);
  pengine2d_AddEmitter(emitterFire[2], nil, 740, 525);

  emitterDiamond := emitter2d_LoadFromFile(dirRes + 'emitter_diamond.zei');
  pengine2d_AddEmitter(emitterDiamond, nil);

  emitterRain := emitter2d_LoadFromFile(dirRes + 'emitter_rain.zei');
  pengine2d_AddEmitter(emitterRain, nil);

  setFontTextScale(15, fntMain);
end;

procedure Draw;
var
  i: Integer;
begin
  ssprite2d_Draw(texBack, 0, 0, 800, 600, 0);

  // EN: Rendering of all emitters in current particles engine.
  // RU: ��������� ���� ��������� � ������� ������ ������.
  pengine2d_Draw();

  if debug Then
    for i := 0 to particles.Count.Emitters - 1 do
      with particles.List[i].BBox do
        pr2d_Rect(MinX, MinY, MaxX - MinX, MaxY - MinY, $FF0000, 255);

  text_Draw(fntMain, 0, 0, 'FPS: ' + u_IntToStr(zgl_Get(RENDER_FPS)));
  text_Draw(fntMain, 0, 20, 'Particles: ' + u_IntToStr(particles.Count.Particles));
  text_Draw(fntMain, 0, 40, 'Debug(F1): ' + u_BoolToStr(debug));
end;

procedure KeyMouseEvent;
begin
  if key_Press(K_F1) Then
    debug := not debug;
end;

procedure Update(dt: Double);
begin
  // EN: Process all emitters in current particles engine.
  // RU: ��������� ���� ��������� � ������� ������ ������.
  pengine2d_Proc(dt);
end;

procedure Quit;
begin
  // RU: ������� ������ �� ��������� ���������.
  // EN: Free allocated memory for emitters.
  pengine2d_Set(@particles);
  pengine2d_ClearAll();
end;

Begin
  randomize();

  zgl_Reg(SYS_EVENTS, @KeyMouseEvent);
  zgl_Reg(SYS_LOAD, @Init);
  zgl_Reg(SYS_DRAW, @Draw);
  zgl_Reg(SYS_UPDATE, @Update);
  zgl_Reg(SYS_EXIT, @Quit);

  wnd_SetCaption(utf8_Copy('13 - Particles'));

  zgl_Init();
End.

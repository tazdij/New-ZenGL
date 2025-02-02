{
 *  Copyright (c) 2012 Andrey Kemka
 *
 *  This software is provided 'as-is', without any express or
 *  implied warranty. In no event will the authors be held
 *  liable for any damages arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute
 *  it freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented;
 *     you must not claim that you wrote the original software.
 *     If you use this software in a product, an acknowledgment
 *     in the product documentation would be appreciated but
 *     is not required.
 *
 *  2. Altered source versions must be plainly marked as such,
 *     and must not be misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any
 *     source distribution.

 !!! modification from Serge
}
unit zgl_fx;

{$I zgl_config.cfg}

interface

uses
  zgl_gltypeconst,
  zgl_types;

// Rus:
// Eng:
procedure fx_SetBlendMode(Mode: Byte; SeparateAlpha: Boolean = TRUE);
// Rus:
// Eng:
procedure fx_SetColorMode(Mode: Byte);
// Rus:
// Eng:
procedure fx_SetColorMask(R, G, B, Alpha: Boolean);

// Rus:
// Eng:
procedure fx2d_SetColor(Color: LongWord);
// Rus:
// Eng:
procedure fx2d_SetVCA(c1, c2, c3, c4: LongWord; a1, a2, a3, a4: Byte);
// Rus: установка смещений. Для флага FX2D_VCHANGE.
//      Работает только для заданных параллелограммов.
// Eng: offset setting. For the FX2D_VCHANGE flag.
//      Only works for given parallelograms.
procedure fx2d_SetVertexes(xLeft, yUp, xRight, yDown: Single);
// Rus: установка шкалы размерности. Для флага FX2D_SCALE.
// Eng: setting the scale. For the FX2D_SCALE flag.
procedure fx2d_SetScale(scaleX, scaleY: Single);
// Rus: установка точки вращения. Для флага FX2D_RPIVOT.
// Eng: setting the pivot point. For the FX2D_RPIVOT flag.
procedure fx2d_SetRotatingPivot(X, Y: Single);

var
  // FX2D_COLORMIX
  fx2dColor   : array[0..3] of Single;
  fx2dAlpha   : PSingle;
  fx2dColorDef: array[0..3] of Single = (1, 1, 1, 1);
  fx2dAlphaDef: PSingle;

  // FX2D_VCA
  fx2dVCA: array[0..3, 0..3] of Single = ((1, 1, 1, 1),
                                          (1, 1, 1, 1),
                                          (1, 1, 1, 1),
                                          (1, 1, 1, 1));

  // FX2D_VCHANGE
  fx2dVX1, fx2dVX2: Single;
  fx2dVY1, fx2dVY2: Single;

  // FX2D_SCALE
  fx2dSX, fx2dSY: Single;

  // FX2D_RPIVOT
  fx2dRPX, fx2dRPY: Single;

implementation
uses
  {$IFNDEF USE_GLES}
  zgl_opengl,
  zgl_opengl_all,
  {$ELSE}
  zgl_opengles,
  zgl_opengles_all,
  {$ENDIF}
  zgl_render_2d;

procedure fx_SetBlendMode(Mode: Byte; SeparateAlpha: Boolean = TRUE);
var
  srcBlend: LongWord;
  dstBlend: LongWord;
begin
  if b2dCurBlendMode <> Mode + LongWord(SeparateAlpha) shl 8 Then
    batch2d_Flush();

  b2dCurBlendMode := Mode + LongWord(SeparateAlpha) shl 8;
  case Mode of
    FX_BLEND_NORMAL:
      begin
        srcBlend := GL_SRC_ALPHA;
        dstBlend := GL_ONE_MINUS_SRC_ALPHA;
      end;
    FX_BLEND_ADD:
      begin
        srcBlend := GL_SRC_ALPHA;
        dstBlend := GL_ONE;
      end;
    FX_BLEND_MULT:
      begin
        srcBlend := GL_ZERO;
        dstBlend := GL_SRC_COLOR;
      end;
    FX_BLEND_BLACK:
      begin
        srcBlend := GL_SRC_COLOR;
        dstBlend := GL_ONE_MINUS_SRC_COLOR;
      end;
    FX_BLEND_WHITE:
      begin
        srcBlend := GL_ONE_MINUS_SRC_COLOR;
        dstBlend := GL_SRC_COLOR;
      end;
    FX_BLEND_MASK:
      begin
        srcBlend := GL_ZERO;
        dstBlend := GL_SRC_COLOR;
      end;
  else
    begin
      srcBlend := GL_SRC_ALPHA;
      dstBlend := GL_ONE_MINUS_SRC_ALPHA;
    end;
  end;
  if SeparateAlpha and oglSeparate Then
    glBlendFuncSeparate(srcBlend, dstBlend, GL_ONE, GL_ONE_MINUS_SRC_ALPHA)
  else
    glBlendFunc(srcBlend, dstBlend);
end;

procedure fx_SetColorMode(Mode: Byte);
begin
  if b2dCurColorMode <> Mode Then
    batch2d_Flush();

  b2dCurColorMode := Mode;
  case Mode of
    FX_COLOR_MIX:
      begin
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
      end;
    FX_COLOR_SET:
      begin
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
        glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB,  GL_REPLACE);
        glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB,  GL_PRIMARY_COLOR);
      end;
  end;
end;

// эта фигня зачем?
procedure fx_SetColorMask(R, G, B, Alpha: Boolean);
  var
    mask: LongWord;
begin
  mask := Byte(R) + Byte(G) shl 1 + Byte(B) shl 2 + Byte(Alpha) shl 3;
  if mask <> b2dCurColorMask Then
    batch2d_Flush();

  b2dCurColorMask := mask;

  glColorMask(Byte(R), Byte(G), Byte(B), Byte(Alpha));
end;

procedure fx2d_SetColor(Color: LongWord);
begin
  fx2dColor[0] := (Color shr 16) / 255;
  fx2dColor[1] := ((Color and $FF00) shr 8) / 255;
  fx2dColor[2] := (Color and $FF) / 255;
end;

procedure fx2d_SetVCA(c1, c2, c3, c4: LongWord; a1, a2, a3, a4: Byte);
begin
  fx2dVCA[0, 0] := (C1 shr 16) / 255;
  fx2dVCA[0, 1] := ((C1 and $FF00) shr 8) / 255;
  fx2dVCA[0, 2] := C1 and $FF;
  fx2dVCA[0, 3] := A1 / 255;

  fx2dVCA[1, 0] := (C2 shr 16) / 255;
  fx2dVCA[1, 1] := ((C2 and $FF00) shr 8) / 255;
  fx2dVCA[1, 2] := (C2 and $FF) / 255;
  fx2dVCA[1, 3] := A2 / 255;

  fx2dVCA[2, 0] := (C3 shr 16) / 255;
  fx2dVCA[2, 1] := ((C3 and $FF00) shr 8) / 255;
  fx2dVCA[2, 2] := (C3 and $FF) / 255;
  fx2dVCA[2, 3] := A3 / 255;

  fx2dVCA[3, 0] := (C4 shr 16) / 255;
  fx2dVCA[3, 1] := ((C4 and $FF00) shr 8) / 255;
  fx2dVCA[3, 2] := C4 and $FF / 255;
  fx2dVCA[3, 3] := A4 / 255;
end;

procedure fx2d_SetVertexes(xLeft, yUp, xRight, yDown: Single);
begin
  fx2dVX1 := xLeft;
  fx2dVY1 := yUp;
  fx2dVX2 := xRight;
  fx2dVY2 := yDown;
end;

procedure fx2d_SetScale(scaleX, scaleY: Single);
begin
  fx2dSX := scaleX;
  fx2dSY := scaleY;
end;

procedure fx2d_SetRotatingPivot(X, Y: Single);
begin
  fx2dRPX := X;
  fx2dRPY := Y;
end;

initialization
  fx2dAlpha    := @fx2dColor[3];
  fx2dAlphaDef := @fx2dColorDef[3];

end.

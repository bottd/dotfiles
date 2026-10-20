# Dither Press window-open / window-close shaders.
#
# Windows print onto the screen through an 8x8 ordered (Bayer) dither, the same
# halftone the wallpaper is quantised with. A one-cell fringe of the accent
# plate leads the reveal, like ink laid down a moment before the image.
#
# GLSL ES 1.00 (niri's GLES2 renderer): no const arrays or bitwise ops, so the
# Bayer matrix is built recursively from the 2x2 base with fract().
{ lib, colors }:
let
  # "E49B5D" -> "0.894118, 0.607843, 0.364706"
  hexToVec3 =
    hex:
    lib.concatMapStringsSep ", " (i: toString (lib.fromHexString (builtins.substring i 2 hex) / 255.0))
      [
        0
        2
        4
      ];

  common = ''
    // Size of one dither cell in logical pixels. 2 keeps the pattern legible
    // on a 1x 1440p panel without turning into visible blocks.
    #define CELL 2.0
    // Width of the accent fringe, in threshold units.
    #define FRINGE 0.07

    float press_bayer2(vec2 a) {
        a = floor(a);
        return fract(a.x / 2.0 + a.y * a.y * 0.75);
    }

    float press_threshold(vec2 coords, vec2 size) {
        vec2 cell = floor(coords * size / CELL);
        // 8x8 Bayer: the 2x2 base plus two coarser levels at 1/4 and 1/16 weight.
        float b = press_bayer2(cell);
        b = press_bayer2(cell * 0.5) * 0.25 + b;
        b = press_bayer2(cell * 0.25) * 0.0625 + b;
        return b;
    }

    const vec3 press_plate = vec3(${hexToVec3 colors.base09});

    bool press_inside(vec3 c) {
        return 0.0 <= c.x && c.x <= 1.0 && 0.0 <= c.y && c.y <= 1.0;
    }
  '';
in
{
  # Reveal top-down: the head of the window prints first.
  open = common + ''
    vec4 open_color(vec3 coords_geo, vec3 size_geo) {
        // The texture includes decorations outside the window geometry.
        vec3 coords_tex = niri_geo_to_tex * coords_geo;
        if (!press_inside(coords_tex))
            return vec4(0.0);
        vec4 color = texture2D(niri_tex, coords_tex.st);

        float t = press_threshold(coords_geo.xy, size_geo.xy);
        float reveal = niri_clamped_progress * (1.0 + 0.3 + FRINGE) - clamp(coords_geo.y, 0.0, 1.0) * 0.3;

        if (t >= reveal)
            return vec4(0.0);
        if (t >= reveal - FRINGE && niri_clamped_progress < 1.0)
            return vec4(press_plate * color.a, color.a);

        return color;
    }
  '';

  # The same print and lift for Quickshell's panels (Qt ShaderEffect, GLSL 440,
  # compiled with qsb). `common` is shared verbatim so shell surfaces and
  # windows dither through the identical Bayer order and plate fringe.
  # progress runs 0 -> 1 in both directions; closing selects the lift.
  qtPrint = ''
    #version 440
    layout(location = 0) in vec2 qt_TexCoord0;
    layout(location = 0) out vec4 fragColor;
    layout(std140, binding = 0) uniform buf {
        mat4 qt_Matrix;
        float qt_Opacity;
        float progress;
        float closing;
        vec2 extent;
    };
    layout(binding = 1) uniform sampler2D source;
  ''
  + common
  + ''
    void main() {
        vec4 color = texture(source, qt_TexCoord0);
        float t = press_threshold(qt_TexCoord0, extent);
        float y = clamp(qt_TexCoord0.y, 0.0, 1.0);
        vec4 fringe = vec4(press_plate * color.a, color.a) * qt_Opacity;

        if (closing < 0.5) {
            float reveal = progress * (1.0 + 0.3 + FRINGE) - y * 0.3;
            if (t >= reveal) {
                fragColor = vec4(0.0);
                return;
            }
            if (t >= reveal - FRINGE && progress < 1.0) {
                fragColor = fringe;
                return;
            }
        } else {
            float erase = progress * (1.0 + 0.3 + FRINGE) - (1.0 - y) * 0.3;
            if (t < erase - FRINGE) {
                fragColor = vec4(0.0);
                return;
            }
            if (t < erase) {
                fragColor = fringe;
                return;
            }
        }
        fragColor = color * qt_Opacity;
    }
  '';

  # Lift bottom-up: the reverse of the print, so open and close read as a pair.
  close = common + ''
    vec4 close_color(vec3 coords_geo, vec3 size_geo) {
        vec3 coords_tex = niri_geo_to_tex * coords_geo;
        if (!press_inside(coords_tex))
            return vec4(0.0);
        vec4 color = texture2D(niri_tex, coords_tex.st);

        float t = press_threshold(coords_geo.xy, size_geo.xy);
        float erase = niri_clamped_progress * (1.0 + 0.3 + FRINGE) - (1.0 - clamp(coords_geo.y, 0.0, 1.0)) * 0.3;

        if (t < erase - FRINGE)
            return vec4(0.0);
        if (t < erase)
            return vec4(press_plate * color.a, color.a);

        return color;
    }
  '';
}

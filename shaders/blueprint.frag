// Background of every page: a soft accent glow that follows the mouse and a
// slow, faint haze in the presentation color that drifts with time and
// shifts with the scroll. Kept subtle so text contrast never changes.
#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;    // canvas size in logical pixels
uniform float uTime;   // seconds (frozen with reduced motion)
uniform vec2 uMouse;   // smoothed pointer position in logical pixels
uniform float uScroll; // vertical scroll offset in logical pixels
uniform vec4 uBase;    // page background color
uniform vec4 uAccent;  // theme accent (lime)
uniform vec4 uCool;    // presentation layer color (sky)

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
    u.y
  );
}

void main() {
  vec2 p = FlutterFragCoord().xy;

  // Glow around the pointer, relative to the larger side of the canvas.
  float d = distance(p, uMouse) / max(uSize.x, uSize.y);
  float glow = exp(-d * d * 14.0) * 0.09;

  // Haze field: moves slowly with time and a bit slower than the content
  // when scrolling, for a light parallax.
  vec2 q = vec2(p.x, p.y + uScroll * 0.35) / 480.0;
  float n = noise(q + vec2(uTime * 0.025, uTime * 0.015)) * 0.6
          + noise(q * 2.3 - vec2(uTime * 0.02)) * 0.4;
  float haze = smoothstep(0.55, 0.95, n) * 0.045;

  vec3 color = uBase.rgb + uAccent.rgb * glow + uCool.rgb * haze;
  fragColor = vec4(color, 1.0);
}

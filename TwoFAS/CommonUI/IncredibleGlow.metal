//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

#include <metal_stdlib>
using namespace metal;

// Hash for smooth noise
static float hash2(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

// Bilinear smooth noise [0, 1]
static float smoothNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash2(i + float2(0, 0)), hash2(i + float2(1, 0)), u.x),
        mix(hash2(i + float2(0, 1)), hash2(i + float2(1, 1)), u.x),
        u.y
    );
}

// Two octaves of FBM
static float fbm(float2 p) {
    return smoothNoise(p) * 0.6 + smoothNoise(p * 2.1 + float2(1.7, 9.2)) * 0.4;
}

// HSL → RGB (all values in [0,1])
static float3 hsl2rgb(float h, float s, float l) {
    float3 rgb = clamp(abs(fmod(h * 6.0 + float3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return l + s * (rgb - 0.5) * (1.0 - abs(2.0 * l - 1.0));
}

// -------------------------------------------------------------------------
// Main glow shader
// position  — pixel coordinate in the view (top-left origin)
// color     — existing pixel color (ignored; we paint from scratch)
// size      — view size in points
// time      — elapsed seconds, for animation
// -------------------------------------------------------------------------
[[ stitchable ]] half4 incredibleGlow(
    float2 position,
    half4  color,
    float2 size,
    float  time
)
{
    float2 uv = position / size;                        // [0,1] x [0,1]
    float2 centered = uv - float2(0.5, 0.5);

    // Elongate horizontally to match the wide text shape
    float2 elliptic = centered * float2(1.0, 3.2);
    float  baseDist = length(elliptic);

    // Organic warp via fbm noise
    float warp = fbm(uv * 2.8 + float2(time * 0.18, time * 0.11));
    float dist  = baseDist + (warp - 0.5) * 0.14;

    // Soft radial falloff — controls glow radius
    float glow = exp(-dist * dist * 7.5);
    glow = pow(glow, 0.65);                             // lift mid-tones
    if (glow < 0.005) return half4(0);                  // early-out for transparent bg

    // Horizontal hue band: hot-pink (0.88) on left → blue-purple (0.62) on right
    float baseHue = mix(0.88, 0.62, uv.x);
    // Slow animation + noise wobble
    float hue = fract(baseHue + time * 0.07 + (warp - 0.5) * 0.08);

    // Saturation peaks at mid-distance, full at core
    float sat = 0.88 + 0.12 * smoothstep(0.0, 0.3, dist);
    // Lightness: bright center, dims toward edge
    float lit = 0.46 + glow * 0.22;

    float3 rgb = hsl2rgb(hue, sat, lit);

    // Boost brightness proportional to glow so the core is near-white
    rgb = mix(rgb, float3(1.0), glow * 0.35);
    rgb *= glow * 1.6;

    // Clamp; preserve additive-blend-friendly premultiplied look
    rgb = clamp(rgb, 0.0, 1.0);

    return half4(half3(rgb), half(min(glow * 1.4, 1.0)));
}

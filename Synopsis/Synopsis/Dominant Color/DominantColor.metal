//
//  DominantColor.metal
//  Synopsis-Framework
//
//  Created by vade on 12/10/19.
//  Copyright © 2019 v002. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant float3 kRec709Luma = float3(0.2126, 0.7152, 0.0722);
constant uint top_two_bits = 0b11000000;

float3 rgbToHSV(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = mix(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = mix(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 rgbtoHSL( float3 col )
{
    float red   = col.r;
    float green = col.g;
    float blue  = col.b;

    // Cant seem to use fmin3 / fmax3 ?
    float minc  = fmin( col.r, fmin(col.g, col.b) );
    float maxc  = fmax( col.r, fmax(col.g, col.b) );
    float delta = maxc - minc;

    float lum = (minc + maxc) * 0.5;
    float sat = 0.0;
    float hue = 0.0;

    if (lum > 0.0 && lum < 1.0) {
        float mul = (lum < 0.5)  ?  (lum)  :  (1.0-lum);
        sat = delta / (mul * 2.0);
    }

    float3 masks = float3(
        (maxc == red   && maxc != green) ? 1.0 : 0.0,
        (maxc == green && maxc != blue)  ? 1.0 : 0.0,
        (maxc == blue  && maxc != red)   ? 1.0 : 0.0
    );

    float3 adds = float3(
              ((green - blue ) / delta),
        2.0 + ((blue  - red  ) / delta),
        4.0 + ((red   - green) / delta)
    );

    float deltaGtz = (delta > 0.0) ? 1.0 : 0.0;

    hue += dot( adds, masks );
    hue *= deltaGtz;
    hue /= 6.0;

    if (hue < 0.0)
        hue += 1.0;

    return float3( hue, sat, lum);
}

kernel void dominantColorPass1(texture2d<float, access::read>  inTexture  [[texture(0)]],
                               device uint *samples [[buffer(1)]],
                               uint2 gid [[thread_position_in_grid]])
{
    float4 inColor = inTexture.read(gid);

    float3 hsl = rgbtoHSL(inColor.rgb);
    float Y = dot(inColor.rgb, kRec709Luma);
    
    uint3 colorInt = uint3(round(inColor.rgb * 255));
    
    uint Yint = round(Y * 255);
    uint Hint = round(hsl.x * 255);
    uint Lint = round(hsl.z * 255);

    uint packed = ((~~(Yint) & top_two_bits) >> 2) + ((Hint & top_two_bits) >> 4) + ((Lint & top_two_bits) >> 6);
    
    packed *= 4;
    samples[packed]     += colorInt.r;
    samples[packed + 1] += colorInt.g;
    samples[packed + 2] += colorInt.b;
    samples[packed + 3] += 1;
}

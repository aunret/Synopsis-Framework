//
//  DominantColor.metal
//  Synopsis-Framework
//
//  Created by vade on 12/10/19.
//  Copyright © 2019 v002. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);
constant int top_two_bits = 0b11000000;

half3 rgbToHSV(half3 c)
{
    half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    half4 p = mix(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
    half4 q = mix(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

kernel void dominantColorPass1(texture2d<half, access::read>  inTexture  [[texture(0)]],
                               device int *samples [[buffer(1)]],
                               uint2 gid [[thread_position_in_grid]])
{
    // Check if the pixel is within the bounds of the output texture

    half4 inColor = inTexture.read(gid);
    half3 hsv = rgbToHSV(inColor.rgb);
    half Y = dot(inColor.rgb, kRec709Luma);
    
    int3 colorInt = int3(round(inColor.rgb * 255));
    
    int Yint = round(Y * 255);
    int Hint = round(hsv.x * 255);
    int Vint = round(hsv.z * 255);

    int Rint = floor(inColor.r * 255);
    int Gint = round(inColor.g * 255);
    int Bint = round(inColor.b * 255);

    
    int packed  = ( Yint & top_two_bits) << 4;
    packed |= (Hint & top_two_bits) << 2;
    packed |= (Vint & top_two_bits) << 0;
    
/*
    # Due to a bug in the original colorgram.js, RGB isn't included.
    # The original author tries using negative bit shifts, while in
    # fact JavaScript has the stupidest possible behavior for those.
    # By uncommenting these lines, "intended" behavior can be
    # restored, but in order to keep result compatibility with the
    # original the "error" exists here too. Add back in if it is
    # ever fixed in colorgram.js.
    */
//    packed |= (Rint & top_two_bits) >> 2;
//    packed |= (Gint & top_two_bits) >> 4;
//    packed |= (Bint & top_two_bits) >> 6;
    
    packed *= 4;
    samples[packed]     += colorInt.r;
    samples[packed + 1] += colorInt.g;
    samples[packed + 2] += colorInt.b;
    samples[packed + 3] += 1;
}

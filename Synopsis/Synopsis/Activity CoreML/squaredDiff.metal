//
//  squaredDiff.metal
//  Synopsis-Framework
//
//  Created by vade on 12/3/18.
//  Copyright © 2018 v002. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h>

extern "C" {
    namespace coreimage {
        float4 squaredDiff(sample_t foreground, sample_t background) {
//            float squaredDiff = distance_squared(foreground.rgb, background.rgb);
//            return float4(squaredDiff, squaredDiff, squaredDiff, 1.0);
            return float4(pow( abs(foreground.rgb - background.rgb), 2.0), 1.0);
        }
    }
}


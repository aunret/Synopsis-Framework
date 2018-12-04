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
            return float4(pow( abs(foreground.rgb - background.rgb), 2.0), 1.0);
        }
    }
}


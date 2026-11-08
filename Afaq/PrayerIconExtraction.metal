#include <metal_stdlib>
using namespace metal;

// Remove only the dark navy backdrop in the approved source. Opaque artwork
// keeps its source RGB values: no new shapes, recoloring, highlights or rays.
[[ stitchable ]] half4 isolateApprovedGlassIcon(float2 position, half4 color) {
    half brightness = max(color.r, color.g);
    half coverage = smoothstep(half(0.075), half(0.20), brightness);
    return half4(color.rgb * coverage, color.a * coverage);
}

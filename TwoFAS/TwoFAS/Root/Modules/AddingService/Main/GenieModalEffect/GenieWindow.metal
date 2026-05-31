#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

static float smoothProgress(float value) {
    float t = clamp(value, 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
}

[[ stitchable ]]
half4 genieWindow(float2 position, SwiftUI::Layer layer, float2 size, float progress) {
    float t = smoothProgress(progress);

    if (size.x <= 1.0 || size.y <= 1.0) {
        return half4(0.0);
    }

    float y = clamp(position.y / size.y, 0.0, 1.0);

    // The top edge stays pinched for longer, which creates the macOS-like
    // "Genie" pull while SwiftUI moves and scales the modal from the source.
    float topInfluence = pow(1.0 - y, 1.65);
    float pinch = (1.0 - t) * topInfluence;
    float widthFactor = max(0.035, 1.0 - pinch * 0.94);

    float center = size.x * 0.5;
    float left = center - size.x * 0.5 * widthFactor;
    float right = center + size.x * 0.5 * widthFactor;

    float edgeSoftness = max(1.0, 8.0 * (1.0 - t));
    float leftAlpha = smoothstep(left, left + edgeSoftness, position.x);
    float rightAlpha = 1.0 - smoothstep(right - edgeSoftness, right, position.x);
    float shapeAlpha = leftAlpha * rightAlpha;

    if (shapeAlpha <= 0.001) {
        return half4(0.0);
    }

    float normalizedX = (position.x - left) / max(0.001, right - left);
    float sampleX = normalizedX * size.x;

    // A small vertical pull makes the upper pixels lag behind the window body.
    float verticalPull = (1.0 - t) * pow(1.0 - y, 2.1) * size.y * 0.12;
    float sampleY = clamp(position.y + verticalPull, 0.0, size.y);

    half4 color = layer.sample(float2(sampleX, sampleY));
    color.a *= half(shapeAlpha);
    return color;
}

precision highp float;

varying vec2 vUv;
uniform sampler2D tMap;
uniform vec2 uMouse;
uniform float uTime;

void main() {
    vec4 original = texture2D(tMap, vUv);

    vec4 finalColor = vec4(0.);

    vec2 echoOffset = uMouse * 0.005;

    const int echoLayers = 100;
    const float attenuation = .975;

    for (int i = 1; i <= echoLayers; i++) {
        float layerFactor = float(i);

        vec2 currentOffset = echoOffset * layerFactor;
        float alpha = pow(attenuation, layerFactor);
        finalColor += texture2D(tMap, vUv + currentOffset) * alpha;
    }

    finalColor /= float(echoLayers);
    finalColor *= 2.5 + original * 0.25;

    gl_FragColor = finalColor;
}

precision highp float;

varying vec2 vUv;
uniform sampler2D tMap;
uniform vec2 uMouse;
uniform float uTime;

float random (vec2 st) {
    return fract(sin(dot(st.xy,
    vec2(12.9898, 78.233)))*
    43758.5453123);
}

mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
    oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
    oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
    0.0, 0.0, 0.0, 1.0);
}

vec2 rotate(vec2 v, float a) {
    float s = sin(a);
    float c = cos(a);
    mat2 m = mat2(c, s, -s, c);
    return m * v;
}

void main() {
    float angle = 3.1415;
    vec2 r1 = rotate(vUv, angle) * 10.0;

    float rotatedUv = random(vUv * uTime) * .45;

    vec4 original = texture2D(tMap, vUv);

    vec4 finalColor = vec4(0.);


    vec2 echoOffset = uMouse * 0.0025;

    const int echoLayers = 15;
    const float attenuation = 7.5;

    for (int i = 1; i <= 15; i++) {
        float layerFactor = float(i);

        vec2 currentOffset = -echoOffset * layerFactor * 10.0;
        float alpha = pow(1.0, layerFactor);
        float rotatedUv2 = random(vUv * uTime) * .45;

        finalColor += texture2D(tMap, vUv + currentOffset) * alpha;
    }

    for (int i = 1; i <= echoLayers; i++) {
        float layerFactor = float(i);

        vec2 currentOffset = vec2(-.3, -0.3) * (layerFactor * 1.0);
        float alpha = pow(attenuation, layerFactor);
        float rotatedUv1 = random(exp(vUv * 5.0) * uTime) * float(echoLayers);

        finalColor += texture2D(tMap, rotatedUv1 * vUv - currentOffset) * alpha;
    }


    finalColor /= float(echoLayers);
    finalColor *= 2.5 + original * 0.25;

    gl_FragColor = finalColor;
}

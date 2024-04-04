precision highp float;
float random (vec2 st) {
    return fract(sin(dot(st.xy,
    vec2(12.9898, 78.233)))*
    43758.5453123);
}


uniform sampler2D uTexture;
varying vec2 vUv;
void main() {

    vec4 color = texture2D(uTexture, vUv);
    float n = random(vUv) * 100.;
    color.a += n;

    gl_FragColor = color;

}

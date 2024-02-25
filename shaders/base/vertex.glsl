attribute vec3 position;
attribute vec2 uv;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

varying vec2 vUv;
uniform float uTime;

void main() {
    vUv = uv;
    vec4 newPosition = modelViewMatrix * vec4(position, 1.0);

    gl_Position = projectionMatrix * newPosition;
}

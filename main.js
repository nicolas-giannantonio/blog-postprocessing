import {Renderer, Camera, Program, Mesh, Box, Transform, Post, Plane, Texture} from 'ogl';
import "./style.css";
import baseVertex from "./shaders/base/vertex.glsl?raw";
import baseFragment from "./shaders/base/fragment.glsl?raw";
import passFragment from "./shaders/postprocessing/fragment.glsl?raw";

const Lerp = (a, b, t) => (1 - t) * a + t * b;

class GL {

    constructor() {
        this.createGL();
        this.createPost();
        this.createMesh();

        this.mouse = {
            x: 0,
            y: 0,
            lerpX: 0,
            lerpY: 0,
        }

        window.addEventListener('mousemove', this.mouseMove.bind(this), false);
        window.addEventListener('resize', this.resize.bind(this), false);
        this.resize();

        this.update = this.update.bind(this);
        requestAnimationFrame(this.update);
    }

    createGL() {
        // RENDERER
        this.renderer = new Renderer({
            dpr: Math.min(window.devicePixelRatio, 2),
            antialias: true
        });
        this.gl = this.renderer.gl;
        document.body.appendChild(this.gl.canvas);
        this.gl.clearColor(0.0, 0.0, 0.0, 1);

        // CAMERA
        this.camera = new Camera(this.gl, {fov: 35});
        this.camera.position.set(0, 1, 5);
        this.camera.lookAt([0, 0, 0]);

        // SCENE
        this.scene = new Transform();
    }

    createMesh() {

        this.video = document.createElement('video');
        this.video.src = "/feu.mp4";
        this.video.autoplay = true;
        this.video.crossOrigin = "anonymous";
        this.video.loop = false;
        this.video.muted = true;
        this.video.setAttribute('playsinline', 'playsinline');

        window.addEventListener('click', () => {
            this.video.play();
        })

        this.videoTexture = new Texture(this.gl, {
            generateMipmaps: false,
            width: this.video.videoWidth,
            height: this.video.videoHeight,
        });

        // CREATE OUR MESH
        const geometry = new Plane(this.gl);
        const program = new Program(this.gl, {
            vertex: baseVertex,
            fragment: baseFragment,
            uniforms: {
                uTime: {value: 0},
                uTexture: {value: this.videoTexture},
            },
            cullFace: false,
        });

        this.mesh = new Mesh(this.gl, {geometry, program});
        this.mesh.setParent(this.scene);
    }

    createPost() {
        this.post = new Post(this.gl);
        this.mainPass = this.post.addPass({
            fragment: passFragment,
            uniforms: {
                uMouse: {value: [0, 0]},
                uTime: {value: 0},
            }
        })
    }

    mouseMove(e) {
        this.mouse.x = (e.clientX / window.innerWidth) * 2 - 1;
        this.mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;
    }

    update() {
        requestAnimationFrame(this.update);
        if (this.video.readyState >= this.video.HAVE_ENOUGH_DATA) {
            if (!this.videoTexture.image) this.videoTexture.image = this.video;
            this.videoTexture.needsUpdate = true;
        }

        this.mainPass.uniforms.uTime.value += 0.01;

        this.mouse.lerpX = Lerp(this.mouse.lerpX, this.mouse.x, 0.025);
        this.mouse.lerpY = Lerp(this.mouse.lerpY, this.mouse.y, 0.025);

        this.mainPass.uniforms.uMouse.value = [this.mouse.lerpX, this.mouse.lerpY]

        this.post.render({
            scene: this.scene,
            camera: this.camera,
        })
    }

    resize() {
        // SET SIZE AND UPDATE ASPECT RATIO
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.camera.perspective({
            aspect: this.gl.canvas.width / this.gl.canvas.height
        });

        this.mesh.scale.x = .9 * 1.15;
        this.mesh.scale.y = 1.6 * 1.15;


        this.post.resize();
    }

}

new GL();

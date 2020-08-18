using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ScreenSpaceMatrix : MonoBehaviour {

    // _____________________________________________
    // Public
    public  Texture       font_texture;
    public  ComputeShader white_noise_generator;


    // _____________________________________________
    // Private 
    private Camera        cam;
    private Material      mat;
    private CommandBuffer cb;
    private RenderTexture white_noise;

	// Use this for initialization
	void Start () {
        cam = Camera.main;
        if (!cam) Debug.LogError("Couldnt find the main camera, not such gameobject tagged as mainCamera");

        // -----------------------------------------
        white_noise = new RenderTexture(512, 512, 0)
        {
            name              = "white_noise",
            enableRandomWrite = true,
            useMipMap         = false,
            filterMode        = FilterMode.Point,
            wrapMode          = TextureWrapMode.Repeat
            
        };
        white_noise.Create();
        white_noise_generator.SetTexture(0, "_white_noise",    white_noise);

        

        // -----------------------------------------

        mat = new Material(Shader.Find("Unlit/ScreenSpaceMatrixEffect"));
        if (!mat) Debug.LogError("Couldnt find the shader ScreenSpaceMatrixEffect");

        mat.SetTexture("_font_texture",   font_texture);
        mat.SetTexture("_white_noise",    white_noise);
        mat.SetInt    ("_screen_width",   cam.pixelWidth);
        mat.SetInt    ("_screen_height",  cam.pixelHeight);

        // -----------------------------------------

        cb = new CommandBuffer()
        {
            name = "ScreenSpaceMatrixPass",
        };

        cb.DispatchCompute(white_noise_generator, 0, 512 / 8, 512 / 8, 1);
        cb.Blit(BuiltinRenderTextureType.None, BuiltinRenderTextureType.CameraTarget, mat);
       // cb.Blit(white_noise, BuiltinRenderTextureType.CameraTarget);
        cam.AddCommandBuffer(CameraEvent.AfterEverything, cb);
    } 
	
	// Update is called once per frame
	void Update () {
      white_noise_generator.SetInt("_session_rand_seed", Mathf.CeilToInt( Time.time *4.0f));

    }
}

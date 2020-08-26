using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class TriplanarManager : MonoBehaviour {
    // _____________________________________________
    // Public
    public  Texture       font_texture;
    public  ComputeShader white_noise_generator;
    public  bool          colored;
    // _____________________________________________
    // Private 
    private Camera        cam;
    private CommandBuffer cb;
    private RenderTexture white_noise;
    private float         transition_timer;
    private int           cap;
    private float         transition_direction = 0.0f;

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
        Shader.SetGlobalTexture("global_font_texture", font_texture);
        Shader.SetGlobalTexture("global_white_noise",  white_noise);
        Shader.SetGlobalInt    ("_session_rand_seed",  Random.Range(0, int.MaxValue));     
        // -----------------------------------------

        cb = new CommandBuffer()
        {
            name = "ScreenSpaceMatrixPass",
        };

        cb.DispatchCompute(white_noise_generator, 0, 512 / 8, 512 / 8, 1);
        cam.AddCommandBuffer(CameraEvent.AfterEverything, cb);
    
     }

    // Update is called once per frame
    void Update () {
        white_noise_generator.SetInt("_session_rand_seed", Mathf.CeilToInt(Time.time * 6.0f));
        Shader.SetGlobalInt         ("global_colored",     colored?1:0);

        if (Input.GetKeyDown(KeyCode.R))
        {
            if      (cap >= 1) transition_direction = -1.0f;
            else if (cap <= 0) transition_direction =  1.0f;

            bool ShouldCount = true;

            if(((transition_direction == -1.0f) && (transition_timer > (float)(cap))))
                 ShouldCount = false;

            if (((transition_direction == 1.0f) && (transition_timer < (float)(cap+1))))
                ShouldCount = false;

            if(ShouldCount)
            cap += (int) Mathf.Sign(transition_direction) * 1;
        }

        transition_timer += Time.deltaTime * transition_direction * 0.4f;
        transition_timer = Mathf.Clamp(transition_timer, cap , cap +1);


        Shader.SetGlobalFloat ("_Global_Transition_value", transition_timer);
        Shader.SetGlobalVector("_Global_Effect_center",    cam.transform.position);

    }
}

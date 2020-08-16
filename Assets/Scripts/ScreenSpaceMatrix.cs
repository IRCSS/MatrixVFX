using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ScreenSpaceMatrix : MonoBehaviour {

    // _____________________________________________
    // Public
    public  Texture font_texture;

    // _____________________________________________
    // Private 
    private Camera        cam;
    private Material      mat;
    private CommandBuffer cb;

	// Use this for initialization
	void Start () {
        cam = Camera.main;
        if (!cam) Debug.LogError("Couldnt find the main camera, not such gameobject tagged as mainCamera");

        mat = new Material(Shader.Find("Unlit/ScreenSpaceMatrixEffect"));
        if (!mat) Debug.LogError("Couldnt find the shader ScreenSpaceMatrixEffect");

        mat.SetTexture("_font_texture", font_texture);

        cb = new CommandBuffer()
        {
            name = "ScreenSpaceMatrixPass",
        };
        cb.Blit(BuiltinRenderTextureType.None, BuiltinRenderTextureType.CameraTarget, mat);

        cam.AddCommandBuffer(CameraEvent.AfterEverything, cb);
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}

    using UnityEngine;  
      
    [RequireComponent(typeof(Camera))]  
    public class WaterConfig : MonoBehaviour  
    {  
        private Camera cam;  
        [ContextMenu("Depth")]  
        void Start()  
        {  
            if (!cam)  
            {  
                cam = GetComponent<Camera>();  
            }  
            if (SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.Depth))  
            {  
                Shader.EnableKeyword("DEPTH_ON");  
                Shader.DisableKeyword("DEPTH_OFF");  
                if (cam)  
                    cam.depthTextureMode |= DepthTextureMode.Depth;  
            }  
            else  
            {  
                Shader.EnableKeyword("DEPTH_OFF");  
                Shader.DisableKeyword("DEPTH_ON");  
            }  
        }  
    }  
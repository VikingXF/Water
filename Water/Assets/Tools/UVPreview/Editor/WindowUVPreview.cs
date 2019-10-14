#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class WindowUVPreview : EditorWindow {

    protected static WindowUVPreview uvPreviewWindow;
    private int windowDefaultSize = 261;
    private float scale = 1;
    private int ySpace = 100;
    private int sideSpace = 5;
    private Rect uvPreviewRect = new Rect(5,75,200,200 );

    private GameObject selectedObject = null;
    private Mesh m = null;
    private int[] tris;
    private Vector2[] uvs;

    private List<Material> Mat;
    private int selectedUV = 0;
    private string[] selectedUVStrings = new string[]{ "UV1", "UV2", "UV3", "UV4" };
    //public enum BackgroundTextureMode
    //{
    //    BaseMap,
    //    VertexColor,
    //    LightMap
       
    //}
    //BackgroundTextureMode BackgroundTexture = BackgroundTextureMode.BaseMap;
    int SubMeshIndex = 0;
    Texture[] Tex = new Texture[] { };
    string[] TexName = new string[] { "empty" };
    int[] IntIndex = new int[] { 0};

    private int Textureindex;
    private Texture2D BaseTexture ;
    private List<Texture2D> Background_Textures;

    private bool canDrawView;
    private bool GetObject =true;

    private Material lineMaterial;
    private Material CheckerBoardMaterial;
    private Color UVColor = Color.green;

    [MenuItem("Tools/UV框显示/UV Preview")]
    protected static void Start()
    {
        uvPreviewWindow = (WindowUVPreview)EditorWindow.GetWindow(typeof(WindowUVPreview));
        uvPreviewWindow.titleContent = new GUIContent("UV预览");
        uvPreviewWindow.autoRepaintOnSceneChange = true;
        uvPreviewWindow.minSize = new Vector2(256, 330);
    }
    

    private void OnGUI()
    {

        selectedObject = Selection.activeGameObject;

        if (selectedObject == null)
        {
            GUI.color = Color.gray;
            EditorGUILayout.HelpBox("Select the object...",MessageType.Warning);
            canDrawView = false;
        }
        else
        {
            if (selectedObject.GetComponent<MeshFilter>() != null | selectedObject.GetComponent<SkinnedMeshRenderer>() !=null)
            {
                GUI.color = Color.green;
                EditorGUILayout.HelpBox("Selected object: " + selectedObject.name, MessageType.None);
                GUI.color = Color.white;
               
                if (selectedObject.GetComponent<SkinnedMeshRenderer>() == null)
                {
                    m = selectedObject.GetComponent<MeshFilter>().sharedMesh;

                    if (selectedObject.GetComponent<MeshRenderer>().sharedMaterial.mainTexture !=null)
                    {
                        List<Texture> TexList = new List<Texture>();
                        List<string> StringList = new List<string>();
                        List<int> IntList = new List<int>();
                        for (int i = 0; i < selectedObject.GetComponent<MeshRenderer>().sharedMaterials.Length; i++)
                        {
                            TexList.Add(selectedObject.GetComponent<MeshRenderer>().sharedMaterials[i].mainTexture);
                            StringList.Add(selectedObject.GetComponent<MeshRenderer>().sharedMaterials[i].mainTexture.name);
                            IntList.Add(i);
                        }
                        Tex = TexList.ToArray();
                        TexName = StringList.ToArray();
                        IntIndex = IntList.ToArray();
                    }
                    else
                    {
                        List<Texture> TexList = new List<Texture>();
                        List<string> StringList = new List<string>();
                        List<int> IntList = new List<int>();
                    
                        TexList.Add((Texture)CreateFillTexture(1, 1, new Color(0, 0, 0, 0.1f)));
                        StringList.Add("empty");
                        IntList.Add(0);
                        Tex = TexList.ToArray();
                        TexName = StringList.ToArray();
                        IntIndex = IntList.ToArray();
                    }



                }
                else
                {
                    m = selectedObject.GetComponent<SkinnedMeshRenderer>().sharedMesh;
                    if (selectedObject.GetComponent<SkinnedMeshRenderer>().sharedMaterial.mainTexture != null)
                    {
                        List<Texture> TexList = new List<Texture>();
                        List<string> StringList = new List<string>();
                        List<int> IntList = new List<int>();
                        for (int i = 0; i < selectedObject.GetComponent<SkinnedMeshRenderer>().sharedMaterials.Length; i++)
                        {
                            TexList.Add(selectedObject.GetComponent<SkinnedMeshRenderer>().sharedMaterials[i].mainTexture);
                            StringList.Add(selectedObject.GetComponent<SkinnedMeshRenderer>().sharedMaterials[i].mainTexture.name);
                            IntList.Add(i);
                        }
                        Tex = TexList.ToArray();
                        TexName = StringList.ToArray();
                        IntIndex = IntList.ToArray();
                    }
                    else
                    {
                        List<Texture> TexList = new List<Texture>();
                        List<string> StringList = new List<string>();
                        List<int> IntList = new List<int>();

                        TexList.Add((Texture)CreateFillTexture(1, 1, new Color(0, 0, 0, 0.1f)));
                        StringList.Add("empty");
                        IntList.Add(0);
                        Tex = TexList.ToArray();
                        TexName = StringList.ToArray();
                        IntIndex = IntList.ToArray();
                    }
                   


                }
                if (m != null)
                {                  
                    GUILayout.BeginHorizontal();
                    selectedUV = GUILayout.Toolbar(selectedUV, selectedUVStrings);
                    canDrawView = true;                  
                    SubMeshIndex = EditorGUILayout.IntPopup(SubMeshIndex, TexName, IntIndex);

                    //Debug.Log("SubMeshIndex"+SubMeshIndex);
                    //BackgroundTexture = (BackgroundTextureMode)EditorGUILayout.EnumPopup(BackgroundTexture, GUILayout.Width(85));
                    GUILayout.EndHorizontal();
                    //GUILayout.Space(10f);
                    GUILayout.BeginHorizontal();
                    if (GUILayout.Button("Save To PNG"))
                    {

                        WindowUVSave uvSave = (WindowUVSave)EditorWindow.GetWindow(typeof(WindowUVSave));
                        uvSave.titleContent = new GUIContent("Save to PNG");
                        uvSave.maxSize = new Vector2(256, 125);
                        uvSave.minSize = new Vector2(256, 124);
                        uvSave.uvsToRender = uvs;
                        uvSave.trianglesToRender = tris;

                    }

                    //画笔设置
                    UVColor = EditorGUILayout.ColorField(UVColor, GUILayout.Width(85));

                    GUILayout.EndHorizontal();

                    switch (selectedUV)
                    {
                        case 0:
                            if (m.uv.Length > 0)
                            {
                                GUILayout.BeginHorizontal();
                                EditorGUILayout.HelpBox("Mesh UV 1 缩略图:", MessageType.None);
                                //if (Mat.Count > 0)
                                //{

                                //    List<string> matsName = null;
                                //    int[] matsInt = new int[Mat.Count];
                                //    foreach (var item in Mat)
                                //    {
                                //        matsName.Add(item.name);
                                //    }
                                //    Textureindex = EditorGUILayout.IntPopup(Textureindex, matsName.ToArray(), matsInt);
                                //}

                                uvs = m.uv;
                                GUILayout.EndHorizontal();
                            }
                            else
                            {
                                EditorGUILayout.HelpBox("Mesh无UV 1", MessageType.None);
                               
                               
                            }                         
                            break;
                        case 1:
                            GUILayout.BeginHorizontal();
                            if (m.uv2.Length > 0)
                            {
                                EditorGUILayout.HelpBox("Mesh UV2 缩略图:", MessageType.None);
                                uvs = m.uv2;
                            }
                            else
                            {
                                EditorGUILayout.HelpBox("Mesh没有UV2. 点击Generate UV2生成", MessageType.None);
                                if (GUILayout.Button("Generate UV2"))
                                {
                                    Unwrapping.GenerateSecondaryUVSet(m);
                                    EditorApplication.Beep();
                                    EditorUtility.DisplayDialog("Done", "Process is done!", "OK");
                                }
                            }
                            GUILayout.EndHorizontal();

                            break;
                        case 2:
                            if (m.uv3.Length > 0)
                            {
                                EditorGUILayout.HelpBox("Mesh UV3 缩略图:", MessageType.None);
                                uvs = m.uv3;
                            }
                            else
                            {
                                EditorGUILayout.HelpBox("Mesh 无 UV3", MessageType.None);
                            }
                            break;
                        case 3:
                            if (m.uv4.Length > 0)
                            {
                                EditorGUILayout.HelpBox("Mesh UV4 缩略图:", MessageType.None);
                                uvs = m.uv4;
                            }
                            else
                            {
                                EditorGUILayout.HelpBox("Mesh 无 UV4", MessageType.None);
                            }
                            break;

                    }

                }

                BaseTexture = (Texture2D)Tex[SubMeshIndex];

            }
            else
            {
                GUI.color = Color.gray;
                EditorGUILayout.HelpBox("Object must have a Mesh Filter or Skinned Mesh Renderer", MessageType.Warning);
                canDrawView = false;
            }
            
        }

        //BaseTexture = CreateFillTexture(256, 256, new Color(1, 1, 1, 1f));
        //uvPreviewRect = new Rect(new Rect(sideSpace, ySpace + sideSpace, uvPreviewWindow.position.width - (sideSpace * 2), uvPreviewWindow.position.height - ySpace - (sideSpace * 2)));
        
        //GUI.DrawTexture(new Rect(0, 0, uvPreviewWindow.position.width, ySpace), BaseTexture);

        if (canDrawView)
        {
            tris = m.GetTriangles(SubMeshIndex);
            //tris = m.triangles;
    
            uvPreviewRect = new Rect(sideSpace, ySpace, (int)(uvPreviewWindow.position.width - 10), (int)(uvPreviewWindow.position.width - 10));
            GUI.DrawTexture(uvPreviewRect, BaseTexture);
            //GUI.DrawTexture(uvPreviewRect, BaseTexture);
            windowDefaultSize = (int)(uvPreviewWindow.position.width - 10);
           
            //UV
            for (int i = 0; i < tris.Length; i += 3)
            {
                int line1x1 = (int)(uvs[tris[i]].x * (scale * windowDefaultSize) + sideSpace );
                int line1y1 = (int)(-uvs[tris[i]].y * (scale * windowDefaultSize) + ySpace) + windowDefaultSize;
                int line1x2 = (int)(uvs[tris[i + 1]].x * (scale * windowDefaultSize) + sideSpace);
                int line1y2 = (int)(-uvs[tris[i + 1]].y * (scale * windowDefaultSize)  + ySpace + windowDefaultSize);

                int line2x1 = (int)(uvs[tris[i + 1]].x * (scale * windowDefaultSize) + sideSpace );
                int line2y1 = (int)(-uvs[tris[i + 1]].y * (scale * windowDefaultSize) + ySpace  ) + windowDefaultSize;
                int line2x2 = (int)(uvs[tris[i + 2]].x * (scale * windowDefaultSize) + sideSpace );
                int line2y2 = (int)(-uvs[tris[i + 2]].y * (scale * windowDefaultSize)  + ySpace ) + windowDefaultSize;

                int line3x1 = (int)(uvs[tris[i + 2]].x * (scale * windowDefaultSize) + sideSpace );
                int line3y1 = (int)(-uvs[tris[i + 2]].y * (scale * windowDefaultSize) + ySpace) + windowDefaultSize;
                int line3x2 = (int)(uvs[tris[i]].x * (scale * windowDefaultSize) + sideSpace);
                int line3y2 = (int)(-uvs[tris[i]].y * (scale * windowDefaultSize) + ySpace ) + windowDefaultSize;

                Rect cropRect = new Rect(uvPreviewRect.x, uvPreviewRect.y, uvPreviewRect.width + sideSpace, uvPreviewRect.height + ySpace + sideSpace);

                DrawLine(line1x1, line1y1, line1x2, line1y2, new Color(0, 1, 0, 1), true, cropRect);
                DrawLine(line2x1, line2y1, line2x2, line2y2, new Color(0, 1, 0, 1), true, cropRect);
                DrawLine(line3x1, line3y1, line3x2, line3y2, new Color(0, 1, 0, 1), true, cropRect);

            }

        }


    }


    private void DrawLine(int x1, int y1, int x2, int y2, Color lineColor, bool isCrop = false, Rect crop = default(Rect))
    {

        if (!lineMaterial)
        {
            lineMaterial = new Material(Shader.Find("Unlit/Color"));           
            lineMaterial.hideFlags = HideFlags.HideAndDontSave;
            lineMaterial.shader.hideFlags = HideFlags.HideAndDontSave;
        }
        lineMaterial.SetColor("_Color", UVColor);
        lineMaterial.SetPass(0);

        if (isCrop)
        {

            if (x1 < crop.x) x1 = (int)crop.x;
            if (x1 > crop.width) x1 = (int)crop.width;
            if (y1 < crop.y) y1 = (int)crop.y;
            if (y1 > crop.height) y1 = (int)crop.height;

            if (x2 < crop.x) x2 = (int)crop.x;
            if (x2 > crop.width) x2 = (int)crop.width;
            if (y2 < crop.y) y2 = (int)crop.y;
            if (y2 > crop.height) y2 = (int)crop.height;

        }

        GL.Begin(GL.LINES);
        GL.Color(lineColor);
        GL.Vertex3(x1, y1, 0);
        GL.Vertex3(x2, y2, 0);
        GL.End();

    }

    //根据shader处理贴图
    private Texture2D ChangeTex(Texture2D TargetTexture)
    {
        if (!CheckerBoardMaterial)
        {
            CheckerBoardMaterial = new Material(Shader.Find("Hidden/Internal/GUI/CheckerBoard"));
            CheckerBoardMaterial.hideFlags = HideFlags.HideAndDontSave;
            CheckerBoardMaterial.shader.hideFlags = HideFlags.HideAndDontSave;
        }
        CheckerBoardMaterial.SetFloat("_Size", 30);

        Graphics.Blit(TargetTexture, CheckerBoardMaterial, 0);
        return TargetTexture;
    }

    //创建贴图
    private Texture2D CreateFillTexture(int width, int height, Color fillColor)
    {

        Texture2D texture = new Texture2D(width, height);
        Color[] pixels = new Color[width * height];

        for (int i = 0; i < pixels.Length; i++)
        {
            pixels[i] = fillColor;
        }

        texture.SetPixels(pixels);
        texture.Apply();

        return texture;
    }

    //void Update () {
      
    //}
}
#endif
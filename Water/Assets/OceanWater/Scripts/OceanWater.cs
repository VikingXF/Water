using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(MeshRenderer), typeof(MeshFilter))]
public class OceanWater : MonoBehaviour
{
    [SerializeField] protected int meshResolutionX = 20;
    [SerializeField] protected int meshResolutionY = 20;
    [SerializeField] protected float meshBoundsSize = 10.0f;
    protected MeshRenderer meshRenderer;
    protected MeshFilter meshFilter;

    public void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        meshFilter = GetComponent<MeshFilter>();

        if (meshFilter.sharedMesh == null)
        {
            CreateQuadMesh();
        }
    }

    //生成海面模型
    protected void CreateQuadMesh()
    {
        int rx = meshResolutionX;
        int ry = meshResolutionY;

        Vector3[] vertices = new Vector3[rx * ry];
        int[] indices = new int[(rx - 1) * (ry - 1) * 2 * 3];

        for (int x = 0; x < rx; x++)
        {
            for (int y = 0; y < ry; y++)
            {
                vertices[x * ry + y] = new Vector3((float)x / (rx - 1), (float)y / (ry - 1), 0.0f);
            }
        }

        int index = 0;

        for (int x = 0; x < rx - 1; x++)
        {
            for (int y = 0; y < ry - 1; y++)
            {
                indices[index++] = (x + 0) * ry + (y + 0);
                indices[index++] = (x + 0) * ry + (y + 1);
                indices[index++] = (x + 1) * ry + (y + 1);

                indices[index++] = (x + 0) * ry + (y + 0);
                indices[index++] = (x + 1) * ry + (y + 1);
                indices[index++] = (x + 1) * ry + (y + 0);
            }
        }

        Mesh mesh = new Mesh();

        mesh.name = "Ocean Mesh";
        mesh.vertices = vertices;
        mesh.triangles = indices;
        mesh.bounds = new Bounds(Vector3.zero, Vector3.one * meshBoundsSize);

        meshFilter.sharedMesh = mesh;
    }

}

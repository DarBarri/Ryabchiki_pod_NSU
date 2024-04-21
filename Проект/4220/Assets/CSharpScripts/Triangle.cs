using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Triangle : MonoBehaviour
{
    public Mesh mesh;

    public Vector3[] vertices;

    public int[] triangle;

    void Start()
    {
        mesh = GetComponent<MeshFilter>().mesh;
        mesh.vertices = vertices;
        mesh.triangles = triangle;
        Color a = GetComponent<MeshRenderer>().material.color;
        a.a = 0.1f;
        GetComponent<MeshRenderer>().material.color = a;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}

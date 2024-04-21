using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public class Curve : MonoBehaviour
{
    public AnimationCurve curve;
    private LineRenderer lineRenderer;
    // Start is called before the first frame update
    void Start()
    {
        lineRenderer = GetComponent<LineRenderer>();
        lineRenderer.widthCurve = curve;

        lineRenderer.positionCount = 100;

        Vector3[] vertex = new Vector3[100];

        for (int i = 0; i < 100; i++)
        {
            vertex[i].x = (float)i * 10 / 99;
            vertex[i].y = math.sin((float)i * 10 / 99);
        }
        
        lineRenderer.SetPositions(vertex);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}

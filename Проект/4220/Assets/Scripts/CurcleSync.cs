using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CurcleSync : MonoBehaviour
{
    public static int PosID = Shader.PropertyToID("_player_position");
    public static int sizeID = Shader.PropertyToID("_Size");

    public Material Wall;
    public Camera Camera;
    public LayerMask Mask;
    void Update()
    {
        Vector3 dir = Camera.transform.position - transform.position;
        Ray ray = new Ray(transform.position, dir.normalized);

        if (Physics.Raycast(ray, 2000, Mask))
        {
            Wall.SetFloat(sizeID,1);
        }else Wall.SetFloat(sizeID, 0);

        Vector3 view = Camera.WorldToViewportPoint(transform.position);
        Wall.SetVector(PosID, view);
    }
}

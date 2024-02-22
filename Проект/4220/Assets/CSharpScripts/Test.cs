using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    // Update is called once per frame
    void Update()
    {
        Ray ray = new Ray(Vector3.zero, Vector3.up);

        Physics.Raycast(ray.origin, ray.direction);
        
        Debug.DrawRay(ray.origin, ray.direction * 10f, Color.red);
    }
}
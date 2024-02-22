using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FocusOn : MonoBehaviour
{
    public Camera cam;

    public LayerMask layer;
    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Debug.Log(1);
            Ray ray = cam.ScreenPointToRay(Input.mousePosition);

            RaycastHit hit;
            
            if (Physics.Raycast(ray, out hit, 100, layer))
            { 
                Debug.Log(hit.point);
                // hit.collider.transform.gameObject.GetComponent<MeshRenderer>().material.color = Color.red;
            }
        }
    }
}

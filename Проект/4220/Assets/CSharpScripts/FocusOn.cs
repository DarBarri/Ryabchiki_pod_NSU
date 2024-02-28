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
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = cam.ScreenPointToRay(Input.mousePosition);

            RaycastHit hit;

            Physics.Raycast(ray, out hit);
            
            if (Physics.Raycast(ray, out hit, 100, layer))
            { 
                hit.collider.gameObject.GetComponent<HealthController>().Damage(Vector3.down, WeaponType.Axe);
                // hit.collider.transform.gameObject.GetComponent<MeshRenderer>().material.color = Color.red;
            }
        }
    }
}

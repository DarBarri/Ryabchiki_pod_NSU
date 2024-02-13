using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

public class RenderOff : MonoBehaviour
{
    public Transform cam;

    public Transform player;

    public LayerMask layer;

    private List<GameObject> _list = new List<GameObject>();
    // Update is called once per frame
    void Update()
    {
        Ray ray = new Ray(cam.position, player.position - cam.position + Vector3.up);

        RaycastHit[] hits = Physics.RaycastAll(ray, Vector3.Distance(cam.position, player.position));
        List<GameObject> list = new List<GameObject>();
        
        foreach (var hit in hits)
        {
            list.Add(hit.transform.gameObject);
            
            if (!_list.Contains(hit.transform.gameObject))
            {
                if (hit.transform.gameObject.layer == LayerMask.NameToLayer("Walls"))
                {
                    hit.transform.gameObject.GetComponent<MeshRenderer>().enabled = false;
                }
                else if (hit.transform.gameObject.layer == LayerMask.NameToLayer("Items"))
                {
                    Color color = hit.transform.gameObject.GetComponent<MeshRenderer>().material.color;
                    color.a = 0f;
                    hit.transform.gameObject.GetComponent<MeshRenderer>().material.color = color;
                }
                _list.Add(hit.transform.gameObject);
            }
        }
        
        foreach (var hit in _list)
        {
            if (!list.Contains(hit.gameObject))
            {
                hit.transform.gameObject.GetComponent<MeshRenderer>().enabled = true;
                _list.Remove(hit.gameObject);
            }
        }
    }
}

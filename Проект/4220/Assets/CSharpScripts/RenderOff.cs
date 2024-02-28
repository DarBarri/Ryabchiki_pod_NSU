using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

public class RenderOff : MonoBehaviour
{
    public float dist;
    public Transform cam;

    public Transform player;

    public LayerMask layer;

    private Dictionary<GameObject, float> dict = new Dictionary<GameObject, float>();
    private float radius = 1.2f;
    private Ray ray;
    private readonly Vector3 vector = new Vector3(0f, 1.2f, 0f);
    
    private List<GameObject> _list = new List<GameObject>();
    // Update is called once per frame
    void Update()
    {
        Vector3 pv = player.position + vector;
        pv.y = 0f;
        Vector3 cv = cam.position;
        cv.y = 0f;
        float b = Vector3.Distance(pv, cv);
        ray = new Ray(player.position + vector, cam.position - player.position - vector);

        RaycastHit[] hits = Physics.SphereCastAll(ray, radius, Vector3.Distance(player.position + vector, cam.position), layer);
        
        List<GameObject> list = new List<GameObject>();
        
        for (int i = 0; i < hits.Length; i++)
        {
            GameObject temp = hits[i].collider.transform.gameObject;
            Vector3 ov = temp.transform.position;
            ov.y = 0f;
            
            list.Add(temp);
            
            MeshRenderer[] a = temp.GetComponentsInChildren<MeshRenderer>();
            
            if (!_list.Contains(temp) && Vector3.Dot(ov - cv, pv - cv) / b < b)
            {
                _list.Add(temp);
                dict.Add(temp, 1f);
            }
            
            if (_list.Contains(temp) && dict[temp] > 0.25f)
            {
                dict[temp] -= 5f * Time.deltaTime;

                if (a.Length == 0)
                {
                    Color color = temp.GetComponent<MeshRenderer>().material.color;
                    color.a = dict[temp];
                    temp.GetComponent<MeshRenderer>().material.color = color;
                }
                else
                {
                    for (int j = 0; j < a.Length; j++)
                    {
                        Color color = a[j].material.color;
                        color.a = dict[temp];
                        a[j].material.color = color;
                    }
                }
            }
        }
        
        for (int i = 0; i < _list.Count; i++)
        {
            Vector3 ov = _list[i].transform.position;
            ov.y = 0f;
            
            MeshRenderer[] a = _list[i].GetComponentsInChildren<MeshRenderer>();
            if (!list.Contains(_list[i]) || Vector3.Dot(ov - cv, pv - cv) / b > b)
            {
                dict[_list[i]] = 1f;
                
                if (a.Length == 0)
                {
                    Color color = _list[i].GetComponent<MeshRenderer>().material.color;
                    color.a = dict[_list[i]];
                    _list[i].GetComponent<MeshRenderer>().material.color = color;
                }
                else
                {
                    for (int j = 0; j < a.Length; j++)
                    {
                        Color color = a[j].material.color;
                        color.a = dict[_list[i]];
                        a[j].material.color = color;
                    }
                }
                
                dict.Remove(_list[i]);
                _list.Remove(_list[i]);
            }
        }
    }
}
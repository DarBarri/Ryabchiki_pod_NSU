using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;

public class WallsOff : MonoBehaviour
{
    public GameObject player;
    public GameObject cam;
    private List<GameObject> objList = new List<GameObject>();
    private GameObject _room = null;
    public LayerMask layer;

    private void OnTriggerEnter(Collider other)
    {
        _room = other.gameObject;
        
        if (!_room.IsUnityNull())
        {
            GameObject obj = _room.transform.Find("Walls").gameObject;

            if (!obj.IsUnityNull())
            {
                int countChild = obj.transform.childCount;
                
                for (int j = 0; j < countChild; j++)
                {
                    objList.Add(obj.transform.GetChild(j).gameObject);
                }
            }
        }
    }

    private void OnTriggerStay(Collider other)
    {
        for (int i = 0; i < objList.Count; i++)
        {
            MeshRenderer _wallMesh = objList[i].GetComponent<MeshRenderer>();
            if (_wallMesh.isVisible)
            {
                Vector3 a = player.transform.position;
                a.y = 0f;
                Vector3 b = objList[i].transform.position;
                b.y = 0f;
                Ray ray = new Ray(objList[i].transform.position, player.transform.position + Vector3.up * 1.3f - objList[i].transform.position);
                Debug.DrawRay(ray.origin, ray.direction, Color.red);
                RaycastHit hit;

                bool c = Physics.Raycast(ray.origin, ray.direction, out hit, layer);
                
                if (c && hit.collider.transform.gameObject.layer == LayerMask.NameToLayer("Player"))
                { 
                    Vector3 _normal = objList[i].transform.TransformDirection(Vector3.right);
                    _normal.y = 0f;
                    
                    if (Vector3.Dot(_normal, a - b) <= -0.1f)
                    {
                        _normal = -_normal;
                    }
                    
                    Debug.DrawRay(objList[i].transform.position, _normal, Color.blue);
                    
                    Vector3 camDirection = cam.transform.TransformDirection(Vector3.right);
                    camDirection.y = 0f;
                    
                    if (Vector3.Dot(_normal, camDirection) <= 0.1f)
                    {
                        objList[i].GetComponent<WallRenderOff>().Render(false);
                    }
                    else
                    {
                        objList[i].GetComponent<WallRenderOff>().Render(true);
                    }
                }
                else
                {
                    objList[i].GetComponent<WallRenderOff>().Render(false);
                }
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        for (int i = 0; i < objList.Count; i++)
        {
            objList[i].GetComponent<MeshRenderer>().shadowCastingMode = ShadowCastingMode.On;
        }
        
        objList.Clear();
    }
}

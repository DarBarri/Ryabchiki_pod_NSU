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
    
    private List<WallRenderOff> _scriptList = new List<WallRenderOff>();
    
    private GameObject _room = null;

    private void OnTriggerEnter(Collider other)
    {
        _room = other.gameObject;
        
        if (!_room.IsUnityNull())
        {
            Transform[] list = _room.GetComponentsInChildren<Transform>();
            
            for (int i = 0; i < list.Length; i++)
            {
                if (list[i].CompareTag("Wall"))
                {
                    _scriptList.Add(list[i].gameObject.GetComponent<WallRenderOff>());
                }
            }
        }
    }

    private void OnTriggerStay(Collider other)
    {
        Vector3 camDirection = cam.transform.TransformDirection(Vector3.right);
        camDirection.y = 0f;
        
        for (int i = 0; i < _scriptList.Count; i++)
        {
            _scriptList[i].RenderOff(player.transform.position, camDirection);
        }
    }
    
    private void OnTriggerExit(Collider other)
    {
        for (int i = 0; i < _scriptList.Count; i++)
        {
            _scriptList[i].RenderOn();
        }
    }
}

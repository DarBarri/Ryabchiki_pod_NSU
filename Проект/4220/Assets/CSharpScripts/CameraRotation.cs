using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Serialization;

public class CameraRotation : MonoBehaviour
{
    public Camera cam;
    
    public Transform player;
    
    private readonly Vector3 _distance = new Vector3(-15f, 8f, 0f);
    
    private float _nextAngle = 0f;
    
    private float _currentAngle = 0f;
    
    private const float Speed = 3f;
    
    private const float Angle = 45f;

    private readonly Vector3 _rotation = new Vector3(0f, Speed, 0f);
    // Update is called once per frame
    void LateUpdate()
    {
        if (Input.GetKeyUp(KeyCode.E))
        {
            _nextAngle += Angle;
        }
        else if (Input.GetKeyUp(KeyCode.Q))
        {
            _nextAngle -= Angle;
        }
        
        if (_currentAngle < _nextAngle)
        {
            transform.Rotate(_rotation);
            _currentAngle += Speed;
            
        }
        else if (_currentAngle > _nextAngle)
        {
            transform.Rotate(-_rotation);
            _currentAngle += -Speed;
        }
        
        cam.transform.LookAt(player.transform.position + Vector3.up * 2.3f);
    }
}

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Controller : MonoBehaviour
{
    public GameObject cam;

    public GameObject player;

    public float speed = 7f;

    private float _angle;

    private Vector3 _moveDirection = Vector3.zero;

    private Vector3 _moveRotation = Vector3.zero;

    private CharacterController _player = null;

    void Awake()
    {
        _player = GetComponent<CharacterController>();
    }
    private void Update()
    {
        if (Input.GetKey(KeyCode.LeftShift))
        {
            speed = 12f;
        }
        else speed = 7f;
        
        
        if (Input.GetAxis("Horizontal") == 0 && Input.GetAxis("Vertical") == 0)
        {
            _moveDirection = new Vector3(0f, 0f, 0f);
        }
        else
        {
            _moveDirection = new Vector3(Input.GetAxis("Vertical"), 0f, -Input.GetAxis("Horizontal")) * speed /
                             (Mathf.Sqrt(Mathf.Abs(Input.GetAxis("Vertical")) +
                                         Mathf.Abs(Input.GetAxis("Horizontal"))));
        }
        _moveDirection = cam.transform.TransformDirection(_moveDirection);
        _moveRotation = _moveDirection;

        _player.Move(_moveDirection * Time.deltaTime);

        if (_moveRotation != Vector3.zero)
        {
            Quaternion toRotation = Quaternion.LookRotation(_moveRotation, Vector3.up);
            player.transform.rotation = toRotation;
        }
        
        Vector3 smoothPosition = Vector3.Lerp(cam.transform.position, transform.position, 2.5f * Time.deltaTime);
        cam.transform.position = smoothPosition;
    }
}

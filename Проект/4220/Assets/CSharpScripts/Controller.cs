using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Controller : MonoBehaviour
{
    public GameObject cam;
    
    public GameObject player;
    
    public Camera mainCam;
    
    public LayerMask layer;
    
    public float speed = 7f;
    
    private float _angle;

    private CharacterController _player = null;

    private Vector3 _moveDirection = Vector3.zero;

    private Vector3 _point;

    public Animator animator;
    public float gravityValue = -9.81f;
    public bool isCrouching = false;
    public float crouchHeight = 0.5f;
    public float normalHeight = 2.0f;
    private SoundType _soundType;

    private bool isRun = false, isSit = false;

    void Awake()
    {
        _player = GetComponent<CharacterController>();
    }
    private void Update()
    {
        isRun = Input.GetKey(KeyCode.LeftShift);
        
        if (Input.GetKeyDown(KeyCode.LeftControl))
        {
            isSit = !isSit;
        }

        speed = isSit ? 4f : (isRun ? 12f : 7f);
        //Если персонаж не двигается (в плане нажатия WASD), то и вектор направления нулевой. Если нажаты, то направление движения можно представить
        //как один из 8 положений радиуса на окружности со сдвигом на 45 градусов. При этом по итогу, независимо от направления, длина вектора должна 
        //быть равна единице. Положения относительно поворота камеры, потому после надо преобразовать из локали в глобаль
        if (Input.GetAxis("Horizontal") == 0 && Input.GetAxis("Vertical") == 0)
        {
            _moveDirection = new Vector3(0f, 0f, 0f);
            speed = 0f;
        }
        else
        {
            _moveDirection = new Vector3(Input.GetAxis("Vertical"), 0f, -Input.GetAxis("Horizontal")) /
                             (Mathf.Sqrt(Mathf.Abs(Input.GetAxis("Vertical")) +
                                         Mathf.Abs(Input.GetAxis("Horizontal"))));
        }
        
        animator.SetFloat("speed", _moveDirection.magnitude * (Input.GetAxis("Shift") == 1 ? 2 : 1));

        if (Input.GetKeyDown(KeyCode.LeftControl))
        {
            isCrouching = !isCrouching;
            _player.height = isCrouching ? crouchHeight : normalHeight;
        }

        switch (speed)
        {
            case 12:
            {
                _soundType = SoundType.Running;
                break;
            }
            case 7:
            {
                _soundType = SoundType.Walking;
                break;
            }
            case 4:
            {
                _soundType = SoundType.SitDown;
                break;
            }
            case 0:
            {
                _soundType = SoundType.Stand;
                break;
            }
        }
        
        GetComponent<AudioNotice>().SetSoundType(_soundType);
        _moveDirection = cam.transform.TransformDirection(_moveDirection);

        RotatePlayer();
        _player.Move(_moveDirection * speed * Time.deltaTime);

        _moveDirection.y += gravityValue * Time.deltaTime;
        _player.Move(_moveDirection * Time.deltaTime);

        Vector3 smoothPosition = Vector3.Lerp(cam.transform.position, transform.position, 2.5f * Time.deltaTime);
        cam.transform.position = smoothPosition;
    }

    private void RotatePlayer()
    {
        if (Input.GetMouseButton(1))
        {
            speed = 4f;
            Ray ray = mainCam.ScreenPointToRay(Input.mousePosition);

            RaycastHit hit;
            
            if (Physics.Raycast(ray, out hit, layer))
            {
                _point = hit.point;
                _point.y = player.transform.position.y;
                
                Quaternion toRotation = Quaternion.LookRotation(_point - player.transform.position, Vector3.up);
                player.transform.rotation = toRotation;
            }
        }
        else if (_moveDirection != Vector3.zero)
        {
            Quaternion toRotation = Quaternion.LookRotation(_moveDirection, Vector3.up);
            player.transform.rotation = toRotation;
        }
    }
}

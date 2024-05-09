using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;

public class Controller : MonoBehaviour
{
    public bool isCrouching = false;
    
    public float speed = 7f;
    
    public float gravityValue = -9.81f;
    
    public float crouchHeight = 0.5f;
    
    public float normalHeight = 2.0f;
    
    public LayerMask layer;
    
    public Text text;
    
    public GameObject cam;
    
    public GameObject obj;
    
    public GameObject player;
    
    public GameObject trajectory;
    
    public Transform pointWeapon;
    
    public Camera mainCamera;
    
    public Animator animator;
    
    private int currentAmountAmmo = 100;

    private bool isRun = false, isSit = false;
    
    private float _angle;

    private Vector3 _moveDirection = Vector3.zero;

    private Vector3 _point;

    private WeaponType currentWeaponType;
    
    private SoundType _soundType;
    
    private CharacterController _player = null;
    
    private GameObject stone;
    
    private Rigidbody stoneRigidbody;

    private Transform rangeWeapon, meleeWeapon, scriptWeapon, projectileWeapon, implantWeapon;

    private RangeWeapon rangeWeaponController;

    void Awake()
    {
        currentWeaponType = WeaponType.Projectile;
        rangeWeaponController = pointWeapon.GetComponent<RangeWeapon>();
        rangeWeaponController.countAmmoThisType = currentAmountAmmo;
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

        // if (Input.GetKeyDown(KeyCode.LeftControl))
        // {
        //     isCrouching = !isCrouching;
        //     _player.height = isCrouching ? crouchHeight : normalHeight;
        // }

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

        switch (currentWeaponType)
        {
            case WeaponType.Range:
            {
                if (Input.GetMouseButton(0) && rangeWeaponController.rechardeState == false)
                {
                    Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
                    ray.origin -= 1.9f * Vector3.up;

                    Physics.Raycast(ray, out RaycastHit hit, 100, layer);

<<<<<<< HEAD
                    rangeWeaponController.Shoot(player.transform, pointWeapon.position, hit.point, rangePriority);
                    
                    DrawArc(hit.point, (5f * Mathf.PI / 180));
=======
                    rangeWeaponController.Shoot(player.transform, pointWeapon.position, hit.point);
>>>>>>> parent of d3b240b (Upgrade of shooting)
                }
                else
                {
                    rangeWeaponController.CollingDown();
                }

                if (Input.GetMouseButton(1))
                {
                    Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
                    ray.origin -= 1.9f * Vector3.up;
                    
                    Physics.Raycast(ray, out RaycastHit hit, 100, layer);
                    
                    DrawArc(hit.point, (5f * Mathf.PI / 180));
                }

                break;
            }
            case WeaponType.Projectile:
            {
                if (Input.GetMouseButtonDown(1))
                {
                    stone = Instantiate(obj, transform.position + Vector3.up * 2, transform.rotation);
                    stone.transform.parent = transform;
                    
                    stone.GetComponent<Throwing>().IsKinematic(true);
                }
                else if (Input.GetMouseButtonUp(1))
                {
                    stone.transform.parent = null;
                    stone.GetComponent<Throwing>().IsKinematic(false);
                
                    Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
                
                    Physics.Raycast(ray, out RaycastHit hit, 100, layer);
                
                    Vector3 target = hit.point + hit.normal * 0.1f;
                    
                    stone.GetComponent<Throwing>().Throw(target);
                }
                else if (Input.GetMouseButton(1))
                {
                    stone.GetComponent<Throwing>().IsKinematic(true);
                
                    Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
                
                    Physics.Raycast(ray, out RaycastHit hit, 100, layer);
                
                    Vector3 target = hit.point + hit.normal * 0.1f;
                    
                    stone.GetComponent<Throwing>().ShowTrajectory(target);
                }

                break;
            }
        }

        if (pointWeapon.GetComponent<RangeWeapon>().rechardeState == false)
        {
            currentAmountAmmo = pointWeapon.GetComponent<RangeWeapon>().countAmmoThisType;
            if (Input.GetKeyDown(KeyCode.R))
            {
                pointWeapon.GetComponent<RangeWeapon>().Recharge(currentAmountAmmo);
            }   
        }

        text.text = $"Ammo {pointWeapon.GetComponent<RangeWeapon>().weaponData.currentAmountAmmo}/{currentAmountAmmo}";
    }

    private void ChangeWeapon(WeaponType weaponType)
    {
        // очистка данных бывшего оружия или ещё чего хз
        // switch (currentWeaponType)
        // {
        //
        // }

        currentWeaponType = weaponType;

        switch (weaponType)
        {
            case WeaponType.Melee:
            {
                break;
            }
            case WeaponType.Range:
            {
                break;
            }
            case WeaponType.Script:
            {
                break;
            }
            case WeaponType.Projectile:
            {
                break;
            }
            case WeaponType.Implant:
            {
                break;
            }
        }
    }

    private void RotatePlayer()
    {
        if (Input.GetMouseButton(1))
        {
            speed = 4f;
            Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
            
            if (Physics.Raycast(ray, out RaycastHit hit, 100, layer))
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

    private void DrawArc(Vector3 aimPoint, float angleDeviation)
    {
        Vector3 playerPosition = transform.position;
        playerPosition.y += 1.9f;
        Vector3 directionView = aimPoint - playerPosition;
        directionView.y = 0f;

        Vector3[] vertex = new Vector3[9];
            
        for (int i = -4; i <= 4; i++)
        {
            float sin = Mathf.Sin(angleDeviation * i / 4);
            float cos = Mathf.Cos(angleDeviation * i / 4);
            vertex[i + 4] = playerPosition + new Vector3(directionView.x * cos - directionView.z * sin, 0f, directionView.x * sin + directionView.z * cos);
            
            if (i > -4)
            {
                Debug.DrawLine(vertex[i + 3], vertex[i + 4], Color.blue);
            }
        }

        Vector3 lowerPoint = playerPosition + directionView;
        
        Debug.DrawLine(lowerPoint, lowerPoint - Vector3.up * 1.9f, Color.green);
    }
}

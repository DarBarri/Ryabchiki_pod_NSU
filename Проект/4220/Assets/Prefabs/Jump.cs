using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class Jump : MonoBehaviour
{
    private Rigidbody cubeRigidbody;
    private PlayerInputActions playerInputActions;

    private void Awake()
    {
        cubeRigidbody = GetComponent<Rigidbody>();
        playerInputActions = new PlayerInputActions();
        playerInputActions.Player.Enable();
    }

    private void FixedUpdate()
    {
        Vector2 direction = playerInputActions.Player.Movement.ReadValue<Vector2>();
    }

    public void LetsJump(InputAction.CallbackContext context)
    {
        Debug.Log(context);
        
        cubeRigidbody.AddForce(Vector3.up * 5f, ForceMode.Impulse);
    }
}

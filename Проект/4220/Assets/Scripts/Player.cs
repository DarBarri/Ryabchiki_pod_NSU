using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    public Animator animator;
   CharacterController controller;
   Vector3 playerVelocity;
   public Transform playerCamera;
   bool groundedPlayer;
   bool runPlayer;
   public float playerSpeed = 2.0f;
   public float playerRunSpeed = 4.0f;
   public float jumpHeight = 1.0f;
   public float gravityValue = -9.81f;
   public bool isCrouching = false;
   public float crouchHeight = 0.5f;
   public float normalHeight = 2.0f;

    private void Start()
    {
        controller = GetComponent<CharacterController>();
    }

    private void Update()
    {
        groundedPlayer = controller.isGrounded;
        if (groundedPlayer && playerVelocity.y < 0)
        {
            playerVelocity.y = 0f;
        }

        if (Input.GetKeyDown(KeyCode.LeftShift) && groundedPlayer)
        {
            runPlayer = true;
        }
        if (Input.GetKeyUp(KeyCode.LeftShift))
        {
            runPlayer = false;
        }
        if (Input.GetButtonDown("Jump") && groundedPlayer)
        {
            playerVelocity.y += Mathf.Sqrt(jumpHeight * -3.0f * gravityValue);
        }

        if (Input.GetKeyDown(KeyCode.LeftControl))
        {
            isCrouching = !isCrouching;
            controller.height = isCrouching ? crouchHeight : normalHeight;
        }

        //Vector3 move = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
        Vector3 move = new Vector3(Input.GetAxis("Horizontal"), 0f, Input.GetAxis("Vertical")) * (runPlayer ? playerRunSpeed : playerSpeed) /
                             (Mathf.Sqrt(Mathf.Abs(Input.GetAxis("Vertical")) +
                                         Mathf.Abs(Input.GetAxis("Horizontal"))));
        move = playerCamera.transform.TransformDirection(move);
        controller.Move(move * Time.deltaTime);

        playerVelocity.y += gravityValue * Time.deltaTime;
        controller.Move(playerVelocity * Time.deltaTime);

    }
}

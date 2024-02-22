using UnityEngine;

public class CollisionChecker : MonoBehaviour
{
    public Transform player;
    public Transform playerCamera;
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Static") && other.GetComponent<MeshRenderer>())
        {
            float camDistToPl = Vector3.Distance(playerCamera.position, player.position);
            float camDistToCol = Vector3.Distance(playerCamera.position, other.transform.position);
            //if (camDistToCol < camDistToPl)
            //other.GetComponent<MeshRenderer>().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.ShadowsOnly;
            other.GetComponent<MeshRenderer>().material.renderQueue = 3002;
        }
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.CompareTag("Static") && collision.transform.GetComponent<MeshRenderer>())
        {
            float camDistToPl = Vector3.Distance(playerCamera.position, player.position);
            float camDistToCol = Vector3.Distance(playerCamera.position, collision.transform.position);
            //if (camDistToCol < camDistToPl)
            //collision.transform.GetComponent<MeshRenderer>().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.ShadowsOnly;
            collision.transform.GetComponent<MeshRenderer>().material.renderQueue = 3002;
        }
    }

    private void OnCollisionExit(Collision collision)
    {
        if (collision.transform.CompareTag("Static") && collision.transform.GetComponent<MeshRenderer>())
        {
            //collision.transform.GetComponent<MeshRenderer>().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
            collision.transform.GetComponent<MeshRenderer>().material.renderQueue = 2000;
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Static") && other.GetComponent<MeshRenderer>())
        {
            //other.GetComponent<MeshRenderer>().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
            other.GetComponent<MeshRenderer>().material.renderQueue = 2000;
        }
    }
}


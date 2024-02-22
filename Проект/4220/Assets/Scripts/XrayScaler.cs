using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class XrayScaler : MonoBehaviour
{
    public GameObject playerPrefab;
    public GameObject cube;

    private void Start()
    {
        float distance = Vector3.Distance(transform.position, playerPrefab.transform.position);
        Vector3 scales = new Vector3(Screen.height / distance, Screen.width / distance, distance);
        cube.transform.localScale = scales;
    }
}

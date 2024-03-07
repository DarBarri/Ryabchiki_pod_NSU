using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FallingBox : MonoBehaviour
{
    private void Awake()
    {
        GetComponent<AudioNotice>()._type = SoundType.Stand;
    }

    private void OnCollisionEnter(Collision other)
    {
        GetComponent<AudioNotice>()._type = SoundType.Running;

        StartCoroutine(ChangeType());
    }

    IEnumerator ChangeType()
    {
        yield return new WaitForSeconds(0.25f);

        GetComponent<AudioNotice>()._type = SoundType.Stand;
    }
}

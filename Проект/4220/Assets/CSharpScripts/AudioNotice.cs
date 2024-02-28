using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioNotice : MonoBehaviour
{
    private SphereCollider trigger;

    private void Awake()
    {
        trigger = GetComponent<SphereCollider>();
        trigger.enabled = false;
    }
    
    public void CastSound(float sound)
    {
        if (!trigger.enabled)
        {
            trigger.radius = sound;
            trigger.enabled = true;

            StartCoroutine(SoundOff());
        }
    }

    IEnumerator SoundOff()
    {
        yield return new WaitForFixedUpdate();
        trigger.radius = 0f;
        trigger.enabled = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log(other.name);
    }
}

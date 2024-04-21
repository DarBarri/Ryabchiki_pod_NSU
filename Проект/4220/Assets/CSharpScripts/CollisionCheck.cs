using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollisionCheck : MonoBehaviour
{
    private SoundType _type;

    private void Awake()
    {
        _type = SoundType.Scream;
    }

    private void OnCollisionEnter(Collision other)
    {
        Debug.Log(2);
        GetComponent<AudioNotice>().SetSoundType(_type);

        StartCoroutine(DestroyAfter());
    }

    IEnumerator DestroyAfter()
    {
        yield return new WaitForSeconds(1f);
        Destroy(this.gameObject);
    }
}

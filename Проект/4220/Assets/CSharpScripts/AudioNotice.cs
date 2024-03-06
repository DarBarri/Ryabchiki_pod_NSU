using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioNotice : MonoBehaviour
{
    private GameObject _soundManager;
    public SoundType _type;
    private void Start()
    {
        _soundManager = GameObject.Find("SoundManager");
        _soundManager.GetComponent<SoundManager>().AddSoundGameObject(gameObject);
    }

    public SoundSource CastSound()
    {
        return new SoundSource(gameObject.GetHashCode(), _type, transform.position);
    }

    public void SetSoundType(SoundType type)
    {
        _type = type;
    }
}

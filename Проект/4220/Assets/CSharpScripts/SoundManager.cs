using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    private List<GameObject> _soundGameObjects;
    private List<SoundSource> _soundSources;
    private void Awake()
    {
        _soundGameObjects = new List<GameObject>();
        _soundSources = new List<SoundSource>();
    }

    public void AddSoundGameObject(GameObject soundGameObject)
    {
        _soundGameObjects.Add(soundGameObject);
    }

    public void RemoveSoundSources(GameObject soundGameObject)
    {
        _soundGameObjects.Remove(soundGameObject);
    }
    void Update()
    {
        _soundSources.Clear();
        
        foreach (GameObject soundGameObject in _soundGameObjects)
        {
            _soundSources.Add(soundGameObject.GetComponent<AudioNotice>().CastSound());
        }
    }

    public SoundSource[] GetSoundSources()
    {
        return _soundSources.ToArray();
    }

    public SoundSource[] GetActiveSoundSource()
    {
        List<SoundSource> activeSoundSources = new List<SoundSource>();

        foreach (SoundSource variableSoundSource in _soundSources)
        {
            if (GlobalDictionary.Sound[variableSoundSource.Type].Radius != 0)
            {
                activeSoundSources.Add(variableSoundSource);
            }
        }

        return activeSoundSources.ToArray();
    }
}

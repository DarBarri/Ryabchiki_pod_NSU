using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyManager : MonoBehaviour
{
    public static EnemyManager Singleton { get; private set; }
    private GameObject[] _enemies;
    private SoundManager soundManager;
    void Awake()
    {
        _enemies = GameObject.FindGameObjectsWithTag("Enemy");
        soundManager = GameObject.Find("SoundManager").GetComponent<SoundManager>();
    }
    
    void Update()
    {
        SoundSource[] soundSources = soundManager.GetActiveSoundSource();

        foreach (GameObject variableEnemy in _enemies)
        {
            variableEnemy.GetComponent<EnemyStateController>().Action(soundSources);
        }
    }
}

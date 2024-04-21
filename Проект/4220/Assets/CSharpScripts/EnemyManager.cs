using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class EnemyManager : MonoBehaviour
{
    private EnemyHorde _enemyHorde;
    private GameObject[] _enemies;
    private SoundManager soundManager;
    void Awake()
    {
        _enemies = GameObject.FindGameObjectsWithTag("Enemy");
        soundManager = GameObject.Find("SoundManager").GetComponent<SoundManager>();
        _enemyHorde = new EnemyHorde(false, false, Vector3.zero, Vector3.zero, Vector3.zero);
    }
    
    void Update()
    {
        _enemyHorde.IsHearingPlayer = false;
        _enemyHorde.IsSeenPlayer = false;
        
        SoundSource[] soundSources = soundManager.GetActiveSoundSource();
        bool needCheck = true;

        foreach (GameObject variableEnemy in _enemies)
        {
            var enemy = variableEnemy.GetComponent<EnemyStateController>();
            enemy.HearingAndVision(soundSources);
            
            // Debug.Log($"{enemy._isSeenPlayer}, {enemy._isHearingPlayer}");
            _enemyHorde.IsSeenPlayer |= enemy._isSeenPlayer;
            _enemyHorde.IsHearingPlayer |= enemy._isHearingPlayer;

            if (needCheck && enemy._isSeenPlayer)
            {
                _enemyHorde.VisionPoint = enemy.visionPoint;

                needCheck = false;
            }
            else if (needCheck && enemy._isHearingPlayer && !enemy._isSeenPlayer)
            {
                _enemyHorde.HearingPoint = enemy.hearingPoint;

                needCheck = false;
            }
        }

        _enemyHorde.TargetPoint = _enemyHorde.IsSeenPlayer ? _enemyHorde.VisionPoint :
            (_enemyHorde.IsHearingPlayer ? _enemyHorde.HearingPoint : _enemyHorde.TargetPoint);

        foreach (GameObject variableEnemy in _enemies)
        {
            var enemy = variableEnemy.GetComponent<EnemyStateController>();
            enemy.Action(_enemyHorde);
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyStateController : MonoBehaviour
{
    public NavMeshAgent agent;
    
    public Transform player;

    private EnemyState _currentState;

    public Vector3 visionPoint, hearingPoint;
    
    //Patrolling
    private bool walkPointSet;
    
    //Attacking 
    private bool alreadyAttacked;
    
    //States
    public float attackRange;
    public bool playerInAttackRange;
    
    public Vector3 targetPoint = Vector3.zero;
    private int _targetIndex;
    
    private GameObject head;
    public bool _isSeenPlayer = false;
    public bool _isHearingPlayer = false;
    public bool _isHearingSomething = false;
    
    public State patrollingState;
    public State checkingState;
    public State chasingState;
    public State attackState;
    public State hideAndSeekState;
    public int targetHashCode;
    public List<int> ignoringHashCode;
    public State currentState;
    public int currentHashCode;

    private void Awake()
    {
        SetState(patrollingState);
        targetPoint = transform.position;
        agent = GetComponent<NavMeshAgent>();
        head = GameObject.Find("Head");
        ignoringHashCode = new List<int>();
    }

    public void Action(SoundSource[] soundSources)
    {
        List<int> newIgnoringHashCode = new List<int>();
        
        foreach (int hashCode in ignoringHashCode)
        {
            foreach (SoundSource variableSoundSource in soundSources)
            {
                if (hashCode == variableSoundSource.HashCode)
                {
                    newIgnoringHashCode.Add(hashCode);
                    break;
                }
            }
        }

        ignoringHashCode = newIgnoringHashCode;
        _isSeenPlayer = head.GetComponent<EnemyVision>().Vision();

        visionPoint = player.position;
        
        _targetIndex = head.GetComponent<EnemyHearing>().Hear(soundSources);

        if (_targetIndex != -1)
        {
            _isHearingPlayer = GlobalDictionary.Sound[soundSources[_targetIndex].Type].ID == 0;
            _isHearingSomething = GlobalDictionary.Sound[soundSources[_targetIndex].Type].ID != -1;
            currentHashCode = soundSources[_targetIndex].HashCode;

            if (_isSeenPlayer)
            {
                _isHearingSomething = false;
            }
            else if (!_isSeenPlayer && !_isHearingPlayer && ignoringHashCode.Contains(currentHashCode))
            {
                _isHearingPlayer = false;
                _isHearingSomething = false;
            }
            
            if (_isHearingSomething || _isHearingPlayer)
            {
                targetHashCode = currentHashCode;
                hearingPoint = soundSources[_targetIndex].Point;
            }
        }
        else
        {
            _isHearingPlayer = false;
            _isHearingSomething = false;
        }

        playerInAttackRange = Vector3.Distance(transform.position, player.transform.position) < attackRange;
        
        Debug.Log(currentState.name);
        if (!currentState.IsFinished)
        {
            currentState.Action();
        }
        else
        {
            SetState(patrollingState);
        }
    }

    public void SetState(State state)
    {
        currentState = Instantiate(state);
        currentState.enemy = this;
        currentState.Enter();
    }
}

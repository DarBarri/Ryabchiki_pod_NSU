using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyStateController : MonoBehaviour
{
    public NavMeshAgent agent;

    public float speed;
    
    public LayerMask layer;
    
    public Transform player;

    public LayerMask whatIsGround, whatIsPlayer;

    private EnemyState _currentState;

    public Vector3 visionPoint, hearingPoint;

    private bool flag = true;
    //Patrolling
    public Vector3 walkPoint;
    private bool walkPointSet;
    public float walkPointRange;
    
    //Attacking 
    public float timeBetweenAttacks;
    private bool alreadyAttacked;
    
    //States
    public float sightRange, attackRange;
    public bool playerInSightRange, playerInAttackRange;
    
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

    public State currentState;

    private void Awake()
    {
        SetState(patrollingState);
        targetPoint = transform.position;
        agent = GetComponent<NavMeshAgent>();
        head = GameObject.Find("Head");
    }

    public void Action(SoundSource[] soundSources)
    {
        _isSeenPlayer = head.GetComponent<EnemyVision>().Vision();

        visionPoint = player.position;
        
        _targetIndex = head.GetComponent<EnemyHearing>().Hear(soundSources);

        if (_targetIndex != -1)
        {
            _isHearingPlayer = (_targetIndex == 0);
            _isHearingSomething = (_targetIndex != -1);

            if (_isHearingSomething)
            {
                hearingPoint = soundSources[_targetIndex].Point;
            }
        }
        else
        {
            _isHearingPlayer = false;
            _isHearingSomething = false;
        }

        playerInAttackRange = Vector3.Distance(transform.position, player.transform.position) < attackRange;
        
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

using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using Unity.VisualScripting.Antlr3.Runtime.Tree;
using UnityEngine;
using UnityEngine.AI;
using Debug = UnityEngine.Debug;

enum EnemyState
{
    Patrolling, 
    Checking,
    Chasing, 
    Attack,
    HideAndSeek
}
public class EnemyController : MonoBehaviour
{
    public float speed;
    
    public LayerMask layer;
    
    public NavMeshAgent agent;
    
    public Transform player;

    public LayerMask whatIsGround, whatIsPlayer;

    private EnemyState _currentState;

    private GameObject head;
    private bool _isSeenPlayer = false;
    private bool _isHearingPlayer = false;
    private bool _isHearingSomething = false;

    private Vector3 visionPoint, hearingPoint;

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

    private void Awake()
    {
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
        
        switch (_currentState)
        {
            case EnemyState.Patrolling:
            {
                if (_isSeenPlayer && !playerInAttackRange)
                {
                    _currentState = EnemyState.Chasing;
                    targetPoint = visionPoint;
                    
                    ChaseEntity();
                }
                else if (_isHearingSomething && !_isSeenPlayer)
                {
                    _currentState = EnemyState.Checking;
                    targetPoint = hearingPoint;
                    
                    CheckPoint();
                }
                else
                {
                    Patrolling();
                }
                break;
            }
            case EnemyState.Checking:
            { 
                if (_isSeenPlayer && !playerInAttackRange)
                {
                    _currentState = EnemyState.Chasing;
                    targetPoint = visionPoint;
                    
                    ChaseEntity();
                }
                else
                {
                    _currentState = EnemyState.Checking;
                    targetPoint = _isHearingSomething ? hearingPoint : targetPoint;
                    
                    CheckPoint();
                }
                break;
            }
            case EnemyState.Chasing:
            {
                if ((_isSeenPlayer || _isHearingPlayer) && !playerInAttackRange)
                {
                    _currentState = EnemyState.Attack;
                    
                    AttackEntity();
                }
                else if (_isSeenPlayer)
                {
                    targetPoint = visionPoint;
                    _currentState = EnemyState.Chasing;
                    
                    ChaseEntity();
                }
                else if (_isHearingPlayer && !_isSeenPlayer)
                {
                    targetPoint = hearingPoint;
                    _currentState = EnemyState.Chasing;
                    
                    ChaseEntity();
                }
                
                break;
            }
            case EnemyState.Attack:
            {
                AttackEntity();
                break;
            }
            case EnemyState.HideAndSeek:
            {
                if (_isSeenPlayer)
                {
                    targetPoint = visionPoint;
                    _currentState = EnemyState.Chasing;
                    
                    ChaseEntity();
                }
                else if (_isHearingSomething && !_isSeenPlayer)
                {
                    targetPoint = hearingPoint;
                    _currentState = EnemyState.Chasing;
                    
                    ChaseEntity();
                }
                else
                {
                    _currentState = EnemyState.HideAndSeek;
                    
                    HideAndSeek();
                }
                break;
            }
        }
        
        Debug.Log($"State = {_currentState}, Hear = {_isHearingSomething}, Vision = {_isSeenPlayer}");
    }
    
    private void Patrolling()
    {
        agent.speed = 2f;
        bool targetIsAchieve = AchieveTarget();

        if (targetIsAchieve)
        {
            SearchWalkPoint(false);
        }
    }
    
    private void HideAndSeek()
    {
        agent.speed = 2f;
        bool targetIsAchieve = AchieveTarget();

        if (targetIsAchieve)
        {
            SearchWalkPoint(true);
        }
    }

    private void CheckPoint()
    {
        agent.speed = 5f;
        
        bool targetIsAchieve = AchieveTarget();

        if (targetIsAchieve)
        {
            _currentState = EnemyState.Patrolling;
        }
    }

    private void ChaseEntity()
    {
        agent.speed = 12f;
        
        bool targetIsAchieve = AchieveTarget();
        
        if (targetIsAchieve)
        {
            _currentState = EnemyState.HideAndSeek;
        }
    }

    private bool AchieveTarget()
    {
        agent.SetDestination(targetPoint);
        
        Vector3 distanceToWalkPoint = transform.position - targetPoint;
        
        Debug.Log(distanceToWalkPoint.magnitude);
        return distanceToWalkPoint.magnitude < 1f;
    }
    
    private void SearchWalkPoint(bool withHide)
    {
        float randomZ = Random.Range(-walkPointRange, walkPointRange);
        float randomX = Random.Range(-walkPointRange, walkPointRange);

        Vector3 point = withHide ? targetPoint : transform.position;
        targetPoint = new Vector3(point.x + randomX, transform.position.y, point.z + randomZ);
    }

    private void AttackEntity()
    {
        agent.SetDestination(transform.position);
        
        transform.LookAt(player);
    
        if (!alreadyAttacked)
        {
            alreadyAttacked = true;
            Invoke(nameof(ResetAttack), timeBetweenAttacks);
        }
    }
    
    private void ResetAttack()
    {
        alreadyAttacked = false;
    }

    public void PlaySound()
    {
        Debug.Log("It is me, Mario!");
    }
}

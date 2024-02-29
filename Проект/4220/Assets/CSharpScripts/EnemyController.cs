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

    private void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
        head = GameObject.Find("Head");
    }

    private void Update()
    {
        _isSeenPlayer = head.GetComponent<EnemyVision>().Vision();

        visionPoint = player.position;

        if (Input.GetKeyDown(KeyCode.F))
        {
            flag = !flag;
            _isHearingPlayer = false;
        }

        Debug.Log(flag);
        
        if (flag)
        { 
            _isHearingPlayer = head.GetComponent<EnemyHearing>().Hear(agent);
            hearingPoint = player.position;
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
                else if (_isHearingPlayer && !_isSeenPlayer)
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
                    targetPoint = _isHearingPlayer ? hearingPoint : targetPoint;
                    
                    CheckPoint();
                }
                break;
            }
            case EnemyState.Chasing:
            {
                if (_isSeenPlayer)
                {
                    targetPoint = visionPoint;
                }
                else if (_isHearingPlayer && !_isSeenPlayer)
                {
                    targetPoint = hearingPoint;
                }
                
                ChaseEntity();
                
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
                else if (_isHearingPlayer && !_isSeenPlayer)
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
        
        Debug.Log($"State = {_currentState}, Hear = {_isHearingPlayer}, Vision = {_isSeenPlayer}");
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

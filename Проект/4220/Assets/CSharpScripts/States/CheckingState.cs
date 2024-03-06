using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class CheckingState : State
{
    public override void Enter()
    {
        
    }

    public override void Action()
    {
        if (enemy._isSeenPlayer && !enemy.playerInAttackRange)
        {
            enemy.SetState(enemy.chasingState);
            enemy.targetPoint = enemy.visionPoint;
            
            return;
        }
        else
        {
            enemy.targetPoint = enemy._isHearingSomething ? enemy.hearingPoint : enemy.targetPoint;
        }
        
        enemy.agent.speed = 5f;
        
        bool targetIsAchieve = AchieveTarget();

        if (targetIsAchieve)
        {
            enemy.SetState(enemy.patrollingState);
        }
    }

    public override void Exit()
    {
        
    }

    private bool AchieveTarget()
    {
        enemy.agent.SetDestination(enemy.targetPoint);
        
        Vector3 distanceToWalkPoint = enemy.transform.position - enemy.targetPoint;
        
        Debug.Log(distanceToWalkPoint.magnitude);
        return distanceToWalkPoint.magnitude < 1f;
    }
}

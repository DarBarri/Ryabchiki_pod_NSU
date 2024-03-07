using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class ChasingState : State
{
    public override void Enter()
    {
        
    }

    public override void Action()
    {
        if ((enemy._isSeenPlayer || enemy._isHearingPlayer) && enemy.playerInAttackRange)
        {
            enemy.SetState(enemy.attackState);
            
            return;
        }
        else if (enemy._isSeenPlayer)
        {
            enemy.targetPoint = enemy.visionPoint;
        }
        else if (enemy._isHearingPlayer && !enemy._isSeenPlayer)
        {
            enemy.targetPoint = enemy.hearingPoint;
        }
        
        enemy.agent.speed = 12f;
        
        bool targetIsAchieve = AchieveTarget();
        
        if (targetIsAchieve)
        {
            enemy.SetState(enemy.hideAndSeekState);
        }
    }

    public override void Exit()
    {
        
    }
    
    private bool AchieveTarget()
    {
        enemy.agent.SetDestination(enemy.targetPoint);
        
        Vector3 distanceToWalkPoint = enemy.transform.position - enemy.targetPoint;

        return distanceToWalkPoint.magnitude < 1f;
    }
}

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
        enemy.agent.speed = 12f;
        if ((enemy._isSeenPlayer || enemy._isHearingPlayer) && enemy.playerInAttackRange)
        {
            enemy.SetState(enemy.attackState);
            
            return;
        }
        else if ((enemy._isSeenPlayer && !enemy.inHorde) || (enemy.inHorde && enemy.Horde.IsSeenPlayer))
        {
            enemy.targetPoint = enemy.inHorde? enemy.Horde.TargetPoint: enemy.visionPoint;
            
            if (!enemy.inHorde)
            {
                enemy.inHorde = true;
            }
        }
        else if ((enemy._isHearingPlayer && !enemy.inHorde) || (enemy.inHorde && enemy.Horde.IsHearingPlayer))
        {
            enemy.targetPoint = enemy.inHorde? enemy.Horde.TargetPoint: enemy.hearingPoint;
            
            if (!enemy.inHorde)
            {
                enemy.inHorde = true;
            }
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

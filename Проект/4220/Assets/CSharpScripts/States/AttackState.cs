using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class AttackState : State
{
    public override void Enter()
    {
        
    }

    public override void Action()
    {
        if (enemy._isSeenPlayer && !enemy.playerInAttackRange)
        {
            enemy.targetPoint = enemy.visionPoint;
            enemy.SetState(enemy.chasingState);
            
            return;
        }
        else if (enemy._isHearingPlayer && !enemy.playerInAttackRange)
        {
            enemy.targetPoint = enemy.hearingPoint;
            enemy.SetState(enemy.chasingState);
            
            return;
        }
        
        enemy.agent.SetDestination(enemy.transform.position);
        
        enemy.transform.LookAt(enemy.player);
    }

    public override void Exit()
    {
        
    }
}

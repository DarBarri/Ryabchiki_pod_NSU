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
        if ((enemy._isSeenPlayer || enemy._isHearingPlayer) && !enemy.playerInAttackRange)
        {
            enemy.targetPoint = enemy._isHearingPlayer? enemy.hearingPoint: enemy.visionPoint;
            enemy.SetState(enemy.chasingState);
        }
        
        enemy.agent.SetDestination(enemy.transform.position);
        
        // enemy.transform.LookAt(enemy.player);
    }

    public override void Exit()
    {
        
    }
}

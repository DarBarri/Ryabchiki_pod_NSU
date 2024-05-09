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
            Debug.Log(1);
            enemy.SetState(enemy.attackState);
            
            return;
        }
        else if ((enemy._isSeenPlayer || enemy._isHearingPlayer) && !enemy.playerInAttackRange)
        {
            enemy.targetPoint = enemy._isHearingPlayer? enemy.hearingPoint: enemy.visionPoint;
        }
        
        Ray ray = new Ray(enemy.targetPoint + Vector3.up, Vector3.down * 10f);

        bool isHit = Physics.Raycast(ray, out RaycastHit hit, 100f, 1 << LayerMask.NameToLayer("Roof"));

        enemy.targetPoint = hit.point;
        
        // Debug.Log($"{enemy.agent.hasPath}, {enemy.targetPoint.y}");
        
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
        
        Vector3 distanceToWalkPoint = enemy.agent.transform.position - enemy.targetPoint;

        return distanceToWalkPoint.magnitude < 1f;
    }
}

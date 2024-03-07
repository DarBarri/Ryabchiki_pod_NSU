using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class PatrollingState : State
{
    private float walkPointRange = 10f;
    public override void Enter ()
    {
        
    }

    public override void Action()
    {
        if (enemy._isSeenPlayer && !enemy.playerInAttackRange)
        {
            enemy.SetState(enemy.chasingState);
            enemy.targetPoint = enemy.visionPoint;

            IsFinished = true;
            
            return;
        }
        else if (enemy._isHearingSomething && !enemy._isSeenPlayer)
        {
            enemy.SetState(enemy.checkingState);
            enemy.targetPoint = enemy.hearingPoint;

            IsFinished = true;
            
            return;
        }
        
        bool targetIsAchieve = AchieveTarget();

        if (targetIsAchieve)
        {
            SearchWalkPoint(false);
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
    
    private void SearchWalkPoint(bool withHide)
    {
        float randomZ = Random.Range(-walkPointRange, walkPointRange);
        float randomX = Random.Range(-walkPointRange, walkPointRange);

        Vector3 point = withHide ? enemy.targetPoint : enemy.transform.position;
        enemy.targetPoint = new Vector3(point.x + randomX, enemy.transform.position.y, point.z + randomZ);
    }
}

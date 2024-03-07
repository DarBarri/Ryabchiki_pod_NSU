using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class HideAndSeekState : State
{
    private float walkPointRange = 10f;
    public override void Enter()
    {
        
    }

    public override void Action()
    {
        if (enemy._isSeenPlayer)
        {
            enemy.targetPoint = enemy.visionPoint;
            enemy.SetState(enemy.chasingState);
            
            return;
        }
        else if (enemy._isHearingSomething && !enemy._isSeenPlayer)
        {
            enemy.targetPoint = enemy.hearingPoint;
            enemy.SetState(enemy.chasingState);
            
            return;
        }
        
        enemy.agent.speed = 2f;
        bool targetIsAchieve = AchieveTarget();

        if (targetIsAchieve)
        {
            SearchWalkPoint(true);
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

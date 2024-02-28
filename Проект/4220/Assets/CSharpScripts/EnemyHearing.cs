using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyHearing : MonoBehaviour
{
    public LayerMask layer;
    private LayerMask _playerLayer = 1 << 12;
    private Transform player;

    private void Start()
    {
        player = GameObject.Find("Player").GetComponent<Transform>();
    }

    public bool Hear(NavMeshAgent agent)
    {
        if (Physics.CheckSphere(transform.position, 30f, _playerLayer))
        {
            float dist = Vector3.Distance(transform.position, player.position + Vector3.up);
            float straightDistance = 0f;

            RaycastHit hit, newHit;

            Ray ray = new Ray(transform.position, player.position + Vector3.up - transform.position);

            RaycastHit[] hits = Physics.RaycastAll(ray,
                Vector3.Distance(transform.position, player.position + Vector3.up * 2f), layer,
                QueryTriggerInteraction.Ignore);

            Debug.DrawRay(ray.origin, ray.direction * dist, Color.red);
            Physics.Raycast(ray, out hit, Mathf.Infinity, layer, QueryTriggerInteraction.Ignore);

            float coef = 0.6f;
            straightDistance += Vector3.Distance(transform.position, hit.point) / Mathf.Pow(coef, hits.Length - 1);

            for (int i = 1; i < hits.Length; i++)
            {
                ray = new Ray(hit.point, player.position - hit.point);

                Physics.Raycast(ray, out newHit, dist, layer, QueryTriggerInteraction.Ignore);

                straightDistance += Vector3.Distance(hit.point, newHit.point) / Mathf.Pow(coef, hits.Length - 1 - i);
                hit = newHit;
            }

            NavMeshPath path = new NavMeshPath();
            agent.CalculatePath(player.position, path);

            float curveDistance = 0f;

            for (int i = path.corners.Length - 1; i > 0; i--)
            {
                curveDistance += Vector3.Distance(path.corners[i], path.corners[i - 1]);
            }

            // Debug.Log($"{straightDistance}, {curveDistance}");
            return 15f > Mathf.Min(straightDistance, curveDistance);
        }
        else return false;
    }
}

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
    public NavMeshAgent agent;
    private float _maxVolumeSound;
    private int _targetIndex;
    private int index;

    private void Start()
    {
        player = GameObject.Find("Player").GetComponent<Transform>();
    }

    public int Hear(SoundSource[] soundSources)
    {
        _maxVolumeSound = 0f;
        _targetIndex = -1;
        index = 0;
        
        foreach (SoundSource soundSource in soundSources)
        {
            Vector3 point = soundSource.Point;
            float dist = Vector3.Distance(transform.position, point);
            float straightDistance = 0f;

            RaycastHit hit, newHit;

            Ray ray = new Ray(transform.position, point - transform.position);

            RaycastHit[] hits = Physics.RaycastAll(ray,
                Vector3.Distance(transform.position, point), layer,
                QueryTriggerInteraction.Ignore);

            Debug.DrawRay(ray.origin, ray.direction * dist, Color.red);
            Physics.Raycast(ray, out hit, Mathf.Infinity, layer, QueryTriggerInteraction.Ignore);

            float coef = 0.6f;
            straightDistance += Vector3.Distance(transform.position, hit.point) / Mathf.Pow(coef, hits.Length - 1);

            for (int i = 1; i < hits.Length; i++)
            {
                ray = new Ray(hit.point, point - hit.point);

                Physics.Raycast(ray, out newHit, dist, layer, QueryTriggerInteraction.Ignore);

                straightDistance += Vector3.Distance(hit.point, newHit.point) / Mathf.Pow(coef, hits.Length - 1 - i);
                hit = newHit;
            }

            NavMeshPath path = new NavMeshPath();
            agent.CalculatePath(point, path);

            float curveDistance = 0f;

            for (int i = path.corners.Length - 1; i > 0; i--)
            {
                curveDistance += Vector3.Distance(path.corners[i], path.corners[i - 1]);
            }

            straightDistance = GlobalDictionary.Sound[soundSource.Type].Radius - straightDistance;
            curveDistance = GlobalDictionary.Sound[soundSource.Type].Radius - curveDistance;

            if (_maxVolumeSound < Math.Max(straightDistance, curveDistance))
            {
                _maxVolumeSound = Math.Max(straightDistance, curveDistance);
                _targetIndex = index;
            }

            index++;
        }

        return _targetIndex;
    }
}

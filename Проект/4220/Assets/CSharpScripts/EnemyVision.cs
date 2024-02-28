using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyVision : MonoBehaviour
{
    public LayerMask layer;
    private readonly LayerMask _layer = 1 << 12;
    private Transform player;
    private const float _PlayerRadius = 0.3f;
    void Start()
    {
        player = GameObject.Find("Player").GetComponent<Transform>();
    }

    private void Update()
    {
        Vision();
    }
    public bool Vision()
    {
        Vector3 direction = player.position - transform.position;
        direction.y = 0f;
        float dist = Vector2.Distance(new Vector2(player.position.x, player.position.z), new Vector2(transform.position.x, transform.position.z));
        float angle = Mathf.Asin(_PlayerRadius / dist);
    
        for (int i = -4; i <= 4; i++)
        {
            float sin = Mathf.Sin((i * angle) / 4);
            float cos = 1 - sin * sin;
    
            Vector3 localDirection =
                new Vector3(direction.x * cos - direction.z * sin, 0f, direction.x * sin + direction.z * cos);
            
            Ray ray = new Ray(transform.position, localDirection);
            
            if (!Physics.Raycast(ray, Vector3.Distance(transform.position, player.position + Vector3.up), ~layer, QueryTriggerInteraction.Ignore))
            {
                return true;
            }
        }

        return false;
    }
}

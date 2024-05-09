using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class WallRenderOff : MonoBehaviour
{
    private readonly LayerMask _layer = (1 << 11) | (1 << 12); //слои игрока и стены
    
    private bool _less = false;
    
    private float _albedo = 1f;
    
    private MeshRenderer _wallMesh = null;
    private void Awake()
    {
        _wallMesh = GetComponent<MeshRenderer>();
        _wallMesh.material.SetInt("_ZWrite", 1);
    }
    
    private void ChangeAlbedo(bool rend, int queue)
    {
        if (rend && _albedo > 0.25f)
        {
            _albedo -= 5f * Time.deltaTime;
    
            // _wallMesh.shadowCastingMode = ShadowCastingMode.Off;
            
            Color color = _wallMesh.material.color;
            color.a = _albedo < 0.25f ? 0.25f : _albedo;
            _wallMesh.material.color = color;
            _wallMesh.material.renderQueue = 3000+queue;
        }
        else if (!rend && _albedo < 1f)
        {
            _albedo += 5f * Time.deltaTime;
            
            // _wallMesh.shadowCastingMode = ShadowCastingMode.On;
            
            Color color = _wallMesh.material.color;
            color.a = _albedo > 1f ? 1f : _albedo;
            _wallMesh.material.color = color;
            _wallMesh.material.renderQueue = 1500;
        }
    }

    public void RenderOff(Vector3 player, Vector3 mainCam, int queue)
    {
        if (_wallMesh.isVisible)
        {
            Vector3 a = player;
            a.y = 0f;
            Vector3 b = transform.position;
            b.y = 0f;
            Vector3 c = mainCam;
            c.y = 0f;
            
            Ray ray = new Ray(transform.position, player + Vector3.up * 1.3f - transform.position);
            RaycastHit hit;

            if (Physics.Raycast(ray.origin, ray.direction, out hit, Vector3.Distance(transform.position, player + Vector3.up * 1.3f - transform.position), _layer) && hit.collider.transform.gameObject.layer == LayerMask.NameToLayer("Player"))
            { 
                Vector3 _normal = transform.TransformDirection(Vector3.right);
                _normal.y = 0f;
                
                //нормаль в направлении игрока. если угол отрицательный, то разворот нормали
                if (Vector3.Dot(_normal, a - b) <= 0f)
                {
                    _normal = -_normal;
                }
                
                //угол между камерой и нормалью стены. если отрицательный, то НЕ делаем прозрачным, иначе делать
                if (Vector3.Dot(_normal, c) <= 0.1f)
                {
                    _less = false;
                }
                else
                {
                    _less = true;
                }
            }
            //если попал в стену
            else
            {
                _less = false;
            }
        }
        ChangeAlbedo(_less, queue);
    }

    public void RenderOn()
    {
        _less = false;

        ChangeAlbedo(_less, 0);
    }
}

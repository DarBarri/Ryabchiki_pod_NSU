using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering;

public class WallRenderOff : MonoBehaviour
{
    private bool _less = false;
    private float _albedo = 1f;
    private MeshRenderer _wallMesh = null;
    private void Awake()
    {
        _wallMesh = GetComponent<MeshRenderer>();
        _wallMesh.material.SetInt("_ZWrite", 1);
    }

    public void Render(bool flag)
    {
        _less = flag;
        if (_less && _albedo > 0.25f)
        {
            _albedo -= 5f * Time.deltaTime;

            // _wallMesh.shadowCastingMode = ShadowCastingMode.Off;
            Color color = _wallMesh.material.color;
            color.a = _albedo < 0.25f ? 0.25f : _albedo;
            _wallMesh.material.color = color;
        }
        else if (!_less && _albedo < 1f)
        {
            _albedo += 5f * Time.deltaTime;

            // _wallMesh.shadowCastingMode = ShadowCastingMode.On;

            Color color = _wallMesh.material.color;
            color.a = _albedo > 1f ? 1f : _albedo;
            _wallMesh.material.color = color;
        }
    }
}

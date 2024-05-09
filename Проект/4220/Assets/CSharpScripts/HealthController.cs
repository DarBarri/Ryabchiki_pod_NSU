using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;
using Random = UnityEngine.Random;

struct Debuff
{
    public bool IsActive;
    public float Damage;
    public float Timer;
    public float ActionTime;

    public Debuff(bool isActive, float damage, float timer, float actionTime)
    {
        IsActive = isActive;
        Damage = damage;
        Timer = timer;
        ActionTime = actionTime;
    }
}
public class HealthController : MonoBehaviour
{
    public Canvas canvas;
    public Image image;
    public float health;
    private float constSpeed = 7f;
    public float currentSpeed = 7f;
    private Debuff _bleeding = new Debuff(false, 0f, 0f, 0f);
    private Debuff _fracture = new Debuff(false, 0f, 0f, 0f);
    private Debuff _stunning = new Debuff(false, 0f, 0f, 0f);
    private bool isStunning;

    public void Damage(Vector3 point, Weapon weaponType)
    {
        WeaponData data = GlobalDictionary.Weapons[weaponType];
        
        Debug.Log(health);

        isDeath(data.Range);
        
        if (!_bleeding.IsActive && data.BleedingChance > Random.Range(0f, 1f))
        {
            // Debug.Log("Bleeding");
            _bleeding.IsActive = true;
            _bleeding.Damage = data.BleedingRange;
            _bleeding.Timer = 0f;
            _bleeding.ActionTime = 5f;

            StartCoroutine(Bleeding());
        }

        if (!_fracture.IsActive && data.FractureChance > Random.Range(0f, 1f))
        {
            // Debug.Log("Fracture");
            _fracture.IsActive = true;
            _fracture.Damage = data.FractureRange;

            currentSpeed = 2f;
            constSpeed = currentSpeed;
        }
        
        if (!_stunning.IsActive && data.StunningChance > Random.Range(0f, 1f))
        {
            // Debug.Log("Stunning");

            _stunning.IsActive = true;
            _stunning.Damage = 0f;
            _stunning.Timer = 0f;
            _stunning.ActionTime = 5f;

            StartCoroutine(Stunning());
        }
    }

    private void isDeath(float damage)
    {
        if (health <= damage)
        {
            health = 0f;
            Death();
        }
        else health -= damage;

        image.fillAmount = health / 100f;
    }

    private void Update()
    {
        canvas.transform.LookAt(Camera.main.transform);
    }

    private void Death()
    {
        Debug.Log("Death");
        StopAllCoroutines();
    }

    IEnumerator Bleeding()
    {
        for (int i = 0; i < _bleeding.ActionTime; i++)
        {
            yield return new WaitForSeconds(1f);
            isDeath(_bleeding.Damage);
        }

        _bleeding.IsActive = false;
    }

    IEnumerator Stunning()
    {
        currentSpeed = 0f;
        
        for (int i = 0; i < _stunning.ActionTime; i++)
        {
            yield return new WaitForSeconds(1f);
        }

        currentSpeed = constSpeed;

        _stunning.IsActive = false;
    }
}

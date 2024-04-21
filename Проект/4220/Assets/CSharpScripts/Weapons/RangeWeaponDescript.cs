using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "RangeWeapon", menuName = "Weapon/RangeWeapon")]
public class RangeWeaponDescript : ScriptableObject
{
    public float damage;
    
    public float criticalDamage;
    
    public float criticalChance;
    
    public float maxDistance;

    public int currentAmountAmmo;

    public int maxAmountAmmo;

    public float angleDeviation;

    public float minDelay;

    public float timeRecharge;

    public AnimationCurve accuracyHipCurve;

    public AnimationCurve accuracyAimedCurve;
}

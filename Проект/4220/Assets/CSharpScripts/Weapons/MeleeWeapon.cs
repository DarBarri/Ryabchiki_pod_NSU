using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "MeleeWeapon", menuName = "Weapon/MeleeWeapon")]
public class MeleeWeapon : ScriptableObject
{
    public float damage;

    public float criticalChance;

    public float criticalDamage;

    public float range;
}

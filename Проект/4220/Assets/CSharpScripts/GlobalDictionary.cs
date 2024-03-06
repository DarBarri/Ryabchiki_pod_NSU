using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct SoundSource
{
    public int HashCode;
    public SoundType Type;
    public Vector3 Point;

    public SoundSource(int hashCode, SoundType type, Vector3 point)
    {
        HashCode = hashCode;
        Type = type;
        Point = point;
    }
}
public struct SoundData
{
    public int ID;
    public float Radius;

    public SoundData(int id, float radius)
    {
        ID = id;
        Radius = radius;
    }
}
public struct WeaponData
{
    public int ID;

    public float Range;

    public float BleedingChance;

    public float BleedingRange;

    public float FractureChance;

    public float FractureRange;

    public float StunningChance;

    public float Repulsive;
    
    public WeaponData(int id, float range, float bleedingChance, float bleedingRange, float fractureChance, float fractureRange, float stunningChance, float repulsive)
    {
        ID = id;
        Range = range;
        BleedingChance = bleedingChance;
        BleedingRange = bleedingRange;
        FractureChance = fractureChance;
        FractureRange = fractureRange;
        StunningChance = stunningChance;
        Repulsive = repulsive;
    }
}
public class GlobalDictionary : MonoBehaviour
{
    public static Dictionary<WeaponType, WeaponData> Weapon = new Dictionary<WeaponType, WeaponData>()
    {
        { WeaponType.Pistol, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.AutoRifle, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.Shotgun, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.NonAutoRifle, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.MachineGun, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.SniperRifle, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.SubMachineGun, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.Machete, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.Axe, new WeaponData(0, 10f, 1f, 1f, 0.1f, 2f, 0.1f, 10f) },
        { WeaponType.Blockhead, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.Knife, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.Mace, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.Fist, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.Sword, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { WeaponType.Saber, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) }
    };

    public static Dictionary<SoundType, SoundData> Sound = new Dictionary<SoundType, SoundData>()
    {
        { SoundType.Running, new SoundData(0, 30f)},
        { SoundType.Scream, new SoundData(0, 30f)},
        { SoundType.Walking, new SoundData(0, 15f)},
        { SoundType.SitDown, new SoundData(0, 0f)},
        { SoundType.Stand, new SoundData(0, 0f)},
    };
}

public enum WeaponType {Pistol, AutoRifle, Shotgun, NonAutoRifle, MachineGun, SniperRifle, SubMachineGun, Machete, Axe, Blockhead, Knife, Mace, Fist, Sword, Saber}

public enum SoundType {Running, Scream, Walking, SitDown, Stand}
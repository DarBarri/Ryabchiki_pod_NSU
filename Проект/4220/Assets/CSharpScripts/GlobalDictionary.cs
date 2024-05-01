using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.ProBuilder;

public struct EnemyHorde
{
    public bool IsSeenPlayer;
    public bool IsHearingPlayer;
    public Vector3 VisionPoint;
    public Vector3 HearingPoint;
    public Vector3 TargetPoint;

    public EnemyHorde(bool isSeenPlayer, bool isHearingPlayer, Vector3 visionPoint, Vector3 hearingPoint, Vector3 targetPoint)
    {
        IsSeenPlayer = isSeenPlayer;
        IsHearingPlayer = isHearingPlayer;
        VisionPoint = visionPoint;
        HearingPoint = hearingPoint;
        TargetPoint = targetPoint;
    }
}

public enum LimbType{Hand, Head, Body, Leg}
public struct Anchor
{
    public Vector3 Position;
    public LimbType LimbType;

    public Anchor(Vector3 position, LimbType limbType)
    {
        Position = position;
        LimbType = limbType;
    }
}

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
    public static Dictionary<Weapon, WeaponData> Weapons = new Dictionary<Weapon, WeaponData>()
    {
        { Weapon.Pistol, new WeaponData(0, 0.5f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.AutoRifle, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.Shotgun, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.NonAutoRifle, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.MachineGun, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.SniperRifle, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.SubMachineGun, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.Machete, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.Axe, new WeaponData(0, 10f, 1f, 1f, 0.1f, 2f, 0.1f, 10f) },
        { Weapon.Blockhead, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.Knife, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.Mace, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.Fist, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.Sword, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) },
        { Weapon.Saber, new WeaponData(0, 10f, 10f, 10f, 10f, 10f, 10f, 10f) }
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

public enum Weapon {Pistol, AutoRifle, Shotgun, NonAutoRifle, MachineGun, SniperRifle, SubMachineGun, Machete, Axe, Blockhead, Knife, Mace, Fist, Sword, Saber}

public enum SoundType {Running, Scream, Walking, SitDown, Stand}

public enum WeaponType {Melee, Range, Script, Projectile, Implant}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class RangeWeapon : MonoBehaviour
{
    public bool rechardeState;

    public int countAmmoThisType;
    
    // public void DrawBorder(Vector3 weaponPosition, Vector3 directionView, float currentAngleView)
    // {
    //     float localAngleView = currentAngleView;
    //
    //     float sin = Mathf.Sin(localAngleView);
    //     float cos = Mathf.Cos(localAngleView);
    //
    //     Vector3 leftBorder = new Vector3(directionView.x * cos - directionView.z * sin, 0f,
    //         directionView.x * sin + directionView.z * cos);
    //
    //     Debug.DrawLine(weaponPosition, weaponPosition + leftBorder, Color.red);
    //
    //     sin = -sin;
    //
    //     leftBorder = new Vector3(directionView.x * cos - directionView.z * sin, 0f,
    //         directionView.x * sin + directionView.z * cos);
    //
    //     Debug.DrawLine(weaponPosition, weaponPosition + leftBorder, Color.red);
    // }
    
    public RangeWeaponDescript weaponData;
    public abstract void Shoot(Transform player, Vector3 shootPoint, Vector3 point, LimbType rangePriority);

    public abstract void Aim(Transform player, Vector3 shootPoint, Vector3 point, LimbType rangePriority);

    public abstract void Recharge(int playerCountAmmo);

    public abstract void CollingDown();
}

using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEditor.Experimental.GraphView;
using UnityEditor.Rendering;
using UnityEngine;

public class Pistol : RangeWeapon
{
    private float lastShoot = 0f;
    
    private float heating = 0f;

    public override void Shoot(Transform player, Vector3 shootPoint, Vector3 point)
    {
        if (Time.time - lastShoot > weaponData.minDelay && weaponData.currentAmountAmmo > 0) 
        { 
            weaponData.currentAmountAmmo--;
                
            heating = ((heating + 1) > weaponData.maxAmountAmmo) ? weaponData.maxAmountAmmo : heating + 1;
                
            Vector3 shootDir = point - shootPoint;
            shootDir.y = 0f;
                
            Normal normalRandom = new Normal();
                
            float randomDeviation;
                
            do
            {
                randomDeviation = (float)normalRandom.NextDouble() * weaponData.angleDeviation / 3;
            } while (randomDeviation >= weaponData.angleDeviation || randomDeviation <= -weaponData.angleDeviation);
                
            randomDeviation += weaponData.accuracyHipCurve.Evaluate(heating / weaponData.maxAmountAmmo);
                
            float angleDeviation =(Mathf.PI * randomDeviation)/ 180;
            float sin = Mathf.Sin(angleDeviation);
            float cos = Mathf.Cos(angleDeviation);
                
            shootDir = new Vector3(shootDir.x * cos - shootDir.z * sin, 0f, shootDir.x * sin + shootDir.z * cos);
                
            Vector3 weaponPosition = shootPoint;
            weaponPosition.y = 1f;
                
            Collider[] hitColliders = new Collider[10];
            int countHit = Physics.OverlapSphereNonAlloc(weaponPosition, 25f, hitColliders, 1 << LayerMask.NameToLayer("Enemy"));

            bool isHit = false;
                
            for (int i = 0; i < countHit; i++)
            {
                Vector3 directionToEnemy = hitColliders[i].transform.position - shootPoint;
                
                directionToEnemy.y = 0f;
                
                float angle = Mathf.PI * Vector3.SignedAngle(shootDir, directionToEnemy,Vector3.up) / 180;
                float enemySin = Mathf.Sin(angle);
                float enemyCos = Mathf.Cos(angle);
                
                Vector3 directionToHit = new Vector3(directionToEnemy.x * enemyCos - directionToEnemy.z * enemySin, 0f,
                        directionToEnemy.x * enemySin + directionToEnemy.z * enemyCos);
                
                Vector3 hitPoint = shootPoint + directionToHit;
                hitPoint.y = hitColliders[i].transform.position.y;
                
                Ray rayBelow = new Ray(shootPoint, hitPoint + Vector3.up * 0.5f - Vector3.up * 1.3f - shootPoint);
                Ray rayAbove = new Ray(shootPoint, hitPoint + Vector3.up * 1.5f - Vector3.up * 1.3f - shootPoint);
                
                RaycastHit hitBelow, hitAbove;
                    
                bool isHitBelow = Physics.Raycast(rayBelow.origin, rayBelow.direction, out hitBelow, 100f, ~(1 << LayerMask.NameToLayer("Player")));
                bool isHitAbove = Physics.Raycast(rayAbove.origin, rayAbove.direction, out hitAbove, 100f, ~(1 << LayerMask.NameToLayer("Player")));
                
                if ((isHitBelow && (hitBelow.transform.gameObject == hitColliders[i].gameObject)) ||
                        (isHitAbove && (hitAbove.transform.gameObject == hitColliders[i].gameObject)))
                {
                    hitColliders[i].gameObject.GetComponent<HealthController>().Damage(Vector3.zero, Weapon.Pistol);
                    
                    Debug.Log($"{hitAbove.point}, {hitBelow.point}");
                        
                    Debug.DrawLine(shootPoint, hitAbove.point, Color.red, weaponData.minDelay / 2);

                    isHit = true;

                    break;
                }
            }

            if (isHit == false)
            {
                Debug.DrawLine(weaponPosition, weaponPosition + shootDir, Color.red, weaponData.minDelay / 2);
            }
                
            lastShoot = Time.time;
        }
    }
    
    public override void Recharge(int playerCountAmmo)
    {
        StartCoroutine(RechargeMagazineCoroutine(playerCountAmmo));
    }
    
    public IEnumerator RechargeMagazineCoroutine(int playerCountAmmo)
    {
        rechardeState = true;
        
        yield return new WaitForSeconds(weaponData.timeRecharge);
        
        int lastAmountAmmo = weaponData.currentAmountAmmo;
        
        weaponData.currentAmountAmmo = weaponData.maxAmountAmmo - weaponData.currentAmountAmmo > playerCountAmmo
            ? weaponData.currentAmountAmmo + playerCountAmmo
            : weaponData.maxAmountAmmo;
        
        
        countAmmoThisType = playerCountAmmo - (weaponData.currentAmountAmmo - lastAmountAmmo);

        rechardeState = false;
    }

    public override void AimedShoot(Transform player, Vector3 point)
    {
        
    }

    public override void CollingDown()
    {
        heating = heating - (float)weaponData.maxAmountAmmo / 5 < 0 ? 0f : heating - (float)weaponData.maxAmountAmmo / 5;
    }
}

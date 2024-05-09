using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Unity.VisualScripting;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.ProBuilder;

public class Pistol : RangeWeapon
{
    private float lastShoot = 0f;
    
    private float heating = 0f;

    public float countHitEnemy;

    public override void Shoot(Transform player, Vector3 shootPoint, Vector3 point, LimbType rangePriority)
    {
        if (Time.time - lastShoot > weaponData.minDelay && weaponData.currentAmountAmmo > 0) 
        { 
            weaponData.currentAmountAmmo--;
                
            heating = ((heating + 1) > weaponData.maxAmountAmmo) ? weaponData.maxAmountAmmo : heating + 1;
                
            Vector3 shootDir = point - shootPoint;
            shootDir.y = 0f;
                
            //поиск всех врагов в радиусе. Вариант неоптимизированный, так как попадают и враги за спиной. Ну ч поделать, потом переделаю (нет)
            Vector3 weaponPosition = shootPoint;
            weaponPosition.y = 1f;
                
            Collider[] hitColliders = new Collider[10];
            int countHit = Physics.OverlapSphereNonAlloc(weaponPosition, 25f, hitColliders, 1 << LayerMask.NameToLayer("Enemy"));
            
            Vector3 shootDirReal = shootDir;
                        
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
                        
            shootDirReal = new Vector3(shootDirReal.x * cos - shootDirReal.z * sin, 0f, shootDirReal.x * sin + shootDirReal.z * cos);

            Anchor targetAnchor = FindTargetAnchor(shootPoint, shootDirReal, countHit, hitColliders, rangePriority);

            if (!targetAnchor.IsUnityNull())
            {
                float length = Vector3.Distance(Vector3.zero, shootDirReal);
                
                shootDirReal = Vector3.Normalize(shootDirReal);
                shootDirReal.y = Vector3.Normalize(targetAnchor.Position - shootPoint).y;
                shootDirReal *= length;
                
                bool isAnchorHit = Physics.Raycast(shootPoint, shootDirReal, out RaycastHit anchorHit, 100f, ~((1 << LayerMask.NameToLayer("Player")) | (1 << LayerMask.NameToLayer("Enemy"))));
                
                if (isAnchorHit && (anchorHit.transform.gameObject.CompareTag("Head") || anchorHit.transform.gameObject.CompareTag("Hand") || anchorHit.transform.gameObject.CompareTag("Leg") || anchorHit.transform.gameObject.CompareTag("Body")))
                {
                    hitColliders[0].gameObject.GetComponent<HealthController>().Damage(Vector3.zero, Weapon.Pistol);
                    Debug.Log($"Hit! to {anchorHit.transform.gameObject.tag}");
                    Debug.DrawLine(shootPoint, anchorHit.point, Color.red, weaponData.minDelay / 2);
                }
                else Debug.DrawLine(shootPoint, shootPoint + shootDirReal, Color.red, weaponData.minDelay / 2);
            }
            
            //реализация стрельбы с учётом аима
            // //теперь проходимся по всем и смотрим. Если появилась привязка к какому то врагу, то стреляем по нему (с учётом приоритета стрельбы)
            // for (int i = 0; i < countRealHit; i++)
            // {
            //     //здесь проверяем, попадаем ли мы по врагу рейкастом (для этого отображаем место, на котором находится враг,
            //     //на вектор направления взгляда и кидаем рейкаст - верх и низ)
            //     Vector3 directionToEnemy = hitColliders[i].transform.position - shootPoint;
            //     directionToEnemy.y = 0f;
            //     
            //     float angle = Mathf.PI * Vector3.SignedAngle(shootDir, directionToEnemy,Vector3.up) / 180;
            //     float enemySin = Mathf.Sin(angle);
            //     float enemyCos = Mathf.Cos(angle);
            //     
            //     //собственно отображение
            //     Vector3 directionToHit = new Vector3(directionToEnemy.x * enemyCos - directionToEnemy.z * enemySin, 0f,
            //             directionToEnemy.x * enemySin + directionToEnemy.z * enemyCos);
            //     
            //     //точка, куда стреляем рейкастами. Константы 0.5f и 1.5f - высоты, на которых проверяем попадание
            //     Vector3 hitPoint = shootPoint + directionToHit;
            //     hitPoint.y = hitColliders[i].transform.position.y;
            //     
            //     bool haveAnyHit = false;
            //     Anchor[] anchors = hitColliders[i].gameObject.GetComponent<HealthController>().ReturnAnchors();
            //     
            //     float angleToTarget = 100f;
            //
            //     Anchor targetPoint = new Anchor();
            //     for (int j = 0; j < anchors.Length; j++)
            //     {
            //         Vector3 anchorShootDir = anchors[j].Position - shootPoint;
            //         bool isAnchorHit = Physics.Raycast(shootPoint, anchorShootDir, out RaycastHit anchorHit, 100f, ~((1 << LayerMask.NameToLayer("Player")) | (1 << LayerMask.NameToLayer("Enemy"))));
            //             
            //         anchorShootDir.y = 0f;
            //
            //         if (isAnchorHit && anchors[j].LimbType == rangePriority && Vector3.Angle(anchorShootDir, shootDir) < angleToTarget)
            //         {
            //             haveAnyHit = true;
            //             angleToTarget = Vector3.Angle(anchorShootDir, shootDir);
            //             targetPoint = anchors[j];
            //         }
            //     }
            //
            //     if (haveAnyHit)
            //     {
            //         Normal normalRandom = new Normal();
            //
            //         float randomDeviation = 0f;
            //             //
            //             // do
            //             // {
            //             //     randomDeviation = (float)normalRandom.NextDouble() * weaponData.angleDeviation / 3;
            //             // } while (randomDeviation >= weaponData.angleDeviation || randomDeviation <= -weaponData.angleDeviation);
            //             //
            //         randomDeviation += weaponData.accuracyHipCurve.Evaluate(heating / weaponData.maxAmountAmmo);
            //         float angleDeviation =(Mathf.PI * randomDeviation)/ 180;
            //         float sin = Mathf.Sin(angleDeviation);
            //         float cos = Mathf.Cos(angleDeviation);
            //         
            //         Vector3 shootDirReal = targetPoint.Position - shootPoint;
            //
            //         shootDirReal = new Vector3(shootDirReal.x * cos - shootDirReal.z * sin, (targetPoint.Position - shootPoint).y, shootDirReal.x * sin + shootDirReal.z * cos);
            //             
            //         bool isHit2 = Physics.Raycast(shootPoint, shootDirReal, out RaycastHit hit2, 100f, ~((1 << LayerMask.NameToLayer("Player")) | (1 << LayerMask.NameToLayer("Enemy"))));
            //
            //         if (isHit2 && !hit2.transform.gameObject.CompareTag("Untagged"))
            //         {
            //             countHitEnemy++;
            //             Debug.DrawLine(shootPoint, shootPoint + shootDirReal, Color.red, weaponData.minDelay / 2);
            //         }
            //         else
            //         {
            //             float length = Vector3.Distance(Vector3.zero, shootDir);
            //             shootDirReal = Vector3.Normalize(shootDirReal);
            //             shootDirReal *= length;
            //             Debug.DrawLine(shootPoint, shootPoint + shootDirReal, Color.red, weaponData.minDelay / 2);
            //         }
            //     }
            // }
                
            lastShoot = Time.time;
        }
    }

    public override void Aim(Transform player, Vector3 shootPoint, Vector3 point, LimbType rangePriority)
    {
        Vector3 direction = point - shootPoint;
        direction.y = 0f;
        
        Vector3 weaponPosition = shootPoint;
        weaponPosition.y = 1f;
                
        Collider[] hitColliders = new Collider[10];
        int countHit = Physics.OverlapSphereNonAlloc(weaponPosition, 25f, hitColliders, 1 << LayerMask.NameToLayer("Enemy"));

        Anchor targetAnchor = FindTargetAnchor(shootPoint, direction, countHit, hitColliders, rangePriority);
        
        float length = Vector3.Distance(Vector3.zero, direction);
                
        direction = Vector3.Normalize(direction);
        direction.y = Vector3.Normalize(targetAnchor.Position - shootPoint).y;
        direction *= length;

        bool isHit = Physics.Raycast(shootPoint, direction, out RaycastHit hit, 100f,
            ~((1 << LayerMask.NameToLayer("Player")) | (1 << LayerMask.NameToLayer("Enemy"))));
        
        if (isHit && (hit.transform.gameObject.CompareTag("Head") || hit.transform.gameObject.CompareTag("Hand") || hit.transform.gameObject.CompareTag("Leg") || hit.transform.gameObject.CompareTag("Body")))
        {
            Debug.DrawLine(shootPoint, hit.point, Color.red, weaponData.minDelay / 25);
        }
        else Debug.DrawLine(shootPoint, shootPoint + direction, Color.red, weaponData.minDelay / 25);
    }

    public Anchor FindTargetAnchor(Vector3 shootPoint, Vector3 direction, int countHit, Collider[] hitColliders,
        LimbType rangePriority)
    {
        float maxDist = 10f;
        Anchor targetAnchor = new Anchor();

        for (int i = 0; i < countHit; i++)
        {
            Anchor[] anchors = hitColliders[i].gameObject.GetComponent<HealthController>().ReturnAnchors(rangePriority);

            for (int j = 0; j < anchors.Length; j++)
            {
                Vector3 playerToEnemyAnchor = anchors[j].Position - shootPoint;
                playerToEnemyAnchor.y = 0f;
                float angle = Vector3.Angle(direction, playerToEnemyAnchor) * Mathf.PI / 180;

                if (Vector3.Distance(playerToEnemyAnchor, Vector3.zero) * Mathf.Sin(angle) < maxDist)
                {
                    targetAnchor = anchors[j];
                    maxDist = Vector3.Distance(playerToEnemyAnchor, Vector3.zero) * Mathf.Sin(angle);
                }
            }
        }

        return targetAnchor;
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

    public override void CollingDown()
    {
        heating = heating - (float)weaponData.maxAmountAmmo / 5 < 0 ? 0f : heating - (float)weaponData.maxAmountAmmo / 5;
    }
}

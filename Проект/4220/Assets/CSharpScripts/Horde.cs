using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Node
{
    public Node Father;
    public GameObject Enemy;
    public Vector3 TargetPoint;
    public bool IsReached;
    public bool IsSeenPlayer;
    public bool IsSeenTarget;
}
public class Horde : MonoBehaviour
{
    private List<List<Node>> layers;

    private void Awake()
    {
        layers = new List<List<Node>>();
    }

    public void EnterHorde()
    {
        
    }

    public void ExitHorde()
    {
        
    }
}

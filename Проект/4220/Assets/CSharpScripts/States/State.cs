using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public abstract class State : ScriptableObject
{
    public bool IsFinished { get; protected set; }
    public EnemyStateController enemy;

    public abstract void Enter();

    public abstract void Action();

    public abstract void Exit();
}

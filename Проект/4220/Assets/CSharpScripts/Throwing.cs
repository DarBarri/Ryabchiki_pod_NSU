using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;

public class Throwing : MonoBehaviour
{
    public float width;

    private LineRenderer lineRenderer;

    private GameObject stone;

    private Transform player;
    
    private Rigidbody _rigidbody;

    private Collider _collider;

    private const float Gravity = 9.81f;

    private const int PositionCount = 100;

    private Vector3[] trajectoryPosition;

    private Vector3[] solutions;
    
    private float[] resTimes;

    private Vector3 velocity;

    private int layer;
    
    void Awake()
    {
	    lineRenderer = GetComponent<LineRenderer>();
	    lineRenderer.startWidth = width;
	    lineRenderer.endWidth = width;
	    
	    _rigidbody = GetComponent<Rigidbody>();
	    _collider = GetComponent<Collider>();

	    layer = 1 << LayerMask.NameToLayer("Player");
    }
    
    private static bool IsZero(double d) {
	    const double eps = 1e-9;
	    
	    return d > -eps & d < eps;
    }

    private static double GetCubicRoot(double value)
    {   
	    if (value > 0.0) 
	    {
		    return System.Math.Pow(value, 1.0 / 3.0);
	    } 
	    else if (value < 0) 
	    {
		    return -System.Math.Pow(-value, 1.0 / 3.0);
	    } 
	    else 
	    {
		    return 0.0;
	    }
    }
    
    private static int SolveCubic(double c0, double c1, double c2, double c3, out double s0, out double s1, out double s2)
    {
	    s0 = double.NaN;
	    s1 = double.NaN;
	    s2 = double.NaN;

	    int num;
	    double sub, a, b, c, squareA, p, q, cbP, d;

	    /* normal form: x^3 + Ax^2 + Bx + C = 0 */
	    a = c1 / c0;
	    b = c2 / c0;
	    c = c3 / c0;

	    /*  substitute x = y - A/3 to eliminate quadric term:  x^3 +px + q = 0 */
	    squareA = a * a;
	    p = 1.0/3 * (- 1.0/3 * squareA + b);
	    q = 1.0/2 * (2.0/27 * a * squareA - 1.0/3 * a * b + c);

	    /* use Cardano's formula */
	    cbP = p * p * p;
	    d = q * q + cbP;

	    if (IsZero(d)) {
		    if (IsZero(q)) /* one triple solution */ {
			    s0 = 0;
			    num = 1;
		    }
		    else /* one single and one double solution */ {
			    double u = GetCubicRoot(-q);
			    s0 = 2 * u;
			    s1 = - u;
			    num = 2;
		    }
	    }
	    else if (d < 0) /* Casus irreducibilis: three real solutions */ {
		    double phi = 1.0/3 * System.Math.Acos(-q / System.Math.Sqrt(-cbP));
		    double t = 2 * System.Math.Sqrt(-p);

		    s0 =   t * System.Math.Cos(phi);
		    s1 = - t * System.Math.Cos(phi + System.Math.PI / 3);
		    s2 = - t * System.Math.Cos(phi - System.Math.PI / 3);
		    num = 3;
	    }
	    else /* one real solution */ {
		    double sqrtD = System.Math.Sqrt(d);

		    s0 = GetCubicRoot(sqrtD - q) - GetCubicRoot(sqrtD + q);
		    num = 1;
	    }

	    /* resubstitute */
	    sub = 1.0/3 * a;
	    
	    s0 -= sub;

	    if (num > 1)
	    {
		    s1 -= sub;
	    }

	    if (num > 2)
	    {
		    s2 -= sub;
	    }

	    return num;
    }
    
    private static int SolveQuadric(double c0, double c1, double c2, out double s0, out double s1) {
	    s0 = double.NaN;
	    s1 = double.NaN;

	    double p, q, d;

	    /* normal form: x^2 + px + q = 0 */
	    p = c1 / (2 * c0);
	    q = c2 / c0;

	    d = p * p - q;

	    if (IsZero(d)) {
		    s0 = -p;
		    return 1;
	    }
	    else if (d < 0) {
		    return 0;
	    }
	    else /* if (D > 0) */ {
		    double sqrtD = System.Math.Sqrt(d);

		    s0 = sqrtD - p;
		    s1 = -sqrtD - p;
		    return 2;
	    }
    }

    private static int SolveQuartic(double c0, double c1, double c2, double c3, double c4, out double s0, out double s1, out double s2, out double s3) {
        s0 = double.NaN;
        s1 = double.NaN;
        s2 = double.NaN;
        s3 = double.NaN;

        double[] coefs = new double[4];
        double z, u, v, sub, a, b, c, d, sqA, p, q, r;
        int num;

        /* normal form: x^4 + Ax^3 + Bx^2 + Cx + D = 0 */
        a = c1 / c0;
        b = c2 / c0;
        c = c3 / c0;
        d = c4 / c0;

        /*  substitute x = y - A/4 to eliminate cubic term: x^4 + px^2 + qx + r = 0 */
        sqA = a * a;
        p = - 3.0/8 * sqA + b;
        q = 1.0/8 * sqA * a - 1.0/2 * a * b + c;
        r = - 3.0/256*sqA*sqA + 1.0/16*sqA*b - 1.0/4*a*c + d;

        if (IsZero(r)) {
	        /* no absolute term: y(y^3 + py + q) = 0 */

	        coefs[3] = q;
	        coefs[2] = p;
	        coefs[1] = 0;
	        coefs[0] = 1;

	        num = SolveCubic(coefs[0], coefs[1], coefs[2], coefs[3], out s0, out s1, out s2);
        }
        else {
	        /* solve the resolvent cubic ... */
	        coefs[3] = 1.0/2 * r * p - 1.0/8 * q * q;
	        coefs[2] = - r;
	        coefs[1] = - 1.0/2 * p;
	        coefs[0] = 1;

            SolveCubic(coefs[0], coefs[1], coefs[2], coefs[3], out s0, out s1, out s2);

	        /* ... and take the one real solution ... */
	        z = s0;

	        /* ... to build two quadric equations */
	        u = z * z - r;
	        v = 2 * z - p;

	        if (IsZero(u))
	        {
		        u = 0;
	        }
	        else if (u > 0)
	        {
		        u = System.Math.Sqrt(u);
	        }
	        else
	        {
		        return 0;
	        }

	        if (IsZero(v))
	        {
		        v = 0;
	        }
	        else if (v > 0)
	        {
		        v = System.Math.Sqrt(v);
	        }
	        else
	        {
		        return 0;
	        }

	        coefs[2] = z - u;
	        coefs[1] = q < 0 ? -v : v;
	        coefs[0] = 1;

	        num = SolveQuadric(coefs[0], coefs[1], coefs[2], out s0, out s1);

	        coefs[2]= z + u;
	        coefs[1] = q < 0 ? v : -v;
	        coefs[0] = 1;

	        if (num == 0)
	        {
		        num += SolveQuadric(coefs[0], coefs[1], coefs[2], out s0, out s1);
	        }
            else if (num == 1)
            {
	            num += SolveQuadric(coefs[0], coefs[1], coefs[2], out s1, out s2);
            }
            else if (num == 2)
            {
	            num += SolveQuadric(coefs[0], coefs[1], coefs[2], out s2, out s3);
            }
        }

        /* resubstitute */
        sub = 1.0/4 * a;

        if (num > 0)
        {
	        s0 -= sub;
        }

        if (num > 1)
        {
	        s1 -= sub;
        }

        if (num > 2)
        {
	        s2 -= sub;
        }

        if (num > 3)
        {
	        s3 -= sub;
        }

        return num;
    }

    public void CalculateTrajectory(Vector3 target)
    {
	    Vector3 stonePosition = transform.position;
	    double g = Gravity;

        double a = stonePosition.x;
        double b = stonePosition.y;
        double c = stonePosition.z;
        double m = target.x;
        double n = target.y;
        double o = target.z;
        double p = 0f;
        double q = 0f;
        double r = 0f;
        double s = 25f;

        double h = m - a;
        double j = o - c;
        double k = n - b;
        double l = -0.5f * g;
        double c0 = l * l;
        double c1 = -2 * q * l;
        double c2 = q * q - 2 * k * l - s * s + p * p + r * r;
        double c3 = 2 * k * q + 2 * h * p + 2 * j * r;
        double c4 = k * k + h * h + j * j;

        double[] times = new double[4];
        SolveQuartic(c0, c1, c2, c3, c4, out times[0], out times[1], out times[2], out times[3]);

        // Sort so faster collision is found first
        System.Array.Sort(times);

        // Plug quartic solutions into base equations
        // There should never be more than 2 positive, real roots.
        solutions = new Vector3[2];
        resTimes = new float[2];
        
        int numSolutions = 0;

        for (int i = 0; i < times.Length && numSolutions < 2; ++i) {
	        double t = times[i];
	        if (t <= 0 | double.IsNaN(t))
		        continue;

	        solutions[numSolutions].x = (float)((h+p*t)/t);
	        solutions[numSolutions].y = (float)((k+q*t-l*t*t)/ t);
	        solutions[numSolutions].z = (float)((j+r*t)/t);
	        resTimes[numSolutions] = (float)t;
	        ++numSolutions;
        }

        velocity = solutions[0];
    }

    public void ShowTrajectory(Vector3 target)
    {
	    Vector3 stonePosition = transform.position;
	    CalculateTrajectory(target);
	    
	    trajectoryPosition = new Vector3[100];

	    trajectoryPosition[0].x = stonePosition.x;
	    trajectoryPosition[0].y = stonePosition.y;
	    trajectoryPosition[0].z = stonePosition.z;
	    
	    for (int i = 1; i < PositionCount; i++)
	    {
		    float lastTime = (resTimes[0] * i) / (PositionCount - 1);
		    
		    trajectoryPosition[i].x = stonePosition.x + solutions[0].x * lastTime;
		    trajectoryPosition[i].y = stonePosition.y + solutions[0].y * lastTime - (float)Gravity * lastTime * lastTime / 2;
		    trajectoryPosition[i].z = stonePosition.z + solutions[0].z * lastTime;

		    RaycastHit hit;
		    
		    Debug.DrawLine(trajectoryPosition[i - 1], trajectoryPosition[i], Color.red);

		    if (Physics.Raycast(trajectoryPosition[i - 1], trajectoryPosition[i] - trajectoryPosition[i - 1], out hit, Vector3.Distance(trajectoryPosition[i - 1], trajectoryPosition[i]), ~layer))
		    {
			    trajectoryPosition[i].x = hit.point.x;
			    trajectoryPosition[i].y = hit.point.y;
			    trajectoryPosition[i].z = hit.point.z;
			    
			    break;
		    }
	    }
    }

    public void Throw(Vector3 target)
    {
	    _rigidbody.velocity = Vector3.zero;
	    lineRenderer.enabled = false;
	    
	    CalculateTrajectory(target);

	    transform.parent = null;
	    
	    _rigidbody.AddForce(velocity, ForceMode.VelocityChange);
    }

    public void IsKinematic(bool isKinematic)
    {
	    _rigidbody.isKinematic = isKinematic;
    }
}

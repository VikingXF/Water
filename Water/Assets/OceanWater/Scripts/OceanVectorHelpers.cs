using UnityEngine;

namespace OceanWaterNS
{
    public static class OceanVectorHelpers
    {
        public static Vector2 GetXY(Vector4 val)
        {
            return new Vector2(val.x, val.y);
        }

        public static Vector2 GetZW(Vector4 val)
        {
            return new Vector2(val.z, val.w);
        }

        public static Vector2 GetXZ(Vector3 val)
        {
            return new Vector2(val.x, val.z);
        }

        public static Vector2 Mul(Vector2 a, Vector2 b)
        {
            return new Vector4(a.x * b.x,
                                a.y * b.y);
        }

        public static Vector4 Mul(Vector4 a, Vector4 b)
        {
            return new Vector4(a.x * b.x,
                                a.y * b.y,
                                a.z * b.z,
                                a.w * b.w);
        }

        public static Vector4 Div(Vector4 a, Vector4 b)
        {
            return new Vector4(a.x / b.x,
                                a.y / b.y,
                                a.z / b.z,
                                a.w / b.w);
        }

        public static Vector4 Sin(Vector4 val)
        {
            return new Vector4(Mathf.Sin(val.x),
                                Mathf.Sin(val.y),
                                Mathf.Sin(val.z),
                                Mathf.Sin(val.w));
        }

        public static Vector4 Pow(Vector4 val, Vector4 exp)
        {
            return new Vector4(Mathf.Pow(val.x, exp.x),
                                Mathf.Pow(val.y, exp.y),
                                Mathf.Pow(val.z, exp.z),
                                Mathf.Pow(val.w, exp.w));
        }

        public static float Sum(Vector4 val)
        {
            return val.x + val.y + val.z + val.w;
        }
    }

}


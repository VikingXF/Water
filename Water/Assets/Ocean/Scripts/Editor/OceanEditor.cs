using UnityEngine;
using UnityEditor;

namespace OceanToolkit
{
    [CustomEditor(typeof(Ocean))]
    public class OceanEditor : Editor
    {
        protected static float Zero = 0.0f;
        protected static float MaxAngle = 360.0f;
        protected static float MaxSpeed = 20.0f;
        protected static float MaxScale = 10.0f;
        protected static float MinLength = 0.1f;
        protected static float MaxLength = 40.0f;
        protected static float MaxExponent = 10.0f;

        public static bool showWave0;
        public static bool showWave1;
        public static bool showWave2;
        public static bool showWave3;
        public static bool showNormal0;
        public static bool showNormal1;
        public static bool showFoam;
        public static bool showMesh;

        public override void OnInspectorGUI()
        {
            Ocean o = (Ocean)target;

            // Prepare for changes
            EditorGUI.BeginChangeCheck();

            EditorGUILayout.LabelField("Appearance", EditorStyles.boldLabel);
            var oceanMaterial = (Material)EditorGUILayout.ObjectField("Ocean Material", o.OceanMaterial, typeof(Material), false);
            var sunLight = (Light)EditorGUILayout.ObjectField("Sun Light", o.SunLight, typeof(Light), true);

            EditorGUILayout.LabelField("Global settings", EditorStyles.boldLabel);
            var windAngle = EditorGUILayout.Slider("Wind Angle", o.WindAngle, 0.0f, MaxAngle);

            EditorGUILayout.LabelField("Wave function", EditorStyles.boldLabel);
            showWave0 = EditorGUILayout.Foldout(showWave0, "Channel 0");
            var waveAngle0 = o.WaveAngle0;
            var waveSpeed0 = o.WaveSpeed0;
            var waveScale0 = o.WaveScale0;
            var waveLength0 = o.WaveLength0;
            var waveSharpness0 = o.WaveSharpness0;
            if (showWave0)
            {
                waveAngle0 = EditorGUILayout.Slider("Angle", o.WaveAngle0, Zero, MaxAngle);
                waveSpeed0 = EditorGUILayout.Slider("Speed", o.WaveSpeed0, Zero, MaxSpeed);
                waveScale0 = EditorGUILayout.Slider("Scale", o.WaveScale0, Zero, MaxScale);
                waveLength0 = EditorGUILayout.Slider("Length", o.WaveLength0, MinLength, MaxLength);
                waveSharpness0 = EditorGUILayout.Slider("Sharpness", o.WaveSharpness0, 1.0f, MaxExponent);
            }
            showWave1 = EditorGUILayout.Foldout(showWave1, "Channel 1");
            var waveAngle1 = o.WaveAngle1;
            var waveSpeed1 = o.WaveSpeed1;
            var waveScale1 = o.WaveScale1;
            var waveLength1 = o.WaveLength1;
            var waveSharpness1 = o.WaveSharpness1;
            if (showWave1)
            {
                waveAngle1 = EditorGUILayout.Slider("Angle", o.WaveAngle1, Zero, MaxAngle);
                waveSpeed1 = EditorGUILayout.Slider("Speed", o.WaveSpeed1, Zero, MaxSpeed);
                waveScale1 = EditorGUILayout.Slider("Scale", o.WaveScale1, Zero, MaxScale);
                waveLength1 = EditorGUILayout.Slider("Length", o.WaveLength1, MinLength, MaxLength);
                waveSharpness1 = EditorGUILayout.Slider("Sharpness", o.WaveSharpness1, 1.0f, MaxExponent);
            }
            showWave2 = EditorGUILayout.Foldout(showWave2, "Channel 2");
            var waveAngle2 = o.WaveAngle2;
            var waveSpeed2 = o.WaveSpeed2;
            var waveScale2 = o.WaveScale2;
            var waveLength2 = o.WaveLength2;
            var waveSharpness2 = o.WaveSharpness2;
            if (showWave2)
            {
                waveAngle2 = EditorGUILayout.Slider("Angle", o.WaveAngle2, Zero, MaxAngle);
                waveSpeed2 = EditorGUILayout.Slider("Speed", o.WaveSpeed2, Zero, MaxSpeed);
                waveScale2 = EditorGUILayout.Slider("Scale", o.WaveScale2, Zero, MaxScale);
                waveLength2 = EditorGUILayout.Slider("Length", o.WaveLength2, MinLength, MaxLength);
                waveSharpness2 = EditorGUILayout.Slider("Sharpness", o.WaveSharpness2, 1.0f, MaxExponent);
            }
            showWave3 = EditorGUILayout.Foldout(showWave3, "Channel 3");
            var waveAngle3 = o.WaveAngle3;
            var waveSpeed3 = o.WaveSpeed3;
            var waveScale3 = o.WaveScale3;
            var waveLength3 = o.WaveLength3;
            var waveSharpness3 = o.WaveSharpness3;
            if (showWave3)
            {
                waveAngle3 = EditorGUILayout.Slider("Angle", o.WaveAngle3, Zero, MaxAngle);
                waveSpeed3 = EditorGUILayout.Slider("Speed", o.WaveSpeed3, Zero, MaxSpeed);
                waveScale3 = EditorGUILayout.Slider("Scale", o.WaveScale3, Zero, MaxScale);
                waveLength3 = EditorGUILayout.Slider("Length", o.WaveLength3, MinLength, MaxLength);
                waveSharpness3 = EditorGUILayout.Slider("Sharpness", o.WaveSharpness3, 1.0f, MaxExponent);
            }

            EditorGUILayout.LabelField("Detail Maps", EditorStyles.boldLabel);
            showNormal0 = EditorGUILayout.Foldout(showNormal0, "Normal Map 0");
            var normalMapAngle0 = o.NormalMapAngle0;
            var normalMapSpeed0 = o.NormalMapSpeed0;
            if (showNormal0)
            {
                normalMapAngle0 = EditorGUILayout.Slider("Angle", o.NormalMapAngle0, Zero, MaxAngle);
                normalMapSpeed0 = EditorGUILayout.Slider("Speed", o.NormalMapSpeed0, Zero, MaxSpeed);
            }
            showNormal1 = EditorGUILayout.Foldout(showNormal1, "Normal Map 1");
            var normalMapAngle1 = o.NormalMapAngle1;
            var normalMapSpeed1 = o.NormalMapSpeed1;
            if (showNormal1)
            {
                normalMapAngle1 = EditorGUILayout.Slider("Angle", o.NormalMapAngle1, Zero, MaxAngle);
                normalMapSpeed1 = EditorGUILayout.Slider("Speed", o.NormalMapSpeed1, Zero, MaxSpeed);
            }
            showFoam = EditorGUILayout.Foldout(showFoam, "Foam Map");
            var foamMapAngle = o.FoamMapAngle;
            var foamMapSpeed = o.FoamMapSpeed;
            if (showFoam)
            {
                foamMapAngle = EditorGUILayout.Slider("Angle", o.FoamMapAngle, Zero, MaxAngle);
                foamMapSpeed = EditorGUILayout.Slider("Speed", o.FoamMapSpeed, Zero, MaxSpeed);
            }

            EditorGUILayout.LabelField("Advanced", EditorStyles.boldLabel);
            showMesh = EditorGUILayout.Foldout(showMesh, "Screen Space Mesh");
            var screenSpaceMeshResolutionX = o.ScreenSpaceMeshResolutionX;
            var screenSpaceMeshResolutionY = o.ScreenSpaceMeshResolutionY;
            var screenSpaceMeshBoundsSize = o.ScreenSpaceMeshBoundsSize;
            if (showMesh)
            {
                screenSpaceMeshResolutionX = EditorGUILayout.IntField("Resolution X", o.ScreenSpaceMeshResolutionX);
                screenSpaceMeshResolutionY = EditorGUILayout.IntField("Resolution Y", o.ScreenSpaceMeshResolutionY);
                screenSpaceMeshBoundsSize = EditorGUILayout.FloatField("Bounds Size", o.ScreenSpaceMeshBoundsSize);
            }
            var mainCameraOnly = EditorGUILayout.Toggle("Main Camera Only", o.MainCameraOnly);
            var sceneCameraFixFarPlane = EditorGUILayout.Toggle("Scene Camera Fix Far Plane", o.SceneCameraFixFarPlane);
            var sceneCameraFarPlane = EditorGUILayout.FloatField("Scene Camera Far Plane", o.SceneCameraFarPlane);

            // Handle changes
            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(o, "Ocean Setting");

                o.OceanMaterial = oceanMaterial;
                o.SunLight = sunLight;
                o.WindAngle = windAngle;
                o.WaveAngle0 = waveAngle0;
                o.WaveSpeed0 = waveSpeed0;
                o.WaveScale0 = waveScale0;
                o.WaveLength0 = waveLength0;
                o.WaveSharpness0 = waveSharpness0;
                o.WaveAngle1 = waveAngle1;
                o.WaveSpeed1 = waveSpeed1;
                o.WaveScale1 = waveScale1;
                o.WaveLength1 = waveLength1;
                o.WaveSharpness1 = waveSharpness1;
                o.WaveAngle2 = waveAngle2;
                o.WaveSpeed2 = waveSpeed2;
                o.WaveScale2 = waveScale2;
                o.WaveLength2 = waveLength2;
                o.WaveSharpness2 = waveSharpness2;
                o.WaveAngle3 = waveAngle3;
                o.WaveSpeed3 = waveSpeed3;
                o.WaveScale3 = waveScale3;
                o.WaveLength3 = waveLength3;
                o.WaveSharpness3 = waveSharpness3;
                o.NormalMapAngle0 = normalMapAngle0;
                o.NormalMapSpeed0 = normalMapSpeed0;
                o.NormalMapAngle1 = normalMapAngle1;
                o.NormalMapSpeed1 = normalMapSpeed1;
                o.FoamMapAngle = foamMapAngle;
                o.FoamMapSpeed = foamMapSpeed;
                o.ScreenSpaceMeshResolutionX = screenSpaceMeshResolutionX;
                o.ScreenSpaceMeshResolutionY = screenSpaceMeshResolutionY;
                o.ScreenSpaceMeshBoundsSize = screenSpaceMeshBoundsSize;
                o.MainCameraOnly = mainCameraOnly;
                o.SceneCameraFixFarPlane = sceneCameraFixFarPlane;
                o.SceneCameraFarPlane = sceneCameraFarPlane;

                EditorUtility.SetDirty(o);
            }
        }
    }
}
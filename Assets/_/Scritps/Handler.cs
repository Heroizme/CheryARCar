using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;

public class Handler : MonoBehaviour
{

    [SerializeField]
    ARPointCloudManager ARPointCloud;

    [SerializeField]
    ARPlaneManager ARPlane;

    [SerializeField]
    Text FovTxt;

    [SerializeField]
    Toggle ShowToggle;

    [SerializeField]
    Toggle ShowARPlaneToggle;

    [SerializeField]
    Toggle ShowARBgToggle;

    [SerializeField]
    ARCameraBackground ARBg;

    [SerializeField]
    List<GameObject> UIObjs;
    
    [SerializeField]
    List<Button> CarModeBtns;
    
    [SerializeField]
    List<GameObject> CarModeObjs;

    [SerializeField]
    List<Button> SceneModeBtns;
    
    [SerializeField]
    List<GameObject> SceneObjs;

    ARPlaneManager planeManager;

    private void Awake()
    {

        planeManager = FindObjectOfType<ARPlaneManager>();

        ShowToggle.onValueChanged.AddListener((e) =>
        {
            for (int i = 0; i < UIObjs.Count; i++)
            {
                UIObjs[i].SetActive(e);
            }

        });

        ShowARPlaneToggle.onValueChanged.AddListener((e) =>
        {
            ARPointCloud.SetTrackablesActive(e);
            ARPlane.SetTrackablesActive(e);

            foreach (var plane in planeManager.trackables)
            {
                plane.gameObject.SetActive(e);
            }

            ARPlane.enabled = e;

            // Disable each existing one
            foreach (var pointCloud in ARPointCloud.trackables)
            {
                pointCloud.gameObject.SetActive(e);
            }

            // Stop updating point clouds
            ARPointCloud.enabled = e;

        });

        ShowARBgToggle.onValueChanged.AddListener((e) =>
        {
            ARBg.enabled = (e);
        });

        for (int i = 0; i < CarModeBtns.Count; i++)
        {
            int index = i;
            CarModeBtns[i].onClick.AddListener(() =>
            {
                CarMode(index);
            });
        }

        for (int i = 0; i < SceneModeBtns.Count; i++)
        {
            int index = i;
            SceneModeBtns[i].onClick.AddListener(() =>
            {
                SceneMode(index);
            });
        }

    }

    private void Update()
    {
        FovTxt.text = "Fov : " + ARBg.GetComponent<Camera>().fieldOfView;
    }

    /// <summary>
    /// 车显示模式，AR、模型、隐藏
    /// </summary>
    /// <param name="index"></param>
    void CarMode(int index)
    {
        for (int i = 0; i < 2; i++)
        {
            CarModeObjs[i].SetActive(i == index);
        }
    }

    /// <summary>
    /// 场景显示控制
    /// </summary>
    /// <param name="index"></param>
    void SceneMode(int index)
    {
        for (int i = 0; i < SceneObjs.Count; i++)
        {
            SceneObjs[i].SetActive(i == index);
        }
    }

}

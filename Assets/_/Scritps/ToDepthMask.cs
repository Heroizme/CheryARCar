using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ToDepthMask : MonoBehaviour
{

    [SerializeField]
    Material depthMat;


    [SerializeField]
    Transform MatRoot;

    [ContextMenu("Set all child depth material")]
    void SetDepthMats()
    {
        for (int i = 0; i < MatRoot.childCount; i++)
        {

        }
    }

    void Iterator(Transform root, int index)
    {
        for (int i = 0; i < root.childCount; i++)
        {

        }
    }
}

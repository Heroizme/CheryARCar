using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;

public class ARKitBaseImageTest : MonoBehaviour
{


    [SerializeField]
    Text debug;

    [SerializeField]
    Slider scaler;

    [SerializeField]
    Toggle addToggle;

    [SerializeField]
    Toggle updateToggle;

    [SerializeField]
    Transform Anchor;

    ARTrackedImageManager imageManager;


    private void Awake()
    {

        imageManager = FindObjectOfType<ARTrackedImageManager>();

        scaler.onValueChanged.AddListener((e) =>
        {
            Anchor.GetChild(0).localScale = Vector3.one * e;
        });

    }


    private void OnEnable()
    {
        imageManager.trackedImagesChanged += ImageChanged;
    }

    private void OnDisable()
    {
        imageManager.trackedImagesChanged -= ImageChanged;
    }


    void ImageChanged(ARTrackedImagesChangedEventArgs args)
    {


        if (addToggle.isOn)
        {
            foreach (ARTrackedImage image in args.added)
            {
                UpdateImage(image);
            }

        }

        if (updateToggle.isOn)
        {
            foreach (ARTrackedImage image in args.updated)
            {
                UpdateImage(image);
            }
        }

    }

    private void UpdateImage(ARTrackedImage ARTracker)
    {
        debug.text = $"Track: {ARTracker.trackingState}";

        Anchor.position = ARTracker.transform.position;
        Anchor.rotation = ARTracker.transform.rotation;
    }

}

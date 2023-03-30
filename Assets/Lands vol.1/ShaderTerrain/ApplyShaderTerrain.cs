using UnityEngine;
using System.Collections;

public class ApplyShaderTerrain : MonoBehaviour {
	public GameObject DistanceStartFrom;
	private Texture diffuseFar;
	private Vector2 tilingdiffuseFar;
	private Texture normalVicina;
	private Vector2 tilingnormalVicina;
	private Texture normalLontana;
	private Vector2 tilingnormalLontana;
	private float DistanzaNormal;
	private float DistanzaBlend;
	private Material terrainMaterial;
	private Vector4 center;
	private Terrain loTerrain;
	// Use this for initialization
	void Start () {
		terrainMaterial = GetComponent<Material> ();
		loTerrain = Terrain.activeTerrain;


	}
	
	// Update is called once per frame
	void Update () {
		center.x = DistanceStartFrom.transform.position.x;
		center.y = DistanceStartFrom.transform.position.y;
		center.z = DistanceStartFrom.transform.position.z;
		loTerrain.materialTemplate.SetVector ("_CentrePoint",center);

	}
}

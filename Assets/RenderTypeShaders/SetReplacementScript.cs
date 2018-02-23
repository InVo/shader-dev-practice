using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetReplacementScript : MonoBehaviour {

    [SerializeField]
    private Shader _replacementShader;

    private bool _replaced = false;

	// Update is called once per frame
	void Update () {
		if (Input.GetKeyDown(KeyCode.Space))
        {
            if (!_replaced)
            {
                Camera.main.SetReplacementShader(_replacementShader, "RenderType");
            }
            else
            {
                Camera.main.ResetReplacementShader();
            }
            _replaced = !_replaced;
        }
	}
}

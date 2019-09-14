using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneController : MonoBehaviour
{
    [SerializeField]
    private List<string> _sceneList;

    private int _index = 0;

    private string _currentScene;

    private void Start()
    {
        DontDestroyOnLoad(this.gameObject);
    }

    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space))
        {
            _currentScene = _sceneList[_index];
            SceneManager.LoadScene(_currentScene);
            _index++;
            if(_index == _sceneList.Count)
            {
                _index = 0;
            }
        }
    }
}

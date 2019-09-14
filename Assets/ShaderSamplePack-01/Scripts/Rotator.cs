using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour
{
    [SerializeField]
    private float _speed = 10f;

    [SerializeField]
    private bool _enableDelayStart = true;

    [SerializeField]
    private float _delayTime = 3.0f;

    private bool _active = true;

    private void Start()
    {
        if (_enableDelayStart)
        {
            _active = false;
            StartCoroutine(DelayStart());
        }
    }

    private IEnumerator DelayStart()
    {
        yield return new WaitForSeconds(_delayTime);
        _active = true;
    }

    private void Update()
    {
        if(!_active)
        {
            return;
        }
        transform.Rotate(transform.up, Time.deltaTime * _speed);
    }
}

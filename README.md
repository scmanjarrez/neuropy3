# Description
Python3 library to read data from Neurosky Mindwave Mobile 2 in linux using
bluetooth.

**Contents:**
  - [Requirements](#requirements)
  - [Pre-execution](#pre-execution)
  - [Execution](#execution)
    - [Command line interface](#command-line-interface)
    - [Graphical user interface](#graphical-user-interface)
    - [Importing library](#importing-library)
  - [License](#license)

# Requirements
- libbluetooth-dev

# Pre-execution
You can install dependencies using setup.py
```bash
$ python -m pip install .
```
or install manually via pip
```bash
$ python -m pip install -r requirements.txt
```


# Execution
## Command line interface
```bash
$ python -m neuropy3
$ python -m neuropy3 --address XX:YY:ZZ:AA:BB:CC
$ python -m neuropy3 --address XX:YY:ZZ:AA:BB:CC --verbose 3
```
> Address argument helps speed up connection process, otherwise a neuropy3
> will run a scan of nearby bluetooth devices (which takes a lot).

## Graphical user interface
```bash
$ python -m neuropy3 --gui
$ python -m neuropy3 --address XX:YY:ZZ:AA:BB:CC --gui
```

## Importing library
```python
>>> from neuropy3.neuropy3 import MindWave
>>> mw = MindWave()
# mw = MindWave(address='XX:YY:ZZ:AA:BB:CC', verbose=3)
>> mw.update_callback('eeg', lambda x: print(x))
>> mw.update_callback('meditation', lambda x: print(x))
>> mw.update_callback('attention, lambda x: print(x))
```

# Acknowledgement

- Based on [lihas/NeuroPy](https://github.com/lihas/NeuroPy) library.

- Communication protocol from [neurosky](http://developer.neurosky.com/docs/doku.php?id=thinkgear_communications_protocol).

# License
    neuropy3  Copyright (C) 2022 Sergio Chica Manjarrez @ pervasive.it.uc3m.es.
    Universidad Carlos III de Madrid.
    This program comes with ABSOLUTELY NO WARRANTY; for details check below.
    This is free software, and you are welcome to redistribute it
    under certain conditions; check below for details.

[LICENSE](LICENSE)

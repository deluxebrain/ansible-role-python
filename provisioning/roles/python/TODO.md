# TODO

- Get rid of pyenv

    In the case where Python 3 is installed as python3 and Python 2 is not installed, pyenv does not work against the system python.

    A workaround is to link python to python3 ( note that an alias will not work ).

    `sudo ln -s /usr/bin/python3 /usr/bin/python`

- Get rid of pipenv

    Lock file creation is too slow.

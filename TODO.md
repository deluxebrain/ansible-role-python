# TODO

1. Molecule docker images

    By default, Molecule >= 3 no longer runs from a local Dockerfile.

    However - the official Ubuntu docker images do not come with Python installed.

    Need to create a lightweight Ubuntu image with Python and publish it to DockerHub.

    Until then, I have reverted to using the Dockerfile.j2 as taken from a pre-3.0 Molecule project.

2. Deadsnakes

    Single Python version using a specific Python version >= 3.3 using the `deadsnakes` PPA and venv

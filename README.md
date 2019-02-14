docker-tmate
============

Alpine Linux-based tmate-slave Docker service

This is based on the work of [Yann Hodique](https://github.com/sigma), but it had acquired some bit-rot due to changes from the [tmate-slave](https://github.com/tmate-io/tmate-slave) and [libssh](https://www.libssh.org/) projects.

# Details

This image must be run via the `--privileged` argument as tmate-slave requires two special capabilities: `CLONE_NEWIPC` and `CLONE_NEWNET`.

# Running

If you want to use it:
```
sudo docker run --privileged -p 2222 -t ktreadway/docker-tmate
```

The container will build new `tmate-slave` keys, provide some useful output, and start `tmate-slave`:
```
...
Add this to your /root/.tmate.conf file
-----------------------------------
set -g tmate-server-host 44e1e6d550d0
set -g tmate-server-port 2222
set -g tmate-server-rsa-fingerprint "c2:20:50:58:89:dd:a0:98:6b:6b:c7:c9:9d:e7:96:de"
set -g tmate-server-ecdsa-fingerprint "13:dd:6f:82:a0:04:12:9a:8f:4d:6b:a2:c8:a2:db:75"
set -g tmate-identity ""
-----------------------------------
<5> (tmate) Accepting connections on :2222
```

This will bind a random host port to the container's port 2222, but to know which port, run:
```
docker ps # this will show you the container id
docker port <container id> 2222
```

If you want to use it and expose it via a specific port, matching in this case:
```
sudo docker run --privileged -p 2222:2222 -t ktreadway/docker-tmate
```

# Additional Configuration

## Using existing keys

The keys for `tmate-slave` live in `/etc/tmate-keys` within the container.  It's probably not ideal to generate new SSH keys every time the container restarts.  The keys can be provided from outside the container and no new keys will be generated if they exist:
```
sudo docker run --privileged -v /etc/tmate-slave/keys:/etc/tmate-keys -p 2222:2222 -t ktreadway/docker-tmate
```

If you want to create new keys, they are standard RSA and ECDSA SSH keys.  They can be generated using the `create_keys.sh` script.

## Hostname

`tmate-slave` does report the hostname that it thinks it has automatically, but there are options to change it.

### Using the host's hostname

I've had success changing the [Docker UTS settings](https://docs.docker.com/engine/reference/run/#uts-settings---uts) to use the `host` namespace:
```
sudo docker run --privileged --uts host -p 2222:2222 -t ktreadway/docker-tmate
```

### Specifying the hostname

You can specify the hostname by passing in the `HOST` environment variable as an argument:
```
sudo docker run --privileged -e HOST=tmate.example.com -p 2222:2222 -t ktreadway/docker-tmate
```

## Port

If you need to change the port that `tmate-slave` listens on within the Docker container, you can pass in the `PORT` environment variable as an argument:
```
sudo docker run --privileged -e PORT=22000 -p 2222:22000 -t ktreadway/docker-tmate
```

# Building

If you want to build it:
```
docker build -t docker-tmate .
```

# TODO
* Better/easier configuration of libssh version.
* Better/easier configuration of tmate-slave branch/commit.
* Automated Docker testing?

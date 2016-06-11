# Unbound DNS Server Docker Image

## Supported tags and respective `Dockerfile` links

- [`1.5.8`, `latest` (*1.5.9/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.5.9)
- [`1.5.8`, (*1.5.8/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.5.8)
- [`1.5.7`, (*1.5.7/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.5.7)


## What is Unbound?

Unbound is a validating, recursive, and caching DNS resolver.
> [unbound.net](https://unbound.net/)

## How to use this image

### Standard usage

Run this container with the following command:

```console
docker run --name my-unbound -d -p 53:53/udp \
--restart=always mvance/unbound:latest
```

*For a DNS server with lots of short-lived connections, you may wish to consider
adding `--net=host` to the run command for performance reasons. However, it is
not required and some shared container hosting services may not allow it. You
should also be aware `--net=host` can be a security risk in some situations. The
[Center for Internet Security Docker 1.6
Benchmark](https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_1.6_Benchmark_v1.0.0.pdf)
recommends against this mode since it essentially tells Docker to not
containerize the container's networking, thereby giving it full access to the
host machine's network interfaces. It also mentions this option could cause the
container to do unexpected things such as shutting down the Docker host as
referenced in [Docker Issue #6401](https://github.com/docker/docker/issues/6401)
. For the most secure deployment, unrelated services with confidential data
should not be run on the same host or VPS. In such cases, using `--net=host`
should have limited impact on security.*

### Serve Custom DNS Records for Local Network

While Unbound is not a full authoritative name server, it supports resolving
custom entries on a small, private LAN. In other words, you can use Unbound to
resolve fake names such as your-computer.local within your LAN.

To support such custom entries using this image, you need to provide an
`a-records.conf` file. This conf file is where you will define your custom
entries for forward and reverse resolution.

The `a-records.conf` file should use the following format:

```
# A Record
  #local-data: "somecomputer.local. A 192.168.1.1"
  local-data: “laptop.local. A 192.168.1.2”

# PTR Record
  #local-data-ptr: "192.168.1.1 somecomputer.local."
  local-data-ptr: "192.168.1.2 laptop.local."
```

Once the file has your entries in it, mount your version of the file as a volume
when starting the container:

```console
docker run --name my-unbound -d -p 53:53/udp -v \
$(pwd)/a-records.conf:/opt/unbound/etc/unbound/a-records.conf:ro \
--restart=always mvance/unbound:latest
```

# Supported Docker versions

This image is tested on Docker version 1.11.2.

Use on older versions at your own risk.

# User feedback

## Documentation

Documentation for this image is stored right here in the [`README.md`](https://github.com/MatthewVance/unbound-docker/blob/master/README.md).

Documentation for Unbound is available on the [project's website](https://unbound.net/).

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/MatthewVance/unbound-docker/issues).
## Contributing

You are invited to contribute new features, fixes, or updates, large or small. I
imagine the upstream projects would be equally pleased to receive your
contributions.

Please familiarize yourself with the [repository's `README.md`
file](https://github.com/MatthewVance/unbound-docker/blob/master/README.md)
before attempting a pull request.

Before you start to code, I recommend discussing your plans through a [GitHub
issue](https://github.com/MatthewVance/unbound-docker/issues), especially for
more ambitious contributions. This gives other contributors a chance to point
you in the right direction, give you feedback on your design, and help you find
out if someone else is working on the same thing.
## Acknowledgments

The code in this image is heavily influenced by DNSCrypt server Docker image,
though the upstream projects most certainly also deserve credit for making this
all possible.
- [DNSCrypt server Docker image](https://github.com/jedisct1/dnscrypt-server-docker)
- [Docker](https://www.docker.com/)
- [LibreSSL](http://www.libressl.org/)
- [Unbound](https://unbound.nlnetlabs.nl/)

## Licenses
### License

Unless otherwise specified, all code is released under the MIT License (MIT).
See the [repository's `LICENSE`
file](https://github.com/MatthewVance/unbound-docker/blob/master/LICENSE) for
details.
### Licenses for other components

- DNSCrypt server Docker image: [ISC License](https://github.com/jedisct1/dnscrypt-server-docker/blob/master/LICENSE)
- Docker: [Apache 2.0](https://github.com/docker/docker/blob/master/LICENSE)
- Unbound: [BSD License](https://unbound.nlnetlabs.nl/svn/trunk/LICENSE)
- LibreSSL: [Various](http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/lib/libssl/src/LICENSE?rev=1.12&content-type=text/x-cvsweb-markup)


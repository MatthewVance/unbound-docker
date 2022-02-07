# Unbound DNS Server Docker Image

## Supported tags and respective `Dockerfile` links

- [`1.14.0`, `latest` (*1.14.0/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.14.0)
- [`1.13.2`, (*1.13.2/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.13.2)
- [`1.13.1`, (*1.13.1/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.13.1)
- [`1.13.0`, (*1.13.0/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.13.0)
- [`1.12.0`, (*1.12.0/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.12.0)
- [`1.11.0`, (*1.11.0/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.11.0)
- [`1.10.1`, (*1.10.1/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.10.1)
- [`1.10.0`, (*1.10.0/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.10.0)
- [`1.9.6`, (*1.9.6/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.9.6)
- [`1.9.5`, (*1.9.5/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.9.5)
- [`1.9.4`, (*1.9.4/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.9.4)
- [`1.9.3`, (*1.9.3/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.9.3)
- [`1.9.2`, (*1.9.2/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.9.2)
- [`1.9.1`, (*1.9.1/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.9.1)
- [`1.9.0`, (*1.9.0/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.9.0)
- [`1.8.3`, (*1.8.3/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.8.3)
- [`1.8.2`, (*1.8.2/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.8.2)
- [`1.8.1`, (*1.8.1/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.8.1)
- [`1.7.3`, (*1.7.3/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.7.3)
- [`1.6.8`, (*1.6.8/Dockerfile*)](https://github.com/MatthewVance/unbound-docker/tree/master/1.6.8)

## What is Unbound?

Unbound is a validating, recursive, and caching DNS resolver.
> [unbound.net](https://unbound.net/)

## How to use this image

### Standard usage

Run this container with the following command:

```console
docker run --name my-unbound -d -p 53:53/udp -p 53:53/tcp \
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
`a-records.conf` or `srv-records.conf` file.
This conf file is where you will define your custom
entries for forward and reverse resolution.

#### A records

The `a-records.conf` file should use the following format:

```
# A Record
  #local-data: "somecomputer.local. A 192.168.1.1"
  local-data: "laptop.local. A 192.168.1.2"

# PTR Record
  #local-data-ptr: "192.168.1.1 somecomputer.local."
  local-data-ptr: "192.168.1.2 laptop.local."
```

Once the file has your entries in it, mount your version of the file as a volume
when starting the container:

```console
docker run --name my-unbound -d \
-p 53:53/udp -p 53:53/tcp \
-v $(pwd)/a-records.conf:/opt/unbound/etc/unbound/a-records.conf:ro \
--restart=always mvance/unbound:latest
```

#### SRV records

The `srv-records.conf` file should use the following format:

```
# SRV records
# _service._proto.name. | TTL | class | SRV | priority | weight | port | target.
_etcd-server-ssl._tcp.domain.local.  86400 IN    SRV 0        10     2380 etcd-0.domain.local.
_etcd-server-ssl._tcp.domain.local.  86400 IN    SRV 0        10     2380 etcd-1.domain.local.
_etcd-server-ssl._tcp.domain.local.  86400 IN    SRV 0        10     2380 etcd-2.domain.local.
```

Run a container that use this SRV config file:
```console
docker run --name my-unbound -d \
-p 53:53/udp -p 53:53/tcp \
-v $(pwd)/srv-records.conf:/opt/unbound/etc/unbound/srv-records.conf:ro \
--restart=always mvance/unbound:latest
```

### Override default forward

By default, forwarders are configured to use Cloudflare and CleanBrowsing DNS. You can retrieve the configuration in the [1.10.0/forward-records.conf](1.10.0/forward-records.conf) file.

You can create your own configuration file and override the one placed in `/opt/unbound/etc/unbound/forward-records.conf` in the container.

Example `forward-records.conf`:
```
forward-zone:
  # Forward all queries (except those in cache and local zone) to
  # upstream recursive servers
  name: "."

  # my DNS
  forward-addr: 192.168.0.1@53#home.local
```

Once the file has your entries in it, mount your version of the file as a volume
when starting the container:

```console
docker run --name my-unbound -d -p 53:53/udp -p 53:53/tcp -v \
$(pwd)/forward-records.conf:/opt/unbound/etc/unbound/forward-records.conf:ro \
--restart=always mvance/unbound:latest
```


### Use a customized Unbound configuration

Instead of using this image's default configuration for Unbound, you may supply your own configuration. If your customized configuration is located at `/my-directory/unbound/unbound.conf`, pass `/my-directory/unbound` as a volume when creating your container:

```console
docker run --name=my-unbound \
--volume=/my-directory/unbound:/opt/unbound/etc/unbound/ \
--publish=53:53/tcp \
--publish=53:53/udp \
--restart=unless-stopped \
--detach=true \
mvance/unbound:latest
```

This will expose all files in `/my-directory/unbound/` to the container. As an alternate way to serve custom DNS records for any local zones, either place them directly in your `unbound.conf`, or place the local zones in a separate file and use Unbound's include directive within your `unbound.conf`:

```
include: /opt/unbound/etc/unbound/local-zone-unbound.conf
```

Your volume's contents might eventually look something like this:

```
/my-directory/unbound/
-- unbound.conf
-- local-zone-unbound.conf
-- secret-zone.conf
-- some-other.conf
```

Overall, this approach is very similar to the `a-records.conf` approach described above. However, by passing your unbound directory rather than a single file, you have more options for customizing and segmenting your Unbound configuration.

***Note:** Care has been taken in the image's default configuration to enable
security options so it is recommended to use it as a guide.*

### k3s usage

> The method described here is basic and I would not recommend it for larger environments atm.

In order to spin the deployment up use:

```
kubectl apply -f unbound-main-conf.yml -f other-files.yml ...
```

Remember when taking it down to use the reverse order in which you spun the deployment up.

Restarting:

```
kubectl rollout restart deployment dns 
```

An example deployment can be viewed [here](k8s/deployment.yml). It is not ready since you need to fill it with your
records and the main unbound configuration file.

> A fair warning: I am using not using a Service but hostPort, thus this is only a start. In theory one should not do 
> that in a production cluster.

> Additional warning: As per [this](https://kubernetes.io/docs/concepts/configuration/secret/) document the default
> secrets configuration is unencrypted per default. You are responsible to harden this yourself and should do so!

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
- [Docker](https://www.docker.com/)
- [DNSCrypt server Docker image](https://github.com/jedisct1/dnscrypt-server-docker)
- [OpenSSL](https://www.openssl.org/)
- [Unbound](https://unbound.nlnetlabs.nl/)

## Licenses

### License

Unless otherwise specified, all code is released under the MIT License (MIT).
See the [repository's `LICENSE`
file](https://github.com/MatthewVance/unbound-docker/blob/master/LICENSE) for
details.

### Licenses for other components

- Docker: [Apache 2.0](https://github.com/docker/docker/blob/master/LICENSE)
- DNSCrypt server Docker image: [ISC License](https://github.com/jedisct1/dnscrypt-server-docker/blob/master/LICENSE)
- LibreSSL: [Various](http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/lib/libssl/src/LICENSE?rev=1.12&content-type=text/x-cvsweb-markup)
- OpenSSL: [Apache-style license](https://www.openssl.org/source/license.html)
- Unbound: [BSD License](https://unbound.nlnetlabs.nl/svn/trunk/LICENSE)

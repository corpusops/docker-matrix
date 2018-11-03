# docker based matrix image

Dockerfile for installation of [matrix] open federated Instant Messaging and
VoIP communication server.

- [compose](https://github.com/corpusops/setups.matrix)
- [coturn](https://github.com/coturn/coturn)
- [matrix img](https://github.com/corpusops/docker-matrix)
- [matrix](https://matrix.org)
- [riot](https://github.com/corpusops/docker-riot)

# Configuration
To configure run the image with "generate" as argument. You have to setup the
server domain and a `/data`-directory. After this you have to edit the
generated homeserver.yaml file.

To get the things done, "generate" will create a own self-signed certificate.

> This needs to be changed for production usage.

Example:

    $ docker run -v /tmp/data:/data --rm -e SERVER_NAME=localhost -e REPORT_STATS=no corpusops/docker-matrix generate

# Start

For starting you need the port bindings and a mapping for the
`/data`-directory.

    $ docker run -d -p 8448:8448 -p 3478:3478 -v /tmp/data:/data corpusops/docker-matrix start

# Port configurations

## Matrix Homeserver

The following ports are used in the container for the Matrix server. You can use `-p`-option on
`docker run` to configure this part (eg.: `-p 443:8448`):
`8008,8448 tcp`


# Version information

To get the installed synapse version you can run the image with `version` as
argument or look at the container via cat.

    $ docker run -ti --rm corpusops/docker-matrix version
    -=> Matrix Version
    synapse: master (7e0a1683e639c18bd973f825b91c908966179c15)

    # docker exec -it CONTAINERID cat /synapse.version
    synapse: master (7e0a1683e639c18bd973f825b91c908966179c15)

# Environment variables

* `SERVER_NAME`: Server and domain name, mandatory, needed only  for `generate`
* `REPORT_STATS`: statistic report, mandatory, values: `yes` or `no`, needed
  only for `generate`
* `MATRIX_UID`/`MATRIX_GID`: UserID and GroupID of user within container which
  runs the synapse server. The files mounted under /data are `chown`ed to this
  ownership. Default is `MATRIX_UID=991` and `MATRIX_GID=991`. It can overriden
  via `-e MATRIX_UID=...` and `-e MATRIX_GID=...` at start time.

# build specific arguments

* `BV_SYN`: synapse version, optional, defaults to `master`

For building of synapse version v0.11.0-rc2 with commit a9fc47e add
`--build-arg BV_SYN=v0.11.0-rc2 to the `docker
build` command.

# diff between system and fresh generated config file

To get a hint about new options etc you can do a diff between your configured
homeserver.yaml and a newly created config file. Call your image with `diff` as
argument.


```
$ docker run --rm -ti -v /tmp/data:/data corpusops/docker-matrix diff
[...]
+# ldap_config:
+#   enabled: true
+#   server: "ldap://localhost"
+#   port: 389
+#   tls: false
+#   search_base: "ou=Users,dc=example,dc=com"
+#   search_property: "cn"
+#   email_property: "email"
+#   full_name_property: "givenName"
[...]
```

For generating of this output its `diff` from `busybox` used. The used diff
parameters can be changed through `DIFFPARAMS` environment variable. The
default is `Naur`.


# Exported volumes

* `/data`: data-container


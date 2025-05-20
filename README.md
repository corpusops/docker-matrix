
DISCLAIMER - ABANDONED/UNMAINTAINED CODE / DO NOT USE
=======================================================
While this repository has been inactive for some time, this formal notice, issued on **December 10, 2024**, serves as the official declaration to clarify the situation. Consequently, this repository and all associated resources (including related projects, code, documentation, and distributed packages such as Docker images, PyPI packages, etc.) are now explicitly declared **unmaintained** and **abandoned**.

I would like to remind everyone that this project’s free license has always been based on the principle that the software is provided "AS-IS", without any warranty or expectation of liability or maintenance from the maintainer.
As such, it is used solely at the user's own risk, with no warranty or liability from the maintainer, including but not limited to any damages arising from its use.

Due to the enactment of the Cyber Resilience Act (EU Regulation 2024/2847), which significantly alters the regulatory framework, including penalties of up to €15M, combined with its demands for **unpaid** and **indefinite** liability, it has become untenable for me to continue maintaining all my Open Source Projects as a natural person.
The new regulations impose personal liability risks and create an unacceptable burden, regardless of my personal situation now or in the future, particularly when the work is done voluntarily and without compensation.

**No further technical support, updates (including security patches), or maintenance, of any kind, will be provided.**

These resources may remain online, but solely for public archiving, documentation, and educational purposes.

Users are strongly advised not to use these resources in any active or production-related projects, and to seek alternative solutions that comply with the new legal requirements (EU CRA).

**Using these resources outside of these contexts is strictly prohibited and is done at your own risk.**

This project has been transfered to Makina Corpus <freesoftware-corpus.com> ( https://makina-corpus.com ). This project and its associated resources, including published resources related to this project (e.g., from PyPI, Docker Hub, GitHub, etc.), may be removed starting **March 15, 2025**, especially if the CRA’s risks remain disproportionate.

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


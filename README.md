# Alma Webhook Service

- [Auditing Secrets](#auditing-secrets)
- [Docker](#docker)

## Auditing Secrets

You can use [Gitleaks](https://github.com/upenn-libraries/gitleaks) to check the repository for unencrypted secrets that have been committed.

```
docker run --rm --name=gitleaks -v $PWD:/code quay.io/upennlibraries/gitleaks:v1.23.0 -v --repo-path=/code --repo-config
```

Any leaks will be logged to `stdout`. You can add the `--redact` flag if you do not want to log the offending secrets.

## Docker

This docker image is built from the [Official Docker Image](https://hub.docker.com/_/ruby) and uses the build arguments `IMAGE_DISTRO` and `RUBY_VERSION` to define the image tag to pull. See the additional build arguments, along with their descriptions and defaults, and build/run instructions below.

| Build Arg    | Default    | Description                                                                                                                |
| ------------ | ---------- | -------------------------------------------------------------------------------------------------------------------------- |
| APP_ENV      | production | The environment to build the image. If set to `development` the build will install gems in the development and test groups |
| IMAGE_DISTRO | alpine     | The Linux distribution used to create the image                                                                            |
| RAILS_ROOT   | /home/app  | The project location                                                                                                       |
| RUBY_VERSION | 2.5.1      | The ruby version used to create the image                                                                                  |

### Building an image

To build an image for production run the following command from the project's root dir:

```
docker build -t alma-webhook .
```

To build an image for development or testing set the build argument `APP_ENV=development`:

```
docker build --build-arg APP_ENV=development -t alma-webhook .
```

### Running a container

After the image has been built a container can be run by using the following command:

```
docker run -d alma-webhook
```

By default the container will accept connections on port 3000. If necessary you can forward traffic from a different port on the host by passing the `p` flag followed by the `host-port:container-port` configuration:

```
docker run -d -p 80:3000 alma-webhook
```

To run the container in a development environment map the project dir into the container and include the env variables `APP_UID` and `APP_GID` when running:

```
docker run -d -v ${PWD}:/home/app -e APP_UID=$(id -u) -e APP_GID=$(id -g) alma-webhook
```

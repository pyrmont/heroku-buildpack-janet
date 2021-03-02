# Heroku Buildpack for Janet

This is a buildpack for deploying applications written in Janet to Heroku.

It features:

- easy configuration with the `janet_buildpack.config` file
- caching of jpm dependencies and downloads

## Usage

```shell
# Creating a Heroku app with this buildpack
$ heroku create --buildpack pyrmont/janet

# Setting the buildpack for an existing Heroku app
$ heroku buildpacks:set pyrmont/janet

# Using the latest version of the buildpack
$ heroku buildpacks:set https://github.com/pyrmont/heroku-buildpack-janet.git
```

Your app will need its own [Procfile][].

[Procfile]: https://devcenter.heroku.com/articles/procfile

Your `project.janet` file must be configured to create an executable that will
be launched by Heroku. This can be done using the `declare-executable` macro.
Your Procfile then needs to be configured to launch this executable.

### Example

An example project is available [here][hello-janet].

[hello-janet]: https://github.com/pyrmont/hello-janet

### Version Pinning

The methods above always use the latest version of the buildpack. To use a
specific version of the buildpack, choose a commit from the [commits][] page.
The commit SHA forms part of your buildpack URL.

[commits]: https://github.com/pyrmont/heroku-buildpack-janet/commits/master

```shell
$ heroku buildpacks:set https://github.com/pyrmont/heroku-buildpack-janet.git#<SHA>
```

**It is recommended** that you use a buildpack URL with a commit SHA on production
apps. This prevents the unpleasant moment when your Heroku build fails because
the buildpack you use just got updated with a breaking change.

## Configuration

You can configure this buildpack by creating a `janet_buildpack.config` file in
your app's root directory. The file's syntax is bash.

If you don't specify a config option, then the default option from the
buildpack's [`janet_buildpack.config`][config] file will be used.

[config]: https://github.com/pyrmont/heroku-buildpack-janet/blob/master/janet_buildpack.config

The current configuration options:

```shell
# Janet version
janet_version=1.15.3

# Rebuild from scratch on every deploy
always_rebuild=false
```

## Credits

This buildpack is based on the [Elixir buildpack][elixir-bp]. Special thanks to
Akash Manohar and contributors.

[elixir-bp]: https://github.com/HashNuke/heroku-buildpack-elixir

## Version

The latest version is v1.0.0.

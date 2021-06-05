# NWSync Dockerfile

This repo contains a sample dockerfile that will build the most recent NWSync version into a docker image.  The resulting image can be used to run NWSync against NWN server resources to create manifests for the NWSync file service.

This dockerfile requires no local files to build the image.  The Beamdog NWSync repo is downloaded from GitHub as part of the build.  This allows the dockerfile to be built by using only the dockerfile itself as the build context.
```
docker build - < Dockerfile -t <user>/<image>:<tag>
```
>This syntax will cause an error if using Windows PowerShell; use Git Bash instead.

The generic Docker command required to run this image is:
```
docker run --rm -it -v <nwsync volume> -v <resources volume> <user>/<image>:<tag> <root> <resources>
```

## Volumes
Once built, the image contains two volumes to access local data:

* For manifests and manifest data -> `/nwsync`
* For custom content resources -> `/resources`

>The following examples use sample pathing that may not correspond to your server setup.  Each volume consists of a path pair separated by a colon.  The left side should your absolute path; the right side is the absolute path within the image.  Do not change the path on the right.

Set the NWSync server's public file location to `/nwsync`
```
    -v /var/www/nwsync/:/nwsync
```
Set the game server's directory to `/resources`
```
    -v /home/nwn/server/:/resources
```
## Image Tag
When building the dockerfile, you can set any `<user>/<image>:<tag>` combination you'd like.  Not all components are required.  It could be as simple as as a single word.  However, once the image is built, you have to know the tag you designated in order to run the docker container via the command line.  Failing to establish a tag during the build process will make it very difficult to use the image.

## Root
`<root>` designates the primary working path for building manifests and holding resource data for NWSync file service.  This should always be `/nwsync` as it refers to the working path within the image.

## Resources
`<resources>` is a list of files to be manifested by nwsync and should be relative to the image's `resources` volume.  For example, if you set your `<resources volume>` to be the server's data folder, you could designate the server's module file (.mod) as the container to derive all data from -> `/resources/modules/<my-server-name>.mod`

## Complete Examples

> Sample paths are used below for illustration purposes.  Replace them with your absolute paths.

* NWSync Volume -> /var/www/nwsync
* NWN Server -> /home/nwn/server
* Image Tag -> tinygiant/nwsync:latest
* Module Name -> my_test_module.mod

To run nwsync_write against all the haks/tlk in the module:
```
docker run --rm -it -v /var/www/nwsync/:/nwsync -v /home/nwn/server/:/resources tinygiant/nwsync:latest /nwsync /resources/modules/my_test_module.mod
```
You can also run nwsync_write against a folder of loose files (not in a hak/tlk).  As an examples, let's say all your loose files are held in `/usr/my-loose-files`:
```
docker run --rm -it -v /var/www/nwsync/:/nwsync -v /usr/my-loose-files:/resources tinygiant/nwsync:latest /nwsync /resources
```
To run nwsync_write against a specific resource file called `mytesthak.hak` held in the server hak folder:
```
docker run --rm -it -v /var/www/nwsync/:/nwsync -v /home/nwn/server/:/resources tinygiant/nwsync:latest /nwsync /resources/mytesthak.hak
```
To run a different executable, such as nwsync_prune, add an entrypoint override along with appropriate arguments:
```
--entrypoint nwsync_prune
--entrypoint nwsync_print
```

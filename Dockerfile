# This Dockerfile does not use any local files for the
# build process, so you can send the file as context:
#   docker build - < Dockerfile -t <user>/<images>:<tag>

# If on Windows, recommend using Git Bash instead of
# PowerShell to eliminate Docker `future use` errors

# NWSync is written in nim, so start from nim.
FROM nimlang/nim:alpine

# We're also going to need git and ssh to download the
# nwsync repo so we can build the image.  Additionally,
# neverwinter.nim requires pcre to function correctly.
# Bash is just for convenience.
RUN apk add --no-cache \ 
    git \
    openssh \
    bash \
    pcre

# Create parallel directory structures, one for the nwsync
# data and one for the game resources used to build manifests
RUN bash -c "mkdir -pv /nwsync/{manifests,data}"
RUN bash -c "mkdir -pv /resources/{modules,hak,tlk}"

# Clonse the nwsync repo.
RUN git clone https://github.com/Beamdog/nwsync.git /nwsync-bin --depth 1

# Build the nwsync application.  neverwinter.nim is the major
# dependency of this install.  Expect the entire build to take 
# just under 10 minutes to complete, with neverwinter.nim taking
# about 97% of that time.
WORKDIR /nwsync-bin
RUN nimble build -d:release -y

# The following executables now exist in /nwsync-bin/bin
# > nwsync_print
# > nwsync_prune
# > nwsync_write

# To make it easy to get to the executables, modify the
# PATH environmental variable to add the executables' folder.
ENV PATH="/nwsync-bin/bin:$PATH"

ENTRYPOINT [ "nwsync_write" ]
CMD [ "--help" ]

# Sample calls to run this setup:
# 
#   > Server Folder is /home/nwn/server
#   > NWSync Folder is /var/www/nwsync
#   > Image is <user>/<image>:latest
#
# To run nwsync_write against all the haks/tlk in the module:
#   docker run --rm -it -v /var/www/nwsync/:/nwsync -v /home/nwn/server/:/resources
#           <user>/<image>:latest /nwsync /resources/modules/<module_name>.mod
#
# To run nwsync_write against a directory of individual resource files:
#   docker run --rm -it -v /var/www/nwsync/:/nwsync -v /<path>/:/resources
#	    <user>/<image>:latest /nwsync /resources
#
# To run nwsync_write against a specific resource file:
#   docker run --rm -it -v /var/www/nwsync/:/nwsync -v /<path>/:/resources
#	    <user>/<image>:latest /nwsync /resources/<filename>.<ext>
#
# To run a different executable, such as nwsync_prune, add an entrypoint override:
#   --entrypoint nwsync_prune
#	along with the appropriate arguments

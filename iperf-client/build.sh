#!/bin/bash
buildah bud -f Dockerfile -t quay.io/randomparity/iperf-client . && \
buildah push quay.io/randomparity/iperf-client

#!/bin/bash
	buildah bud -f Dockerfile -t quay.io/randomparity/iperf-server .
	buildah push quay.io/randomparity/iperf-server

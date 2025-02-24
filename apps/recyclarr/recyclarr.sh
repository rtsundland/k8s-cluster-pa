#!/usr/bin/env bash

kubectl -n recyclarr exec -ti service/recyclarr -c recyclarr -- recyclarr $*

#!/bin/bash

service eventstore stop
rm -r /var/lib/eventstore/*
service eventstore start
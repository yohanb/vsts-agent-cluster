#!/bin/bash

service mongod stop
rm -r /var/lib/mongodb/*
service mongod start
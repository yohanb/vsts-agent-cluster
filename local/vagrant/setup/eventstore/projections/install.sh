#!/bin/bash

curl -i --data-binary "@/vagrant/setup/eventstore/projections/app-all-projection.js" http://localhost:2113/projections/continuous?name=app-all-projection%26type=js%26enabled=true%26emit=true%26trackemittedstreams=true -u admin:changeit
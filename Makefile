.PHONY: all influxdb influxdb-build influxdb-clean deploy devel

PWD=$(shell pwd)
.DEFAULT_GOAL := all

INFLUXDB_TAG  := monitoring-influxdb:0.13.0

REPO_URL := undergreen

influxdb-build:
	$(MAKE) -C $(PWD)/influxdb -e TARGET=influxd TARGETDIR=influxdb -f $(PWD)/buildbox.mk

influxdb-clean:
	$(MAKE) -C $(PWD)/influxdb clean

influxdb: influxdb-build
	docker build --pull -t $(INFLUXDB_TAG) $@

all: influxdb

clean: influxdb-clean

.PHONY: deploy
deploy:
	$(foreach ct,$(INFLUXDB_TAG), \
		docker tag $(ct) $(REPO_URL)/$(ct) ; \
		docker push $(REPO_URL)/$(ct) ; )

.PHONY: devel
devel:
	helm package influxdb
	helm repo index ./
	helm serve --repo-path ./

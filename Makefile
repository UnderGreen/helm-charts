.PHONY: all influxdb influxdb-build influxdb-clean \
	heapster heapster-build heapster-clean deploy devel

PWD=$(shell pwd)
.DEFAULT_GOAL := all

INFLUXDB_TAG  := monitoring-influxdb:0.13.0
HEAPSTER_TAG  := monitoring-heapster:1.0.2

REPO_URL := undergreen

influxdb-build:
	$(MAKE) -C $(PWD)/influxdb -e TARGET=influxd TARGETDIR=influxdb -f $(PWD)/buildbox.mk

influxdb-clean:
	$(MAKE) -C $(PWD)/influxdb clean

influxdb: influxdb-build
	docker build --pull -t $(INFLUXDB_TAG) $@

heapster-build:
	$(MAKE) -C $(PWD)/heapster -e TARGET=heapster TARGETDIR=heapster -f $(PWD)/buildbox.mk

heapster-clean:
	$(MAKE) -C $(PWD)/heapster -f Makefile clean

heapster: heapster-build
	docker build --pull -t $(HEAPSTER_TAG) $@

all: influxdb heapster

clean: influxdb-clean heapster-clean

.PHONY: deploy
deploy:
	$(foreach ct,$(INFLUXDB_TAG) $(HEAPSTER_TAG), \
		docker tag $(ct) $(REPO_URL)/$(ct) ; \
		docker push $(REPO_URL)/$(ct) ; )

.PHONY: devel
devel:
	$(foreach pkg,influxdb heapster, \
		helm package $(pkg) ; )
	helm repo index ./
	helm serve --repo-path ./

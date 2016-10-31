FROM quay.io/gravitational/debian-tall:0.0.1

ENV INFLUXDB_HOME /influxdb
ENV PATH $INFLUXDB_HOME:$PATH

# admin, http, udp, cluster, graphite, opentsdb, collectd
EXPOSE 8083 8086 8086/udp 8088 2003 4242 25826

RUN mkdir -p $INFLUXDB_HOME /data

ADD build/influx* $INFLUXDB_HOME/

ENTRYPOINT ["/influxdb/influxd"]

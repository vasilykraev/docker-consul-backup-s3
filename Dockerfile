# Alpine 3.7 is current latest
FROM consul:1.4.2

ENV AWS_CLI_VERSION=1.15.40

RUN apk --update --no-cache add \
    python \
    py-pip \
    jq \
    bash \
    && pip install --no-cache-dir awscli==$AWS_CLI_VERSION \
    && pip install --no-cache-dir awscli \
    && apk del py-pip

RUN rm -rf /var/cache/apk/* /root/.cache/pip/* /usr/lib/python2.7/site-packages/awscli/examples

ADD consul-backup /usr/bin/consul-backup
RUN chmod +x /usr/bin/consul-backup

# Expose .aws to mount config/credentials
VOLUME /root/.aws

# Expose workspace to mount stuff
VOLUME /workspace
WORKDIR /workspace

ENTRYPOINT ["/usr/bin/consul-backup"]

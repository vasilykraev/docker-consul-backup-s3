# Alpine 3.13 is current latest
FROM consul:1.10

ENV AWS_CLI_VERSION=1.22.72

RUN apk --update --no-cache add \
    python3 \
    py3-pip \
    jq \
    bash \
    && pip install --no-cache-dir awscli==$AWS_CLI_VERSION \
    && pip3 install --no-cache-dir awscli \
    && apk del py3-pip \
    && rm -rf /var/cache/apk/* /root/.cache/pip/* /usr/lib/python3/site-packages/awscli/examples

#ADD consul-backup /usr/bin/consul-backup
#RUN chmod +x /usr/bin/consul-backup

# Expose .aws to mount config/credentials
VOLUME /root/.aws

# Expose workspace to mount stuff
VOLUME /workspace
WORKDIR /workspace

ENTRYPOINT ["/usr/bin/consul-backup"]

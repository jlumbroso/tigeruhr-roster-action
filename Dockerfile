FROM alpine:3.16

# Install recent versions of `git' and `ssh'
# (with --no-cache the package index is not stored locally, keeping the container small)
# https://stackoverflow.com/a/49119046/408734 

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/community" >> /etc/apk/repositories \
        & cat /etc/apk/repositories

RUN rm -rf /var/cache/apk/* \
        & apk update \
        & apk add --update --no-cache git openssh \
        # python3 and pip from community repo
        # REF: https://stackoverflow.com/a/65365149/408734
        & apk add --update --no-cache python3 py3-pip \
        # openssl + python headers for python-ldap
        # REF: https://stackoverflow.com/a/59580230
        & apk add --update --no-cache openldap-dev python3-dev

RUN rm -rf /var/cache/apk/* \
        & apk update \
        & pip install --upgrade pip \
        & pip install pipenv \
        & pipenv install --dev --deploy

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

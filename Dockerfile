FROM minio/mc:RELEASE.2022-05-04T06-07-55Z

COPY README.md /
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Code Backup on AWS S3
A GitHub action to mirror a repository to S3 compatible object storage.

## Usage
This example will mirror your repository to an S3 bucket called `repo-backup-bucket` and at the optional key `/at/some/path`. Objects at the target will be overwritten, and extraneous objects will be removed. This default usage keeps your S3 backup in sync with GitHub.
```yml
    - name: S3 Backup
      uses: peter-evans/s3-backup@v1
      env:
        ACCESS_KEY_ID: ${{ secrets.ACCESS_KEY_ID }}
        SECRET_ACCESS_KEY: ${{ secrets.SECRET_ACCESS_KEY }}
        MIRROR_TARGET: repo-backup-bucket/at/some/path
      with:
        args: --overwrite --remove
```
S3 Backup uses the `mirror` command of [MinIO Client](https://github.com/minio/mc).
Additional arguments may be passed to the action via the `args` parameter.
#### Secrets and environment variables
The following variables may be passed to the action as secrets or environment variables. `MIRROR_TARGET`, for example, if considered sensitive should be passed as a secret.
- `ACCESS_KEY_ID` (**required**) - The storage service access key id.
- `SECRET_ACCESS_KEY` (**required**) - The storage service secret access key.
- `MIRROR_TARGET` (**required**) - The target bucket, and optionally, the key within the bucket.
- `MIRROR_SOURCE` - The source defaults to the repository root. If required a path relative to the root can be set.
- `STORAGE_SERVICE_URL` - The URL to the object storage service. Defaults to `https://s3.amazonaws.com` for Amazon S3.
- `STORAGE_SERVICE_ALIAS` - Defaults to `s3`. See [MinIO Client](https://github.com/minio/mc) for other options such as S3 compatible `minio`, and `gcs` for Google Cloud Storage.
  

#### IAM user policy
The IAM user associated with the `ACCESS_KEY_ID` and `SECRET_ACCESS_KEY` should have `s3:*` policy access.
If required you can create a policy to restrict access to specific resources.
The following policy grants the user access to the bucket `my-restricted-bucket` and its contents.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowBucketStat",
            "Effect": "Allow",
            "Action": [
                "s3:HeadBucket"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowThisBucketOnly",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::my-restricted-bucket/*",
                "arn:aws:s3:::my-restricted-bucket"
            ]
        }
    ]
}
```
## Complete workflow example
The workflow below filters `push` events for the `master` branch before mirroring to S3.
```yml
name: Mirror repo to S3
on:
  push:
    branches:
      - master
jobs:
  s3Backup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: S3 Backup
        uses: orxagridrepo/action-code-backup@main
        env:
          ACCESS_KEY_ID: ${{ secrets.ACCESS_KEY_ID }}
          MIRROR_TARGET: ${{ secrets.MIRROR_TARGET }}
          SECRET_ACCESS_KEY: ${{ secrets.SECRET_ACCESS_KEY }}
        with:
          args: --overwrite --remove
```
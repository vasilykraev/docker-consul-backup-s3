# consul-backup-s3
Docker container to backup consul and upload it to amazon S3

[![](https://badge.imagelayers.io/giovannicandido/consul-backup-s3:latest.svg)](https://imagelayers.io/?images=giovannicandido/consul-backup-s3:latest 'Get your own badge on imagelayers.io')
[![Docker Registry](https://img.shields.io/docker/pulls/giovannicandido/consul-backup-s3.svg)](https://registry.hub.docker.com/u/giovannicandido/consul-backup-s3)&nbsp;


Info/Usage
-----

```
Backups consul to a s3 bucket. You must provide all 4 arguments

Usage: consul-backup -m backup -h http://127.0.0.1:8500 -b s3://somebucket/backups/ -p prefix
Usage: consul-backup -m restore -h http://127.0.0.1:8500 -b s3://somebucket/backups/ -f prefix-2019-03-09_01:39.snap

Parameters:

-m backup | restore - Operation mode 
-h | --host     - The Consul Host Address
-b | --s3bucket  - The s3 bucket path to use, no trailing slash
-p | --prefix  - The prefix for the filename. Don't use with -f
-f | --filename - The full filename to restore. Don't use with -p
```

Running the container
----------------------
```
docker run giovannicandido/consul-backup-s3 -m backup -h consul.server -p prefix -b s3://somebucketname
```

To provide AWS credentials mount your .aws folder and/or set your environment
variables as needed. If you are running this inside ec2 this won't be needed
if the instance has the correct permissions to access s3.

```
docker run  -v ~/.aws:/root/.aws giovannicandido/consul-backup-s3 -m backup -h consul.server -p prefix -b s3://somebucketname
```

## Kubernetes usage

Create a secret:

```
kubectl create secret generic consul-backup-aws --from-file=./.aws/config --from-file=./.aws/credentials
```

How to create a restore job:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: consul-restore
spec:
  template:
    spec:
      containers:
      - name: consul-backup
        image: giovannicandido/consul-backup-s3
        args:
          - -m 
          - restore
          - -h
          - http://192.168.0.11:8500
          - -f
          - prefix-2019-03-09_01:39.snap
          - -b 
          - s3://my-bucket/backups
        volumeMounts:
          - name: aws-credentials
          mountPath: /root/.aws
          readOnly: true
      volumes:
      - name: aws-credentials
        secret:
          secretName: consul-backup-aws
      restartPolicy: OnFailure
  backoffLimit: 4  
```

How to create a single backup Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: consul-restore
spec:
  template:
    spec:
      containers:
      - name: consul-backup
        image: giovannicandido/consul-backup-s3
        args:
          - -m 
          - backup
          - -h
          - http://192.168.0.11:8500
          - -f
          - prefix
          - -b 
          - s3://my-bucket/backups
        volumeMounts:
          - name: aws-credentials
          mountPath: /root/.aws
          readOnly: true
      volumes:
      - name: aws-credentials
        secret:
          secretName: consul-backup-aws
      restartPolicy: OnFailure
  backoffLimit: 4  
```

How to create a Cron backup job

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: consul-backup
spec:
  schedule: "0 * * * *" # every hour
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: consul-backup
            image: giovannicandido/consul-backup-s3
            args:
              - -m 
              - backup
              - -h
              - http://192.168.0.11:8500
              - -p
              - test 
              - -b 
              - s3://my-bucket/backups
            volumeMounts:
            - mountPath: /root/.aws
              name: aws-credentials
              readOnly: true
          volumes:
          - name: aws-credentials
            secret:
              secretName: consul-backup-aws
          restartPolicy: OnFailure
      backoffLimit: 4  
```

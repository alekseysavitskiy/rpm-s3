FROM centos:7
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION=eu-central-1
ARG BUCKET
ARG REPOPATH=rpm/centos7/master

ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
ENV BUCKET=${BUCKET}
ENV REPOPATH=${REPOPATH}

RUN yum -y update && \
    yum install -y deltarpm python-deltarpm rpm-sign && \
    yum clean all && \
    curl "https://bootstrap.pypa.io/get-pip.py" | python

ADD . /rpm-s3
WORKDIR /rpm-s3
RUN pip install -r requirements.txt

RUN "mkdir -p ${BUCKET}"
RUN "aws s3 sync s3://${BUCKET}/${REPOPATH}/ ./${BUCKET}/"
RUN "rm -rf ./${BUCKET}/repodata"
RUN "aws s3 sync --delete s3://${BUCKET}/${REPOPATH}/ ./${BUCKET}/"
RUN "/rpm-s3/bin/rpm-s3 -b ${BUCKET} -r ${AWS_DEFAULT_REGION} --repopath ${REPOPATH} --visibility public-read --verbose ${BUCKET}/*.rpm"
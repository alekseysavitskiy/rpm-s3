FROM centos:7

RUN yum -y update && \
    yum install -y deltarpm python-deltarpm rpm-sign && \
    yum clean all && \
    curl "https://bootstrap.pypa.io/get-pip.py" | python

ADD . /rpm-s3
WORKDIR /rpm-s3
RUN pip install -r requirements.txt


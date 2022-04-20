FROM python:3.9

ENV TERRAFORM_VERSION=1.0.7

RUN apt-get update && apt-get -y upgrade
RUN apt-get install git

RUN pip3 install awscli


ENV TF_DEV=true
ENV TF_RELEASE=true
ENV TF_VAR_SNOWFLAKE_ACCOUNT=""
ENV TF_VAR_SNOWFLAKE_USER_UM=
ENV TF_VAR_SNOWFLAKE_ROLE_UM=USERADMIN
ENV TF_VAR_SNOWFLAKE_PASS_UM=""
ENV TF_VAR_SNOWFLAKE_USER_OPS=
ENV TF_VAR_SNOWFLAKE_ROLE_OPS=SYSADMIN
ENV TF_VAR_SNOWFLAKE_PASS_OPS=""
ENV TF_VAR_SNOWFLAKE_USER_DDL=
ENV TF_VAR_SNOWFLAKE_ROLE_DDL=SYSADMIN
ENV TF_VAR_SNOWFLAKE_PASS_DDL=""
ENV TF_VAR_database_name=""
ENV TF_VAR_schema_name=""
ENV TF_VAR_snowpipe_user=""
ENV TF_VAR_AWS_ACCESS_KEY_ID=""
ENV TF_VAR_AWS_SECRET_ACCESS_KEY=""
ENV TF_VAR_AWS_DEFAULT_REGION="us-east-1"

COPY . /opt/src/

RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

WORKDIR /opt/src/terraform

CMD ["/bin/bash"]

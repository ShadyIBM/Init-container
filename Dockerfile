# Dockerfile for building the B2BI Init Container ONLY

FROM registry.access.redhat.com/ubi8/ubi:8.7

# Pinning the aws java sdk version to 1.12.487

ARG AWS_JAVA_SDK_VERSION=1.12.487

# Let's set the correct runtime user & group

ARG USER_NAME=b2biuser
ARG USER_ID=1010
ARG GROUP_NAME=b2bigroup
ARG GROUP_ID=1010

# Create directories

RUN mkdir -p /resources
RUN mkdir -p /ibm/resources

# Patch curl, libcurl & libarchive

RUN mkdir -p /resources/aws \
    && groupadd -g ${GROUP_ID} ${GROUP_NAME} \
    && adduser -l -r -u ${USER_ID} -m -d /home/${USER_NAME} -s /sbin/nologin -c "B2BI user" -g ${GROUP_NAME} ${USER_NAME} \
    && chmod 755 /home/${USER_NAME} \
    && chown ${USER_NAME}:${GROUP_NAME} /resources \
    && yum upgrade -y --disableplugin=subscription-manager curl libcurl libarchive platform-python python3-libs \
    && yum -y clean all

# Adding db driver jar

COPY ./db2/db2jcc4.jar /resources

# Adding SEAS integration jars
# COPY ./seas/*.jar /resources/seas

# Adding AWS JAVA SDK & Third-Party jars

COPY ./awssdk/*.jar /resources/aws

# Curl the aws java sdk zip file and unzip the main jar file only
# (because it's too big to store with the repo on github.ibm.com)
# RUN curl https://sdk-for-java.amazonwebservices.com/aws-java-sdk-${AWS_JAVA_SDK_VERSION}.zip -O /tmp/aws-java-sdk.zip \ 
#     && mkdir /resources/aws
# RUN curl 'https://sdk-for-java.amazonwebservices.com/aws-java-sdk-1.12.487.zip' -O /tmp/aws-java-sdk.zip \
#     && mkdir /resources/aws
#
# RUN unzip -j /tmp/aws-java-sdk.zip aws-java-sdk-1.12.487/lib/aws-java-sdk-1.12.487.jar -d /resources/aws \
#     && rm /tmp/aws-java-sdk.zip

# Add any other required resources to the same location

USER ${USER_ID}

ENTRYPOINT [“sh”, “-c”, “cp -rv /resources/* /ibm/resources”]

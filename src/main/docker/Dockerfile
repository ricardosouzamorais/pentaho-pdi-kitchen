##################################################################################################
# Layer to download an uncompress needed files
##################################################################################################
FROM debian:11-slim as downloader

RUN apt-get update && \
        apt-get install -y unzip

WORKDIR /app

RUN mkdir -p /app/download

ARG DOWNLOAD_FILE_PATH=/app/download
ARG PENTAHO_INSTALLER_NAME=pdi-ce
ARG PENTAHO_VERSION=9.4.0.0
ARG PENTAHO_PACKAGE_DIST=343
ARG PENTAHO_FULL_VERSION=${PENTAHO_VERSION}-${PENTAHO_PACKAGE_DIST}
ARG PENTAHO_FILE_SOFTWARE=${PENTAHO_INSTALLER_NAME}-${PENTAHO_VERSION}-${PENTAHO_PACKAGE_DIST}.zip
ARG PENTAHO_SOURCE_URL_DOWNLOAD=https://privatefilesbucket-community-edition.s3.us-west-2.amazonaws.com/${PENTAHO_FULL_VERSION}/ce/client-tools/${PENTAHO_FILE_SOFTWARE}
ARG PENTAHO_FILE_DOWNLOAD_PATH=${DOWNLOAD_FILE_PATH}/${PENTAHO_FILE_SOFTWARE}
ARG PENTAHO_DECOMPRESSED_ORIGIN_FILE_PATH=${DOWNLOAD_FILE_PATH}/data-integration
ARG PENTAHO_DECOMPRESSED_DESTINY_FILE_PATH=${DOWNLOAD_FILE_PATH}/pdi-ce
ARG PENTAHO_DECOMPRESSED_DESTINY_DOCS_PATH=${PENTAHO_DECOMPRESSED_DESTINY_FILE_PATH}/docs
ARG PENTAHO_DECOMPRESSED_DESTINY_SAMPLES_PATH=${PENTAHO_DECOMPRESSED_DESTINY_FILE_PATH}/samples

ADD ${PENTAHO_SOURCE_URL_DOWNLOAD} ${PENTAHO_FILE_DOWNLOAD_PATH}

RUN unzip ${PENTAHO_FILE_DOWNLOAD_PATH} -d ${DOWNLOAD_FILE_PATH} && \
        mv ${PENTAHO_DECOMPRESSED_ORIGIN_FILE_PATH} ${PENTAHO_DECOMPRESSED_DESTINY_FILE_PATH}

RUN rm -rf ${PENTAHO_DECOMPRESSED_DESTINY_DOCS_PATH} && \
        rm -rf ${PENTAHO_DECOMPRESSED_DESTINY_SAMPLES_PATH}

##################################################################################################
# Image for Pentaho Data Integration - Kitchen Utility
##################################################################################################
FROM amazoncorretto:11

RUN yum update -y && \
    yum install -y shadow-utils

ARG PDI_DOWNLOAD_FILE_PATH=/app/download/pdi-ce
ARG PENTAHO_UID=5000
ARG PENTAHO_USER=pentaho
ARG PENTAHO_HOME=/home/pentaho
ARG PENTAHO_INSTALLATION_PATH=/opt/pentaho
ARG PENTAHO_INSTALLATION_LIB_PATH=${PENTAHO_INSTALLATION_PATH}/lib
ARG PENTAHO_EXTRA_LIBS=/app/pentaho-extra-libs
ARG APP_INSTALLATION_PATH=/app
ARG APP_JOBS_PATH=$APP_INSTALLATION_PATH/jobs
ARG APP_RESULTS_PATH=$APP_INSTALLATION_PATH/results
ARG APP_RESULTS_DATA_PATH=$APP_RESULTS_PATH/data
ARG APP_RESULTS_LOGS_PATH=$APP_RESULTS_PATH/logs
ARG APP_RESULTS_LOGS_JVM_PATH=$APP_RESULTS_LOGS_PATH/jvm

ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US.UTF-8  
ENV LC_ALL=en_US.UTF-8 

ENV APP_LOG_LEVEL="Basic"
ENV APP_JVM_MIN_MEMORY=128m
ENV APP_JVM_MAX_MEMORY=512m

COPY --from=downloader ${PDI_DOWNLOAD_FILE_PATH} ${PENTAHO_INSTALLATION_PATH}

COPY src/main/docker/entrypoint.sh ${PENTAHO_INSTALLATION_PATH}/entrypoint.sh
RUN chmod +x ${PENTAHO_INSTALLATION_PATH}/entrypoint.sh

RUN mkdir -p $APP_JOBS_PATH && \
        mkdir -p $PENTAHO_EXTRA_LIBS && \
        mkdir -p $APP_RESULTS_PATH && \
        mkdir -p $APP_RESULTS_DATA_PATH && \
        mkdir -p $APP_RESULTS_LOGS_PATH && \
        mkdir -p $APP_RESULTS_LOGS_JVM_PATH

RUN groupadd -g ${PENTAHO_UID} ${PENTAHO_USER} && \
    useradd --home-dir ${PENTAHO_HOME} --create-home \
    -u ${PENTAHO_UID} -g ${PENTAHO_UID} \
    --shell /bin/bash --skel /dev/null ${PENTAHO_USER} && \
    usermod -g ${PENTAHO_UID} ${PENTAHO_USER}

RUN chown -R pentaho:pentaho ${PENTAHO_INSTALLATION_PATH} && \
    chown -R pentaho:pentaho ${APP_INSTALLATION_PATH}

# WARNING To remove known Oracle errors ORA-00604 and ORA-01882
ENV PENTAHO_DI_JAVA_OPTIONS="-Doracle.jdbc.timezoneAsRegion=false"

ENV PENTAHO_DI_JAVA_OPTIONS="${PENTAHO_DI_JAVA_OPTIONS} -Dfile.encoding=utf8 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$APP_RESULTS_LOGS_JVM_PATH" 
# WARNING carefull with the below options, REMOVED from default, 
#         because if the Container does not have memory limits, 
#         then it can use all the host memory.
ENV PENTAHO_DI_JAVA_OPTIONS="${PENTAHO_DI_JAVA_OPTIONS} -Xms${APP_JVM_MIN_MEMORY} -Xmx${APP_JVM_MAX_MEMORY}"

VOLUME $PENTAHO_EXTRA_LIBS
VOLUME $APP_JOBS_PATH
VOLUME $APP_RESULTS_PATH

USER ${PENTAHO_USER}

ENTRYPOINT [ "/opt/pentaho/entrypoint.sh" ]
ARG IMAGE=intersystemsdc/irishealth-community:latest
FROM $IMAGE as builder
USER ${ISC_PACKAGE_MGRUSER}


WORKDIR /opt/searchtable


COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} iris.script iris.script
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} src src
#COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} user user
COPY --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} csp_user_searchtableAdd.xml /usr/irissys/csp_user_searchtableAdd.xml





RUN iris start IRIS \
    && iris session IRIS < iris.script \
    && iris stop IRIS quietly


#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

tomcat_deployment() {
  DEPLOYMENT_SOURCE=`readlink -e /etc/sqoop2/tomcat-conf`
  DEPLOYMENT_TARGET=/var/lib/sqoop2/tomcat-deployment

  rm -rf ${DEPLOYMENT_TARGET}
  mkdir ${DEPLOYMENT_TARGET}
  cp -r ${DEPLOYMENT_SOURCE}/conf ${DEPLOYMENT_TARGET}
  cp -r /usr/lib/sqoop2/webapps ${DEPLOYMENT_TARGET}/webapps
  cp -r ${DEPLOYMENT_SOURCE}/WEB-INF/* ${DEPLOYMENT_TARGET}/webapps/sqoop/WEB-INF/
  cp -r ${SQOOP_HOME}/bin ${DEPLOYMENT_TARGET}/

  if [ -n "${BIGTOP_CLASSPATH}" ] ; then
    sed -i -e "s#^\(common.loader=.*\)\$#\1,${BIGTOP_CLASSPATH/:/,}#" ${DEPLOYMENT_TARGET}/conf/catalina.properties
  fi

  chown -R sqoop2:sqoop ${DEPLOYMENT_TARGET}
}

# Autodetect JAVA_HOME if not defined
. /usr/lib/bigtop-utils/bigtop-detect-javahome
. /usr/lib/bigtop-utils/bigtop-detect-classpath

LIB_DIR=${LIB_DIR:-/usr/lib}

SQOOP_HOME=${LIB_DIR}/sqoop2
TOMCAT_HOME=${LIB_DIR}/bigtop-tomcat

tomcat_deployment

export CATALINA_BIN=${CATALINA_BIN:-${TOMCAT_HOME}/bin}
export CATALINA_BASE=${CATALINA_BASE:-${DEPLOYMENT_TARGET}}
export CATALINA_OPTS=${CATALINA_OPTS:--Xmx1024m}
export CATALINA_OUT=${CATALINE_OUT:-/var/log/sqoop2/sqoop-tomcat.log}

env CLASSPATH=$CLASSPATH $SQOOP_HOME/bin/sqoop.sh server $@


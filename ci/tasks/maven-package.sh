#!/usr/bin/env bash

set -e -u -x

M2_HOME=${HOME}/.m2
mkdir -p ${M2_HOME}
 
mkdir -p "${M2_HOME}/repository"
 
cat > ${M2_HOME}/settings.xml <<EOF
 
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                          https://maven.apache.org/xsd/settings-1.0.0.xsd">
      <localRepository>${M2_LOCAL_REPO}/repository</localRepository>

      <servers>
      <server>
            <username>${env.REPO_USER}</username>
            <password>${env.REPO_PASSWORD}</password>
            <id>release</id>
      </server>
      <server>
            <username>${env.REPO_USER}</username>
            <password>${env.REPO_PASSWORD}</password>
            <id>snapshots</id>
      </server>
      </servers>
      <mirrors>
      <mirror>
            <mirrorOf>central</mirrorOf>
            <name>Central Mirror</name>
            <url>${env.MIRROR_REPO}</url>
            <id>release</id>
      </mirror>
      </mirrors>
      <profiles>
      <profile>
            <repositories>
            <repository>
            <snapshots>
                  <enabled>false</enabled>
            </snapshots>
            <id>release</id>
            <name>libs-release</name>
            <url>${env.RELEASE_REPO}</url>
            </repository>
            <repository>
            <snapshots />
            <id>snapshots</id>
            <name>libs-snapshot</name>
            <url>${env.SNAPSHOT_REPO}</url>
            </repository>
            </repositories>
            <pluginRepositories>
            <pluginRepository>
            <snapshots>
                  <enabled>false</enabled>
            </snapshots>
            <id>release</id>
            <name>plugins-release</name>
            <url>${env.PLUGIN_RELEASE_REPO}</url>
            </pluginRepository>
            <pluginRepository>
            <snapshots />
            <id>snapshots</id>
            <name>plugins-release</name>
            <url>${env.PLUGIN_SNAPSHOT_REPO}</url>
            </pluginRepository>
            </pluginRepositories>
            <id>artifactory</id>
      </profile>
      </profiles>
      <activeProfiles>
      <activeProfile>artifactory</activeProfile>
      </activeProfiles>
</settings>
 
EOF

cat ${M2_HOME}/settings.xml

cd source-code-repo
mvn package
mv target/${ARTIFACT_NAME}-*.${ARTIFACT_PACKAGING} ../output/${ARTIFACT_NAME}.${ARTIFACT_PACKAGING}
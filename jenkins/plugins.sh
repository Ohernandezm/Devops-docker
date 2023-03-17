#! /bin/bash

# Parse a support-core plugin -style txt file as specification for jenkins plugins to be installed
# in the reference directory, so user can define a derived Docker image with just :
#
# FROM jenkins
# COPY plugins.txt /plugins.txt
# RUN /usr/local/bin/plugins.sh /plugins.txt
#

REF=/usr/share/jenkins/ref/plugins
mkdir -p $REF

while read spec; do
    plugin=(${spec//:/ });
    [[ ${plugin[0]} =~ ^# ]] && continue
    [[ ${plugin[0]} =~ ^\s*$ ]] && continue
    [[ -z ${plugin[1]} ]] && plugin[1]="latest"
    echo "Downloading ${plugin[0]}:${plugin[1]}"
    if [[ "${plugin[1]}" = "latest" ]]; then
      curl -s -L -f ${JENKINS_UC}/${plugin[1]}/${plugin[0]}.hpi -o $REF/${plugin[0]}.hpi || echo "Failed to download ${plugin[0]}:${plugin[1]}"
    else
      curl -s -L -f ${JENKINS_UC}/download/plugins/${plugin[0]}/${plugin[1]}/${plugin[0]}.hpi -o $REF/${plugin[0]}.hpi || echo "Failed to download ${plugin[0]}:${plugin[1]}"
    fi
    unzip -p $REF/${plugin[0]}.hpi META-INF/MANIFEST.MF    
done  < $1

#! /bin/bash
 # Copy files from /usr/share/jenkins/ref into ${JENKINS_HOME}
# So the initial JENKINS-HOME is set with expected content.
# It creates and uses a marker file $COPY_REFERENCE_MARKER
# to ensure that copying of reference files occurs once only to prevent overwriting of
# subsequent changes from the UI etc 

if [ ! -e $COPY_REFERENCE_MARKER ]; then
   copy_reference_file() {
       f="${1%/}" 
       echo "$f" >> $COPY_REFERENCE_FILE_LOG
       rel="${f:23}"
       dir=$(dirname "${f}")
       echo " $f -> $rel" >> $COPY_REFERENCE_FILE_LOG
       echo "copy $rel to JENKINS_HOME" >> $COPY_REFERENCE_FILE_LOG
       if [[ ! -e "${JENKINS_HOME}/${rel}" ]] 
       then
           mkdir -p "${JENKINS_HOME}/${dir:23}"
       fi; 
       cp -r "/usr/share/jenkins/ref/${rel}" "${JENKINS_HOME}/${rel}"; 
   }
   export -f copy_reference_file
   echo "--- Copying files at $(date)" >> $COPY_REFERENCE_FILE_LOG
   find /usr/share/jenkins/ref/ -type f -exec bash -c 'copy_reference_file "{}"' \;
   echo "docker onrun processing complete at $(date)" > $COPY_REFERENCE_MARKER 
fi


# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
   exec java $JAVA_OPTS -jar /usr/share/jenkins/jenkins.war $JENKINS_OPTS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"


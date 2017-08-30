#!/bin/bash

BRAHMS_NAMESPACE="/home/vvr/SystemML/Namespace/dev/NoTremor/saccsim/brahms/0/"
SPINEML_TOOLS="/home/vvr/libs/SpineML_2_BRAHMS/tools"

echo "For now, make sure non-gui mode is enabled in the saccsim config."

echo "Copy component to BRAHMS Namespace."
cp ../build/release-brahms/component.so $BRAHMS_NAMESPACE

echo "Run brahms."

# You'll need to edit this call to provide the path to your SpineML_2_BRAHMS.
brahms --d --par-NamespaceRoots=$SPINEML_TOOLS test_brahms_exe.xml

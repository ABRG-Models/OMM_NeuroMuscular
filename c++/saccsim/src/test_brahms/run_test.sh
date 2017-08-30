#!/bin/bash

echo "For now, make sure non-gui mode is enabled in the saccsim config."

# Copy your component.so file to your Brahms namespace. E.g.:
# cp ../build/component.so ~/SystemML/Namespace/dev/NoTremor/saccsim/brahms/0/

# You'll need to edit this call to provide the path to your SpineML_2_BRAHMS.
brahms --d --par-NamespaceRoots=/home/seb/src/SpineML_2_BRAHMS/tools test_brahms_exe.xml

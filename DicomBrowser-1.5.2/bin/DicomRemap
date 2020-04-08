#!/bin/sh
# DicomRemap: apply an anonymization script to DICOM files
# Copyright (c) 2008,2009 Washington University
# Author: Kevin A. Archie <karchie@npg.wustl.edu>

# The following code attempts to locate the lib directory.
# It's probably preferable to just set the lib directory location explicitly:
# LIBDIR=/path/to/DicomBrowser/lib
APP="`which $0`"
APPHOME="`dirname \"$APP\"`/.."
LIBDIR="${APPHOME}/lib"

if [ $JAVA_HOME ] ; then
	JAVA=${JAVA:-${JAVA_HOME}/bin/java}
else
	JAVA=${JAVA:-java}
fi

export CLASSPATH="`find \"$LIBDIR\" -name '*.jar' -print | tr '\n' :`${LIBDIR}"
case "`uname`" in
	CYGWIN*) export CLASSPATH="`cygpath -wp $CLASSPATH`"
esac

"${JAVA}" -Djava.awt.headless=true org.nrg.dcm.edit.CSVRemapper $*

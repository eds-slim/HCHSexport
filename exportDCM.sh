#!/bin/bash

# Export and pseudonymise HCHS DICOM data
# Copyright (C) 2019, Eckhard Schlemm, CSI, UKE
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.


# Usage: exportDCM [-s SALTFILE] [-t TEMPL] [-c CERT] [-o OUT_DIR] IN_DIR
#
# where
#	-s SALTFILE	file containing SALT for SHA256 hashing of HCHS ID
#			(default ./salt.txt)
#	-t TEMPL	anonymisation template file in DiomEdit format.i
#			(default ./remap_template.das)
#	-c CERT		certificate. If not given will be created and destroyed.	
#			(default ./remap_template.das)
#	-o OUT_DIR	output directory for pseudonymized files, order structure preserved.
#			(default {IN_DIR}_out)
#
#		IN_DIR	input directory containing DCM files, one folder per subject
#
# Output: 0 if succesful
#
# Dependecies
#
#	GDCM:					install via 'sudo apt install libgdcm-tools' or similar.
#	DicomBrowser 1.5.2: 	included. Make executable if necessary.
#							Also available at https://download.nrg.wustl.edu/pub/DicomBrowser/DicomBrowser-1.5.2.tgz
#	JAVA


shopt -s nocaseglob
shopt -s globstar
shopt -s extglob

SALTFILE=./salt.txt
TEMPL=./remap_template.das

CHECK_ID_FLAG=false
DO_FLATTEN_FLAG=true

optspec="s:t:c:o:"
while getopts "$optspec" optchar; do
	case "${optchar}" in
		s)
			SALTFILE="$OPTARG"
			echo "Salt file is $SALTFILE"
			;;
		t)
			TEMPL="$OPTARG"
			;;
		c)
			CERT="$OPTARG"
			;;
		o)
			OUT_DIR="$OPTARG"
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done
shift $(($OPTIND - 1));


# check number of positional argument
if [ ! $# -eq 1 ]; then
	echo "Only one positional argument (IN_DIR) permitted. Exit."
	exit 1
fi       

IN_DIR="$1"
if [ ! -d "$IN_DIR" ]; then
	echo "Input directory $IN_DIR does ot exist. Exit."
	exit 1
fi
IN_DIR=${IN_DIR%%+(/)} # remove trailing slashes
if [ "$IN_DIR" == "" ]; then echo "Root '/' not allowed as input directory. Exit"; exit 1; fi

if [ ! -e "$SALTFILE" ]; then
	echo "Salt file $SALTFILE does not exist. Exit."
	exit 1
fi

SALT=$(cat "$SALTFILE")

if [ ! -e "$TEMPL" ]; then
	echo "Template file $TEMPL does not exist. Exit."
	exit 1
fi

if [ -z ${CERT+x} ]; then
	echo -e "No certificate specified. Creating one ...\n"
	if [ -e private.pem ] || [ -e certificate.pem ]; then
		echo "private.pem and/or certificate.pem found in working directory. Please delete or specifiy with '-c certificate.pem'. Exit"
		exit 1
	fi
	openssl genrsa -out private.pem
	yes xx | openssl req -new -key private.pem -x509 -days 365 -out certificate.pem
fi


## precompute pseudonyms, check for duplicates and save dictionary

if true; then
	DICTFILE=dictioary.dat
	touch $DICTFILE
	echo "Orig,HCHS_ID,pseudonym" > $DICTFILE
	for subj in "$IN_DIR"/*; do


		for FILE in "${subj}"/**/*; do
			if [[ "$(file -b "$FILE")" =~ "DICOM" && ${FILE##*/} != "DICOMDIR" ]]; then break; fi # use first DICOM file in die folder.
		done


		## echo "Extracting HCHS ID ..."
		PatientID=$(dcmdump "$FILE" --search "0010,0010" | grep -oP '(?<=\[).*?(?=\])')
		HCHS_ID=$(echo $PatientID | grep -oP '(?<=65151-)DHCC[0-9]{5}(?=\^HC)')
		if [ "$HCHS_ID" == "" ] && $CHECK_ID_FLAG; then
			echo "PatientID (0010,0010) not of the form '[65151-DHCCxxxxx^HCHS]'. Please check. Exit."
			exit 1
		fi

		HCHS_ID_HASH=$(echo ${SALT}${HCHS_ID} | sha256sum | head -c 8)

		echo "${subj##*/},$HCHS_ID,$HCHS_ID_HASH" >> $DICTFILE
	done

	cat $DICTFILE | awk -F , '{print $2}' | uniq -d
	cat $DICTFILE | uniq | awk -F , '{print $2}' | uniq -d | wc -l

fi
## end pseudonym precheck ##


echo $OUT_DIR
if [ -z ${OUT_DIR+x} ]; then
	echo "Output directory not specified. Using ${IN_DIR}_out."
	OUT_DIR=${IN_DIR}_out
fi

if [ ! -d "$OUT_DIR" ]; then
	echo "Output directory $OUT_DIR does not exist. Creating it ..."
	mkdir -p "$OUT_DIR" || { echo "...failed. Exit"; exit 1; }
fi


mkdir -p "${OUT_DIR}.work"
mkdir -p "${OUT_DIR}.anon.rev"
mkdir -p "${OUT_DIR}.anon.irrev"


############### BEGIN subject loop ########################
for subj in "$IN_DIR"/*; do
	echo -e "Processing subject folder $subj ...\n"
	echo "Copying to ${OUT_DIR}.work ..."
	subjwork="${OUT_DIR}.work/${subj##*/}"
	mkdir "$subjwork"
	cp -r "$subj"/* "$subjwork"

	####################################################
	## Sort files into folders by SequenceDescription ##
	####################################################
	if $DO_FLATTEN_FLAG; then
		echo "Flattening subject directory $subjwork ..."

		pushd . > /dev/null
		cd "$subjwork"
		find . -mindepth 2 -type f -exec bash -c 'file="{}"; t="${file//\//_}"; t=${t/._/}; mv "$file" "$t"' \;
		find . -type d -empty -delete
		popd
	fi

	echo "Sorting DCMs into folders by SeriesDescription"
	pushd . > /dev/null
	cd "$subjwork"
	gdcmscanner -d . -t 0008,103e -p | \
		perl -0777 -pe 's/Filename: (.*) \(.*\n.* -> \[(.*?)\s*\]/mkdir -p \"$2\"; mv \"$1\" \"\$_\"/g' | \
		sed '/^mkdir/!d' | \
		bash
	popd

	#############################################################################
	## Extract some important values. Assumed to be constant for fixed subject ##
	#############################################################################

	for FILE in "$subjwork"/**/*; do
		if [[ "$(file -b "$FILE")" =~ "DICOM" ]]; then break; fi # use first DICOM file in die folder.
	done

	echo "Extracting HCHS ID ..."
	PatientID=$(dcmdump "$FILE" --search "0010,0010" | grep -oP '(?<=\[).*?(?=\])')
	HCHS_ID=$(echo $PatientID | grep -oP '(?<=65151-)DHCC[0-9]{5}(?=\^HCHS)')
	echo $HCHS_ID

	echo "Extracting date of birth ..."
	PatientBirthDate=$(dcmdump "$FILE" --search "0010,0030" | grep -oP '(?<=\[).*?(?=\])')
	echo $PatientBirthDate
	if [[ $PatientBirthDate =~ ^19[0-9]{2}0101$ ]]; then
		echo "PatientBirthDate format compliant (19XX0101)."
	else
		echo "PatientBirthDate format not compliant."
		## Sanitisation dependent on how non-compliant PatientBirthDates actually are
	fi

	HCHS_ID_HASH=$(echo ${SALT}${HCHS_ID} | sha256sum | head -c 8)
	echo $HCHS_ID_HASH


	################################################
	### perform PS 3.15 compliant anonymisation ####
	################################################
	if [ -e "$subjwork"/DICOMDIR ]; then rm "$subjwork"/DICOMDIR; fi	# needed for older version of libgdcm-tool
	gdcmanon -c "$CERT" -e -r --continue "$subjwork" "${OUT_DIR}.anon.rev/$HCHS_ID_HASH"
	gdcmanon --dumb --remove 400,500 --remove 12,62 --remove 12,63 -r --continue "${OUT_DIR}.anon.rev/$HCHS_ID_HASH" "${OUT_DIR}.anon.irrev/$HCHS_ID_HASH"
	rm -r "${OUT_DIR}.anon.rev"/*


################## BEGIN SeriesDescription loop ##############################
	if [ ! -d "${OUT_DIR}/$HCHS_ID_HASH" ]; then
		mkdir "${OUT_DIR}/$HCHS_ID_HASH"
	fi

	sesID=$(find "${OUT_DIR}/$HCHS_ID_HASH" -type d -name "ses-*" -prune -print | grep -c /)
	sesID=$((sesID + 1))
	echo $sesID

	for sede in "$subjwork"/*; do
		if [ ! -d "$sede" ]; then continue; fi

		presuffix=${sede##*/}
		suffix=${presuffix// /_}

		if [ ! "$presuffix" == "$suffix" ]; then
			mv "${OUT_DIR}.anon.irrev/$HCHS_ID_HASH/$presuffix" "${OUT_DIR}.anon.irrev/$HCHS_ID_HASH/$suffix"
		fi

		## could use $sede instead of dcmdumping again. 
		for FILE in "$sede"/**/*; do
			if [[ "$(file -b "$FILE")" =~ "DICOM" ]]; then break; fi # use first DICOM file in die folder.
		done
		SeriesDescription=$(dcmdump "$FILE" --search "0008,103e"  | grep -oP '(?<=\[).*?(?=\])')
		SeriesDescription=${SeriesDescription// /_}
		ProtocolName=$(dcmdump "$FILE" --search "0018,1030"  | grep -oP '(?<=\[).*?(?=\])')
		ProtocolName=${ProtocolName// /_}

		#########################################################
		### post-process DCM headers according to local specs ###
		#########################################################
		pwd
		cp "$TEMPL" remap.das
		sed -i "s/{PatientID}/$HCHS_ID_HASH/g" remap.das
		sed -i "s/{SeriesDescription}/$SeriesDescription/g" remap.das
		sed -i "s/{PatientBirthDate}/$PatientBirthDate/g" remap.das
		sed -i "s/{ProtocolName}/$ProtocolName/g" remap.das

		DicomBrowser-1.5.2/bin/DicomRemap -d remap.das "${OUT_DIR}.anon.irrev/$HCHS_ID_HASH/$suffix" -o "${OUT_DIR}/$HCHS_ID_HASH/ses-${sesID}"
	done
############### END series description loop ########################
	rm -r "${OUT_DIR}.work"/*
	rm -r "${OUT_DIR}.anon.irrev"/*

done
############### END subject loop ########################

rmdir "${OUT_DIR}.work"
rmdir "${OUT_DIR}.anon.rev"
rmdir "${OUT_DIR}.anon.irrev"

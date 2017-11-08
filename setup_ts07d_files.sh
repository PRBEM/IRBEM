#!/bin/sh
# written by Adam C. Kellerman
# modified Nov 7, 2016 to automate download and unpacking

cd $TS07_DATA_PATH # by default we specify the global variable
echo "TS07_DATA_PATH: $TS07_DATA_PATH"

COEFF_DIR=$TS07_DATA_PATH/Coeffs
TAIL_PAR_DIR=$TS07_DATA_PATH/TAIL_PAR

#download the TAIL_PAR files
echo 'Downloading TAIL_PAR.zip'
wget -N http://rbspgway.jhuapl.edu/sites/default/files/SpaceWeather/TAIL_PAR.zip
echo "done"

printf "Unpacking "
mkdir -p $TAIL_PAR_DIR
unzip -u TAIL_PAR.zip -d $TAIL_PAR_DIR
echo "done"

echo 'Downloading coefficient files'
#download all the coefficient files
wget -N http://rbspgway.jhuapl.edu/models/magneticfieldmodeling/ts07d/coeffs/2017/all.tgz
echo "done"

#unpack them
printf 'unpacking coefficient files...'
TS07SETUP_TMP_DIR=$COEFF_DIR/TMP
mkdir -p $TS07SETUP_TMP_DIR
tar -zxf all.tgz -C $TS07SETUP_TMP_DIR
cd $COEFF_DIR
find $TS07SETUP_TMP_DIR -type f -exec mv {} . \;
rm -r $TS07SETUP_TMP_DIR
echo "done"

#extract the tar files to the required directory
echo "Extracting coefficient files to $COEFF_DIR" 
for ifile in *.tgz
do
    filen=`basename $ifile .tgz`
    mkdir -p $filen
    tar -zxf $ifile -C $filen
    #printf "$ifile\b\b\b\b\b\b\b\b\b\b\b\b"
    printf "\b\b\b\b\b\b\b\b\b\b\b\b$ifile"
    rm $ifile # note that we can unpack all.tgz again to get these back
done
printf "\n"
echo "done"
echo 'TS07D setup script completed successfully'

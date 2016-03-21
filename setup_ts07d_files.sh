coeffdir=Coeffs/
# set this to the directory where you have downloaded the .zip, or .tgz files
cd $TS07_DATA_PATH # by default we specify the global variable

# unzip any zip file(s) containing the .tgz files
for ifile in *Coeffs.zip
do
    unzip $ifile
done

#extract the tar files to the required directory
for ifile in *.tgz
do
    yeardoy=`sed 's/\(.\{8\}\).*/\1/' <<<$ifile`
    outdir=$coeffdir$yeardoy/
    mkdir -p $outdir
    echo $outdir$ifile
    tar -zxf $ifile -C $outdir
    rm $ifile # note that we can unzip the Allcoeff.zip to get these back
done

mkdir -p TAIL_PAR
cd TAIL_PAR
unzip ../TAIL_PAR.zip

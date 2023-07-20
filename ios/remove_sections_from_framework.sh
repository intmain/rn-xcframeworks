#!/bin/zsh

FILE_PATH=$1
FRAMEWORK=`basename $FILE_PATH ".framework"`
TMP=${FRAMEWORK}.tmp

mkdir $TMP && cp $FILE_PATH/$FRAMEWORK $TMP
cd $TMP && ar -x $FRAMEWORK
echo "Removing sections from $FRAMEWORK ..."
for obj in *.o 
do
	echo "Processing $obj ..."
	for sect in `otool -l $obj | grep __DWARF --context=3 | grep sectname | awk '{print $2}'`
	do
	 echo "Removing __DWARF,${sect}"
	 /opt/homebrew/opt/llvm@14/bin/llvm-objcopy --remove-section __DWARF,${sect} $obj $obj
    done
done

ar -r $FRAMEWORK *.o
cd .. && cp -f $TMP/$FRAMEWORK ${FILE_PATH}/${FRAMEWORK}
rm -rf $TMP

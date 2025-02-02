# copy libraries
mkdir ../libs
mkdir ../libs/armeabi/
cp ../../../../bin/Android/armv6/libzenjpeg.so ../libs/armeabi/
cp ../../../../bin/Android/armv6/libopenal.so ../libs/armeabi/
cp ../../../../bin/Android/armv6/libogg.so ../libs/armeabi/
cp ../../../../bin/Android/armv6/libvorbis.so ../libs/armeabi/
cp ../../../../bin/Android/armv6/libtheoradec.so ../libs/armeabi/
cp ../../../../bin/Android/armv6/libchipmunk.so ../libs/armeabi/
# copy resources
mkdir ../assets
cp ../../../../bin/data/font* ../assets
cp ../../../../bin/data/CalibriBold50pt* ../assets
cp ../../../../bin/data/arrow.png ../assets
cp ../../../../bin/data/Rus.txt ../assets

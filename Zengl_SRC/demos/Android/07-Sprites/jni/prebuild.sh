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
cp ../../../../bin/data/zengl.png ../assets
cp ../../../../bin/data/back01.jpg ../assets
cp ../../../../bin/data/ground.png ../assets
cp ../../../../bin/data/tux_walking.png ../assets
cp ../../../../bin/data/tux_stand.png ../assets
cp ../../../../bin/data/font* ../assets

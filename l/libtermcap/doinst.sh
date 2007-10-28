( cd lib64 ; rm -rf libtermcap.so.2 )
( cd lib64 ; ln -sf libtermcap.so.2.0.8 libtermcap.so.2 )
( cd usr/lib64 ; rm -rf libtermcap.so )
( cd usr/lib64 ; ln -sf /lib64/libtermcap.so.2.0.8 libtermcap.so )

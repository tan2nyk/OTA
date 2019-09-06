#--------------------------------------------------------------
#               Quectel OpenLinux
#--------------------------------------------------------------
QL_SDK_ROOT   			?= $(shell pwd)/../ql-ol-sdk
QL_SDK_PATH   			?= $(shell pwd)/../ql-ol-sdk/ql-ol-extsdk
QL_SDKTARGETSYSROOT   	?= $(shell pwd)/../ql-ol-sdk/ql-ol-crosstool/sysroots/armv7a-vfp-neon-oe-linux-gnueabi
QL_EXP_TARGETS 			= OTAManager
QL_EXP_LDLIBS  			= -lql_sys_log -lrt -lpthread
EXT_LIBS				?= $(shell pwd)/../libs

#--------------------------------------------------------
# TOOLS BASIC CONFIG
# Note: No Need to change them
#--------------------------------------------------------
CPPFLAGS += -I./                     							\
            -I../include       	   								\
			-I$(QL_SDK_PATH)/include							\
            -I$(QL_SDK_PATH)/lib/interface/inc        			\
            -I$(QL_SDKTARGETSYSROOT)/usr/include               	\
            -I$(QL_SDKTARGETSYSROOT)/usr/include               	\
            -I$(QL_SDKTARGETSYSROOT)/usr/include/data          	\
            -I$(QL_SDKTARGETSYSROOT)/usr/include/dsutils       	\
            -I$(QL_SDKTARGETSYSROOT)/usr/include/qmi           	\
            -I$(QL_SDKTARGETSYSROOT)/usr/include/qmi-framework 	\
            -I$(QL_SDKTARGETSYSROOT)/usr/include/ql-manager    	\


LDFLAGS += -L./                          \
           ${QL_EXP_LDLIBS}              \
           -L$(QL_SDKTARGETSYSROOT)/usr/lib \
           -L$(QL_SDK_PATH)/lib          \
	   -lpthread			 


STD_LIB= $(QL_SDKTARGETSYSROOT)/usr/lib/libdsi_netctrl.so     	\
         $(QL_SDKTARGETSYSROOT)/usr/lib/libdsutils.so         	\
         $(QL_SDKTARGETSYSROOT)/usr/lib/libqmiservices.so     	\
         $(QL_SDKTARGETSYSROOT)/usr/lib/libqmi_cci.so         	\
         $(QL_SDKTARGETSYSROOT)/usr/lib/libqmi_common_so.so   	\
         $(QL_SDKTARGETSYSROOT)/usr/lib/libqmi.so             	\
         $(QL_SDKTARGETSYSROOT)/usr/lib/libmcm.so             	\
         $(QL_SDKTARGETSYSROOT)/usr/lib/libql_mgmt_client.so  	\
#		 $(EXT_LIBS)/librabbitmq.so								\

SINGLE_LIB=-lql_qcmap_client
USR_LIB=$(QL_SDK_PATH)/lib/libql_common_api.a		\
		$(QL_SDK_PATH)/lib/libql_peripheral.a		\
#---------------------
# Source code files
#---------------------
LOCAL_SRC_FILES = OTAManager.c

$(QL_EXP_TARGETS): 
#	$(CC) $(CPPFLAGS) $(CFLAGS) $(LOCAL_SRC_FILES)

	$(COMPILE.c) $(CPPFLAGS) $(LDFLAGS) $(LOCAL_SRC_FILES)
#	$(LINK.o) ini.o zlog.o ntpclient.o HWTrackerEC25.o $(LDFLAGS) $(USR_LIB) $(SINGLE_LIB) $(STD_LIB) -o HWTrackerEC25
#	$(LINK.o) md5_reader.o $(LDFLAGS) $(USR_LIB) $(SINGLE_LIB) $(STD_LIB) -o md5_reader
#	$(LINK.o) md5_writer.o $(LDFLAGS) $(USR_LIB) $(SINGLE_LIB) $(STD_LIB) -o md5_writer
	$(LINK.o) OTAManager.o $(LDFLAGS) $(USR_LIB) $(SINGLE_LIB) $(STD_LIB) -o OTAManager


all: $(QL_EXP_TARGETS)
.PHPNY: all

clean:
	rm -rf $(QL_EXP_TARGETS) *.o

.PHONY:checkmake
checkmake:  
	@echo -e "CURDIR =			\n	${CURDIR}"  
	@echo -e "\nMAKE_VERSION =	\n	${MAKE_VERSION}"  
	@echo -e "\nMAKEFILE_LIST =	\n	${MAKEFILE_LIST}"  
	@echo -e "\nCOMPILE.c =		\n	${COMPILE.c}"
	@echo -e "\nCOMPILE.cc =	\n	${COMPILE.cc}"
	@echo -e "\nCOMPILE.cpp =	\n	${COMPILE.cpp}"
	@echo -e "\nLINK.cc =		\n	${LINK.cc}"
	@echo -e "\nLINK.o =		\n	${LINK.o}"
	@echo -e "\nCPPFLAGS =		\n	${CPPFLAGS}"
	@echo -e "\nCFLAGS =		\n	${CFLAGS}"
	@echo -e "\nCXXFLAGS =		\n	${CXXFLAGS}"
	@echo -e "\nLDFLAGS =		\n	${LDFLAGS}"
	@echo -e "\nLDLIBS =		\n	${LDLIBS}"

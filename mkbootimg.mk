LOCAL_PATH := $(call my-dir)
include kernel/AndroidKernel.mk
CM_DTB_FILES = $(wildcard $(TOP)/$(TARGET_KERNEL_SOURCE)/arch/arm/boot/*.dtb)
CM_DTS_FILE = $(lastword $(subst /, ,$(1)))
DTB_FILE := $(addprefix $(KERNEL_OUT)/arch/arm/boot/,$(patsubst %.dts,%.dtb,$(call CM_DTS_FILE,$(1))))
ZIMG_FILE = $(addprefix $(KERNEL_OUT)/arch/arm/boot/,$(patsubst %.dts,%-zImage,$(call CM_DTS_FILE,$(1))))
KERNEL_ZIMG = $(KERNEL_OUT)/arch/arm/boot/zImage

define append-cm-dtb
mkdir -p $(KERNEL_OUT)/arch/arm/boot;\
$(foreach d, $(CM_DTB_FILES), \
    cat $(KERNEL_ZIMG) $(call DTB_FILE,$(d)) > $(call ZIMG_FILE,$(d));)
endef


## Build and run dtbtool
DTBTOOL := $(HOST_OUT_EXECUTABLES)/dtbTool$(HOST_EXECUTABLE_SUFFIX)
INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img

$(INSTALLED_DTIMAGE_TARGET): $(DTBTOOL) $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr $(INSTALLED_KERNEL_TARGET)
	@echo -e ${CL_CYN}"Start DT image: $@"${CL_RST}
	$(call append-cm-dtb)
	$(call pretty,"Target dt image: $(INSTALLED_DTIMAGE_TARGET)")
	$(DTBTOOL) -2 -o $(INSTALLED_DTIMAGE_TARGET) -s $(BOARD_KERNEL_PAGESIZE) -p $(KERNEL_OUT)/scripts/dtc/ $(KERNEL_OUT)/arch/arm/boot/
	@echo -e ${CL_CYN}"Made DT image: $@"${CL_RST}


## Overload bootimg generation: Same as the original, + --dt arg
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(INSTALLED_DTIMAGE_TARGET)
	$(call pretty,"Target boot image: $@")
	$(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_BOOTIMAGE_ARGS_COMMON) $(BOARD_MKBOOTIMG_ARGS) --dt $(INSTALLED_DTIMAGE_TARGET) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}

## Overload recoveryimg generation: Same as the original, + --dt arg
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(INSTALLED_DTIMAGE_TARGET) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --dt $(INSTALLED_DTIMAGE_TARGET) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

MODEM_IMAGES := \
    modem.b00 modem.b01 modem.b02 modem.b03 modem.b04 modem.b05 \
    modem.b08 modem.b10 modem.b11 modem.b13 modem.b14 modem.b15 \
    modem.b16 modem.b17 modem.b18 modem.b19 modem.b20 modem.b21 \
    modem.b22 modem.b25 modem.b26 modem.b27 modem.mdt

MODEM_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(MODEM_IMAGES)))
$(MODEM_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Modem firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(MODEM_SYMLINKS)

ADSP_IMAGES := \
    adsp.b00 adsp.b01 adsp.b02 adsp.b03 adsp.b04 adsp.b05 adsp.b06 \
    adsp.b07 adsp.b08 adsp.b09 adsp.b10 adsp.b11 adsp.b12 adsp.mdt

ADSP_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(ADSP_IMAGES)))
$(ADSP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "ADSP firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(ADSP_SYMLINKS)

WCNSS_IMAGES := \
    wcnss.b00 wcnss.b01 wcnss.b02 wcnss.b04 wcnss.b06 \
    wcnss.b07 wcnss.b08 wcnss.b09 wcnss.mdt

WCNSS_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(WCNSS_IMAGES)))
$(WCNSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(WCNSS_SYMLINKS)

MBA_IMAGES := \
    mba.b00 mba.mdt

MBA_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(MBA_IMAGES)))
$(MBA_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "MBA firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(MBA_SYMLINKS)

WCD_IMAGES := \
    wcd9320_anc.bin wcd9320_mbhc.bin

WCD_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/wcd9320,$(notdir $(WCD_IMAGES)))
$(WCD_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "WCD9320 firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /data/misc/audio/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(MBA_SYMLINKS)

CMN_IMAGES := \
    cmnlib.b00 cmnlib.b01 cmnlib.b02 cmnlib.mdt

CMN_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(CMN_IMAGES)))
$(CMN_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "CMN firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(CMN_SYMLINKS)

ISDB_IMAGES := \
    isdbtmm.b00 isdbtmm.b01 isdbtmm.b02 isdbtmm.b03 isdbtmm.mdt

ISDB_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(ISDB_IMAGES)))
$(ISDB_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "ISDB firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(ISDB_SYMLINKS)

KM_IMAGES := \
    keymaste.b00 keymaste.b01 keymaste.b02 keymaste.b03 keymaste.mdt

KM_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(KM_IMAGES)))
$(KM_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Keymaster firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(KM_SYMLINKS)

MC_IMAGES := \
    mc_v2.b00 mc_v2.b01 mc_v2.b02 mc_v2.b03 mc_v2.mdt

MC_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(MC_IMAGES)))
$(MC_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Mobicore firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(MC_SYMLINKS)

PLAYREADY_IMAGES := \
    playread.b00 playread.b01 playread.b02 playread.b03 playread.mdt

PLAYREADY_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(PLAYREADY_IMAGES)))
$(PLAYREADY_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Playready firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(PLAYREADY_SYMLINKS)

WV_IMAGES := \
    widevine.b00 widevine.b01 widevine.b02 widevine.b03 widevine.mdt

WV_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(WV_IMAGES)))
$(WV_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Widevine firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(WV_SYMLINKS)

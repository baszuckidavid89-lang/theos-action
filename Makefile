# Target the iPhone architecture
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = AnimalCompany

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Astraeus

# IMPORTANT: All .mm files from your dump must be listed here
Astraeus_FILES = Tweak.x ModMenuController.mm GameHelper.mm IL2CPPResolver.mm
Astraeus_FRAMEWORKS = UIKit CoreGraphics QuartzCore AudioToolbox
Astraeus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

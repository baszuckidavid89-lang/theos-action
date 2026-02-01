TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = AnimalCompany

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Astraeus

# We removed NetworkHelper.mm to prevent the "File not found" error
Astraeus_FILES = Tweak.x ModMenuController.mm GameHelper.mm IL2CPPResolver.mm
Astraeus_FRAMEWORKS = UIKit CoreGraphics QuartzCore
Astraeus_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

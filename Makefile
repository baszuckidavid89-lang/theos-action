TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Astraeus
Astraeus_FILES = Tweak.x
Astraeus_FRAMEWORKS = UIKit QuartzCore CoreGraphics

# THIS LINE IS THE FIX: It tells the compiler to ignore the keyWindow warning
Astraeus_CFLAGS = -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

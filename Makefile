# Define the target architecture (modern iPhones)
ARCHS = arm64 arm64e

# The SDK version you are targeting
TARGET = iphone:clang:latest:14.0

# Include common Theos variables
include $(THEOS)/makefiles/common.mk

# Name of the Tweak
TWEAK_NAME = Astraeus

# The source file(s) to compile
Astraeus_FILES = Tweak.x

# Frameworks required for the Mod Menu UI and Vector3 math
Astraeus_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore

# Libraries for hooking and symbol resolution
Astraeus_LIBRARIES = substrate

# Compiler flags (ARC is recommended for modern Objective-C)
Astraeus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

# Optional: Commands to run after installation (restarts the game)
after-install::
	install.exec "killall -9 UnityFramework" || true

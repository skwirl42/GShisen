
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)

GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make

# The application to be compiled
APP_NAME = GShisen

# The Objective-C source files to be compiled

GShisen_OBJC_FILES = main.m \
							gshisen.m \
							board.m \
							tile.m \
							gsdialogs.m \
							tilepair.m

# The Resource files to be copied into the app's resources directory
GShisen_RESOURCE_FILES = Icons/*

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/application.make

-include GNUmakefile.postamble


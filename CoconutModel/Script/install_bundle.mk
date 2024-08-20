# install_xc.mk

PROJECT_NAME	?= CoocnutModel
BUNDLE_PATH	 = tools/bundles
BIN_PATH	 = tools/bin

all: install_bundle

install_bundle: dummy
	xcodebuild install \
	  -scheme CoconutModel_Bundle \
	  -project $(PROJECT_NAME).xcodeproj \
	  -destination="macOSX" \
	  -configuration Release \
	  -sdk macosx \
	  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
	  INSTALL_PATH=$(BUNDLE_PATH) \
	  SKIP_INSTALL=NO \
	  DSTROOT=$(HOME) \
	  ONLY_ACTIVE_ARCH=NO

dummy:


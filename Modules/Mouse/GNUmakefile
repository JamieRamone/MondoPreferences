####################################################################################################################################
#
#	GNUmakefile
#
#	This file is an part of Mondo Preferences.
#
#	Copyright (C) 2020 Mondo Megagames.
# 	Author: Jamie Ramone <sancombru@gmail.com>
#	Date: 18-5-20
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see
# <http://www.gnu.org/licenses/>
#
####################################################################################################################################
include $(GNUSTEP_MAKEFILES)/common.make
#
# Bundle
#
BUNDLE_NAME = Mouse
Mouse_PRINCIPAL_CLASS = MousePaneController
BUNDLE_EXTENSION = .preference
Mouse_STANDARD_INSTALL = no
#
# Resource files
#
Mouse_RESOURCE_FILES =		$(wildcard Resources/*[^~].*)
#
# Header files
#
Mouse_HEADER_FILES =		$(wildcard *.h)
#
# Class files
#
Mouse_OBJC_FILES =		$(wildcard *.m)
#
# Makefiles
#
-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble

/***********************************************************************************************************************************
 *
 *	Password.h
 *
 * This file is an part of Mondo Preferences.
 *
 *	Copyright (C) 2020 Mondo Megagames.
 * 	Author: Jamie Ramone <sancombru@gmail.com>
 *	Date: 18-5-20
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>
 *
 **********************************************************************************************************************************/
#include <pwd.h>

#include <sys/types.h>

#import <Foundation/Foundation.h>

#import "PreferencePaneController.h"

#define LockImage	@"Lock.tiff"
#define LockOpenImage	@"LockOpen.tiff"

@interface PasswordPaneController : PreferencePaneController {
	NSString		* password;
	struct passwd		* userEntry;
/*
 * NIB outlets.
 */
	NSButton		* cancelButton,
				* okButton;
	NSImageView		* lockImageView;
	NSSecureTextField	* passwordTextField,
				* informationLabel,
				* label;
}
/*
 * NIB actions
 */
- (void) changePassword: (NSButton *) sender;
- (void) cancel: (NSButton *) sender;

@end

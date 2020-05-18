/***********************************************************************************************************************************
 *
 *	AppController.h
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
#import <AppKit/AppKit.h>

#import "AppIconView.h"
#import "LayoutController.h"

@interface AppController : NSObject {
	LayoutController	* layoutController;
	NSMutableArray		* loadedModules;
	AppIconView		* iconView;
}

+ (void) initialize;

- (id) init;

- (AppIconView *) iconView;
- (void) setIconView: (AppIconView *) newIconView;

//- (void) applicationDidFinishLaunching: (NSNotification *)aNotif;
//- (BOOL) applicationShouldTerminate: (id)sender;
//- (void) applicationWillTerminate: (NSNotification *)aNotif;
//- (BOOL) application: (NSApplication *)application openFile: (NSString *)fileName;

- (void) showInfoPanel: (NSMenuItem *) sender;

@end

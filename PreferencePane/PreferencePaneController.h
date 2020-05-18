/***********************************************************************************************************************************
 *
 *	PreferencePaneController.h
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
#import <Foundation/Foundation.h>

#define DefferedLoadingCompletedNotification	@"DefferedLoadingCompletedNotification"

@protocol PreferencePaneController <NSObject>

@optional

- (NSImage *) buttonImage;
- (NSView *) pane;
- (NSString *) title;
- (BOOL) deferedLoading;
- (void) loadPane;

@end

@interface PreferencePaneController : NSObject <PreferencePaneController> {
	NSImage				* icon;
	NSString			* title,
					* nibFile;
	NSCondition			* lock;
/*
 * NIB outlets.
 */
	id				pane;
}

+ (id <PreferencePaneController>) loadPaneAtPath: (NSString *) path;

- (id <PreferencePaneController>) initWithView: (NSView *) rootView title: (NSString *) aTitle icon: (NSImage *) anImage;
- (id <PreferencePaneController>) initWithNibFile: (NSString *) nib title: (NSString *) aTitle icon: (NSImage *) anImage;

@end

/***********************************************************************************************************************************
 *
 *	AppIconView.m
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
#import <AppKit/NSWindow.h>

#import "../aux.h"
#import "AppIconView.h"

@implementation AppIconView

NSString	* PreferencesAppIconViewAutoUpdatedNotification = @"PreferencesAppIconViewAutoUpdatedNotification";

static NSWindow	* _auxWindow = nil;
static NSRect	_AppIconFrame = {{ 0, 0 }, { 60, 60 }};

- (id) initWithFrame: (NSRect) frame
{
	register void	* target = NULL;
	register BOOL	criteria = NO;

	self = [super initWithFrame: _AppIconFrame];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	appIcon = nil;

out:	return self;
};

- (BOOL) isOpaque
{
	register BOOL	result = NO;

	return result;
}

- (void) setFrame: (NSRect) frame
{
	;
};

- (void) update
{
	register NSBitmapImageRep	* representation = nil;
	register NSImage		* appIconImage = nil;
	register void			* target = NULL;
	register NSRect			bounds = NSZeroRect;
	register BOOL			criteria = NO;

	bounds = [self bounds];
	criteria = ( _auxWindow == nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	//NSLog ( @"Initializing aux window..." );
	_auxWindow = [[NSWindow alloc] initWithContentRect: bounds styleMask: NSBorderlessWindowMask backing: NSBackingStoreNonretained defer: NO];
	[_auxWindow setContentView: self];
	[_auxWindow setBackgroundColor: [NSColor clearColor]];
	[_auxWindow setFrameOrigin: NSMakePoint (-1000, -1000)];
out:	[_auxWindow orderFront: nil];
	appIcon = [[NSImage alloc] initWithSize: bounds.size];
	appIconImage = appIcon;
	[self lockFocus];
	[self drawRect: bounds];
	representation = [[NSBitmapImageRep alloc] initWithFocusedViewRect: bounds];
	[self unlockFocus];
	[appIconImage addRepresentation: representation];
	[_auxWindow orderOut: nil];
	//NSLog ( @"Updated icon: %@.", appIcon );
};

- (NSImage *) icon
{
	register NSImage	* result = nil;

	result = appIcon;
	//NSLog ( @"returning icon: %@.", result );

	return result;
};

@end

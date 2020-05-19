/***********************************************************************************************************************************
 *
 *	TimeZoneSelectorView.m
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

#import "../../aux.h"
#import "TimeZoneSelectorView.h"

@interface TimeZoneSelectorView (Private)

- (NSImage *) worldMap;

@end

@implementation TimeZoneSelectorView (Private)

- (NSImage *) worldMap
{
	register NSImage	* result = nil;
	register NSBundle	* bundle = nil;
	register NSString	* path = nil;
	register void		* target = NULL;
	register BOOL		criteria = NO;

	criteria = ( worldMap == nil );
	target = Choose ( criteria, && in, && out );
	goto * target;

	//if ( worldMap == nil ) {
in:	bundle = [NSBundle bundleForClass: [self class]];
	path = [bundle pathForResource: @"world" ofType: @"tiff" inDirectory: @""];
	worldMap = [[NSImage alloc] initWithContentsOfFile: path];
	//}

out:	result = worldMap;

	return result;
};

@end

@implementation TimeZoneSelectorView

- (void) awakeFromNib
{
	worldMap = nil;
};

- (void) mousedown: (NSEvent *) event
{

};

- (void) drawRect: (NSRect) rect
{
	register NSImage	* background = nil;

	background = [self worldMap];
	[background drawInRect: [self frame]];
};

@end

/***********************************************************************************************************************************
 *
 *	PreferencePaneController.m
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
#import "../aux.h"
#import "PreferencePaneController.h"

@interface PreferencePaneController (Private)

- (void) _paneLoaded: (NSNotification *) notification;

@end

@implementation PreferencePaneController (Private)

- (void) _paneLoaded: (NSNotification *) notification
{
	[lock unlock];
};

@end

@implementation PreferencePaneController

+ (id <PreferencePaneController>) loadPaneAtPath: (NSString *) path
{
	register void				* target = NULL;
	register Class				moduleClass = Nil;
	register id <PreferencePaneController>	result = nil;
	register BOOL				criteria = NO;

	moduleClass = [[NSBundle bundleWithPath: path] principalClass];
	criteria = ( class_getSuperclass ( moduleClass ) == [PreferencePaneController class] );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	result = [moduleClass new];

out:	return result;
};

- (id <PreferencePaneController>) initWithView: (NSView *) rootView title: (NSString *) aTitle icon: (NSImage *) anImage
{
	register void	* target = NULL;
	register BOOL	criteria = NO;

	self = [super init];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	[rootView retain];
	pane = rootView;
	[aTitle retain];
	title = aTitle;
	[anImage retain];
	icon = anImage;
	lock = nil;

out:	return self;
};

- (id <PreferencePaneController>) initWithNibFile: (NSString *) nib title: (NSString *) aTitle icon: (NSImage *) anImage
{
	register void	* target = NULL;
	register BOOL	criteria = NO;

	self = [super init];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	[nib retain];
	nibFile = nib;
	pane = nil;
	[aTitle retain];
	title = aTitle;
	[anImage retain];
	icon = anImage;
	lock = nil;
	//NSLog ( @"%@ initialized with nib file %@, title: %@, and image %p.", [self className], nibFile, title, icon );

out:	return self;
};

- (void) awakeFromNib
{
	[pane retain];
	[pane removeFromSuperview];
	[lock signal];
};

- (BOOL) deferedLoading
{
	return pane == nil;
};

- (void) loadPane
{
	NSNotificationCenter	* notifier = nil;

	NSLog ( @"Loading pane \"%@\"...", title );
	lock = [NSCondition new];
	[lock lock];
	notifier = [NSNotificationCenter defaultCenter];
	//NSLog ( @"%@.", [self className] );
	[notifier addObserver: self selector: @selector ( _paneLoaded: ) name: DefferedLoadingCompletedNotification object: nil];
	//NSLog ( @"Pane's owner: \"%@\"...", [self className] );
	[NSBundle loadNibNamed: nibFile owner: self];
	[lock wait];
	[lock release];
	lock = nil;
	NSLog ( @"Pane \"%@\" loaded.", title );
};

- (NSImage *) buttonImage
{
	return icon;
};

- (NSView *) pane
{
	return pane;
};

- (NSString *) title
{
	return title;
};

@end

/***********************************************************************************************************************************
 *
 *	Mouse.m
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
#include <unistd.h>

#import "../../aux.h"
#import "Mouse.h"

@implementation MousePaneController

- (id) init
{
	register NSString	* aTitle = nil,
				* nib = nil,
				* path = nil;
	register NSBundle	* bundle = nil;
	register NSImage	* image = nil;
	register void		* target = NULL;
	register BOOL		criteria = NO;
	
	bundle = [NSBundle bundleForClass: [self class]];
	//NSLog ( @"Loading image from %@.", [bundle bundlePath] );
	image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"Mouse" ofType: @"tiff" inDirectory: @""]];
	nib = @"Mouse";
	aTitle = @"Mouse";
	self = [super initWithNibFile: nib title: aTitle icon: image];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;

	//if ( self != nil ) {
		/*
		 * Initialize any ivar here that DOESN'T depend on the NIB.
		 */
in:		 ;
	//}

out:	return self;
};

- (void) awakeFromNib
{
	register NSAutoreleasePool	* pool = nil;
	register NSNotificationCenter	* notifier = nil;
	register NSUserDefaults		* defaults = nil;
	register NSDictionary		* domain = nil;
	register NSSize			intercellSpacing = NSZeroSize;
	register id			entry = nil;

	pool = [NSAutoreleasePool new];
	[super awakeFromNib];
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [defaults persistentDomainForName: NSGlobalDomain];
	entry = [domain objectForKey: @"SomeKey"];
	intercellSpacing = NSMakeSize ( 8.0, 5.0 );
	//[menuButtonActivationMatrix setIntercellSpacing: intercellSpacing];
	[mouseButtonSelectionMatrix setIntercellSpacing: intercellSpacing];
	//[mouseSpeedMatrix setIntercellSpacing: intercellSpacing];
	intercellSpacing.width = 12.0;
	//[doubleClickDelayMatrix setIntercellSpacing: intercellSpacing];
/*
 * initialize NIB-dependent ivars using the contens of entry, reading as many keys from the user defaults dictionary as deemed
 * appropriate.
 */
	usleep ( 100000 );
	NSLog ( @"Mouse preferences module interface loaded." );
	notifier = [NSNotificationCenter defaultCenter];
	[notifier postNotificationName: DefferedLoadingCompletedNotification object: self];
	[pool dealloc];
};
/*
 * Implement the custom methods you defined in the interface here.
 */
@end

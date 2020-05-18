/***********************************************************************************************************************************
 *
 *	Fonts.m
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
#import "Fonts.h"
#import "MenuView.h"
#import "TitleBarView.h"

@implementation FontsPaneController

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
	image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"Fonts" ofType: @"tiff" inDirectory: @""]];
	nib = @"Fonts";
	aTitle = @"Fonts";
	self = [super initWithNibFile: nib title: aTitle icon: image];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
/*
 * Initialize any ivar here that DOESN'T depend on the NIB.
 */
in:		 ;

out:	return self;
};

static void _initDefaultView ( register NSTextView * defaultView )
{
	register NSAttributedString	* contents = nil;
	register NSString		* string = nil;
	register NSData			* data = nil;
	register NSRect			frame = NSZeroRect;

	string = [[NSString alloc] initWithString: @"{\\rtf1\\ansi\\ansicpg1252\\cocoartf102{\\fonttbl\\f0\\fnil Helvetica;}\\paperw11900\\paperh16840\\margl1440\\margr1440\\margt1440\\viewkind0\\hyphauto1\\hyphfactor0\\pard\\tx720\\tx1440\\tx2160\\tx2880\\tx3600\\tx4320\\tx5040\\tx5760\\tx6480\\tx7200\\tx7920\\tx8640\\ri9020\\ql\\f0\\fs22\\b Date:\\b0 Wed, 4 Dec 91\\par\\b From:\\b0 any_user\\par\\b To:\\b0 me\\par\\b Subject:\\b0 Application Font}"];
	//NSLog ( @"Initialized the contents of the default view: %@", string );
	data = [string dataUsingEncoding: NSASCIIStringEncoding];
	//NSLog ( @"Document string %@", data != nil ? @"converted to data" : @"not converted to data!" );
	contents = [[NSAttributedString alloc] initWithRTF: data documentAttributes: NULL];
	[[defaultView textStorage] setAttributedString: contents];
	frame = [defaultView frame];
	frame.size.height -= 4;
	[defaultView setFrame: frame];
};

- (void) awakeFromNib
{
	register NSAutoreleasePool	* pool = nil;
	register NSNotificationCenter	* notifier = nil;
	register NSUserDefaults		* defaults = nil;
	register NSDictionary		* domain = nil;
	register NSTextView		* otherFontsTextView = nil;
	register id			entry = nil;
	

	pool = [NSAutoreleasePool new];
	[super awakeFromNib];
	[fixedPitchFontView setHidden: YES];
	[titleBarView setHidden: YES];
	[menuView setHidden: YES];
	[otherFontsView setHidden: NO];
	otherFontsTextView = [otherFontsView documentView];
	_initDefaultView ( otherFontsTextView );
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [defaults persistentDomainForName: NSGlobalDomain];
	entry = [domain objectForKey: @"SomeKey"];
/*
 * initialize NIB-dependent ivars using the contens of entry, reading as many keys from the user defaults dictionary as deemed
 * appropriate.
 */
	usleep ( 100000 );
	
	NSLog ( @"Fonts preferences module interface loaded." );
/*
 * DO NOT REMOVE THIS!!
 */
	notifier = [NSNotificationCenter defaultCenter];
	[notifier postNotificationName: DefferedLoadingCompletedNotification object: self];
	[pool dealloc];
};
/*
 * Implement the custom methods you defined in the interface here.
 */
@end

/***********************************************************************************************************************************
 *
 *	Keyboard.m
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
#import "../../aux.h"
#import "Keyboard.h"

@interface KeyboardPaneController (Private)

- (NSString *) keyForMenuEntryTitle: (NSString *) title;
- (NSString *) menuTitleForKey: (NSString *) key;

@end

@implementation KeyboardPaneController (Private)

- (NSString *) keyForMenuEntryTitle: (NSString *) entryTitle
{
	register NSString	* result = nil;

	//NSLog ( @"-keyForMenuEntryTitle: called." );
	result = [entryTitle stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	result = [entries objectForKey: result];
	//NSLog ( @"-keyForMenuEntryTitle: ended." );

	return result;
};

- (NSString *) menuTitleForKey: (NSString *) key
{
	register NSString	* result = nil;
	register NSArray	* keys = nil;

	//NSLog ( @"-menuTitleForKey: called." );
	//NSLog ( @"Menu entries dictionary: %@", entries );
	keys = [entries allKeysForObject: key];
	//NSLog ( @"keys: %@ for key %@", keys, key );
	result = [[keys firstObject] stringByAppendingString: @" "];
	//NSLog ( @"-menuTitleForKey: ended." );

	return result;
};

@end

@implementation KeyboardPaneController

- (id) init
{
	register NSString	* aTitle = nil,
				* nib = nil,
				* path = nil;
	register NSBundle	* bundle = nil;
	register NSImage	* image = nil;
	register void		* target = nil;
	register BOOL		criteria = NO;
	
	bundle = [NSBundle bundleForClass: [self class]];
	//NSLog ( @"Loading image from %@.", [bundle bundlePath] );
	image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"KeyboardPrefs" ofType: @"tiff" inDirectory: @""]];
	nib = @"Keyboard";
	aTitle = @"Keyboard";
	self = [super initWithNibFile: nib title: aTitle icon: image];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	//NSLog ( @"%@ instance initialized (title: \"%@\", image: %p).", [self className], [self title], [self buttonImage] );
	path = [bundle pathForResource: @"entries" ofType: @"plist"];
	entries = [[NSDictionary dictionaryWithContentsOfFile: path] copy];

out:	return self;
};

- (void) awakeFromNib
{
	register NSAutoreleasePool	* pool = nil;
	register NSNotificationCenter	* notifier = nil;
	register NSUserDefaults		* defaults = nil;
	register NSDictionary		* domain = nil;
	register id			entry = nil;

	pool = [NSAutoreleasePool new];
	[super awakeFromNib];
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [defaults persistentDomainForName: NSGlobalDomain];

	entry = [domain objectForKey: @"GSFirstAlternateKey"];
	[leftAltPopup selectItemWithTitle: [self menuTitleForKey: entry]];
	//NSLog ( @"Left Alt key: %@", entry );

	entry = [domain objectForKey: @"GSFirstCommandKey"];
	[leftCommandPopup selectItemWithTitle: [self menuTitleForKey: entry]];
	//NSLog ( @"Left Command key: %@", entry );

	entry = [domain objectForKey: @"GSFirstControlKey"];
	[leftControlPopup selectItemWithTitle: [self menuTitleForKey: entry]];
	//NSLog ( @"Left Ctrl key: %@", entry );

	entry = [domain objectForKey: @"GSSecondAlternateKey"];
	[rightAltPopup selectItemWithTitle: [self menuTitleForKey: entry]];
	//NSLog ( @"Right Alt key: %@", entry );

	entry = [domain objectForKey: @"GSSecondCommandKey"];
	[rightCommandPopup selectItemWithTitle: [self menuTitleForKey: entry]];
	//NSLog ( @"Right Command key: %@", entry );

	entry = [domain objectForKey: @"GSSecondControlKey"];
	[rightControlPopup selectItemWithTitle: [self menuTitleForKey: entry]];
	//NSLog ( @"Right Ctrl key: %@", entry );

	entry = [defaults objectForKey: @"GSModifiersAreKeys"];
	[shiftBugWorkaroundCheckbox setState: Choose ( entry != nil && [entry boolValue], NSOnState, NSOffState )];
	//NSLog ( @"GSModifiersAreKeys: %@", [entry boolValue] ? @"YES" : @"NO" );
	//NSLog ( @"Keyboard preferences module interface loaded." );
	notifier = [NSNotificationCenter defaultCenter];
	[notifier postNotificationName: DefferedLoadingCompletedNotification object: self];
	[pool dealloc];
};

- (void) setModifier: (id) sender
{
	register NSString		* modifier = nil;
	register NSUserDefaults		* defaults = nil;
	register NSMutableDictionary	* domain = nil;
	register NSAutoreleasePool	* pool = nil;
	register NSMenuItem		* item = nil;
	register NSString		* key = nil;
	register void			* target = NULL;
	register BOOL			criteria = NO;

	pool = [NSAutoreleasePool new];
	//NSLog ( @"Left Command menu: %p, right Command menu: %p, left Alt menu: %p, right Alt menu: %p, left Ctrl menu: %p, right Ctrl menu: %p.", leftCommandPopup, rightCommandPopup, leftAltPopup, rightAltPopup, leftControlPopup, rightControlPopup );
	item = [sender selectedItem];
	//NSLog ( @"item = %p, title: %@.", item, [item title] );
	modifier = [self keyForMenuEntryTitle: [item title]];
	//NSLog ( @"Modifier = %@, sender = %p (%@ class), sender title: %@", modifier, sender, [sender className], [item title] );
	criteria = ( modifier != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];
	//NSLog ( @"NSGlobalDomain dictionary: %@.", domain );
	criteria = ( sender == leftAltPopup );
	target = Choose ( criteria, && case1, && case7 );
	criteria = ( sender == leftCommandPopup );
	target = Choose ( criteria, && case2, target );
	criteria = ( sender == leftControlPopup );
	target = Choose ( criteria, && case3, target );
	criteria = ( sender == rightAltPopup );
	target = Choose ( criteria, && case4, target );
	criteria = ( sender == rightCommandPopup );
	target = Choose ( criteria, && case5, target );
	criteria = ( sender == rightControlPopup );
	target = Choose ( criteria, && case6, target );
	goto * target;
case1:	//NSLog ( @"Resetting the left alternate key..." );
	key = @"GSFirstAlternateKey";
	goto resume;
case2:	//NSLog ( @"Resetting the left command key..." );
	key = @"GSFirstCommandKey";
	goto resume;
case3:	//NSLog ( @"Resetting the left control key..." );
	key = @"GSFirstControlKey";
	goto resume;
case4:	//NSLog ( @"Resetting the right alternate key..." );
	key = @"GSSecondAlternateKey";
	goto resume;
case5:	//NSLog ( @"Resetting the right command key..." );
	key = @"GSSecondCommandKey";
	goto resume;
case6:	//NSLog ( @"Resetting the right control key..." );
	key = @"GSSecondControlKey";
	goto resume;
case7:	//NSLog ( @"Internal error." );
	key = nil;
resume:	//NSLog ( @"Adding %@ for key %@ to dictionary %@.", modifier, key, domain );
	[domain setObject: modifier forKey: key];
	[defaults setPersistentDomain: domain forName: NSGlobalDomain];
	[defaults synchronize];
	[domain release];
out:	[pool dealloc];
};

- (void) shiftModWorkaround: (id) sender
{
	register NSAutoreleasePool	* pool = nil;
	register BOOL			state = NO;
	register NSUserDefaults		* defaults = nil;
	register NSMutableDictionary	* domain = nil;
	register NSNumber		* number = nil;

	pool = [NSAutoreleasePool new];
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];
	state = [sender state] == NSOnState ? YES : NO;
	number = [NSNumber numberWithInt: (NSInteger) state];
	[domain setObject: number forKey: @"GSModifiersAreKeys"];
	[defaults setPersistentDomain: domain forName: NSGlobalDomain];
	[defaults synchronize];
	[domain release];
	[pool dealloc];
};

- (void) setInitialDelayAction: (id) sender
{
	register NSInteger	delay = -1,
				rate = -1;
	float			delays [ 4 ] = { 750, 500, 250, 100 },
				rates [ 4 ]  = { 1000, 500, 250, 100 };

	delay = [[sender selectedCell] tag];
	rate = [[repeatRateMatrix selectedCell] tag];
	//NSLog ( @"Selected delay: %d.", delay );
	// Call xset -r here.
};

- (void) setRepeatRateAction: (id) sender
{
	register NSInteger	rate = -1,
				delay = -1;
	float			delays [ 4 ] = { 750, 500, 250, 100 },
				rates [ 4 ]  = { 1000, 500, 250, 100 };

	rate = [[sender selectedCell] tag];
	delay = [[initialDelayMatrix selectedCell] tag];
	//NSLog ( @"Selected rate: %d.", rate );
};

@end

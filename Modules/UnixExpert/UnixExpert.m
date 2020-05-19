/***********************************************************************************************************************************
 *
 *	UnixExpert.m
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
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>

#import "../../aux.h"
#import "UnixExpert.h"

@interface UnixExpertPaneController (Private)

- (void) _setUmaskFromMatrix;
- (void) _setMatrixFromUmask: (mode_t) mode;

@end

@implementation UnixExpertPaneController (Private)

- (void) _setUmaskFromMatrix
{
	register mode_t		mode = -1;
	register int		row = -1,
				column = -1,
				mask = -1;
	register NSButtonCell	* cell = nil;

	mode = 0;
	mask = 0400;

	for ( column = 0; column < 3; column++ ) {
		for ( row = 0; row < 3; row++ ) {
			cell = [umaskMatrix cellAtRow: row column: column];
			mode |= Choose (( [cell state] == NSOnState ), mask, 0 );
			mask = mask >> 1;
		}
	}

	mode &= 0777;
/*
 * Notify Workspace about the umask change here.
 */
	NSLog ( @"umode set to %03o.", mode & 0666 );
};

- (void) _setMatrixFromUmask: (mode_t) mode
{
	register int		row = -1,
				column = -1,
				mask = -1;
	register NSButtonCell	* cell = nil;

	NSLog ( @"umode is %03o.", ~mode & 0666 );
	mask = 0400;

	for ( column = 0; column < 3; column++ ) {
		for ( row = 0; row < 3; row++ ) {
			cell = [umaskMatrix cellAtRow: row column: column];
			[cell setState: ( mode & mask ) != 0 ? NSOffState : NSOnState];
			mask = mask >> 1;
		}
	}
};

@end

@implementation UnixExpertPaneController

- (id) init
{
	register NSString	* aTitle = nil,
				* nib = nil;
	register NSBundle	* bundle = nil;
	register NSImage	* image = nil;
	
	bundle = [NSBundle bundleForClass: [self class]];
	//NSLog ( @"Loading image from %@.", [bundle bundlePath] );
	image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"UnixExpertPrefs" ofType: @"tiff" inDirectory: @""]];
	nib = @"UnixExpert";
	aTitle = @"Unix Expert";
	self = [super initWithNibFile: nib title: aTitle icon: image];

	return self;
};

- (void) awakeFromNib
{
	register NSAutoreleasePool	* pool = nil;
	register NSNotificationCenter	* notifier = nil;
	register NSUserDefaults		* defaults = nil;
	register NSDictionary		* domain = nil;
	register id			entry = nil;
	register NSInteger		state = NSMixedState;
	register mode_t			mask = 0;

	pool = [NSAutoreleasePool new];
	[super awakeFromNib];
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [defaults persistentDomainForName: NSGlobalDomain];
	mask = umask ( 0 );
	umask ( mask );
	[self _setMatrixFromUmask: mask];
	entry = [domain objectForKey: @"GSFileBrowserHideDotFiles"];
	//NSLog ( @"GSFileBrowserHideDotFiles: %@.", [entry boolValue] ? @"YES" : @"NO" );
	state = Choose ( entry != nil, Choose ( [entry boolValue], NSOffState, NSOnState ), NSOnState );
	[unixExpertCheckbox setState: state];
	entry = [domain objectForKey: @"PrivateWindowServer"];
	//NSLog ( @"PrivateWindowServer: %@.", [entry boolValue] ? @"YES" : @"NO" );
	state = Choose ( entry != nil, Choose ( [entry boolValue], NSOffState, NSOnState ), NSOnState );
	[privateWindowServerCheckbox setState: NSOnState];
	entry = [domain objectForKey: @"PrivateSoundServer"];
	//NSLog ( @"PrivateSoundServer: %@.", [entry boolValue] ? @"YES" : @"NO" );
	state = Choose ( entry != nil, Choose ( [entry boolValue], NSOffState, NSOnState ), NSOnState );
	[privateSoundServerCheckbox setState: state];
	entry = [domain objectForKey: @"ProtectedEPSDisplay"];
	//NSLog ( @"ProtectedEPSDisplay: %@.", [entry boolValue] ? @"YES" : @"NO" );
	state = Choose ( entry != nil, Choose ( [entry boolValue], NSOffState, NSOnState ), NSOnState );
	[protectedEPSDisplayCheckbox setState: state];
	domain = [defaults persistentDomainForName: @"Workspace"];
	entry = [domain objectForKey: @"LargeFileSystem"];
	//NSLog ( @"LargeFileSystem: %@", [entry boolValue] ? @"YES" : @"NO" );
	state = Choose ( entry != nil, Choose ( [entry boolValue], NSOffState, NSOnState ), NSOnState );
	[largeFileSystemCheckbox setState: state];
	notifier = [NSNotificationCenter defaultCenter];
	[notifier postNotificationName: DefferedLoadingCompletedNotification object: self];
	//NSLog ( @"Unix expert preferences module interface loaded." );
	[pool dealloc];
};

- (void) umaskMatrixChangeAction: (id) sender
{
	NSLog ( @"Changing the default umask setting." );
	[self _setUmaskFromMatrix];
};

- (void) unixExpertChangeAction: (id) sender
{
	register NSAutoreleasePool			* pool = nil;
	register NSUserDefaults				* defaults = nil;
	register NSMutableDictionary			* domain = nil;
	register NSNumber				* number = nil;
	register NSDistributedNotificationCenter	* notifier = nil;

	pool = [NSAutoreleasePool new];
	NSLog ( @"Changing the \"UNIX Expert\" setting." );
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];
	number = [NSNumber numberWithInteger: ( [unixExpertCheckbox state] == NSOffState ) ? 1 : 0];
	[domain setObject: number forKey: @"GSFileBrowserHideDotFiles"];
	[defaults setPersistentDomain: domain forName: NSGlobalDomain];
	[defaults synchronize];
	notifier = [NSDistributedNotificationCenter defaultCenter];
	/*[domain removeObjectForKey: @"GSFileBrowserHideDotFiles"];
	[domain setObject: number forKey: @"hide"];*/
	[notifier postNotificationName: @"GSHideDotFilesDidChangeNotification" object: nil userInfo: domain];
	[domain release];
	[pool dealloc];
};

- (void) largeFileSystemChangeAction: (id) sender
{
	register NSAutoreleasePool			* pool = nil;
	register NSUserDefaults				* defaults = nil;
	register NSMutableDictionary			* domain = nil;
	register NSNumber				* number = nil;
	register NSDistributedNotificationCenter	* notifier = nil;

	pool = [NSAutoreleasePool new];
	NSLog ( @"Changing the \"Large File System\" setting..." );
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [[defaults persistentDomainForName: @"Workspace"] mutableCopy];
	number = [NSNumber numberWithBool: ( [unixExpertCheckbox state] == NSOnState )];
	[domain setObject: number forKey: @"LargeFileSystem"];
	[defaults setPersistentDomain: domain forName: @"Workspace"];
	NSLog ( @"\"Large File System\" setting changed in memory." );
	[defaults synchronize];
	NSLog ( @"Setting dictionary in memory synchronized." );
	notifier = [NSDistributedNotificationCenter defaultCenter];
	[notifier postNotificationName: @"LargeFileSystemSettingDidChangeNotification" object: nil userInfo: domain];
	[domain release];
	[pool dealloc];
};

- (void) privateWindowServerChangeAction: (id) sender
{
	register NSAutoreleasePool			* pool = nil;
	register NSUserDefaults				* defaults = nil;
	register NSMutableDictionary			* domain = nil;
	register NSNumber				* number = nil;

	pool = [NSAutoreleasePool new];
	NSLog ( @"Changing the \"Private Window Server\" setting." );
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];
	number = [NSNumber numberWithBool: ( [unixExpertCheckbox state] == NSOnState )];
	[domain setObject: number forKey: @"PrivateWindowServer"];
	[defaults setPersistentDomain: domain forName: NSGlobalDomain];
	[defaults synchronize];
	[domain release];
	[pool dealloc];
};

- (void) privateSoundServerChangeAction: (id) sender
{
	register NSAutoreleasePool			* pool = nil;
	register NSUserDefaults				* defaults = nil;
	register NSMutableDictionary			* domain = nil;
	register NSNumber				* number = nil;

	pool = [NSAutoreleasePool new];
	NSLog ( @"Changing the \"Private Sound Server\" setting." );
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];
	number = [NSNumber numberWithBool: ( [unixExpertCheckbox state] == NSOnState )];
	[domain setObject: number forKey: @"PrivateSoundServer"];
	[defaults setPersistentDomain: domain forName: NSGlobalDomain];
	[defaults synchronize];
	[domain release];
	[pool dealloc];
};

- (void) protectedEPSDisplayChangeAction: (id) sender
{
	register NSAutoreleasePool			* pool = nil;
	register NSUserDefaults				* defaults = nil;
	register NSMutableDictionary			* domain = nil;
	register NSNumber				* number = nil;
	register NSDistributedNotificationCenter	* notifier = nil;

	pool = [NSAutoreleasePool new];
	NSLog ( @"Changing the \"Protected EPS Display\" setting." );
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];
	number = [NSNumber numberWithBool: ( [unixExpertCheckbox state] == NSOnState )];
	[domain setObject: number forKey: @"ProtectedEPSDisplay"];
	[defaults setPersistentDomain: domain forName: NSGlobalDomain];
	[defaults synchronize];
	notifier = [NSDistributedNotificationCenter defaultCenter];
	[notifier postNotificationName: @"ProtectedEPSDisplayDidChangeNotification" object: nil userInfo: domain];
	[domain release];
	[pool dealloc];

};

@end

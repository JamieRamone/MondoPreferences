/***********************************************************************************************************************************
 *
 *	AppController.m
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
#import "aux.h"
#import "AppController.h"
#import "LayoutController.h"
#import "InfoPanelController.h"
#import "PreferencePaneController.h"

static inline NSMutableArray * findBundlesInPath (NSMutableString * domain)
{
	register NSFileManager		* fileManager = nil;
	register NSMutableArray		* bundles = nil;
	register NSEnumerator		* enumerator = nil;
	register NSMutableString	* current = nil;
	register void			* target = NULL;
	register BOOL			criteria = NO;

	fileManager = [NSFileManager defaultManager];
	bundles = [NSMutableArray new];
	enumerator = [[fileManager directoryContentsAtPath: domain] objectEnumerator];
	current = [enumerator nextObject];
	criteria = ( current != nil );

	while ( criteria ) {
		criteria = ( [[current pathExtension] isEqualToString: @"preference"] );
		target = Choose ( criteria, && add, && skip );
		goto * target;
add:		[bundles addObject: [domain stringByAppendingPathComponent: current]];
skip:		current = [enumerator nextObject];
		criteria = ( current != nil );
	}

	return bundles;
};

@implementation AppController

+ (void) initialize
{
	register NSUserDefaults		* defaults = nil;
	register NSMutableArray		* searchList = nil;
	register NSDictionary		* dictionary = nil;
	register NSMutableDictionary	* startupDefaults = nil;
/*
 * Register your app's defaults here by adding objects to the
 * dictionary, eg.
 *
 * [defaults setObject:anObject forKey:keyForThatObject];
 *
 */
	defaults = [NSUserDefaults standardUserDefaults];
	searchList = [NSMutableArray arrayWithCapacity: 3];
/*
 * Clear the GSCommandKeyString string in the NSGlobalDomain (global) preference to make sure the '#' character doesn't appear in
 * the menu entries.
 */
	dictionary = [defaults persistentDomainForName: NSGlobalDomain];
	startupDefaults = [NSMutableDictionary dictionaryWithDictionary: dictionary];
	[startupDefaults setObject: @"" forKey: @"GSCommandKeyString"];
	[defaults setPersistentDomain: startupDefaults forName: NSGlobalDomain];
/*
 * Continue with the rest of the initialization here.
 */
	startupDefaults = [NSMutableDictionary alloc];
	[searchList addObject: [NSString stringWithString: @"System"]];
	[searchList addObject: [NSString stringWithString: @"Local"]];
	[searchList addObject: [NSString stringWithString: @"User"]];
	[startupDefaults setObject: searchList forKey: @"searchList"];
	//Add defaults here.
	[defaults registerDefaults: startupDefaults];
	[defaults synchronize];
};

- (id) init
{
	register void	* target = NULL;
	register BOOL	criteria = NO;

	self = [super init];
	criteria = ( self != nil );
	target = Choose ( criteria, && finish, && skip );
	goto * target;
finish:	layoutController = nil;
	loadedModules = [[NSMutableArray alloc] initWithCapacity: 8];

skip:	return self;
};

- (void) dealloc
{
	[layoutController release];
	[super dealloc];
};

/*- (void) awakeFromNib
{
	NSLog ( @"Main interface loaded." );
};*/

- (AppIconView *) iconView
{
	register AppIconView			* result = nil;

	result = iconView;

	return result;
};

- (void) setIconView: (AppIconView *) newIconView
{
	[newIconView retain];
	[iconView release];
	iconView = newIconView;
};

- (NSString *) pathForModule: (NSString *) moduleName inPathsArray: (NSArray *) paths
{
	register NSEnumerator			* dispenser = nil;
	register NSString			* result = nil;
	register BOOL				criteria = NO;

	dispenser = [paths objectEnumerator];
	result = [dispenser nextObject];
	criteria = ( result != nil && [[result lastPathComponent] compare: moduleName] != NSOrderedSame );

	while ( criteria ) {
		//NSLog ( @"Checking %@ in %@.", moduleName, [result lastPathComponent], index );
		result = [dispenser nextObject];
		criteria = ( result != nil && [[result lastPathComponent] compare: moduleName] != NSOrderedSame );
	}

	return result;
};

- (void) loadModules: (NSDictionary *) modules inPath: (NSString *) root
{
	register NSFileManager			* fileManager = nil;
	register NSEnumerator			* dispenser = nil;
	register NSString			* path = nil,
						* module = nil;
	register NSArray			* listing = nil;
	register void				* target = nil;
	register id<PreferencePaneController>	controller = nil;
	register BOOL				criteria = NO;

	NSLog ( @"Now loading modules %@ in paths %@...", modules, root );
	fileManager = [NSFileManager defaultManager];
	listing = [fileManager directoryContentsAtPath: root];
	dispenser = [modules objectEnumerator];
	module = [dispenser nextObject];
	layoutController = [LayoutController sharedInstance];
	criteria = ( module != nil );

	while ( criteria ) {
		path = [self pathForModule: module inPathsArray: listing];
		module = [NSString stringWithFormat:@"%@/%@", root, path ];
		NSLog ( @"Now loading module %@...", path );
		controller = [PreferencePaneController loadPaneAtPath: module];
		criteria = ( controller != nil );
		target = Choose ( criteria, && load, && skip );
		goto * target;
load:		//NSLog ( @"Preference module %@ loaded.", path );
		[loadedModules addObject: controller];
		[layoutController loadPane: controller];
skip:		module = [dispenser nextObject];
		criteria = ( module != nil );
	}
};

- (void) loadModuesInPath: (NSString *) root
{
	register NSFileManager			* fileManager = nil;
	register NSEnumerator			* dispenser = nil;
	register NSString			* module = nil;
	register void				* target = nil;
	register id<PreferencePaneController>	controller = nil;
	register BOOL				criteria = NO;

	NSLog ( @"Loading modules in paths %@...", root );
	fileManager = [NSFileManager defaultManager];
	dispenser = [[fileManager directoryContentsAtPath: root] objectEnumerator];
	module = [dispenser nextObject];
	layoutController = [LayoutController sharedInstance];
	criteria = ( module != nil );

	while ( criteria ) {
		criteria = ( [module hasSuffix: @".preference"] );
		target = Choose ( criteria, && check, && skip );
		goto * target;
check:		NSLog ( @"Loading module %@...", module );
		controller = [PreferencePaneController loadPaneAtPath: module];
		criteria = ( controller != nil );
		target = Choose ( criteria, && load, && failed );
		goto * target;
load:		//NSLog ( @"Preference module %@ loaded.", module );
		[loadedModules addObject: controller];
		[layoutController loadPane: controller];
		goto skip;
failed:		NSLog ( @"Loading module %@ failed!", module );
skip:		module = [dispenser nextObject];
		criteria = ( module != nil );
	}
};

- (void) appIconViewAutoUpdated: (NSNotification *) notification
{
	[NSApp setApplicationIconImage: [iconView icon]];
};

- (void) applicationDidFinishLaunching: (NSNotification *) notification
{
	register NSBundle	* bundle = nil;
	register NSArray	* paths = nil;
	register NSDictionary	* modules = nil;
	register NSString	* path = nil;
	//register BOOL		result = NO;

	//NSLog ( @"Application almost finished launching." );
	[NSApp hide: nil];
	bundle = [NSBundle mainBundle];
	path = [bundle pathForResource: @"modules" ofType: @"plist"];
	modules = [[[NSDictionary dictionaryWithContentsOfFile: path] objectForKey: @"modules"] copy];
	path = [[[NSDictionary dictionaryWithContentsOfFile: path] objectForKey: @"AppIcon"] copy];
	path = [NSString stringWithFormat: @"%@/%@", [bundle bundlePath], path];
	//NSLog ( @"Loading the app icon view at %@.", path );
	bundle = [NSBundle bundleWithPath: path];
	/*result =*/ [bundle load];
	//NSLog ( @"App icon view %@ %@", path, result ? @"loaded." : @"not loaded!" );
	iconView = [[bundle principalClass] new];
	[iconView retain];
	[[NSNotificationCenter defaultCenter] addObserver: self
						 selector: @selector ( appIconViewAutoUpdated: )
						     name: PreferencesAppIconViewAutoUpdatedNotification
						   object: nil];
	//NSLog ( @"Loaded app icon view %@.", iconView );
	[iconView update];
	[NSApp setApplicationIconImage: [iconView icon]];
	path = [[NSBundle mainBundle] bundlePath];
	[self loadModules: modules inPath: path];
	paths = NSSearchPathForDirectoriesInDomains ( NSLibraryDirectory, NSUserDomainMask, NO );
	path = [[paths firstObject] stringByAppendingString: @"/bundles"];
	[self loadModuesInPath: path];
	paths = NSSearchPathForDirectoriesInDomains ( NSLibraryDirectory, NSLocalDomainMask, NO );
	path = [[paths firstObject] stringByAppendingString: @"/bundles"];
	[self loadModuesInPath: path];
	paths = NSSearchPathForDirectoriesInDomains ( NSLibraryDirectory, NSSystemDomainMask, NO );
	path = [[paths firstObject] stringByAppendingString: @"/bundles"];
	[self loadModuesInPath: path];
	//NSLog ( @"Application finished launching." );
	[NSApp hide: nil];
};

- (void) applicationDidUnhide: (id) sender
{
	//NSLog ( @"Showing main window..." );
	[layoutController show];
	//NSLog ( @"Main window shown." );
};

/*- (BOOL) applicationShouldTerminate: (id) sender
{
	return YES;
};*/

/*- (void) applicationWillTerminate: (NSNotification *) notifification
{
	;
};*/

- (BOOL) application: (NSApplication *) application openFile: (NSString *) fileName
{
	return NO; // If the extension is .preference and it's a bundle, load it, add it and open it's pane, and returned YES.
};

- (void) showInfoPanel: (NSMenuItem *) sender
{
	[InfoPanelController showPanel];
};

@end

/***********************************************************************************************************************************
 *
 *	Sound.m
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

#import <Foundation/NSString.h>

#import "../../aux.h"
#import "Sound.h"
#import "MixerView.h"

static snd_mixer_t		* _mixer = NULL;

#define bail(error,errorMessage)	\
	if ( error < 0 ) {		\
		NSLog ( errorMessage );	\
					\
		return;			\
	}

static struct snd_mixer_selem_regopt _options = {
	.ver = 1,
	.abstract = SND_MIXER_SABSTRACT_NONE,
	.device = "default",
};

@interface SoundPaneController (private)

- (void) _initializeMixerView: (MixerView *) view asInput: (BOOL) flag;
- (void) _loadSoundsAtPath: (NSString *) aPath;
- (void) _loadSounds;

@end

@implementation SoundPaneController (private)

- (void) _initializeMixerView: (MixerView *) view asInput: (BOOL) flag
{
	register snd_mixer_elem_t	* control = NULL;
	snd_mixer_selem_id_t		* controlId = NULL;
	register void			* target = NULL;
	register Routine		hasVolume,
					hasSwitch;
	register BOOL			criteria = NO;
	register int			error = -1;

	//NSLog ( @"_initializeMixerView:asInput: called." );
	error = snd_mixer_open ( & _mixer, 0 );
	bail ( error, @"Unable to open mixer." );
	error = snd_mixer_selem_register ( _mixer, & _options, NULL );
	bail ( error, @"Unable to open mixer." );
	//NSLog ( @"Mixer open." );
	error = snd_mixer_load ( _mixer );
	bail ( error, @"Unable to load mixer controls." );
	//NSLog ( @"Mixer loaded." );
	//error = snd_mixer_selem_id_malloc ( & _mixerId );
	//bail ( error, @"Out of memory." );
	criteria = flag;
	hasVolume = (Routine) Choose ( criteria, & snd_mixer_selem_has_capture_volume, & snd_mixer_selem_has_playback_volume );
	hasSwitch = (Routine) Choose ( criteria, & snd_mixer_selem_has_capture_switch, & snd_mixer_selem_has_playback_switch );
	snd_mixer_selem_id_alloca ( & controlId );

	for ( control = snd_mixer_first_elem ( _mixer ); control != NULL; control = snd_mixer_elem_next ( control ) ) {
		criteria = ( hasVolume ( control ) || hasSwitch ( control ));
		target = Choose ( criteria, && add, && skip );
		goto * target;
add:		snd_mixer_selem_get_id ( control, controlId );
		//NSLog ( @"Adding control %s to %@ mixer view...", snd_mixer_selem_id_get_name ( controlId ), Choose ( flag, @"input", @"output" ));
		[view addElementWithMixerControl: control selectable: flag];
skip:		continue;
	}
};

- (void) _loadSoundsAtPath: (NSString *) aPath
{
	register NSFileManager	* fileManager = nil;
	register NSArray	* listing = nil;
	register NSString	* path = nil,
				* sound = nil;
	register NSEnumerator	* dispenser = nil;
	register void		* target = NULL;
	register BOOL		criteria = false;

	fileManager = [NSFileManager defaultManager];
	listing = [fileManager contentsOfDirectoryAtPath: aPath error: NULL];
	dispenser = [listing reverseObjectEnumerator];
	path = [dispenser nextObject];
	criteria = ( path != nil && ! [path hasSuffix: @"Sounds"] );

	while ( criteria ) {
		NSLog ( @"Checking directory %@.", path );
		path = [dispenser nextObject];
		criteria = ( path != nil && ! [path hasSuffix: @"Sounds"] );
	}

	criteria = ( path != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	path = [NSString stringWithFormat: @"%@/%@", aPath, path];
	listing = [fileManager contentsOfDirectoryAtPath: path error: NULL];
	NSLog ( @"Found %d sounds in directory %@ (%@).", [listing count], path, listing );
	dispenser = [listing objectEnumerator];
	sound = [dispenser nextObject];
	criteria = ( sound != nil );

	while ( criteria ) {
		sound = [NSString stringWithFormat: @"%@/%@", path, sound];
		[sounds addObject: sound];
		sound = [dispenser nextObject];
		criteria = ( sound != nil );
	}

out:	return;
};

- (void) _loadSounds
{
	register NSArray	* listing = nil;

	NSLog ( @"Loading system sounds..." );
	listing = NSSearchPathForDirectoriesInDomains ( NSLibraryDirectory, NSUserDomainMask, YES );
	NSLog ( @"Checking for sounds in directory %@.", [listing firstObject] );
	[self _loadSoundsAtPath: [listing firstObject]];
	listing = NSSearchPathForDirectoriesInDomains ( NSLibraryDirectory, NSSystemDomainMask, YES );
	NSLog ( @"Checking for sounds in directory %@.", [listing firstObject] );
	[self _loadSoundsAtPath: [listing firstObject]];
	listing = NSSearchPathForDirectoriesInDomains ( NSLibraryDirectory, NSLocalDomainMask, YES );
	NSLog ( @"Checking for sounds in directory %@.", [listing firstObject] );
	[self _loadSoundsAtPath: [listing firstObject]];
	NSLog ( @"Loading complete, found %d sounds.", [sounds count] );
};

- (NSInteger) browser: (NSBrowser *) browser numberOfRowsInColumn: (NSInteger) column
{
	register NSAutoreleasePool	* pool = nil;
	register void			* target = NULL;
	register BOOL			criteria = NO;
	register NSInteger		result = -1;

	pool = [NSAutoreleasePool new];
	criteria = ( sounds == nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	sounds = [NSMutableArray arrayWithCapacity: 8];
	[sounds retain];
	[self _loadSounds];
out:	result = [sounds count];
	//NSLog ( @"Number of sounds to be shown in browser: %d", result );
	[pool release];

	return result;
};

- (void) browser: (NSBrowser *) browser willDisplayCell: (id) cell atRow: (NSInteger) row column: (NSInteger) column
{
	register NSAutoreleasePool	* pool = nil;
	register NSString		* sound = nil;

	pool = [NSAutoreleasePool new];
	//NSLog ( @"Displaying row %d of column %d", row, column );
	sound = [sounds objectAtIndex: row];
	sound = [sound lastPathComponent];
	sound = [sound stringByDeletingPathExtension];
	[cell setTitle: sound];
	[cell setLeaf: YES];
	[pool release];
};

@end

@implementation SoundPaneController

- (id) init
{
	register NSString	* aTitle = nil,
				* nib = nil;
	register NSBundle	* bundle = nil;
	register NSImage	* image = nil;
	
	bundle = [NSBundle bundleForClass: [self class]];
	//NSLog ( @"Loading image from %@.", [bundle bundlePath] );
	image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"Sound" ofType: @"tiff" inDirectory: @""]];
	nib = @"Sound";
	aTitle = @"Sound";
	self = [super initWithNibFile: nib title: aTitle icon: image];

	return self;
};

- (void) dealloc
{
	[sounds release];
	[super dealloc];
};

- (void) awakeFromNib
{
	register NSAutoreleasePool	* pool = nil;
	register NSDictionary		* domain = nil;
	register NSNotificationCenter	* notifier = nil;
	register NSUserDefaults		* defaults = nil;
	register id			entry = nil;
	register NSInteger		row = -1;

	pool = [NSAutoreleasePool new];
	[super awakeFromNib];
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [defaults persistentDomainForName: NSGlobalDomain];
	entry = [domain objectForKey: SystemBeepKey];
	systemBeep = entry;
/*
 * initialize NIB-dependent ivars using the contents of entry, reading as many keys from the user defaults dictionary as deemed
 * appropriate.
 */
	[inputBrowser setHidden: YES];
	[self _initializeMixerView: [inputBrowser documentView] asInput: YES];
	[outputBrowser setHidden: YES];
	[self _initializeMixerView: [outputBrowser documentView] asInput: NO];
	[systemBeepBrowser setHidden: NO];
	[systemBeepBrowser loadColumnZero];
	row = [sounds indexOfObject: systemBeep];
	[systemBeepBrowser selectRow: row inColumn: 0];
	currentBrowser = systemBeepBrowser;
	NSLog ( @"Sound preferences module interface loaded." );
/*
 * DO NOT REMOVE THIS!!
 */
	notifier = [NSNotificationCenter defaultCenter];
	[notifier postNotificationName: DefferedLoadingCompletedNotification object: self];
	[pool dealloc];
};
/*
 * NIB actions.
 */
- (void) rowSelected: (NSBrowser *) sender
{
	register NSAutoreleasePool	* pool = nil;
	register NSMutableDictionary	* domain = nil;
	register NSString		* sound = nil;
	register NSUserDefaults		* defaults = nil;
	register NSInteger		row = -1;

	pool = [NSAutoreleasePool new];
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	domain = [[defaults persistentDomainForName: NSGlobalDomain] mutableCopy];
	row = [sender selectedRowInColumn: 0];
	sound = [sounds objectAtIndex: row];
	NSLog ( @"Selected sound %@", sound );
	[domain setObject: sound forKey: SystemBeepKey];
	[defaults setPersistentDomain: domain forName: NSGlobalDomain];
	[defaults synchronize];
	[pool dealloc];
};

- (void) selectionChanged: (NSPopUpButton *) sender
{
	[currentBrowser setHidden: YES];

	switch ( [sender indexOfSelectedItem] ) {
		case 0:	[inputBrowser setHidden: NO];
			currentBrowser = inputBrowser;
			//NSLog ( @"Displaying inputBrowser." );
			break;
		case 1:	[outputBrowser setHidden: NO];
			currentBrowser = outputBrowser;
			//NSLog ( @"Displaying OutputBrowser." );
			break;
		case 2:	[systemBeepBrowser setHidden: NO];
			currentBrowser = systemBeepBrowser;
			//NSLog ( @"Displaying systemBeepBrowser." );
	}

	[currentBrowser setNeedsDisplay: YES];
};

@end

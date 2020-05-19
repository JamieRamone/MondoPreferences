/***********************************************************************************************************************************
 *
 *	MixerElementController.m
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
#import <AppKit/NSNibLoading.h>

#import "../../aux.h"

#import "Sound.h"
#import "MixerView.h"
#import "MixerElementController.h"

static BOOL _getMuteState ( register const snd_mixer_elem_t * control, register const snd_mixer_selem_channel_id_t channel, register const BOOL capture )
{
	register Routine	function = NULL;
	BOOL			result = NO;

	function = (Routine) Choose ( capture, & snd_mixer_selem_get_capture_switch, & snd_mixer_selem_get_playback_switch );
	function ((snd_mixer_elem_t *) control, channel, & result );

	return result;
};

static void _setMuteState ( register const snd_mixer_elem_t * control, register const snd_mixer_selem_channel_id_t channel, register const BOOL capture, register const BOOL state )
{
	register Routine	function = NULL;

	function = (Routine) Choose ( capture, & snd_mixer_selem_set_capture_switch, & snd_mixer_selem_set_playback_switch );
	function ((snd_mixer_elem_t *) control, channel, state );
};

@interface MixerElementController (Private)

- (MixerElementController *) initWithMixerControl: (snd_mixer_elem_t *) channel asInput: (BOOL) flag;
- (void) _setSelected: (BOOL) flag;
- (NSInteger) _volumeForChannel: (snd_mixer_selem_channel_id_t) channel;
- (void) _setVolume: (NSInteger) volume forChannel: (snd_mixer_selem_channel_id_t) channel;

@end

@implementation MixerElementController (Private)

- (MixerElementController *) initWithMixerControl: (snd_mixer_elem_t *) control asInput: (BOOL) flag
{
	register NSString		* interface = nil;
	register void			* target = nil;
	register int			//error = -1,
					channel = SND_MIXER_SCHN_UNKNOWN;
	register Routine		function = NULL;
	register BOOL			criteria = NO,
					isMono = NO;
	snd_mixer_selem_channel_id_t	channels [ 4 ] = { SND_MIXER_SCHN_UNKNOWN };

	self = [super init];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	criteria = flag;
	//NSLog ( @"%@ MixerElementContoller instance initializing...", Choose ( criteria, @"Input", @"Output" ));
	mixerControl = control;
	isSelectable = flag && snd_mixer_selem_has_capture_switch_exclusive ( mixerControl );
	criteria = flag;
	//NSLog ( @"Setting up routine pointers..." );
	hasChannel = (Routine) Choose ( criteria, & snd_mixer_selem_has_capture_channel, & snd_mixer_selem_has_playback_channel );
	getVolumeForChannel = (Routine) Choose ( criteria, & snd_mixer_selem_get_capture_volume, & snd_mixer_selem_get_playback_volume );
	setVolumeForChannel = (Routine) Choose ( criteria, & snd_mixer_selem_set_capture_volume, & snd_mixer_selem_set_playback_volume );
	//NSLog ( @"Setting up flags..." );
	function = (Routine) Choose ( criteria, & snd_mixer_selem_is_capture_mono, & snd_mixer_selem_is_playback_mono );
	isMonophonic = function ( mixerControl );
	//NSLog ( @"%@ monophonic.", Choose ( isMonophonic, @"Is", @"Isn't" ));
	function = (Routine) Choose ( criteria, & snd_mixer_selem_has_capture_volume, & snd_mixer_selem_has_playback_volume );
	hasVolumeControl = function ( mixerControl );
	//NSLog ( @"%@ volume control.", Choose ( hasVolumeControl, @"Has", @"Doesn't have" ));
	function = (Routine) Choose ( criteria, & snd_mixer_selem_has_capture_switch, & snd_mixer_selem_has_playback_switch );
	canMute = function ( mixerControl ) && hasVolumeControl;
	//NSLog ( @"%@ mute control.", Choose ( canMute, @"Has", @"Doesn't have" ));
	//NSLog ( @"Checking for left channel..." );
	channels [ 0 ] = SND_MIXER_SCHN_FRONT_LEFT;
	channels [ 1 ] = SND_MIXER_SCHN_REAR_LEFT;
	channels [ 2 ] = SND_MIXER_SCHN_SIDE_LEFT;
	channels [ 3 ] = SND_MIXER_SCHN_MONO;
	left = SND_MIXER_SCHN_UNKNOWN;
/*
 * Locate the left channel for this control (or only one if mono).
 */
	for ( channel = 0; channel < 4 && left == SND_MIXER_SCHN_UNKNOWN; channel++ ) {
		criteria = hasChannel ( control, channel );
		left = Choose ( criteria, channels [ channel ], SND_MIXER_SCHN_UNKNOWN );
	}

	//NSLog ( @"Found left channel %d.", left );
/*
 * If the function says it's hasn't got monophonic input, get the right channel.
 */
	channels [ 0 ] = SND_MIXER_SCHN_FRONT_RIGHT;
	channels [ 1 ] = SND_MIXER_SCHN_REAR_RIGHT;
	channels [ 2 ] = SND_MIXER_SCHN_SIDE_RIGHT;
	right = SND_MIXER_SCHN_UNKNOWN;

	for ( channel = 0; ! isMono && channel < 3 && right == SND_MIXER_SCHN_UNKNOWN; channel++ ) {
		criteria = hasChannel ( mixerControl, channel );
		right = Choose ( criteria, channels [ channel ], SND_MIXER_SCHN_UNKNOWN );
	}
/*
 * If it's monophonic, then we load that interface, otherwise default to stereo.
 */
	//NSLog ( @"Found right channel %d.", right );
	criteria = ( isMonophonic );
	interface = Choose ( criteria, MonoInterface, StereoInterface );
/*
 * If its got volume control, set it up as the maximum and minimum values allowed for the control.
 */
	criteria = hasVolumeControl;
	//NSLog ( @"Control %@ configurable volume.", Choose ( criteria, @"has", @"doesn't have" ));
	minimum = 0;
	maximum = 0;
	target = Choose ( criteria, && range, && norange );
	goto * target;
range:	criteria = flag;
	function = (Routine) Choose ( criteria, & snd_mixer_selem_get_capture_volume_range, & snd_mixer_selem_get_playback_volume_range );
	/*error = */function ( mixerControl, & minimum, & maximum );
	//NSLog ( @"Maximum value for control: %d, minimum: %d, error = %d, reason: %s.", maximum, minimum, error, snd_strerror ( error ));
norange:[NSBundle loadNibNamed: interface owner: self];
	//NSLog ( @"MixerElementContoller instance initialized." );

out:	return self;
};

- (void) _setSelected: (BOOL) flag
{
	isSelected = flag;
	[view setFillColor: Choose ( isSelected, [NSColor whiteColor], [NSColor controlColor] )];
	[view setNeedsDisplay: YES];
	[hashMarksBox setFillColor: Choose ( isSelected, [NSColor whiteColor], [NSColor controlColor] )];
	[hashMarksBox setNeedsDisplay: YES];
	[selectedChannelButton setState: Choose ( flag, NSOnState, NSOffState )];
	//NSLog ( @"Channel %@ %@.", [titleLabel stringValue], isSelected ? @"selected" : @"deselected" );
};

- (NSInteger) _volumeForChannel: (snd_mixer_selem_channel_id_t) channel
{
	register BOOL	criteria = NO;
	//register int	error = -1;
	long		result = -1;

	/*error =*/ getVolumeForChannel ( mixerControl, channel, & result );
	//NSLog ( @"Raw value of control's volume for channel %d: %d (maximum: %d). Error code: %d.", channel, result, maximum, error );
	result *= 100;
	criteria = ( maximum != 0 );
	//NSLog ( @"Maximum != 0: %@.", Choose ( criteria, @"true", @"false" ));
	result /= Choose ( criteria, maximum, -result );
	//NSLog ( @"Normalized ([0..99]) volume: %d.", result );

	return result;
};

- (void) _setVolume: (NSInteger) volume forChannel: (snd_mixer_selem_channel_id_t) channel
{
	register long	realVolume = -1;

	realVolume = volume;
	//NSLog ( @"New volume value: %d", realVolume );
	realVolume *= maximum;
	//NSLog ( @"Scaled-up volume value: %d", realVolume );
	realVolume = (NSInteger) ((double) realVolume / 100.0 );
	//NSLog ( @"Normalized volume value: %d", realVolume );
	setVolumeForChannel ( mixerControl, channel, realVolume );
};

@end

@implementation MixerElementController

+ (MixerElementController *) controllerWithMixerControl: (snd_mixer_elem_t *) control asInput: (BOOL) flag
{
	register MixerElementController	* result = nil;

	result = [[MixerElementController alloc] initWithMixerControl: control asInput: flag];

	return result;
};

- (void) awakeFromNib
{
	register NSColor	* color = nil;
	register NSString	* name = nil;
	register void		* target = NULL;
	register NSRect		box = NSZeroRect;
	register SEL		selector = NULL;
	register IMP		method = NULL;
	register BOOL		criteria = NO;
	snd_mixer_selem_id_t	* controlId = NULL;

	//NSLog ( @"MixerElementController -awakeFromNib called." );
/*
 * Migrate the view from the NIB window by removig it from its view hierarchy, so it can be added to the pane.
 */
	[view retain];
	[view removeFromSuperview];
	//NSLog ( @"1." );
/*
 * Now that we got the main view, we don't need the window any more.
 */
	[window close];
	//NSLog ( @"2." );
/*
 * Configure the box type so it can appear "lit up" when we select it.
 */
	color = [NSColor controlColor];
	[view setBoxType: NSBoxCustom];
	[view setFillColor: color];
	//NSLog ( @"3." );
/*
 * And the box containing the hash marks.
 */
	[hashMarksBox setBoxType: NSBoxCustom];
	[hashMarksBox setFillColor: color];
	//NSLog ( @"4." );
/*
 * Get the title from the mixer channel and put it on the label for this purpose.
 */
	snd_mixer_selem_id_malloc ( & controlId );
	snd_mixer_selem_get_id ( mixerControl, controlId );
	name = [NSString stringWithCString: snd_mixer_selem_id_get_name ( controlId )];
	[titleLabel setStringValue: name];
	//NSLog ( @"5 (%@).", name );
/*
 * Hide components that shouldn't be available if appropriate.
 */
	criteria = ! canMute;
	target = Choose ( criteria, && adjust, && skip1 );
	goto * target;
adjust:	[muteButton setHidden: criteria];
	box = [leftVolumeSlider frame];
	box.origin.x += (int) [muteButton frame].size.width / 2 + 5;
	[leftVolumeSlider setFrame: box];
	box = [rightVolumeSlider frame];
	box.origin.x += (int) [muteButton frame].size.width / 2 + 5;
	[rightVolumeSlider setFrame: box];
	box = [hashMarksBox frame];
	box.origin.x += (int) [muteButton frame].size.width / 2 + 5;
	[hashMarksBox setFrame: box];
	//NSLog ( @"Mute button %@.", Choose ( criteria, @"hidden", @"left alone" ));
skip1:	criteria = ! isSelectable;
	[selectedChannelButton setHidden: criteria];
	target = Choose ( ! criteria, && select, && skip2 );
	goto * target;
select:	[self _setSelected: _getMuteState ( mixerControl, left, YES )];
skip2:	criteria = ! hasVolumeControl;
	[leftVolumeSlider setHidden: criteria];
	[rightVolumeSlider setHidden: criteria];
	[hashMarksBox setHidden: criteria];
	[leftMuteButton setHidden: criteria];
	[rightMuteButton setHidden: criteria];
	//NSLog ( @"6." );
	target = Choose ( ! criteria, && in, && out );
	goto * target;
/*
 * Fix GORM breakage of the sliders by performing some basic configuration on them.
 */
in:	[leftVolumeSlider setMaxValue: 100.0];
	[leftVolumeSlider setMinValue: 1.0];
	[leftVolumeSlider setNumberOfTickMarks: maximum];
	[rightVolumeSlider setMaxValue: 100.0];
	[rightVolumeSlider setMinValue: 1.0];
	[rightVolumeSlider setNumberOfTickMarks: maximum];
	//NSLog ( @"7." );
/*
 * Now load their values.
 */
	[leftVolumeSlider setIntegerValue: [self _volumeForChannel: left]];
	//NSLog ( @"a." );
	criteria = ( right != SND_MIXER_SCHN_UNKNOWN );
	selector = Choose ( criteria, @selector ( setIntegerValue:), @selector ( nop ));
	method = objc_msg_lookup ( rightVolumeSlider, selector );
	method ( rightVolumeSlider, selector, [self _volumeForChannel: right] );
out:	//NSLog ( @"b." );
/*
 * Hilight mute button if not muted.
 */
	enabled = _getMuteState ( mixerControl, left, isSelectable );
	[muteButton setState: Choose ( enabled,  NSOnState, NSOffState )];
	//NSLog ( @"view <%@> initialized with name: \"%@\", left channel volume: %d, right channel volume: %d, enabled: %s.", view, name, volumeLeft, volumeRight, enabled ? "yes" : "no" );
	//NSLog ( @"All done." );
};

- (void) dealloc
{
	[view release];
	[super dealloc];
};

- (void) muteChannel: (id) sender
{
	enabled = ( [sender state] == NSOnState );
	[leftVolumeSlider setEnabled: enabled];
	[rightVolumeSlider setEnabled: enabled];
	_setMuteState ( mixerControl, left, isSelectable, (int) enabled );
	_setMuteState ( mixerControl, right, isSelectable, (int) enabled );
};

- (void) volumeSliderChanged: (id) sender
{
	register NSInteger			volume = -1;
	register snd_mixer_selem_channel_id_t	channel = SND_MIXER_SCHN_UNKNOWN;

	volume = (NSInteger) [sender doubleValue];
	//NSLog ( @"Mouse down on slider %@, currentValue: %d.", sender, volume );
	channel = Choose ( sender == leftVolumeSlider, left, right );
	[self _setVolume: volume forChannel: channel];
};

- (void) selectChannel: (id) sender
{
	//NSLog ( @"Toggling selection of current element (%@)...", view );
	[container elementWillBecomeSelected: self];
	[self _setSelected: YES];
	_setMuteState ( mixerControl, left, YES, YES );
	_setMuteState ( mixerControl, right, YES, YES );
};

- (void) deselect
{
	[self _setSelected: NO];
};

- (BOOL) isSelected
{
	register BOOL	result = NO;

	result = isSelected;

	return result;
}

- (NSBox *) view
{
	register NSBox	* result = nil;

	result = view;

	return result;
};

- (void) setContainer: (id <ElementSelection>) aContainer
{
	container = aContainer;
};

@end

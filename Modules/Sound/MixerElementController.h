/***********************************************************************************************************************************
 *
 *	MixerElementController.h
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
#import <Foundation/Foundation.h>

#import <AppKit/NSBox.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSSlider.h>

#define MonoInterface		@"MonoMixerElementView"
#define StereoInterface		@"StereoMixerElementView"

@class MixerElementController;

@protocol ElementSelection <NSObject>

- (void) elementWillBecomeSelected: (MixerElementController *) element;

@end

@interface MixerElementController : NSObject {
	long				minimum,
					maximum;
	BOOL				enabled,
					isSelectable,
					isSelected,
					isMonophonic,
					hasVolumeControl,
					canMute;
	id <ElementSelection>		container;
	snd_mixer_elem_t		* mixerControl;
	snd_mixer_selem_channel_id_t	left,
					right;
	Routine				getVolumeForChannel,
					setVolumeForChannel,
					hasChannel;
/*
 * NIB outlets.
 */
	NSSlider			* leftVolumeSlider,
					* rightVolumeSlider;
	NSTextField			* titleLabel;
	NSButton			* muteButton,
					* leftMuteButton,
					* rightMuteButton,
					* selectedChannelButton;
	NSBox				* view,
					* hashMarksBox;
	NSWindow			* window;
}

+ (MixerElementController *) controllerWithMixerControl: (snd_mixer_elem_t *) channel asInput: (BOOL) flag;

- (void) deselect;
- (BOOL) isSelected;

- (NSBox *) view;

- (void) setContainer: (id <ElementSelection>) aContainer;
/*
 * NIB actions.
 */
- (void) muteChannel: (id) sender;
- (void) volumeSliderChanged: (id) sender;
- (void) selectChannel: (id) sender;

@end

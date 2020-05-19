/***********************************************************************************************************************************
 *
 *	MixerView.m
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

#import "MixerView.h"
#import "MixerElementController.h"

@interface MixerView (Private)

- (void) _addMixerElement: (MixerElementController *) element;

@end

@implementation MixerView (Private)

- (void) _addMixerElement: (MixerElementController *) element
{
	register NSBox	* view = nil;
	register void	* target = NULL;
	register NSRect	rect = NSZeroRect;
	register BOOL	criteria = NO;

	view = [element view];
	[self addSubview: view];
	rect = [view frame];
	rect.origin.x = -2.0;
	rect.origin.y = [elements count] * ( rect.size.height - 2 );
	[view setFrameOrigin: rect.origin];
	[elements addObject: element];
	criteria = ( [[self subviews] count] == 1 );
	target = Choose ( criteria, && a, && b );
	goto * target;
a:	rect.origin.y = 0;
	goto c;
b:	rect = [self frame];
	rect.size.height += [view frame].size.height - 2;
c:	[self setFrame: rect];
	//NSLog ( @"New element %d in vew placed at (%d, %d)", [elements count], (NSInteger) rect.origin.x, (NSInteger) rect.origin.y );
};

@end

@implementation MixerView

- (MixerView *) initWithFrame: (NSRect) rect
{
	register void	* target = NULL;
	register BOOL	criteria = NO;

	self = [super initWithFrame: rect];
	criteria = ( self != nil );
	//NSLog ( @"self != nil: %@.", criteria ? @"true" : @"false" );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	selectedElement = nil;
	elements = [NSMutableArray arrayWithCapacity: 2];
	[elements retain];
	//NSLog ( @"Initialized MixerView instance." );

out:	return self;
};

- (void) dealloc
{
	//NSLog ( @"Deallocating MixerElementView instance." );
	[elements removeAllObjects];
	[elements release];
	[super dealloc];
};

/*- (void) awakeFromNib
{
	//NSLog ( @"MixerView instance loaded from nib." );
};*/

- (void) addElementWithMixerControl: (snd_mixer_elem_t *) control selectable: (BOOL) flag
{
	register MixerElementController	* element = nil;

	//NSLog ( @"Adding an element to the view..." );
	element = [MixerElementController controllerWithMixerControl: control asInput: flag];
	[element setContainer: self];
	[self _addMixerElement: element];
	selectedElement = Choose ( [element isSelected], element, selectedElement );
	//NSLog ( @"%@elected", Choose ( [element isSelected], @"S", @"Not s" ));
};

- (BOOL) isFlipped
{
	return YES;
};

- (void) elementWillBecomeSelected: (MixerElementController *) element
{
	//NSLog ( @"MixerView: deselecting element %@...", selectedElement );
	[selectedElement deselect];
	selectedElement = element;
	//NSLog ( @"MixerView: selected element now %@ (should be %@)", selectedElement, element );
};

@end

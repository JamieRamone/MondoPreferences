/***********************************************************************************************************************************
 *
 *	LayoutController.m
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

#import "aux.h"
#import "LayoutController.h"
#import "PreferencePaneController.h"

@interface LayoutController (Private)

- (void) loadInterface;

@end

@implementation  LayoutController (Private)

- (void) loadInterface
{
	[NSBundle loadNibNamed: LayoutNibFileName owner: self];
};

@end

@implementation LayoutController

static LayoutController	* _sharedLayoutControllerInstance = nil;

+ (LayoutController *) sharedInstance
{
	register void	* target = nil;
	register BOOL	criteria = NO;

	criteria = ( _sharedLayoutControllerInstance == nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	_sharedLayoutControllerInstance = [LayoutController new];
	[_sharedLayoutControllerInstance loadInterface];

out:	return _sharedLayoutControllerInstance;
};

- (LayoutController *) init
{
	register void	* target = nil;
	register BOOL	criteria = NO;

	self = [super init];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	controllers = [[NSMutableArray alloc] initWithCapacity: 8];

out:	return self;
};

- (void) awakeFromNib
{
	register NSButtonCell	* prototype = nil;
	register NSScroller	* scroller = nil;

	//NSLog ( @"Main interface late initialization." );
	prototype = [[NSButtonCell alloc] initImageCell: nil];
	[prototype setHighlighted: NO];
	[prototype setImagePosition: NSImageOnly];
	[prototype setKeyEquivalent: nil];
	[prototype setBezelStyle: NSPushButtonBezelStyle];
	[prototype setButtonType: NSOnOffButton];
	[buttonMatrix setPrototype: prototype];
	[buttonMatrix setCellSize: NSMakeSize ( 69.0, 69.0 )];
	scroller = [scrollView horizontalScroller];
	//NSLog ( @"Scroller: %016X.", scroller );
	[scroller setArrowsPosition: NSScrollerArrowsNone];
	[window setExcludedFromWindowsMenu: YES];
};

- (void) loadPane: (id <PreferencePaneController>) controller
{
	register NSButtonCell	* buttonCell = nil;
	register void		* target = NULL;
	register int		index = -1;
	register BOOL		criteria = NO;
	NSInteger		rows = -1,
				columns = -1;

	//NSLog ( @"-loadPane: called." );
	criteria = ( controller != nil && ! [controllers containsObject: controller] );
	target = Choose ( criteria, && in, && skip1 );
	goto * target;
in:	[controllers addObject: controller];
	index = [controllers indexOfObject: controller];
	[buttonMatrix getNumberOfRows: & rows columns: & columns];
	criteria = ( columns <= index );
	target = Choose ( criteria, && button, && skip2 );
	goto * target;
button:	//NSLog ( @"Adding column %d...", index );
	[buttonMatrix addColumn];
	[buttonMatrix sizeToCells];
skip2:	buttonCell = [buttonMatrix cellAtRow: 0 column: index];
	//NSLog ( @"Button cell: %p", buttonCell );
	[buttonCell setImage: [controller buttonImage]];
	[buttonCell setState: NSOffState];
	//NSLog ( @"Buton cell's image set to: %p.", [controller buttonImage] );
	criteria = ( index == 0 );
	target = Choose ( criteria, && pane, && skip3 );
	goto * target;
pane:	NSLog ( @"Now displaying pane..." );
	[buttonMatrix deselectAllCells];
	[buttonMatrix selectCellAtRow: 0 column: index];
	[self showPane: buttonMatrix];
	//NSLog ( @"Pane now displayed." );
skip3:	[buttonMatrix setNeedsDisplay: YES];
	goto out;
skip1:	NSLog ( @"Can't load pane: it's either got a nil view or it's already loaded!" );
	//NSLog ( @"-loadPane: ended." );

out:	return;
};

- (void) showPane: (id) sender
{
	register NSView				* pane = nil;
	register void				* target = NULL;
	register id <PreferencePaneController>	controller = nil;
	register BOOL				criteria = NO;
	register int				index = -1;

	index = [sender selectedColumn];
	//NSLog ( @"Index of selected button: %d.", index );
	controller = [controllers objectAtIndex: index];
	//NSLog ( @"Selected pane %@.", [controller title] );
	[buttonMatrix selectCellAtRow: 0 column: index];
	criteria = ( [controller deferedLoading] );
	target = Choose ( criteria, && load, && skip );
	goto * target;
load:	//NSLog ( @"Pane %@ not yet loaded.", [controller title] );
	[window setTitle: [NSString stringWithFormat: @"Loading %@ Preferences...", [controller title]]];
	[controller loadPane];
skip:	pane = [controller pane];
	[paneContainer setContentView: pane];
	[window setTitle: [NSString stringWithFormat: @"%@ Preferences", [controller title]]];
};

- (void) show
{
	[window makeKeyAndOrderFront: self];
};

@end

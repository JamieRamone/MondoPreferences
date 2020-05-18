/***********************************************************************************************************************************
 *
 *	InfoPanelController.m
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
#import "InfoPanelController.h"

@interface InfoPanelController (Private)

- (void) _showPanel;

@end

@implementation InfoPanelController (Private)

- (void) _showPanel
{
	[window makeKeyAndOrderFront: nil];
};

@end

@implementation InfoPanelController

static InfoPanelController	* _sharedInfoPanelControllerInstance = nil;

+ (void) showPanel
{
	register void	* target = NULL;
	register BOOL	criteria = NO;

	criteria = ( _sharedInfoPanelControllerInstance == nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	_sharedInfoPanelControllerInstance = [InfoPanelController new];
out:	[_sharedInfoPanelControllerInstance _showPanel];
};
/*
 * NSObject overrides.
 */
- (InfoPanelController *) init
{
	register void	* target = NULL;
	register BOOL	criteria = NO;

	self = [super init];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	[NSBundle loadNibNamed: InfoPanelInterface owner: self];

out:	return self;
};
/*
 * NIB actions.
 */
- (void) close: (id) sender
{
	[window close];
};

@end

/***********************************************************************************************************************************
 *
 *	StandardAppIconView.m
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
#import <Foundation/NSBundle.h>

#import "../../aux.h"
#import "StandardAppIconView.h"

@implementation StandardAppIconView

- (id) init
{
	register void	* target = NULL;
	register BOOL	criteria = NO;

	self = [super initWithFrame: NSZeroRect];
	//NSLog ( @"Initializing app icon view instance..." );
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	//NSLog ( @"Loading main nib for app icon view (%@)...", StandardAppIconViewNibName );
	timer = nil;
	[NSBundle loadNibNamed: StandardAppIconViewNibName owner: self];

out:	return self;
};

- (void) updateTimeFirst: (NSTimer *) aTimer
{
	timer = [NSTimer scheduledTimerWithTimeInterval: 60 target: self selector: @selector ( updateTime: ) userInfo: nil repeats: YES];
	//NSLog ( @"Updating clock..." );
	[self update];
	[[NSNotificationCenter defaultCenter] postNotificationName: PreferencesAppIconViewAutoUpdatedNotification object: self];
};

- (void) updateTime: (NSTimer *) aTimer
{
	//NSLog ( @"Updating clock..." );
	[self update];
	[[NSNotificationCenter defaultCenter] postNotificationName: PreferencesAppIconViewAutoUpdatedNotification object: self];
};


static inline void _renderDigit ( register const int digit, register const NSPoint at, register const NSImage * led )
{
	register NSRect		bitFrame = NSZeroRect;

	bitFrame.size.width = 9.0;
	bitFrame.size.height = 11.0;
	bitFrame.origin.x = 9 * digit;
	[led compositeToPoint: at fromRect: bitFrame operation: NSCompositeSourceOver];
};

- (void) drawRect: (NSRect) rect
{
	register NSImage	* image = nil;
	register NSCalendarDate	* date = nil;
	register void		* target = NULL;
	register NSPoint	at = NSZeroPoint;
	register NSRect		bitFrame = NSZeroRect;
	register int		bit = -1,
				digit = -1;
	register BOOL		criteria = NO;

	//NSLog ( @"Drawing standard icon view..." );
	image = [NSImage imageNamed: @"common_Tile"];
	bitFrame = NSMakeRect ( 2, 2, 60, 60 );
	//NSLog ( @"Rendering image %p.", image );
	[image compositeToPoint: at fromRect: bitFrame operation: NSCompositeSourceOver];
/*
 * 1. Draw the background image of the LED display and the tear-off callendar.
 */
	[[background image] compositeToPoint: at operation: NSCompositeSourceOver];
	date = [NSCalendarDate date];
	//NSLog ( @"Date to display is %@.", [date description] );
/*
 * 2. Get the hour from the current date and draw it on the LED display.
 */
/*
 * 2.a Get the hour from the date object, set up the rectanglular mask for the selected digit, and set up the initial position to
 *     place the first digit.
 */
	bit = [date hourOfDay];
	image = [ledView image];
	bitFrame.size = NSMakeSize ( 9.0, 11.0 );
	//NSLog ( @"Digit frame [(%0.0f, %0.0f), %0.0f x %0.0f]...", bitFrame.origin.x, bitFrame.origin.y, bitFrame.size.width, bitFrame.size.height );
	at.y = 60.0 - 12.0 - 4.0;
/*
 * 2.b. Get the first (left-most, most significant) digit of the hour. being a 24 hour clock, this value is in the range [0..2], and
 *      draw it.
 */
	digit = bit / 10;
	criteria = ( digit != 0 );
	at.x = 7.0;
	target = Choose ( criteria, && a, && b );
	goto * target;
a:	//NSLog ( @"Rendering the msd of hour (%d) at (%0.0f, %0.0f)...", digit, at.x, at.y );
	_renderDigit ( digit, at, image );
/*
 * 2.c. Get the least significant digit of the hour.
 */
b:	digit = bit % 10;
	at.x += 9.0;
	//NSLog ( @"Rendering the lsd of hour (%d) at (%0.0f, %0.0f)...", digit, at.x, at.y );
	_renderDigit ( digit, at, image );
/*
 * 2.d. Draw the minutes separator (':').
 */
	at.x += 9.0;
	bitFrame.origin.x = 9 * 10;
	bitFrame.origin.y = 0;
	//NSLog ( @"Rendering the separator (:) at (%0.0f, %0.0f)...", digit, at.x, at.y );
	[image compositeToPoint: at fromRect: bitFrame operation: NSCompositeSourceOver];
/*
 * 2.e. Get the minutes part of the date.
 */
	bit = [date minuteOfHour];
/*
 * 2.f. Get the first (left-most, most significant) digit of the minutes and draw it.
 */
	digit = bit / 10;
	at.x += 4.0;
	//NSLog ( @"Rendering the msd of minutes (%d) at (%0.0f, %0.0f)...", digit, at.x, at.y );
	_renderDigit ( digit, at, image );
/*
 * 2.g. Get the least significant digit of the minutes.
 */
	digit = bit % 10;
	at.x += 9.0;
	//NSLog ( @"Rendering the lsd of minutes (%d) at (%0.0f, %0.0f)...", digit, at.x, at.y );
	_renderDigit ( digit, at, image );
/*
 * 3. Draw the weekday label on the tear-off calendar. This one goes on the top.
 */
	image = [dayView image];
	bit = [date dayOfWeek];
	//NSLog ( @"Day of week: %d.", bit );
	bitFrame = NSMakeRect ( 0, bit * [image size].height / 7, [image size].width, [image size].height / 7 );
	//NSLog ( @"Day frame [(%0.0f, %0.0f), %0.0f x %0.0f]...", bitFrame.origin.x, bitFrame.origin.y, bitFrame.size.width, bitFrame.size.height );
	at.x = ( 60.0 - [image size].width ) / 2 - 2;
	at.y -= 12;
	//NSLog ( @"Rendering the day at (%0.0f, %0.0f)...", at.x, at.y );
	[image compositeToPoint: at fromRect: bitFrame operation: NSCompositeSourceOver];
/*
 * 4. Draw the day of month label on the tear-off calendar. This one goes in the middle.
 */
	image = [digitView image];
/*
 * 4.a. Get the day of month, always a number in the range [1..31] and set up the initial location of the digits.
 */
	bit = [date dayOfMonth];
	//bit = 1;
	//NSLog ( @"Day of month: %d.", bit );
	at.y -= [image size].height / 10;
	
/*
 * 4.b. Get the most significant digit from the month, which is a number in the range [0..3], and display it. The value must be
 * incremented by one to get the right glyph from the image, due to the position of glyph 0.
 */
	digit = bit / 10;
	criteria = ( digit != 0 );
	target = Choose ( criteria, && c, && d );
	goto * target;
c:	at.x = 60.0 / 2 - [image size].width - 2;
	//NSLog ( @"First digit is: %d.", digit );
	bitFrame = NSMakeRect ( 0, [image size].height - ( digit + 1 ) * [image size].height / 10, [image size].width, [image size].height / 10 );
	[image compositeToPoint: at fromRect: bitFrame operation: NSCompositeSourceOver];
	at.x += [image size].width;
	goto e;
d:	at.x = ( rect.size.width - [image size].width ) / 2 - 2;
/*
 * 4.c. Get the least significant digit from the month, which is a number in the range [0..9], and display it.
 */
e:	digit = bit % 10;
	//NSLog ( @"Second digit is: %d.", digit );
	bitFrame = NSMakeRect ( 0, [image size].height - ( digit  + 1 ) * [image size].height / 10, [image size].width, [image size].height / 10 );
	[image compositeToPoint: at fromRect: bitFrame operation: NSCompositeSourceOver];
/*
 * 5. Get the month of year and display it's label at the bottom of the tear-off callendar.
 */
	image = [monthView image];
	bit = [date monthOfYear];
	//NSLog ( @"Month of year: %d.", bit );
	at.y -= [image size].height / 12 + 1;
	at.x = ( 60.0 - [image size].width ) / 2 - 4;
	bitFrame = NSMakeRect ( 0, [image size].height - bit * [image size].height / 12, [image size].width, [image size].height / 12 );
	//NSLog ( @"Month frame: [(%0.02f, %0.02f), %0.02f x %0.02f].", bitFrame.origin.x, bitFrame.origin.y, bitFrame.size.width, bitFrame.size.height );
	//NSLog ( @"Month placed at (%0.02f, %0.02f).", at.x, at.y );
	[image compositeToPoint: at fromRect: bitFrame operation: NSCompositeSourceOver];
	//NSLog ( @"All done!" );
};

- (void) awakeFromNib
{
	register NSCalendarDate	* date = nil;
	register int		seconds = -1;

	date = [NSCalendarDate date];
	seconds = [date secondOfMinute];
	//NSLog ( @"First clock update scheduled in %d seconds.", seconds );
	timer = [NSTimer scheduledTimerWithTimeInterval: 60 - seconds target: self selector: @selector ( updateTimeFirst: ) userInfo: nil repeats: NO];
	//NSLog ( @"StandardAppIconView instance fully loaded." );
};

@end

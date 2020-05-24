/***********************************************************************************************************************************
 *
 *	Password.m
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
#define _GNU_SOURCE
#include <crypt.h>
#include <pwd.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/stat.h>
#include <sys/types.h>

#import <Foundation/NSFileHandle.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSNotification.h>

#import "../../aux.h"
#import "AlertPanelController.h"
#import "Password.h"

#define FieldSeparator	@":"

static inline void _random ( register const char * numbers, register const int total )
{
        register int	randomFile = -1;
        register void	* target = NULL;
	register BOOL	criteria = NO;

	//NSLog ( @"_random ( void ) called." );
	randomFile = open ( "/dev/random", O_RDONLY );
	criteria = ( randomFile != -1 );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	read ( randomFile, (char *) numbers, sizeof ( char ) * total );
	//NSLog ( @"random number: %d.", result );
	//NSLog ( @"_random ( void ) ended." );

out:	return;
};

static char * _salt ( void )
{
        register NSString	* saltSet = nil;
	register int		i = -1;
	register unsigned int	index = -1;
	char			numbers [ 16 ] = { -1 };
	static char		result [] = "$6$................";

	//NSLog ( @"_salt () called." );
	_random ( numbers, 16 );
	saltSet = @"./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

	for ( i = 0; i < 16; i++ ) {
		index = numbers [ i ] & 0x0000003F;
		//NSLog ( @"Next character index: %u (%d).", index, index );
		result [ 3 + i ] = [saltSet characterAtIndex: index];
	}

	//NSLog ( @"Salt: %s", salt + 3 );

	return result;
};

static inline char * _encrypt ( register NSString * original )
{
	register char		* result = NULL,
				* salt = NULL;

	//NSLog ( @"_encrypt ( register NSString * ) called." );
	salt = _salt ();
	result = crypt ( [original cString], salt );
	//NSLog ( @"full encrypted string: %s", result );
	//NSLog ( @"_encrypt ( register NSString * ) ended." );

	return result;
};

@interface PasswordPaneController (Private)

- (void) _initialState;
- (void) _verifyOldPassword: (NSButton *) sender;
- (void) _getNewPassword: (NSButton *) sender;
- (void) _confirmNewPassword: (NSButton *) sender;
- (void) _updatePassword;

@end

@implementation PasswordPaneController (Private)

- (void) _initialState
{
	register NSString	* imagePath = nil;

	//NSLog ( @"-initialState called." );
	[passwordTextField setEnabled: YES];
	[passwordTextField setStringValue: nil];
	[passwordTextField setHidden: YES];
	[label setHidden: NO];
	[okButton setTitle: @"Change"];
	[okButton setAction: @selector ( changePassword: )];
	[informationLabel setStringValue: nil];
	[cancelButton setEnabled: NO];
	[okButton setEnabled: YES];
	imagePath = [[NSBundle bundleForClass: [self class]] pathForImageResource: LockImage];
	[lockImageView setImage: [[NSImage alloc] initWithContentsOfFile: imagePath]];
	//NSLog ( @"-initialState ended." );
};                                                                                        

- (void) _verifyOldPassword: (NSButton *) sender
{
	register NSAutoreleasePool	* pool = nil;
	register NSString		* original = nil;
	register char			* pw = NULL;
	register void			* target = NULL;
	register BOOL			criteria = NO;

	pool = [NSAutoreleasePool new];
	//NSLog ( @"-verifyOldPassword: called." );
	[okButton setEnabled: NO];
	original = [passwordTextField stringValue];
	criteria = ( strlen ( userEntry->pw_passwd ) != 0 );
	target = Choose ( criteria, && a, && b );
	goto * target;
a:	password = [NSString stringWithCString: crypt ( [original cString], userEntry->pw_passwd ) encoding: NSASCIIStringEncoding];
	//NSLog ( @"Entered %@, password: %s.", password, userEntry->pw_passwd );
	criteria = (BOOL) ( strcmp ( [password cString], userEntry->pw_passwd ) == 0 );
	//NSLog ( @"Criteria = %@.", criteria ? @"true" : @"false" );
	target = Choose ( criteria, && b, && c );
	goto * target;
b:	//NSLog ( @"Passwords match, proceeding..." );
	[informationLabel setStringValue: @"Please type in your new password."];
	[passwordTextField setStringValue: nil];
	[okButton setAction: @selector ( _getNewPassword: )];
	[okButton setEnabled: YES];
	//[lockImageView setImage: [NSImage imageNamed: LockOpenImage]];
	original = [[NSBundle bundleForClass: [self class]] pathForImageResource: LockOpenImage];
	[lockImageView setImage: [[NSImage alloc] initWithContentsOfFile: original]];
	goto out;
c:	//NSLog ( @"Current password validation failed." );
	[passwordTextField setEnabled: NO];
	[AlertPanelController alertPanelWithTitle: @"Alert" message: @"Sorry, you entered your old password incorrectly." defaultButtonLabel: @"OK" alternateButtonLabel: nil otherButtonLabel: nil];
	[self _initialState];
out:	[pool release];
};

- (void) _getNewPassword: (NSButton *) sender
{
	register NSAutoreleasePool	* pool = nil;

	pool = [NSAutoreleasePool new];
	password = [passwordTextField stringValue];
	[password retain];
	[informationLabel setStringValue: @"Please type in your new password again."];
	[passwordTextField setStringValue: nil];
	[okButton setAction: @selector ( _confirmNewPassword: )];
	[okButton setEnabled: YES];
	[pool release];
};

- (void) _confirmNewPassword: (NSButton *) sender
{
	register NSAutoreleasePool	* pool = nil;
	register NSString		* string = nil;
	register void			* target = NULL;
	register BOOL			criteria = NO;

	pool = [NSAutoreleasePool new];
	string = [passwordTextField stringValue];
	//NSLog ( @"2 (string = %@, password = %@).", string, password );
	criteria = ( [password compare: string] != NSOrderedSame );
	target = Choose ( criteria, && a, && b );
	goto * target;
a:	[AlertPanelController alertPanelWithTitle: @"Alert" message: @"Sorry, passwords don't match. Please type it in again." defaultButtonLabel: @"OK" alternateButtonLabel: nil otherButtonLabel: nil];
	[passwordTextField setStringValue: nil];
	goto out;
b:	[self _updatePassword];
	[self _initialState];
out:	[pool release];
};
/*
 * Copy /etc/passwd to /tmp/ passwd, locate the entry for the current user, update its password field, and move it back to
 * /etc/passwd, overwriting it.
 */
- (void) _updatePassword
{
	register NSData		* data = nil;
	register NSFileManager	* fileManager = nil;
	register NSFileHandle	* original = nil,
				* duplicate = nil;
	register NSScanner	* scanner = nil;
	register NSString	* me = nil;
	register BOOL		criteria = NO;
	NSError			* error = nil;
	NSString		* contents = nil;

	//NSLog ( @"Updating passwords file..." );
/*
 * Before proceding, encrypt the new password.
 */
	password = [NSString stringWithCString: _encrypt ( password )];
	fileManager = [NSFileManager defaultManager];
	[fileManager createFileAtPath: @"/tmp/passwd" contents: nil attributes: nil];
/*
 * Open the original password for reading, and the duplicate for writing.
 */
	me = NSUserName ();
	original = [NSFileHandle fileHandleForReadingAtPath: @"/etc/passwd"];
	duplicate = [NSFileHandle fileHandleForWritingAtPath: @"/tmp/passwd"];
	data = [original availableData];
	contents = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
	scanner = [NSScanner scannerWithString: contents];

	while ( ! [scanner isAtEnd] ) {
		[scanner scanUpToString: FieldSeparator intoString: & contents];
		//NSLog ( @"Read account name field %@", contents );
		criteria = ( [contents compare: me] == NSOrderedSame );
/*
 * Write the account field into the duplicate.
 */
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
/*
 * Write the field separator into the duplicate.
 */
		[scanner scanString: FieldSeparator intoString: & contents];
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
		[scanner scanUpToString: FieldSeparator intoString: & contents];
/*
 * If the first field matches the current user, then write the NEW password next. Otherwise, duplicate the field that was read in
 */
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		data = Choose ( criteria, [password dataUsingEncoding: NSASCIIStringEncoding], data );
		//NSLog ( @"Password field: %@", [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding] );
		[duplicate writeData: data];
		[scanner scanString: FieldSeparator intoString: & contents];
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
/*
 * Write the uid.
 */
		[scanner scanUpToString: FieldSeparator intoString: & contents];
		//NSLog ( @"Read uid field %@", contents );
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
		[scanner scanString: FieldSeparator intoString: & contents];
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
/*
 * Write the gid.
 */
		[scanner scanUpToString: FieldSeparator intoString: & contents];
		//NSLog ( @"Read gid field %@", contents );
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
		[scanner scanString: FieldSeparator intoString: & contents];
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
/*
 * Write the GECOS information.
 */
		[scanner scanUpToString: FieldSeparator intoString: & contents];
		//NSLog ( @"Read GECOS field %@", contents );
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
		[scanner scanString: FieldSeparator intoString: & contents];
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
/*
 * Write the home directory.
 */
		[scanner scanUpToString: FieldSeparator intoString: & contents];
		//NSLog ( @"Read home directory field %@", contents );
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
		[scanner scanString: FieldSeparator intoString: & contents];
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
/*
 * Write the shell.
 */
		[scanner scanUpToString: @"\n" intoString: & contents];
		//NSLog ( @"Read shell field %@", contents );
		data = [contents dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
		data = [[NSString stringWithFormat: @"\n"] dataUsingEncoding: NSASCIIStringEncoding];
		[duplicate writeData: data];
	}

	[fileManager moveItemAtPath: @"/tmp/passwd" toPath: @"/etc/passwd.new" error: & error];
	//NSLog ( @"File move error: %@.", error );
	error = nil;
	[fileManager removeItemAtPath: @"/etc/passwd" error: & error];
	//NSLog ( @"File remove error: %@.", error );
	error = nil;
	[fileManager moveItemAtPath: @"/etc/passwd.new" toPath: @"/etc/passwd" error: & error];
	//NSLog ( @"File move error: %@.", error );
};

@end

@implementation PasswordPaneController

- (id) init
{
	register NSString	* aTitle = nil,
				* nib = nil;
	register NSBundle	* bundle = nil;
	register NSImage	* image = nil;
	register void		* target = nil;
	register BOOL		criteria = NO;

	bundle = [NSBundle bundleForClass: [self class]];
//NSLog ( @"Loading image from %@.", [bundle bundlePath] );
	image = [[NSImage alloc] initWithContentsOfFile: [bundle pathForResource: @"Password" ofType: @"tiff" inDirectory: @""]];
	nib = @"Password";
	aTitle = @"Password";
	self = [super initWithNibFile: nib title: aTitle icon: image];
	criteria = ( self != nil );
	target = Choose ( criteria, && in, && out );
	goto * target;
in:	userEntry = getpwuid ( getuid ());
	password = nil;

out:	return self;
};

- (void) awakeFromNib
{
	register NSAutoreleasePool	* pool = nil;
	register NSNotificationCenter	* notifier = nil;

	pool = [NSAutoreleasePool new];
	[super awakeFromNib];
	[passwordTextField setHidden: YES];
	[passwordTextField setEchosBullets: NO];
	//NSLog ( @"Password preferences module interface loaded." );
	[self _initialState];
	notifier = [NSNotificationCenter defaultCenter];
	[notifier postNotificationName: DefferedLoadingCompletedNotification object: self];
	[pool dealloc];
};
/*
 * NIB actions
 */
- (void) changePassword: (NSButton *) sender
{
	register NSAutoreleasePool	* pool = nil;

	pool = [NSAutoreleasePool new];
	[label setHidden: YES];
	[passwordTextField setStringValue: nil];
	[passwordTextField setHidden: NO];
	[passwordTextField becomeFirstResponder];
	[informationLabel setStringValue: @"Please type in your current password"];
	[okButton setTitle: @"OK"];
	[cancelButton setEnabled: YES];
	[okButton setAction: @selector ( _verifyOldPassword: )];
	//NSLog ( @"Preparing to change password..." );
	[pool release];
};

- (void) cancel: (NSButton *) sender
{
	register NSAutoreleasePool	* pool = nil;

	pool = [NSAutoreleasePool new];
	[self _initialState];
	[pool release];
};

@end

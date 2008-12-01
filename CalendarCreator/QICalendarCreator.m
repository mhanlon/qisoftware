//
//  QICalendarCreator.m
//  CalendarCreator
//
//  Created by Matthew Hanlon on Wed Jul 09 2003.
//  Copyright (c) 2003 Q.I. Software. All rights reserved.
//

#import "QICalendarCreator.h"



@implementation QICalendarCreator

-(void)doAddEventService:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error {
    NSString *pboardString; // the string coming from the pasteboard.
                            // Services dump the selected data, be it a file, string, or whathaveyou
                            // to the pasteboard.
    NSArray *types; // the NSArray you'll be using to store the types of the current pasteboard...
                    // see below for more info...

    // This array initialising should probably be moved to init.
    monthNames = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];

    types = [pboard types];

    // Now check to see if the thing selected is an NSString.
    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType])) {
        *error = NSLocalizedString(@"Error: The pasteboard doesn't contain a string.",
                                   @"NSPasteboard couldn't give string.");
        return;
    }


    if (pboardString) {
        // The pasteboard contains a string, we're going to go ahead and create the event
        [self createEventInCalendar:pboardString];
    }
}

-(void)doAddToDoService:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error {
    NSString *pboardString; // the string coming from the pasteboard.
                            // Services dump the selected data, be it a file, string, or whathaveyou
                            // to the pasteboard.
    NSArray *types; // the NSArray you'll be using to store the types of the current pasteboard...
                    // see below for more info...
	
    // This array initialising should probably be moved to init.
    monthNames = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
	
    types = [pboard types];
	
    // Now check to see if the thing selected is an NSString.
    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType])) {
        *error = NSLocalizedString(@"Error: The pasteboard doesn't contain a string.",
                                   @"NSPasteboard couldn't give string.");
        return;
    }
	
	
    if (pboardString) {
        // The pasteboard contains a string, we're going to go ahead and create the event
        [self createToDoInCalendar:pboardString];
    }
}

// This method sets up the NSCalendarDate from the string on the pasteboard and fills in the AppleScript in
// iCalEventAdderScript.txt.
// Now, AppleScript isn't our main thing here. In fact, it wasn't our thing at all until we threw this service
// together, so I can't guarantee the quality of that code is brilliant.
// To find out how how much of an app is scriptable, in Project Builder.app choose Open Dictionary from the File menu.
// That will bring up a list of apps you can inspect for AppleScript dictionaries.
-(void)createEventInCalendar:(NSString *)pboardString {
    NSMutableString *theScript = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iCalEventAdderScript" ofType:@"txt"]]; // read in the script text
    NSMutableString *cleanPboardString = [NSMutableString stringWithString:pboardString]; // used for removing "'s
    NSAppleScript *script; // The actual script we're going to run
    NSAppleEventDescriptor *descriptor; // This tells us what happens afterwards
    NSDictionary *errorDict;
    long time; // Used to set the time in AppleScript, this will hold the number of seconds from 0.00am.

    // clean the pboardString of quotation marks, which'll give our AppleScript headaches...
    // This probably could have been done better...
    [cleanPboardString replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:nil range:NSMakeRange(0, [pboardString length])];

    // This is why Cocoa rocks, kids. This is all the extra work we had to do to figure out what date you actually wanted.
    theDate = [NSCalendarDate dateWithNaturalLanguageString:pboardString];

//    [NSBundle loadNibNamed:@"CalendarCreator.nib" owner:self];
//    [myWindow makeKeyAndOrderFront:nil];

    // As it says above, this is to set the time of the event from 0.00am in seconds.
    time = ([theDate hourOfDay] * 60 * 60) + ([theDate minuteOfHour] * 60);

    // Replace the QI_ prefixed strings in the script file.
    // Most of this is pretty self-explanatory.
    // The AppleScript basically tries to find a calendar called CalendarCreator.
    // If it fails to, it'll create it, otherwise, it'll just add the new event to that calendar.
    // The reason why we went this way instead of using libical or the iCal private framework is because
    // accessing iCal via AppleScript automatically refreshes the display on iCal.
    // Using the private frameworks is never a great idea, and if you *do* use them, you get locking
    // issues if the user already has iCal open where your event won't be saved without a lot of extra
    // work.
	NSString *defaultCalendarName = [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultCalendarName"];
	if (!defaultCalendarName) {
		defaultCalendarName = @"CalendarCreator";
	}
    [theScript replaceOccurrencesOfString:@"QI_CAL_TITLE" withString:defaultCalendarName options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_EVENT_DESCRIPTION" withString:cleanPboardString options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_TIME" withString:[NSString stringWithFormat:@"%d", time] options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_YEAR" withString:[NSString stringWithFormat:@"%d", [theDate yearOfCommonEra]] options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_MONTH_NAME" withString:[monthNames objectAtIndex:[theDate monthOfYear]-1] options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_DAY" withString:[NSString stringWithFormat:@"%d", [theDate dayOfMonth]] options:nil range:NSMakeRange(0, [theScript length])];

    script = [[NSAppleScript alloc] initWithSource:theScript];
    errorDict = [NSDictionary dictionary];
    // run the script and keep the results of any erros in errorDict.
    descriptor = [script executeAndReturnError:&errorDict];
    [script release];
   if (descriptor == nil) {
       // If there was a problem, it'll be stored in our errorDict with the key NSAppleScriptErrorMessage.
        if ([errorDict objectForKey:NSAppleScriptErrorMessage] != nil) {
            NSLog(@"There was an error... %@", [errorDict objectForKey:NSAppleScriptErrorMessage]);
        }

   }
    // And that's it...
}

// Needless, careless copy and paste. This will be an exercise in refactoring sometime in the future.
-(void)createToDoInCalendar:(NSString *)pboardString {
    NSMutableString *theScript = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iCalToDoAdderScript" ofType:@"txt"]]; // read in the script text
    NSMutableString *cleanPboardString = [NSMutableString stringWithString:pboardString]; // used for removing "'s
    NSAppleScript *script; // The actual script we're going to run
    NSAppleEventDescriptor *descriptor; // This tells us what happens afterwards
    NSDictionary *errorDict;
    long time; // Used to set the time in AppleScript, this will hold the number of seconds from 0.00am.
	
    // clean the pboardString of quotation marks, which'll give our AppleScript headaches...
    // This probably could have been done better...
    [cleanPboardString replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:nil range:NSMakeRange(0, [pboardString length])];

    // This is why Cocoa rocks, kids. This is all the extra work we had to do to figure out what date you actually wanted.
    theDate = [NSCalendarDate dateWithNaturalLanguageString:pboardString];

	//    [NSBundle loadNibNamed:@"CalendarCreator.nib" owner:self];
	//    [myWindow makeKeyAndOrderFront:nil];

    // As it says above, this is to set the time of the event from 0.00am in seconds.
    time = ([theDate hourOfDay] * 60 * 60) + ([theDate minuteOfHour] * 60);

    // Replace the QI_ prefixed strings in the script file.
    // Most of this is pretty self-explanatory.
    // The AppleScript basically tries to find a calendar called CalendarCreator.
    // If it fails to, it'll create it, otherwise, it'll just add the new event to that calendar.
    // The reason why we went this way instead of using libical or the iCal private framework is because
    // accessing iCal via AppleScript automatically refreshes the display on iCal.
    // Using the private frameworks is never a great idea, and if you *do* use them, you get locking
    // issues if the user already has iCal open where your event won't be saved without a lot of extra
    // work.
	NSString *defaultCalendarName = [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultCalendarName"];
	if (!defaultCalendarName) {
		defaultCalendarName = @"CalendarCreator";
	}
    [theScript replaceOccurrencesOfString:@"QI_CAL_TITLE" withString:defaultCalendarName options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_EVENT_DESCRIPTION" withString:cleanPboardString options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_TIME" withString:[NSString stringWithFormat:@"%d", time] options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_YEAR" withString:[NSString stringWithFormat:@"%d", [theDate yearOfCommonEra]] options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_MONTH_NAME" withString:[monthNames objectAtIndex:[theDate monthOfYear]-1] options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_DAY" withString:[NSString stringWithFormat:@"%d", [theDate dayOfMonth]] options:nil range:NSMakeRange(0, [theScript length])];
    [theScript replaceOccurrencesOfString:@"QI_PRIORITY" withString:[NSString stringWithFormat:@"%d", 5] options:nil range:NSMakeRange(0, [theScript length])];

    script = [[NSAppleScript alloc] initWithSource:theScript];
    errorDict = [NSDictionary dictionary];
    // run the script and keep the results of any erros in errorDict.
    descriptor = [script executeAndReturnError:&errorDict];
    [script release];
	if (descriptor == nil) {
		// If there was a problem, it'll be stored in our errorDict with the key NSAppleScriptErrorMessage.
        if ([errorDict objectForKey:NSAppleScriptErrorMessage] != nil) {
            NSLog(@"There was an error... %@", [errorDict objectForKey:NSAppleScriptErrorMessage]);
        }
		
	}
    // And that's it... again.
}

-(IBAction)addEvent:(id)sender {
    
}
-(void)dealloc {
    [theDate release];
	[super dealloc];
}
@end

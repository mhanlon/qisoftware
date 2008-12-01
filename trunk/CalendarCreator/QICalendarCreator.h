//
//  QICalendarCreator.h
//  CalendarCreator
//
//  Created by Matthew Hanlon on Wed Jul 09 2003.
//  Copyright (c) 2003 Q.I. Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface QICalendarCreator : NSObject {
    NSArray *monthNames;
    NSCalendarDate *theDate;
    IBOutlet NSWindow *myWindow;
    IBOutlet NSComboBox *calsComboBox;
}
-(IBAction)addEvent:(id)sender;

-(void)doAddEventService:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error;
-(void)createEventInCalendar:(NSString *)pboardString;

-(void)doAddToDoService:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error;
-(void)createToDoInCalendar:(NSString *)pboardString;

@end

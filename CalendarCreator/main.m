//
//  main.m
//  CalendarCreator
//
//  Created by Matthew Hanlon on Wed Jul 09 2003.
//  Copyright (c) 2003 Q.I. Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QICalendarCreator.h>

int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    QICalendarCreator *serviceProvider = [[QICalendarCreator alloc] init];

    NSRegisterServicesProvider(serviceProvider, @"CalendarCreator");
    
    NS_DURING
        [[NSRunLoop currentRunLoop] configureAsServer];
        [[NSRunLoop currentRunLoop] run];
    NS_HANDLER
        NSLog(@"%@", localException);
    NS_ENDHANDLER

    [serviceProvider release];
    [pool release];

    // tmp measure.
    // uncomment if you want this to take effect without the user logging out.
    //NSUpdateDynamicServices();

    exit(0);       // insure the process exit status is 0
    return 0;      // ...and make main fit the ANSI spec.
}

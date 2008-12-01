//
//  QIContactCreator.m
//  ContactCreator
//
//  Created by Matt Hanlon on Tue Feb 11 2003.
//  Copyright (c) 2003 Q.I. Software. All rights reserved.
//

#import "QIContactCreator.h"


@implementation QIContactCreator

// This is a *very* simple service to add a given piece of text to your
// addressBook.
// This is the method that gets invoked when someone chooses to Add Contact
// from the Services menu.
// Look in the Info.plist on the built product, or in the ContactCreator Target
// Info.plist Entries section in Project Builder, the Services architecture
// knows that this method, below, handles adding of contacts because we tell
// it so in one of the array elements in the NSServices entry.
- (void)doAddContactService:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error {
    NSString *pboardString; // the string coming from the pasteboard.
                            // Services dump the selected data, be it a file, string, or whathaveyou
                            // to the pasteboard.
    NSArray *types; // the NSArray you'll be using to store the types of the current pasteboard...
                    // see below for more info...

    // AddressBook vars
    ABAddressBook *aBook = [ABAddressBook sharedAddressBook]; // The global AddressBook database
    ABPerson *aPerson; // The contact you're about to add.

    types = [pboard types];

    // Now check to see if the thing selected is an NSString.
    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType])) {
        *error = NSLocalizedString(@"Error: The pasteboard doesn't contain a string.",
                                   @"NSPasteboard couldn't give string.");
        return;
    }

    // Set up your booleans for email and website population...
    dataContainsEmail = NO;
    dataContainsWebSite = NO;

    if (pboardString) {
        aPerson = [[ABPerson alloc] init];

        // We only expect this to be one contact, so we can call
        // putTextInProperPlace:forPerson without any splitting
        [self putTextInProperPlace:pboardString forPerson:aPerson];
        
        [aBook addRecord:aPerson];

        // Reset your flags in case you need to process more addresses,
        // this stuff isn't necessary here, but it's nice to reset the state
        // of things before we go.
        dataContainsEmail = NO;
        dataContainsWebSite = NO;
    }
    
    if ([aBook hasUnsavedChanges]) {
        if (![aBook save]) {
            NSLog(@"There was a problem saving %@ to the addressbook.", aPerson);
        }
    }
    return;
}


// Parse the pasteboard string and dump it in the ABPerson.
// Now, this bit may be a bit ugly, but that's okay.
// This idea came from L after me suggesting something entirely too
// complex for what should be a simple/common enough problem.
// Instead of building NSRanges and all that good stuff to search
// and eventually split up a string, use componentsSeparatedByString
// on the string to get an array back.
// Anyway, what we do is, if there's only one word selected, dump it in the
// first name property, if there are two, first name and last name, and if there
// are more than that, dump them in the Notes field.
// Cool, huh?
// NB. This is intended to be used on one chunk of information all related to
// ONE contact at a time... This is important when you look at the newer
// service method in the ContactCreatorGroup category.
-(void)putTextInProperPlace:(NSString *)text forPerson:(ABPerson *)aPerson {
    NSArray *contactInfoArray; // This is the contact info
    contactInfoArray = [text componentsSeparatedByString:@" "];
    // Test for email addresses and websites and populate those fields, first
    [self testForOtherFields:contactInfoArray forPerson:aPerson];

    if ([contactInfoArray count] == 1) {
        [aPerson setValue:[contactInfoArray objectAtIndex:0] forProperty:kABFirstNameProperty];
    } else if ([contactInfoArray count] == 2) {
        [aPerson setValue:[contactInfoArray objectAtIndex:0] forProperty:kABFirstNameProperty];
        [aPerson setValue:[contactInfoArray objectAtIndex:1] forProperty:kABLastNameProperty];
    } else if ([contactInfoArray count] == 3 && dataContainsEmail) {
        // sort of faulty logic here, sort of...
        [aPerson setValue:[contactInfoArray objectAtIndex:0] forProperty:kABFirstNameProperty];
        [aPerson setValue:[contactInfoArray objectAtIndex:1] forProperty:kABLastNameProperty];
    } else {
        // Else dump all of it into a Note attached to the person...
        [aPerson setValue:text forProperty:kABNoteProperty];
    }
}

-(void)testForOtherFields:(NSArray *)contactInfoArray forPerson:(ABPerson *)aPerson {
    ABMutableMultiValue *aMultiVal; //just in case... you know, like, email
    int i; // loop var
    
    // The loop to see if we haven't any potential email address in the strings
    // in the array. (We only check for an "@" symbol, nothing more clever than that.
    for (i = 0; i < [contactInfoArray count]; i++) {
        if ([[contactInfoArray objectAtIndex:i] rangeOfString:@"@"].location != NSNotFound) {
            // test for brackets and delete them if found...
            NSMutableString *tmpString = [NSMutableString stringWithString:[contactInfoArray objectAtIndex:i]];
            if ([tmpString rangeOfString:@"<"].location != NSNotFound) {
                [tmpString deleteCharactersInRange:[tmpString rangeOfString:@"<"]];
            }
            if ([tmpString rangeOfString:@">"].location != NSNotFound) {
                [tmpString deleteCharactersInRange:[tmpString rangeOfString:@">"]];
            }

            // Now start the AddressBook population
            aMultiVal = [[ABMutableMultiValue alloc] init];
            [aMultiVal addValue:tmpString withLabel:kABEmailHomeLabel];
            [aPerson setValue:aMultiVal forProperty:kABEmailProperty];

            // Now with added .Mac support! We may be populating more!
            // As a special favour, if the email address ends in @mac.com,
            // we add that same address to the AIM Home field.
            // We use the tmpString because that's been stripped of any
            // unsightly brackets...
            if ([tmpString rangeOfString:@"@mac.com"].location != NSNotFound) {
                ABMutableMultiValue *imMultiVal = [[ABMutableMultiValue alloc] init];
                [imMultiVal addValue:tmpString withLabel:kABAIMHomeLabel];
                [aPerson setValue:imMultiVal forProperty:kABAIMInstantProperty];
            }

            // And finally we're done...
            dataContainsEmail = YES;
        }
        if ([[contactInfoArray objectAtIndex:i] hasPrefix:@"http://"]) {
            [aPerson setValue:[contactInfoArray objectAtIndex:i] forProperty:kABHomePageProperty];
            dataContainsWebSite = YES;
        }
    }
}



@end

// A category added, yes, inside the same header and implementation files,
// that adds the ability to add lists of people to your Address Book
@implementation QIContactCreator (QIContactCreatorGroup)

-(void)doAddListOfContactsService:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error {
    NSString *pboardString; // the string coming from the pasteboard.
                            // Services dump the selected data, be it a file, string, or whathaveyou
                            // to the pasteboard.
    NSArray *types; // the NSArray you'll be using to store the types of the current pasteboard...
                    // see below for more info...

    // AddressBook vars
       // The global AddressBook database
    ABAddressBook *aBook = [ABAddressBook sharedAddressBook];
       // The group you'll create for these new contacts
    ABGroup *aGroup = [self fetchContactCreatorGroup:@"ContactCreator Imported Group" inBook:aBook];

    types = [pboard types];

    // Now check to see if the thing selected is an NSString.
    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType])) {
        *error = NSLocalizedString(@"Error: The pasteboard doesn't contain a string.",
                                   @"NSPasteboard couldn't give string.");
        return;
    }


    // Most of this method, as you probably have noticed, is borrowed from the
    // original doAddContactService: method.
    
    // Set up your booleans for email and website population...
    dataContainsEmail = NO;
    dataContainsWebSite = NO;

    if (pboardString) {
        // Split up the list of people into an array.
        NSArray *contacts = [pboardString componentsSeparatedByString:@","];
        // We're going to use an enumerator for this one, instead of the for
        // loops we used above.
        NSEnumerator *contactsEnumerator = [contacts objectEnumerator];
        id _contact;

        while (_contact = [contactsEnumerator nextObject]) {
            ABPerson *aPerson = [[ABPerson alloc] init];

            // We pass in an array made from the pboard string, split on spaces.
            [self putTextInProperPlace:_contact forPerson:aPerson];

            if (![aGroup addMember:aPerson]) {
                // We might want to implement these as Alert Panels...
                NSLog(@"There was a problem adding %@ to the group.", aPerson);
            } else {
                [aBook addRecord:aPerson];
            }

            
            // Reset your flags in case you need to process more addresses.
            dataContainsEmail = NO;
            dataContainsWebSite = NO;
        }
        
    }
    
    if ([aBook hasUnsavedChanges]) {
        if (![aBook save]) {
            // We might want to implement these as Alert Panels...
            NSLog(@"There was a problem saving %@ to the addressbook.", aGroup);
        }
    }    
}

// Try and find a ContactCreatorGroup Imported Group group
-(ABGroup *)fetchContactCreatorGroup:(NSString *)name inBook:(ABAddressBook *)aBook {
    // This search should return nil if the group doesn't exist or it should
    // return an array with 1 group if the group's already been created.
    NSArray *_groups = [aBook recordsMatchingSearchElement:[ABGroup searchElementForProperty:kABGroupNameProperty
                                                         label:nil
                                                           key:nil
                                                         value:name
                                                    comparison:kABEqualCaseInsensitive]];

    if ([_groups count] > 0) {
        return [_groups objectAtIndex:0];
    } else {
        // We didn't find any groups matching our ContactCreator Group,
        // init the new group we'll be putting contacts into
        // set the name of the new group into which contacts'll be dumped
        ABGroup *aGroup = [[ABGroup alloc] init];
        [aGroup setValue:name forProperty:kABGroupNameProperty];

        // Now, add the group to the Address Book.
        [aBook addRecord:aGroup];

        return aGroup;
    }
}

@end
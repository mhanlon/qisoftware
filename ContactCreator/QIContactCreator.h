//
//  QIContactCreator.h
//  ContactCreator
//
//  Created by Matt Hanlon on Tue Feb 11 2003.
//  Copyright (c) 2003 Q.I. Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface QIContactCreator : NSObject {
    BOOL dataContainsEmail;
    BOOL dataContainsWebSite;
}
-(void)doAddContactService:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error;

-(void)putTextInProperPlace:(NSString *)text forPerson:(ABPerson *)aPerson;
-(void)testForOtherFields:(NSArray *)contactInfoArray forPerson:(ABPerson *)aPerson;
@end


@interface QIContactCreator (QIContactCreatorGroup)

-(void)doAddListOfContactsService:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error;
-(ABGroup *)fetchContactCreatorGroup:(NSString *)name inBook:(ABAddressBook *)aBook;
@end
//
//  CPSABProtocol.h
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 17.11.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <Foundation/Foundation.h>


enum {
	CPSABRefOrderLastFirst  = 0,
	CPSABRefOrderFirstLast
};
typedef NSUInteger CPSABRefNameOrder;

// Objects responding to the CPSABReferenceAccessing protocol should also conform to CPSABReferenceStoring
@protocol CPSABReferenceStoring
@property (strong) NSString * contactUID;
@property (strong) NSString * primaryLabel;
@property (strong) NSString * secondaryLabel;
@end

@protocol CPSABReferenceSorting
- (CPSABRefNameOrder) sortOrder;
@end

@protocol CPSABReferenceAccessing
- (NSString *)displayName;
- (NSString *)firstName;
- (NSString *)lastName;
- (NSData *)pictureData;
- (NSImage *)picture;

- (NSDate*)birthdate;

- (NSString*)mobileLabel;
- (NSString*)mobilePhone;

- (NSString*)localizedPrimaryLabel;
- (NSString*)primaryAddress;
- (NSString*)primaryZip;
- (NSString*)primaryCity;
- (NSString*)primaryPhone;
- (NSString*)primaryFax;
- (NSString*)primaryEmail;

- (NSString*)localizedSecondaryLabel;
- (NSString*)secondaryAddress;
- (NSString*)secondaryZip;
- (NSString*)secondaryCity;
- (NSString*)secondaryPhone;
- (NSString*)secondaryFax;
- (NSString*)secondaryEmail;
@end

@protocol CPSABReferenceEditing
- (void)setBirthdate:(NSDate*)aBirthdate;

- (void)setMobilePhone:(NSString*)aMobilePhone;

- (void)setPrimaryAddress:(NSString*)arimaryAddress;
- (void)setPrimaryZip:(NSString*)aPrimaryZip;
- (void)setPrimaryCity:(NSString*)aPrimaryCity;
- (void)setPrimaryPhone:(NSString*)aPrimaryPhone;
- (void)setPrimaryFax:(NSString*)aPrimaryFax;
- (void)setPrimaryEmail:(NSString*)aPrimaryEmail;

- (void)setSecondaryAddress:(NSString*)aSecondaryAddress;
- (void)setSecondaryZip:(NSString*)aSecondaryZip;
- (void)setSecondaryCity:(NSString*)aSecondaryCity;
- (void)setSecondaryPhone:(NSString*)aSecondaryPhone;
- (void)setSecondaryFax:(NSString*)aSecondaryFax;
- (void)setSecondaryEmail:(NSString*)aSecondaryEmail;
@end

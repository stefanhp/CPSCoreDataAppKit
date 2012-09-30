//
//  CPSABReference.h
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 17.07.08.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>
#import "CPSABProtocol.h"

@interface CPSABManagedObject : NSManagedObject <CPSABReferenceStoring> {
	NSString* primaryLabel;
	NSString* secondaryLabel;
}
@property (strong) NSString * contactUID;
@property (strong) NSString * compositeName;
@property (strong) NSString * primaryLabel;
@property (strong) NSString * secondaryLabel;

@end


@interface CPSABManagedObject (CPSABReference) <CPSABReferenceAccessing>
+ (NSString *)contactUIDFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject;
+ (NSString *)compositeNameFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject;
+ (void)archiveCompositeNameFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject;
+ (NSArray*)matchingRecordsFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject;
+ (NSString *)primaryLabelFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject;
+ (NSString *)secondaryLabelFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject;
+ (ABRecord *)abEntryFor:(CPSABManagedObject*)managedObject;
+ (BOOL)isCompany:(CPSABManagedObject*)managedObject;
+ (NSString *)displayNameForABRef:(CPSABManagedObject <CPSABReferenceStoring,CPSABReferenceAccessing>*)abObject orderBy:(CPSABRefNameOrder)order;
+ (NSString *)firstNameForABRef:(CPSABManagedObject <CPSABReferenceStoring,CPSABReferenceAccessing>*)abObject;
+ (NSString *)lastNameForABRef:(CPSABManagedObject <CPSABReferenceStoring,CPSABReferenceAccessing>*)abObject;
+ (NSData *)pictureDataForABRef:(CPSABManagedObject <CPSABReferenceStoring,CPSABReferenceAccessing>*)abObject;
+ (NSImage *)pictureForABRef:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject;
+ (NSDate *)birthdate:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject;

+ (NSString	*)addressLabel:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label;
+ (NSString	*)address:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label;
+ (NSString	*)zip:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label;
+ (NSString	*)city:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label;
+ (NSString	*)phoneLabel:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label;
+ (NSString	*)phone:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label;
+ (NSString	*)emailLabel:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label;
+ (NSString	*)email:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label;

//protocol ABReferenceAccessing
- (NSString *)displayName;
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

@interface CPSABManagedObject (CPSABMutableReference) <CPSABReferenceEditing> 
+ (void)setValue:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject withLabel:(NSString*)label inProperty:(NSString*)property andKey:(NSString*)key;
+ (void)setValue:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject withLabel:(NSString*)label forProperty:(NSString*)property;

+ (void)setAddress:(NSString*)address forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label;
+ (void)setZip:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label;
+ (void)setCity:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label;
+ (void)setPhone:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label;
+ (void)setEmail:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label;

//protocol CPSABReferenceEditing
- (void)setBirthdate:(NSDate*)aBirthdate;
- (void)deleteBirthdate;

- (void)setMobilePhone:(NSString*)aMobilePhone;

- (void)setPrimaryAddress:(NSString*)aPrimaryAddress;
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


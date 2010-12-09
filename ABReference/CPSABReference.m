//
//  CPSABReference.m
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 17.07.08.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import "CPSABReference.h"
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABAddressBookC.h>


#define COMPOSITE_SEPARATOR @"@@@"

@implementation CPSABManagedObject

@dynamic contactUID;
@dynamic compositeName;
@synthesize primaryLabel;
@synthesize secondaryLabel;

@end

@implementation CPSABManagedObject (CPSABReference) 

+ (NSString *)contactUIDFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject{
	return [managedObject contactUID];
}

+ (NSString *)compositeNameFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject{
	return [managedObject compositeName];
}

+ (void)archiveCompositeNameFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject{
	NSString *uid = [CPSABManagedObject contactUIDFor:managedObject];
	if(uid != nil){
		ABRecord* record = [[ABAddressBook sharedAddressBook] recordForUniqueId:uid];
		NSString* current = [CPSABManagedObject compositeNameFor:managedObject];
		NSString* company = [record valueForProperty:kABOrganizationProperty];
		if(company == nil){
			company = @"";
		}
		NSString* first = [record valueForProperty:kABFirstNameProperty];
		if(first == nil){
			first = @"";
		}
		NSString* last = [record valueForProperty:kABLastNameProperty];
		if(last == nil){
			last = @"";
		}
		NSArray* parts = [NSArray arrayWithObjects:company, first, last, nil];
		NSString* newComposite = [parts componentsJoinedByString:COMPOSITE_SEPARATOR];
		if(current !=nil && ([current compare:newComposite] == NSOrderedSame)){
			// current and new composite are identical: do nothing
			//NSlog(@"Already have proper composite value");
		} else {
			// Archive new value
			//Dlog(@"Setting composite to: %@",newComposite);
			[managedObject setCompositeName:newComposite];
		}

	}
}

+ (NSArray*)matchingRecordsFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject{
	NSString *compositeName = [CPSABManagedObject compositeNameFor:managedObject];
	if(compositeName != nil){
		// Composite must exist meaning the record exsited once
		NSArray* parts = [compositeName componentsSeparatedByString:COMPOSITE_SEPARATOR];
		if([parts count] == 3){
			ABSearchElement *company = [ABPerson searchElementForProperty:kABOrganizationProperty
																	label:nil
																	  key:nil
																	value:[parts objectAtIndex:0]
															   comparison:kABContainsSubStringCaseInsensitive];
			ABSearchElement *first = [ABPerson searchElementForProperty:kABFirstNameProperty
																  label:nil
																	key:nil
																  value:[parts objectAtIndex:1]
															 comparison:kABContainsSubStringCaseInsensitive];
			ABSearchElement *last = [ABPerson searchElementForProperty:kABLastNameProperty
																 label:nil
																   key:nil
																 value:[parts objectAtIndex:2]
															comparison:kABContainsSubStringCaseInsensitive];
			ABSearchElement *companyAndFirstAndLast = [ABSearchElement searchElementForConjunction:kABSearchAnd
																						  children:[NSArray arrayWithObjects:
																									company, first, last, nil]];
			return [[ABAddressBook sharedAddressBook] recordsMatchingSearchElement:companyAndFirstAndLast];
		}
	}
	return [NSArray array];
}

+ (NSString *)primaryLabelFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject{
	return [managedObject primaryLabel];
}

+ (NSString *)secondaryLabelFor:(CPSABManagedObject<CPSABReferenceStoring>*)managedObject{
	return [managedObject secondaryLabel];
}

+ (ABRecord *)abEntryFor:(CPSABManagedObject*)managedObject{
	NSString *uid = [CPSABManagedObject contactUIDFor:managedObject];
	if(uid != nil){
		ABRecord* record = [[ABAddressBook sharedAddressBook] recordForUniqueId:uid];
		if(record != nil){
			return record;
		}
	}
	// No record for that UID, search a matching one
	NSArray *matches = [CPSABManagedObject matchingRecordsFor:managedObject];
	if([matches count] == 1){
		// found a unique match, update UID and return that record
		ABRecord* record = [matches objectAtIndex:0];
		[managedObject setContactUID:[record uniqueId]];
		return record;
	}
	
	return nil;
}

+ (BOOL)isCompany:(CPSABManagedObject*)managedObject{
	BOOL value = NO;
	ABRecord* record = [CPSABManagedObject abEntryFor:managedObject];
	if(record != nil){
		NSNumber *flags = [record valueForProperty:kABPersonFlags];
		return [flags intValue] && kABShowAsCompany;
	}
	return value;
}

+ (NSString *)displayNameForABRef:(CPSABManagedObject <CPSABReferenceStoring,CPSABReferenceAccessing>*)abObject orderBy:(CPSABRefNameOrder)order{	
	NSString *uid = [CPSABManagedObject contactUIDFor:abObject];
	
	if(uid != nil){
		//NSLog(@"UID: %@", uid);
		ABRecord *record = [[ABAddressBook sharedAddressBook] recordForUniqueId:uid];
		if(record != nil){
			//NSLog(@"Record: %@", record);
			NSNumber *flags = [record valueForProperty:kABPersonFlags];
			if([flags intValue] && kABShowAsCompany){ // Company
				//NSLog(@"--Company");
				return [record valueForProperty:kABOrganizationProperty];
			} else { // Person
				//NSLog(@"--Person");
				NSString *firstName = [record valueForProperty:kABFirstNameProperty];
				NSString *lastName = [record valueForProperty:kABLastNameProperty];
				if(firstName != nil && lastName == nil){
					return firstName;
				}
				else if(firstName != nil && lastName != nil){
					NSString *theDisplayName;
					switch(order){
						case CPSABRefOrderLastFirst:
							theDisplayName = [lastName stringByAppendingString:@" "];
							theDisplayName = [theDisplayName stringByAppendingString:firstName];
							break;
						case CPSABRefOrderFirstLast:
						default:
							theDisplayName = [firstName stringByAppendingString:@" "];
							theDisplayName = [theDisplayName stringByAppendingString:lastName];
							break;
					}		
					
					return theDisplayName;
				}
				else if(firstName == nil && lastName != nil){
					return lastName;
				}
			}
		} else {
			return NSLocalizedStringWithDefaultValue(@"INVALID_UID", 
													 @"iMed", 
													 [NSBundle mainBundle], 
													 @"<Contact with this ID does not exist in Address Book>", 
													 @"Contact with this ID does not exist in Address Book");
		}
	} else {
		return NSLocalizedStringWithDefaultValue(@"NIL_UID", 
												 @"iMed", 
												 [NSBundle mainBundle], 
												 @"<No Contact selected in Address Book>", 
												 @"Error string for display name when no contact info is selected");
	}
	
	return NSLocalizedStringWithDefaultValue(@"EMPTY_OBJECT", 
											 @"iMed", 
											 [NSBundle mainBundle], 
											 @"<No field set>", 
											 @"Error string for display name when no valid field is filled");
}

+ (NSString *)firstNameForABRef:(CPSABManagedObject <CPSABReferenceStoring,CPSABReferenceAccessing>*)abObject{
	NSString *uid = [CPSABManagedObject contactUIDFor:abObject];
	if(uid != nil){
		ABPerson *record = (ABPerson*)[[ABAddressBook sharedAddressBook] recordForUniqueId:uid];
		if(record != nil){
			NSString *firstName = [record valueForProperty:kABFirstNameProperty];
			return firstName;
		}
	}
	
	return nil;
}

+ (NSString *)lastNameForABRef:(CPSABManagedObject <CPSABReferenceStoring,CPSABReferenceAccessing>*)abObject{
	NSString *uid = [CPSABManagedObject contactUIDFor:abObject];
	if(uid != nil){
		ABPerson *record = (ABPerson*)[[ABAddressBook sharedAddressBook] recordForUniqueId:uid];
		if(record != nil){
			NSString *lastName = [record valueForProperty:kABLastNameProperty];
			return lastName;
		}
	}
	
	return nil;
}

+ (NSData *)pictureDataForABRef:(CPSABManagedObject <CPSABReferenceStoring,CPSABReferenceAccessing>*)abObject {
	NSString *uid = [CPSABManagedObject contactUIDFor:abObject];
	if(uid != nil){
		ABPerson *record = (ABPerson*)[[ABAddressBook sharedAddressBook] recordForUniqueId:uid];
		if(record != nil){
			NSData* data = [record imageData];
			return data;
		}
	}
	
	return nil;
}

+ (NSImage *)pictureForABRef:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject {
	NSData* data = [abObject pictureData];
	NSImage* image = nil;
	if(data != nil){
		image = [[[NSImage alloc]initWithData:data]autorelease];
	} else if([CPSABManagedObject isCompany:abObject]){
		image = [[[NSImage alloc]initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"company-48" ofType:@"png"]]autorelease];
	} else {
		image = [NSImage imageNamed:NSImageNameUser];
	}
	return image;
}

+ (NSDate *)birthdate:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject {
	ABRecord* record = [CPSABManagedObject abEntryFor:abObject];
	if(record != nil){
		return [record valueForProperty:kABBirthdayProperty];
	}
	return nil;
}

+ (NSString	*)addressLabel:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label{
	ABMultiValue *addresses = [[CPSABManagedObject abEntryFor:abObject] valueForProperty:kABAddressProperty];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [addresses count]; primaryIndex++){
		if([[addresses labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [addresses count]){
		NSString* localizedValue = [(NSString*)ABCopyLocalizedPropertyOrLabel((CFStringRef)[addresses labelAtIndex:primaryIndex]) autorelease];
		return [localizedValue capitalizedString];
	}
	return nil;
}

+ (NSString	*)address:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label{
	ABMultiValue *addresses = [[CPSABManagedObject abEntryFor:abObject] valueForProperty:kABAddressProperty];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [addresses count]; primaryIndex++){
		if([[addresses labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [addresses count]){
		NSMutableDictionary *theAddress = [addresses valueAtIndex:primaryIndex];
		if(theAddress != nil){
			return [theAddress objectForKey:kABAddressStreetKey];
		}
	}
	return nil;
}

+ (NSString	*)zip:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label{
	ABMultiValue *addresses = [[CPSABManagedObject abEntryFor:abObject] valueForProperty:kABAddressProperty];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [addresses count]; primaryIndex++){
		if([[addresses labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [addresses count]){
		NSMutableDictionary *theAddress = [addresses valueAtIndex:primaryIndex];
		if(theAddress != nil){
			return [theAddress objectForKey:kABAddressZIPKey];
		}
	}
	return nil;
}

+ (NSString	*)city:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label{
	ABMultiValue *addresses = [[CPSABManagedObject abEntryFor:abObject] valueForProperty:kABAddressProperty];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [addresses count]; primaryIndex++){
		if([[addresses labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [addresses count]){
		NSMutableDictionary *theAddress = [addresses valueAtIndex:primaryIndex];
		if(theAddress != nil){
			return [theAddress objectForKey:kABAddressCityKey];
		}
	}
	return nil;
}

+ (NSString	*)phoneLabel:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label{
	ABMultiValue *phones = [[CPSABManagedObject abEntryFor:abObject] valueForProperty:kABPhoneProperty];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [phones count]; primaryIndex++){
		if([[phones labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [phones count]){
		if(phones != nil){
			NSString* value = [phones labelAtIndex:primaryIndex];
			NSString* localizedValue =  [(NSString*)ABCopyLocalizedPropertyOrLabel((CFStringRef)value) autorelease];
			return [localizedValue capitalizedString];
		}
	}
	return nil;
}

+ (NSString	*)phone:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label{
	ABMultiValue *phones = [[CPSABManagedObject abEntryFor:abObject] valueForProperty:kABPhoneProperty];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [phones count]; primaryIndex++){
		if([[phones labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [phones count]){
		if(phones != nil){
			NSString* value = [phones valueAtIndex:primaryIndex];
			return value;
		}
	}
	return nil;
}

+ (NSString	*)emailLabel:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label{
	ABMultiValue *emails = [[CPSABManagedObject abEntryFor:abObject] valueForProperty:kABEmailProperty];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [emails count]; primaryIndex++){
		if([[emails labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [emails count]){
		if(emails != nil){
			NSString* value = [emails labelAtIndex:primaryIndex];
			NSString* localizedValue = [(NSString*)ABCopyLocalizedPropertyOrLabel((CFStringRef)value) autorelease];
			return [localizedValue capitalizedString];
		}
	}
	return nil;
}

+ (NSString	*)email:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject forLabel:(NSString*)label{
	ABMultiValue *emails = [[CPSABManagedObject abEntryFor:abObject] valueForProperty:kABEmailProperty];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [emails count]; primaryIndex++){
		if([[emails labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [emails count]){
		if(emails != nil){
			NSString* value = [emails valueAtIndex:primaryIndex];
			return value;
		}
	}
	return nil;
}

- (NSString *)displayName {
	if([self conformsToProtocol:@protocol(CPSABReferenceSorting)]){
		return [CPSABManagedObject displayNameForABRef:self orderBy:[(CPSABManagedObject<CPSABReferenceSorting>*)self sortOrder]];
	}
	return [CPSABManagedObject displayNameForABRef:self orderBy:CPSABRefOrderLastFirst];
}

- (NSString *)firstName{
	return [CPSABManagedObject firstNameForABRef:self];
}

- (NSString *)lastName{
	return [CPSABManagedObject lastNameForABRef:self];
}

- (NSData *)pictureData {
	return [CPSABManagedObject pictureDataForABRef:self];
}

- (NSImage *)picture {
	return [CPSABManagedObject pictureForABRef:self];
}
- (NSDate*)birthdate{
	return [CPSABManagedObject birthdate:self];
}
- (NSString*)mobileLabel{
	return [CPSABManagedObject phoneLabel:self forLabel:kABPhoneMobileLabel]; 
}
- (NSString*)mobilePhone{
	return [CPSABManagedObject phone:self forLabel:kABPhoneMobileLabel]; 
}

- (NSString*)localizedPrimaryLabel{
	NSString *result = [CPSABManagedObject phoneLabel:self forLabel:[self primaryLabel]];
	if(result == nil){
		result = [CPSABManagedObject addressLabel:self forLabel:[self primaryLabel]];
	}
	if(result == nil){
		result = [CPSABManagedObject emailLabel:self forLabel:[self primaryLabel]];
	}
	return result;
}

- (NSString*)primaryAddress{
	return [CPSABManagedObject address:self forLabel:[self primaryLabel]]; 
}

- (NSString*)primaryZip{
	return [CPSABManagedObject zip:self forLabel:[self primaryLabel]]; 
}

- (NSString*)primaryCity{
	return [CPSABManagedObject city:self forLabel:[self primaryLabel]]; 
}

- (NSString*)primaryPhone{
	return [CPSABManagedObject phone:self forLabel:[self primaryLabel]]; 
}

- (NSString*)primaryFax{
	if([[self primaryLabel]isEqualToString:kABAIMHomeLabel]){
		return [CPSABManagedObject phone:self forLabel:kABPhoneHomeFAXLabel];
	} 
	return [CPSABManagedObject phone:self forLabel:kABPhoneWorkFAXLabel]; 
}

- (NSString*)primaryEmail{
	return [CPSABManagedObject email:self forLabel:[self primaryLabel]]; 
}

- (NSString*)localizedSecondaryLabel{
	NSString *result = [CPSABManagedObject phoneLabel:self forLabel:[self secondaryLabel]];
	if(result == nil){
		result = [CPSABManagedObject addressLabel:self forLabel:[self secondaryLabel]];
	}
	if(result == nil){
		result = [CPSABManagedObject emailLabel:self forLabel:[self secondaryLabel]];
	}
	return result;
}

- (NSString*)secondaryAddress{
	return [CPSABManagedObject address:self forLabel:[self secondaryLabel]]; 
}

- (NSString*)secondaryZip{
	return [CPSABManagedObject zip:self forLabel:[self secondaryLabel]]; 
}

- (NSString*)secondaryCity{
	return [CPSABManagedObject city:self forLabel:[self secondaryLabel]]; 
}

- (NSString*)secondaryPhone{
	return [CPSABManagedObject phone:self forLabel:[self secondaryLabel]]; 
}

- (NSString*)secondaryFax{
	if([[self secondaryLabel]isEqualToString:kABAIMWorkLabel]){
		return [CPSABManagedObject phone:self forLabel:kABPhoneWorkFAXLabel];
	}
	return [CPSABManagedObject phone:self forLabel:kABPhoneHomeFAXLabel]; 
}

- (NSString*)secondaryEmail{
	return [CPSABManagedObject email:self forLabel:[self secondaryLabel]]; 
}

@end

@implementation CPSABManagedObject (CPSABMutableReference)
+ (void)setAddress:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label{
	[CPSABManagedObject setValue:newValue forObject:abObject withLabel:label inProperty:kABAddressProperty andKey:kABAddressStreetKey];
}

+ (void)setZip:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label{
	[CPSABManagedObject setValue:newValue forObject:abObject withLabel:label inProperty:kABAddressProperty andKey:kABAddressZIPKey];
}

+ (void)setCity:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label{
	[CPSABManagedObject setValue:newValue forObject:abObject withLabel:label inProperty:kABAddressProperty andKey:kABAddressCityKey];
}

+ (void)setPhone:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label{
	[CPSABManagedObject setValue:newValue forObject:abObject withLabel:label forProperty:kABPhoneProperty];
}

+ (void)setEmail:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject andLabel:(NSString*)label{
	[CPSABManagedObject setValue:newValue forObject:abObject withLabel:label forProperty:kABEmailProperty];
}

+ (void)setValue:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject withLabel:(NSString*)label inProperty:(NSString*)property andKey:(NSString*)key{
	if(label == nil){
		return;
	}
	ABRecord *record = [CPSABManagedObject abEntryFor:abObject];
	ABMutableMultiValue *multiValue = [[[record valueForProperty:property]mutableCopy]autorelease];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [multiValue count]; primaryIndex++){
		if([[multiValue labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [multiValue count]){
		NSMutableDictionary *existingValueDict = [[[multiValue valueAtIndex:primaryIndex]mutableCopy]autorelease];
		if(existingValueDict != nil){
			if(newValue != nil){
				[existingValueDict setObject:newValue forKey:key];
			} else {
				[existingValueDict removeObjectForKey:key];
			}
			if([[existingValueDict allKeys]count] > 0){
				[multiValue replaceValueAtIndex:primaryIndex withValue:existingValueDict];
			} else {
				[multiValue removeValueAndLabelAtIndex:primaryIndex];
			}
			[record setValue:multiValue forProperty:property];
			[[ABAddressBook sharedAddressBook]save];
		}
	} else if(newValue != nil) {
		// no entry yet
		NSMutableDictionary *theValueDict = [NSMutableDictionary dictionaryWithObject:newValue forKey:key];
		if(multiValue == nil){
			multiValue = [[[ABMutableMultiValue alloc]init]autorelease];
		}
		[multiValue addValue:theValueDict withLabel:label];
		[record setValue:multiValue forProperty:property];
		[[ABAddressBook sharedAddressBook]save];
	}
}

+ (void)setValue:(NSString*)newValue forObject:(CPSABManagedObject <CPSABReferenceAccessing>*)abObject withLabel:(NSString*)label forProperty:(NSString*)property{
	if(label == nil){
		return;
	}
	ABRecord *record = [CPSABManagedObject abEntryFor:abObject];
	ABMutableMultiValue *multiValue = [[[record valueForProperty:property]mutableCopy]autorelease];
	NSUInteger primaryIndex = 0;
	for(primaryIndex = 0; primaryIndex < [multiValue count]; primaryIndex++){
		if([[multiValue labelAtIndex:primaryIndex] isEqualToString:label]){
			break;
		}
	}
	if(primaryIndex < [multiValue count]){
		if(newValue != nil){
			[multiValue replaceValueAtIndex:primaryIndex withValue:newValue];
			[record setValue:multiValue forProperty:property];
		} else {
			[multiValue removeValueAndLabelAtIndex:primaryIndex];
			if([multiValue count] > 0){
				[record setValue:multiValue forProperty:property];
			} else {
				[record removeValueForProperty:property];
			}
		}
		[[ABAddressBook sharedAddressBook]save];
	} else if(newValue != nil){
		if(multiValue == nil){
			multiValue = [[[ABMutableMultiValue alloc]init]autorelease];
		}
		[multiValue addValue:newValue withLabel:label];
		[record setValue:multiValue forProperty:property];
		[[ABAddressBook sharedAddressBook]save];
	}
}

- (void)setBirthdate:(NSDate*)aBirthdate{
	ABRecord* record = [CPSABManagedObject abEntryFor:self];
	if(record != nil){
		if(aBirthdate != nil){
			[record setValue:aBirthdate forProperty:kABBirthdayProperty];
			[[ABAddressBook sharedAddressBook]save];
		} else {
			if([record valueForProperty:kABBirthdayProperty] != nil){
				[record removeValueForProperty:kABBirthdayProperty];
				[[ABAddressBook sharedAddressBook]save];
			}
		}
	}
}
- (void)deleteBirthdate{
	[self setBirthdate:nil];
}

- (void)setMobilePhone:(NSString*)aMobilePhone{
	//[self willChangeValueForKey:@"mobilePhone"];
	[self willChangeValueForKey:@"mobileLabel"];
	[CPSABManagedObject setPhone:aMobilePhone forObject:self andLabel:kABPhoneMobileLabel]; 	
	[self didChangeValueForKey:@"mobileLabel"];
	//[self didChangeValueForKey:@"mobilePhone"];
}

- (void)setPrimaryAddress:(NSString*)aPrimaryAddress{
	[CPSABManagedObject setAddress:aPrimaryAddress forObject:self andLabel:[self primaryLabel]]; 	
}
- (void)setPrimaryZip:(NSString*)aPrimaryZip{
	[CPSABManagedObject setZip:aPrimaryZip forObject:self andLabel:[self primaryLabel]]; 	
}
- (void)setPrimaryCity:(NSString*)aPrimaryCity{
	[CPSABManagedObject setCity:aPrimaryCity forObject:self andLabel:[self primaryLabel]]; 	
}
- (void)setPrimaryPhone:(NSString*)aPrimaryPhone{
	[CPSABManagedObject setPhone:aPrimaryPhone forObject:self andLabel:[self primaryLabel]]; 	
}
- (void)setPrimaryFax:(NSString*)aPrimaryFax{
	if([[self primaryLabel]isEqualToString:kABAIMHomeLabel]){
		[CPSABManagedObject setPhone:aPrimaryFax forObject:self andLabel:kABPhoneHomeFAXLabel];
	} else {
		[CPSABManagedObject setPhone:aPrimaryFax forObject:self andLabel:kABPhoneWorkFAXLabel]; 
	}
}
- (void)setPrimaryEmail:(NSString*)aPrimaryEmail{
	[CPSABManagedObject setEmail:aPrimaryEmail forObject:self andLabel:[self primaryLabel]]; 	
}

- (void)setSecondaryAddress:(NSString*)aSecondaryAddress{
	[CPSABManagedObject setAddress:aSecondaryAddress forObject:self andLabel:[self secondaryLabel]]; 	
}

- (void)setSecondaryZip:(NSString*)aSecondaryZip{
	[CPSABManagedObject setZip:aSecondaryZip forObject:self andLabel:[self secondaryLabel]]; 	
}
- (void)setSecondaryCity:(NSString*)aSecondaryCity{
	[CPSABManagedObject setCity:aSecondaryCity forObject:self andLabel:[self secondaryLabel]]; 	
}
- (void)setSecondaryPhone:(NSString*)aSecondaryPhone{
	[CPSABManagedObject setPhone:aSecondaryPhone forObject:self andLabel:[self secondaryLabel]]; 	
}
- (void)setSecondaryFax:(NSString*)aSecondaryFax{
	if([[self secondaryLabel]isEqualToString:kABAIMWorkLabel]){
		[CPSABManagedObject setPhone:aSecondaryFax forObject:self andLabel:kABPhoneWorkFAXLabel];
	} else {
		[CPSABManagedObject setPhone:aSecondaryFax forObject:self andLabel:kABPhoneHomeFAXLabel]; 
			
	}
}
- (void)setSecondaryEmail:(NSString*)aSecondaryEmail{
	[CPSABManagedObject setEmail:aSecondaryEmail forObject:self andLabel:[self secondaryLabel]]; 	
}

@end

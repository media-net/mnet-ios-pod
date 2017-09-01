//
//  MNetUser.h
//  Pods
//
//  Created by nithin.g on 04/08/17.
//
//

#import <Foundation/Foundation.h>

typedef enum{
    MNetGenderOther,
    MNetGenderMale,
    MNetGenderFemale
} MNetUserGender;

@interface MNetUser : NSObject

/// An ID for identifying the user
- (void)addUserId:(NSString *)userId;

/// Gender of the user.
- (void)addGender:(MNetUserGender)gender;

/// Name of the user
- (void)addName:(NSString *)name;

/// Year of birth of the user. The string MUST be 4 digits indicating a valid year of birth
- (BOOL)addYearOfBirth:(NSString *)yob;

/// Comma separated list of keywords, user-interests or intent
- (void)addKeywords:(NSString *)keywords;

@end

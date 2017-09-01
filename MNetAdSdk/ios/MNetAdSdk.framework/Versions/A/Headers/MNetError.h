//
//  MNetError.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <Foundation/Foundation.h>

/// The class that's the error type for ads.
@interface MNetError: NSObject

/// Initialise MNetError with the NSError object
-(id)initWithError:(NSError *)errorObj;

/// Initialise MNetError with the NSError object with the callstack
-(id)initWithError:(NSError *)errorObj withCallStack:(NSArray *)callstack;

/// Initialise MNetError with a NSString
-(id)initWithStr:(NSString *)errorStr;

/// Initialise the MNetError with a NSString and callstack
-(id)initWithStr:(NSString *)errorStr withCallStack:(NSArray *)callstack;

/// Returns the error description
- (NSString *)getErrorString;

/// Get the Error object from MNetError
- (NSError *)getError;

/// Creates and returns an NSError object with the given description
+ (NSError *)createErrorWithDescription:(NSString *) descriptionStr;

/// Creates and returns an NSError object with the given description
/// and failure reason.
+ (NSError *)createErrorWithDescription:(NSString *) descriptionStr
                       AndFailureReason:(NSString *) failureReasonStr;

/// Creates and returns an NSError object with the given description,
/// failure reason and the recoverySuggestion string.
+ (NSError *)createErrorWithDescription:(NSString *) descriptionStr
                       AndFailureReason:(NSString *) failureReasonStr
                  AndRecoverySuggestion:(NSString *) recoverySuggestionStr;

@end


//
//  MNetError.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    // HTTP error code
    MNetErrCodeGeneric                  = -1000,
    MNetErrCodeNoInternetConnection     = -1001,
    MNetErrCodeInvalidRequest           = -1002,
    MNetErrCodeInvalidURL               = -1003,
    MNetErrCodeInvalidResponse          = -1004,
    // Ad loading error code
    MNetErrCodeInvalidAdUnitId          = -2000,
    MNetErrCodeAdLoadFailed             = -2001,
    MNetErrCodeInvalidAdRequest         = -2002,
    MNetErrCodeAdViewBusy               = -2203,
    MNetErrCodeInvalidAdSize            = -2004,
    MNetErrCodePrefetchLoadFailed       = -2005,
    MNetErrCodeInvalidAdType            = -2006,
    MNetErrCodeInvalidAdController      = -2007,
    MNetErrCodeRootViewControllerNil    = -2008,
    MNetErrCodeInvalidAdCode            = -2009,
    MNetErrCodeInvalidAdUrl             = -2010,
    MNetErrCodeAdUrlRequestFailed       = -2011,
    // HB error code
    MNetErrCodeHBLoadFailed             = -3000,
    // MRAID error code
    MNetErrCodeMRAID                    = -4000,
    // Video error code
    MNetErrCodeVideo                    = -5000,
    // Ad view reuse code
    MNetErrCodeAdViewReuse              = -6000,
    // Adx error code
    MNetErrCodeAdxFailed                = -7000,
}MNetErrorCode;


/// The class that's the error type for ads.
@interface MNetError: NSObject

NS_ASSUME_NONNULL_BEGIN
/// Initialise MNetError with the NSError object
-(id)initWithError:(NSError * _Nullable)errorObj;

/// Initialise MNetError with the NSError object with the callstack
-(id)initWithError:(NSError *)errorObj withCallStack:(NSArray * _Nullable)callstack;

/// Initialise MNetError with a NSString
-(id)initWithStr:(NSString *)errorStr;

/// Initialise the MNetError with a NSString and callstack
-(id)initWithStr:(NSString *)errorStr withCallStack:(NSArray * _Nullable)callstack;

/// Returns the error description
- (NSString *)getErrorString;

/// Returns the error reason
- (NSString *)getErrorReasonString;

/// Get the Error object from MNetError
- (NSError *)getError;

/// Creates and returns an NSError object with the given description
+ (NSError *)createErrorWithDescription:(NSString *)descriptionStr;

/// Creates and returns an NSError object with the given description
/// and failure reason.
+ (NSError *)createErrorWithDescription:(NSString * _Nullable)descriptionStr
                       AndFailureReason:(NSString * _Nullable)failureReasonStr;

/// Creates and returns an NSError object with the given description,
/// failure reason and the recoverySuggestion string.
+ (NSError *)createErrorWithDescription:(NSString * _Nullable)descriptionStr
                       AndFailureReason:(NSString * _Nullable)failureReasonStr
                  AndRecoverySuggestion:(NSString * _Nullable)recoverySuggestionStr;

//// Create and return an NSError object with the given Error code.
+ (NSError *)createErrorWithCode:(MNetErrorCode)errCode withFailureReason:(NSString * _Nullable)reason;

// Create and return an NSError object with the given Error code,
// description and failure reason.
+ (NSError *)createErrorWithCode:(MNetErrorCode)errCode
                errorDescription:(NSString * _Nullable)description
                andFailureReason:(NSString * _Nullable)reason;

NS_ASSUME_NONNULL_END
@end


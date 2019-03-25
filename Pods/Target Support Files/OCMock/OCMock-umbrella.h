#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSInvocation+OCMAdditions.h"
#import "NSMethodSignature+OCMAdditions.h"
#import "NSNotificationCenter+OCMAdditions.h"
#import "NSObject+OCMAdditions.h"
#import "OCClassMockObject.h"
#import "OCMArg.h"
#import "OCMBlockCaller.h"
#import "OCMBoxedReturnValueProvider.h"
#import "OCMConstraint.h"
#import "OCMExceptionReturnValueProvider.h"
#import "OCMIndirectReturnValueProvider.h"
#import "OCMNotificationPoster.h"
#import "OCMObserverRecorder.h"
#import "OCMock.h"
#import "OCMockObject.h"
#import "OCMockRecorder.h"
#import "OCMPassByRefSetter.h"
#import "OCMRealObjectForwarder.h"
#import "OCMReturnValueProvider.h"
#import "OCObserverMockObject.h"
#import "OCPartialMockObject.h"
#import "OCPartialMockRecorder.h"
#import "OCProtocolMockObject.h"

FOUNDATION_EXPORT double OCMockVersionNumber;
FOUNDATION_EXPORT const unsigned char OCMockVersionString[];


//
//  FKFlickrTagsGetMostFrequentlyUsed.m
//  FlickrKit
//
//  Generated by FKAPIBuilder on 12 Jun, 2013 at 17:19.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrTagsGetMostFrequentlyUsed.h" 

@implementation FKFlickrTagsGetMostFrequentlyUsed

- (BOOL) needsLogin {
    return YES;
}

- (BOOL) needsSigning {
    return YES;
}

- (FKPermission) requiredPerms {
    return 0;
}

- (NSString *) name {
    return @"flickr.tags.getMostFrequentlyUsed";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrTagsGetMostFrequentlyUsedError_InvalidSignature:
			return @"Invalid signature";
		case FKFlickrTagsGetMostFrequentlyUsedError_MissingSignature:
			return @"Missing signature";
		case FKFlickrTagsGetMostFrequentlyUsedError_LoginFailedOrInvalidAuthToken:
			return @"Login failed / Invalid auth token";
		case FKFlickrTagsGetMostFrequentlyUsedError_UserNotLoggedInOrInsufficientPermissions:
			return @"User not logged in / Insufficient permissions";
		case FKFlickrTagsGetMostFrequentlyUsedError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrTagsGetMostFrequentlyUsedError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrTagsGetMostFrequentlyUsedError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrTagsGetMostFrequentlyUsedError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrTagsGetMostFrequentlyUsedError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrTagsGetMostFrequentlyUsedError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrTagsGetMostFrequentlyUsedError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end

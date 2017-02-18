#import <Foundation/Foundation.h>

@interface ARAPIKey : NSObject

+ (instancetype)sharedInstance;

- (void)setAPIKey:(NSString *)key;

- (BOOL)keyIsValid;

@end

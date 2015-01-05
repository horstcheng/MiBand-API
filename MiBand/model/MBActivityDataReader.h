#import "MBDataReader.h"

@interface MBActivityDataReader : MBDataReader

- (BOOL)isDone;
- (instancetype)appendData:(NSData *)data;
- (NSArray *)activityDataFragmentList;

@end

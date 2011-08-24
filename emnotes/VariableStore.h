//
//  VariableStore.h
//  emnotes
//
//a simple singleton to contain global variables
//only needed for now so to communicate need for cache cleanup to avoid cache crashing app after updates
//would rather use singleton rather than properties such as '[NSNumber numberWithInt:[prefs integerForKey:@"lastDatabaseGenerationTime"]]

//  Created by ck on 8/23/11.
//

//#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface VariableStore : NSObject
{
    // Place any "global" variables here
	BOOL notesViewNeedsCacheReset;
}

//class methods... ie static methods
// message from which our instance is obtained
+ (VariableStore *)sharedInstance;

//object methods
//-(void) bla;

//public properties
@property BOOL notesViewNeedsCacheReset;

@end

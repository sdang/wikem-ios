//
//  VariableStore.m
//  emnotes
//
//  Created by ck on 8/23/11.
 //

#import "VariableStore.h"


@implementation VariableStore
//	BOOL notesViewNeedsCacheReset;
//@synthesize used for properties makes automatic getter and setter :)
@synthesize notesViewNeedsCacheReset;


static VariableStore* myInstance = nil;

+ (VariableStore *)sharedInstance
{
    // the instance of this class is stored here
   // static VariableStore *myInstance = nil;
	
	
	/*@syncronized puts locks on block of code 
	  'a lock is a synchronization mechanism for enforcing limits on access to a resource in an environment where there are many threads of execution.
	 Locks are one way of enforcing concurrency control policies.'
	 */
	@synchronized([VariableStore class]){
		
		// check to see if an instance already exists
		if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
		
        // initialize variables here
		//BOOL notesViewNeedsCacheReset = NO;

		}
		// return the instance of this class
		return myInstance;
		}
	return nil;
}

+(id)alloc{
	@synchronized([VariableStore class])
			{
				/*Why use assertations from NSAssert?
				 'Assert is to make sure a value is what its suppose to be.
				 If assertion fails that means something went wrong and so the app quits. 
				 One reason to use assert would be if you have some function that will not behave or will create very bad side effects
				 if one of the parameters passed to it is not exactly some value (or a range of values) 
				 you can put an assert to make sure that value is what you expect it to be, and if its not then something is really wrong, 
				 and so the app quits. Assert can be very useful for debugging/unit testing,
				 and also when you provide frameworks to stop the users from doing "evil" things'
				 */
				NSAssert( myInstance == nil, @"Attempted to allocate a second instance of a singleton.");
				myInstance = [super alloc];
				return myInstance;
			}
	return nil;
}
				  
-(id)init {
	self = [super init];
	if (self !=nil) {
		//initialize stuff here
		notesViewNeedsCacheReset = NO;
	}
	return self;
}				  
				  
//getters
- (BOOL*) notesViewNeedsCacheReset {
    return notesViewNeedsCacheReset;
}
@end
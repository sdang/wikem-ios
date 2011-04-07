//
//  EditNoteViewController.h
//  emnotes
//
//  Created by Sabin Dang on 4/6/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditNoteViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    UITextField *noteTitleTextField;
    UITextView *noteContentTextField;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITextField *noteTitleTextField;
@property (nonatomic, retain) IBOutlet UITextView *noteContentTextField;

@end

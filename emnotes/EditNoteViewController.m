//
//  EditNoteViewController.m
//  emnotes
//
//  Created by Sabin Dang on 4/6/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "EditNoteViewController.h"
#import "PersonalNote.h"

@implementation EditNoteViewController
@synthesize noteTitleTextField;
@synthesize noteContentTextField;
@synthesize managedObjectContext;
@synthesize editingMode;

# pragma mark - Text View Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.noteTitleTextField)
        [noteContentTextField becomeFirstResponder];
    
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // if we're the content text area, clear Placeholder text

       // if we're centered, we're place holder text
    if (self.noteContentTextField.textAlignment == UITextAlignmentCenter && textView == self.noteContentTextField) {
        [self.noteContentTextField setTextAlignment:UITextAlignmentLeft];
        [self.noteContentTextField setText:@""];
        [self.noteContentTextField setTextColor:[UIColor blackColor]];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // set back placeholder text if we have no content
    if (self.noteContentTextField.textAlignment == UITextAlignmentLeft && textView == self.noteContentTextField && [textView.text isEqualToString:@""]) {
        [self.noteContentTextField setTextAlignment:UITextAlignmentCenter];
        [self.noteContentTextField setText:@"Tap Here to Edit Note Content"];
        [self.noteContentTextField setTextColor:[UIColor grayColor]];
    }
}

# pragma mark - Note Management

- (void)saveNote
{
    [PersonalNote personalNoteWithTitle:self.noteTitleTextField.text content:self.noteContentTextField.text inManagedObjectContext:self.managedObjectContext forceCreate:YES];
    [self.navigationController popViewControllerAnimated:TRUE];
    NSLog(@"Saving Personal Note");
}

# pragma mark - Memory Management

- (id)initWithNote:(PersonalNote *)personalNote {
    [super init];
    
    if (personalNote) {
        self.editingMode = TRUE;
        self.noteContentTextField.text = personalNote.content;
        self.noteTitleTextField.text = personalNote.title;
        [self.noteTitleTextField setEnabled:NO];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveNote)];
        self.navigationItem.rightBarButtonItem = saveButton;
        [saveButton release];
    }
    return self;
}

- (void)dealloc
{
    [noteTitleTextField release];
    [noteContentTextField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.noteTitleTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setNoteTitleTextField:nil];
    [self setNoteContentTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

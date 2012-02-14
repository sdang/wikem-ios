//
//  PersonalNotesViewController.m
//  emnotes
//
//  Created by Sabin Dang on 4/6/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "PersonalNotesViewController.h"
#import "EditNoteViewController.h"
#import "emnotesAppDelegate.h"

@implementation PersonalNotesViewController
@synthesize noteTextField;
@synthesize personalNote;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // add an edit button
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonSystemItemAction target:self action:@selector(editNote)];
        self.navigationItem.rightBarButtonItem = editButton;
        [editButton release];
    }
    return self;
}

- (void)dealloc
{
    [noteTextField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Note Management

- (void)editNote
{
    EditNoteViewController *editController = [[EditNoteViewController alloc] initWithNote:self.personalNote];
    editController.managedObjectContext = [(emnotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    editController.delegate = self;
    [self.navigationController pushViewController:editController animated:YES];
    [editController release];
}

- (void)userSavedChanges
{
    [self updateNoteText];
}

#pragma mark - View lifecycle
- (void)updateNoteText
{
    if (self.personalNote) {
        self.title = self.personalNote.title;
        self.noteTextField.text = self.personalNote.content;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateNoteText];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateNoteText];

}

- (void)viewDidUnload
{
    [self setNoteTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

 

@end

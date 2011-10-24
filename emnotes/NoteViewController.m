//
//  NoteViewController.m
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "NoteViewController.h"


@implementation NoteViewController

@synthesize webView, note;


- (void)editNote
{
    
    UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Editing requires web access and a WikEM.org login. Proceed?" delegate:self cancelButtonTitle: @"Cancel" otherButtonTitles:@"Ok", nil];
    
    [someError show];
    [someError release];   
}

- (void)openEditURL
{
    NSString *update_url_template = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"edit_note_url"];
    NSString *articleName = [self.note.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSLog(@"%@", [NSString stringWithFormat:update_url_template, articleName]);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:update_url_template, articleName]]];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self openEditURL];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editNote)];
        self.navigationItem.rightBarButtonItem = editButton;
        [editButton release];
        
    }
    return self;
}

- (void)dealloc
{
    [note release];
    [webView release];
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
    NSURL *resourceBaseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [webView loadHTMLString:[self.note formattedContent] baseURL:resourceBaseURL];
    self.title = self.note.name;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

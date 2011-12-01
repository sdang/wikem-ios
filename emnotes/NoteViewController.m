//
//  NoteViewController.m
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "NoteViewController.h"
#import "emnotesAppDelegate.h"

@implementation NoteViewController

@synthesize webView, note;
//ck add initializer for new context for this class
@synthesize managedObjectContext;
@synthesize scalesPageToFit;



/*
-(id)init{
	if (self=[super init]){
		
		[webView setDelegate:self]
		 }return self;
}*/

 

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
	//
	[managedObjectContext release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{	
	NSLog(@"didreceivememory warning in noteview");
	
	
	NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
   
    /* if anything is in the pool..drain it*/
    [pool drain];
	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	
}

#pragma mark - View lifecycle

//ck : as this wv already a uiwebviewdelegate, can call this BEFORE any wv loads
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	if(navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *url = request.URL;
		NSString *urlString = url.absoluteString;

//from appledocs use		NSString *documentFilename = [documentPath lastPathComponent];
		NSString *imagefilestring = [urlString lastPathComponent];

		//convert encoded characters in the link
		NSString *convertedString = [self convertURLString:imagefilestring];

		//get a note with this name
		//		
/*		+ (Note *)noteFromName:(NSString *)name
	inManagedObjectContext:(NSManagedObjectContext *)context;*/
		//NSManagedObjectContext* originalContext = [emnotesAppDelegate managedObjectContext];
	
		
		
		//name of note is from the <name> xml. links will have had characters url encoded
		//todo decode
		
		//get the note with the title of link... if it exists. 
		Note* newNote = [self noteFromName:convertedString ]; 
      //  NSLog(@"Retain Count of newNote :%i",[newNote retainCount]);

		
		
		/*call a new webview just like the originial call from categorytableview...
		 - (void)managedObjectSelected:(NSManagedObject *)managedObject
		 {
		 //NSLog 
		 NoteViewController *noteViewController = [[NoteViewController alloc] init];
		 noteViewController.note = (Note *)managedObject;
		 [self.navigationController pushViewController:noteViewController animated:YES];
		 [noteViewController release];
		 }
		 */
		if (newNote !=nil){
			NSLog(@"woohoo a match");

			NoteViewController *noteViewController2 = [[NoteViewController alloc] init];
			noteViewController2.note = newNote;
            noteViewController2.managedObjectContext = self.managedObjectContext;
		 //setter syntax
 
			[self.navigationController pushViewController:noteViewController2 animated:NO];
            
            noteViewController2 = nil;
			[noteViewController2 release];
        //    NSLog(@"Retain Count :%i",[noteViewController2 retainCount]);

		}else {
			NSLog(@"no action for the link click");
			return YES;
		}
      //  NSLog(@"Retain Count of newNote :%i",[newNote retainCount]);

        newNote = nil; //not necessarily needed

		return NO;
	}
	//ie, a link not clicked. do nothing special before webview loads
	return YES;
}



//after a webivew loaded calls this- (void)viewDidLoad but don't useAlways try to write only UI initialisation code in viewDidLoad. If you write code to alloc/init a variable in your viewDidLoad, then when the method is invoked a second time the variable will be alloc/init'd again causing a memory leak. 
//If you really do need to alloc/init your member variable in viewdidload , do it only if it is not already allocated.
-(void)viewDidAppear:(BOOL)animated{
//called everytime view reappears
    //for first time context wont be loaded...so load it here:
	if (managedObjectContext == nil) 
	{   NSLog(@"managedobjectcontext was nil so set in viewdidappear of NVC");
        managedObjectContext = [(emnotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
 	}
	
    
    //ck instead of baseurl as www.wikem... will try native images using local url
 	//get the path of current users documents folder for read/write
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString* imagePath = [paths objectAtIndex:0];
	NSURL *testURL = [NSURL fileURLWithPath:imagePath];
	
	webView.dataDetectorTypes = UIDataDetectorTypeLink;
	
    /*ck when traversing lots of links. get to a match for a link. then crash due to uncuaght exception. basically note is nil so calling formattedContent does nothing...
     
     THE UNPREDICTABLILITY OF THIS ERROR SEEMS TO BE CHARACTERISITIC OF REQUESTING DEALLOCATED MEMORY... WHICH GIVES THESE TYPES OF UNPREDICTABLE ERRORS...
     */
	if (self.note == nil){
        NSLog(@"ERROR !!!!! why is the note nil?!");
        //don't proceed to load anything. it will crash
    }
    else{
        
        //as baseURL changes, need to add css as a string...not as a 'link'
        [webView loadHTMLString:[self.note formattedContent] baseURL:testURL];
        
        //this alone does not zoom appropriately. added meta 'viewport' tag for html5 in header to make work
        self.webView.scalesPageToFit = YES;
        
        self.title = self.note.name;
    }

    
    
}
-(void)viewDidLoad:(BOOL)animated{
	NSLog(@"noteviewcontroller viewDidLOAD");

	    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    
    //ck : make these nil. just incase. pointers that are nil can respond with nil, safely, without blowing up. released objects on the other hand will give the crazy errors that i am getting  
    
    NSLog(@"viewDidUnload");
    self.webView = nil;
    self.note = nil;
    self.managedObjectContext = nil;
    

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    //eg. self.myOutlet = nil;
    
 
 } 


//unescape these url encoded characters
- (NSString*) convertURLString: (NSString *) myString {
    NSMutableString * temp = [myString mutableCopy];
	//change underscores back to space...for whatever reason the renderer doesnt use %20 for space but _
    [temp replaceOccurrencesOfString:@"_"
                          withString:@" "
                             options:0
                               range:NSMakeRange(0, [temp length])];
	//change parentheses back... there seem to be some inconsistencies almost all unescaped
	//just incase
    [temp replaceOccurrencesOfString:@"%28"
                          withString:@"("
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"%29"
                          withString:@")"
                             options:0
                               range:NSMakeRange(0, [temp length])];
	//change quotes... (don't think used.. but just incase) "&quot;"
    [temp replaceOccurrencesOfString:@"%22"
                          withString:@"\""
                             options:0
                               range:NSMakeRange(0, [temp length])];
	//change apostrophes... @"&apos;"
    [temp replaceOccurrencesOfString:@"%27"
                          withString:@"'"
                             options:0
                               range:NSMakeRange(0, [temp length])];
	
    return [temp autorelease];
}

- (Note *)noteFromName:(NSString *)name
//inManagedObjectContext:(NSManagedObjectContext *)context
{
    Note *note2 = nil;
    
    // request category of title
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    request.fetchBatchSize = 1;
    
    NSError *error = nil;
    note2 = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !note2) {
        // no note..
        //TODO throw a toast or something?
        
		//  note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
		[request release];

        return nil;
    }
    else if (error)
    { //TODO what to do here?
     //why would it ever throw an error here
        NSLog(@"there is an error trying to find a note by title?!");
        //throw an alert?
        [request release];
        return nil;
    }
    else{ //default... there is a note
       // NSLog(@"Retain Count of note2 :%i",[note2 retainCount]);

        [request release];
        return note2;
    }
}

/*the key property which leads to this leak is the WebKitCacheModelPreferenceKey application setting.
 And when you open a link in a UIWebView, this property is automatically set to the value "1". 
 So, the solution is to set it back to 0 everytime you open a link. 
 You may easily do this by adding a UIWebViewDelegate to your UIWebView :
*/ 
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
}

@end

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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

//ck : as this wv already a uiwebviewdelegate, can call this BEFORE any wv loads
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	if(navigationType == UIWebViewNavigationTypeLinkClicked) {
		
		//todo...if internal link with a #...ignore... so menu links don't need 2 clicks
		
		//a link was clicked, intercept it...unfortunately, no nsurlrequest.method for getting the title="bla" attribute
		//so will need to process string before trying to search->return a note with given name
		
 		//get the path of current users documents folder for read/write
	//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	////	NSString* documentsDir = [paths objectAtIndex:0];
		
		NSURL *url = request.URL;
		NSString *urlString = url.absoluteString;
		//NSLog(@"docdir is:");
		NSLog(urlString);
		// remove baseurl, which was needed to load images
	//	NSString *myString = [[[NSBundle mainBundle] infoDictionary] objectForKey:documentsDir];
	/*	NSString *myString2 = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"link_base_url"];

		urlString = [urlString stringByReplacingOccurrencesOfString:documentsDir
											 withString:@""];
		NSLog(urlString);
		
		urlString = [urlString stringByReplacingOccurrencesOfString:myString2
														 withString:@""];
		NSLog(urlString);
*/
//from appledocs use		NSString *documentFilename = [documentPath lastPathComponent];
		NSString *imagefilestring = [urlString lastPathComponent];
		NSLog(imagefilestring);

		//convert encoded characters in the link
		NSString *convertedString = [self convertURLString:imagefilestring];
		NSLog(convertedString);

		//get a note with this name
		//		
/*		+ (Note *)noteFromName:(NSString *)name
	inManagedObjectContext:(NSManagedObjectContext *)context;*/
		//NSManagedObjectContext* originalContext = [emnotesAppDelegate managedObjectContext];
	
		
		
		//name of note is from the <name> xml. links will have had characters url encoded
		//todo decode
		
		//get the note with the title of link... if it exists. 
		Note* newNote = [self noteFromName:convertedString inManagedObjectContext:managedObjectContext ]; 
		
		
		
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
			[self.navigationController pushViewController:noteViewController2 animated:YES];
			[noteViewController2 release];
		}else {
			NSLog(@"no action for the link click");
			return YES;
		}

		return NO;
	}
	//ie, a link not clicked. do nothing special before webview loads
	return YES;
}

//after a webivew loaded calls this
- (void)viewDidLoad 
{
	
//per recs try adding the context here...assuming it wasnt loaded right
	if (managedObjectContext == nil) 
	{ 
        managedObjectContext = [(emnotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"After managedObjectContext: %@",  managedObjectContext);
	}
//what is the url ?? ck
	NSLog(@"wth is the url anyways??????");
	
	//ck instead of baseurl as www.wikem... will try native images using local url
 	//get the path of current users documents folder for read/write
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString* imagePath = [paths objectAtIndex:0];
	
	NSLog(imagePath);
	/*
	 TODO : remove. test code
	 */
	NSFileManager* fileManager = [NSFileManager defaultManager];
		//NSString* wikipath = [documentsDir stringByAppendingString:@"/wiki/"];

	for (NSString* fileName in [fileManager contentsOfDirectoryAtPath:imagePath error:nil]) {
		NSLog(fileName);
	}
	
	
	
//baseurl now loaded, assuming inernet connection can get images 
//	NSString *myString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"base_url"];
	NSURL *testURL = [NSURL fileURLWithPath:imagePath];
	
	webView.dataDetectorTypes = UIDataDetectorTypeLink;
	
	
	
	NSURL *url = [NSURL URLWithString: [imagePath lastPathComponent] relativeToURL: [NSURL fileURLWithPath: [imagePath stringByDeletingLastPathComponent] isDirectory: YES]];

	
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

	NSLog(imagePath);
	
	
	
	//as baseURL changes, need to add css as a string...not as a 'link'
    [webView loadHTMLString:[self.note formattedContent] baseURL:testURL];
		//[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//",imagePath]]];
	 
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
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
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Note *note = nil;
    
    // request category of title
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    request.fetchBatchSize = 1;
    
    NSError *error = nil;
    note = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !note) {
        // no note..
		//  note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
        return nil;
    }
    
    [request release];
    return note;
}

@end

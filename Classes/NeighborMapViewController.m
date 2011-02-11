    //
//  NeighborMapViewController.m
//  NeighborMe
//
//  Created by Aditya Herlambang on 11/22/10.
//  Copyright 2010 University of Arizona. All rights reserved.
//

#import "NeighborMapViewController.h"

@implementation NeighborMapViewController

@synthesize mapView;
@synthesize locationManager;
@synthesize scrollView;
@synthesize imgArray;
@synthesize annotationArray;
@synthesize childController;
//@synthesize reverseGeocoder;

- (UIImage *) imageWithImage:(UIImage *) image scaledToSize:(CGSize) newSize{
	UIGraphicsBeginImageContext(newSize);
	[image drawInRect: CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (void) generateAnnotation
{	
	for (NSDictionary * element in results){
		NSDictionary * user = [element objectForKey:@"user"];
		CLLocationCoordinate2D aCoordinate;
		aCoordinate.latitude = [[user objectForKey:@"LATITUDE"] doubleValue];
		aCoordinate.longitude = [[user objectForKey:@"LONGITUDE"] doubleValue];
		NeighborMapAnnotation *neighbor = [[NeighborMapAnnotation alloc] initWithCoordinate:aCoordinate];
		neighbor.title = [user objectForKey:@"NAME"];
		neighbor.uid = [user objectForKey:@"UID"];
		NSURL *url = [NSURL URLWithString:[user objectForKey:@"PROF_PIC"]];
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];
		neighbor.image = [self imageWithImage:img scaledToSize:CGSizeMake(32, 32)];
		
		/* 
		self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:aCoordinate] autorelease];
		reverseGeocoder.delegate = self;
		[reverseGeocoder start];
		*/
		
		[annotationArray addObject:neighbor];
	}
}

- (MKCoordinateRegion)regionFromLocations {
	NSLog(@"Size of the array is %d", [annotationArray count]);

    CLLocationCoordinate2D upper = [[annotationArray objectAtIndex:0] coordinate];
    CLLocationCoordinate2D lower = [[annotationArray objectAtIndex:0] coordinate];
	
    // FIND LIMITS
    for(NeighborMapAnnotation *eachLocation in annotationArray) {
        if([eachLocation coordinate].latitude > upper.latitude) upper.latitude = [eachLocation coordinate].latitude;
        if([eachLocation coordinate].latitude < lower.latitude) lower.latitude = [eachLocation coordinate].latitude;
        if([eachLocation coordinate].longitude > upper.longitude) upper.longitude = [eachLocation coordinate].longitude;
        if([eachLocation coordinate].longitude < lower.longitude) lower.longitude = [eachLocation coordinate].longitude;
    }
	
    // FIND REGION
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta = upper.latitude - lower.latitude;
    locationSpan.longitudeDelta = upper.longitude - lower.longitude;
    CLLocationCoordinate2D locationCenter;
    locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
    locationCenter.longitude = (upper.longitude + lower.longitude) / 2;
	
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    return region;
}

-(IBAction) toggleAction:(id) sender {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];  
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
	
	[self.navigationController popToRootViewControllerAnimated:YES];
	
	[UIView commitAnimations];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem * test = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleAction:)];
	self.navigationItem.title = @"Neighbor's Map";
	self.navigationItem.rightBarButtonItem = test;	
	self.navigationItem.hidesBackButton = YES;
	
	self.annotationArray = [NSMutableArray array];

	mapView.delegate = self;
		
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.delegate=self;
	self.locationManager.distanceFilter = kCLLocationAccuracyBest;
	[self.locationManager startUpdatingLocation];
	
	imgArray = [[NSMutableArray alloc] init];
	
	responseData = [[NSMutableData data] retain];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.adityaherlambang.me/webservice.php?user=all&format=json"]];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	
	results = [[responseString JSONValue] retain];
	[self generateAnnotation];
	[mapView addAnnotations:annotationArray];
	[mapView setRegion:[self regionFromLocations] animated:YES];
}


-(void) toggleView:(id) selector {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mapView release];
	//[annotationArray release];
    [super dealloc];
}

/*
 - (void) mapView:(MKMapView *) mapView
 didAddAnnotationViews:(NSArray *) views
 {
 for (MKPinAnnotationView * mkaview in views)
 {
 
 mkaview.pinColor = MKPinAnnotationColorPurple;
 UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
 mkaview.rightCalloutAccessoryView = button;
 }
 
 }
 */



- (MKAnnotationView *) mapView:(MKMapView *) theMapView viewForAnnotation:(id <MKAnnotation>) annotation
{
	if ([annotation isKindOfClass:[NeighborMapAnnotation class]])
    {
        static NSString *AnnotationIdentifier = @"AnnotationIdentifier";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
        if (!pinView)
        {
            MKPinAnnotationView *annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
			
			if (!pinView)
			{
				pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
				annotationView.canShowCallout = YES;
				annotationView.animatesDrop = YES;
			}
			else {
				pinView.annotation = annotation;
			}

            UIImageView *leftCalloutView = [[UIImageView alloc] initWithImage:((NeighborMapAnnotation *)annotation).image];
			leftCalloutView.contentMode = UIViewContentModeScaleAspectFit;
            annotationView.leftCalloutAccessoryView = leftCalloutView;
			[leftCalloutView release];

			
			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			annotationView.rightCalloutAccessoryView = rightButton;
			
            			
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
	
    return nil;

}	

- (void) mapView: (MKMapView *) mapView annotationView:(MKAnnotationView *) view calloutAccessoryControlTapped:(UIControl *) control
{
	childController = [[NeighborProfileViewController alloc] initWithNibName:@"NeighborProfileViewController" bundle:nil];
	childController.title = view.annotation.title;
    childController.uid = [((NeighborMapAnnotation *)(view.annotation)) uid];
	if (self.navigationController == nil)
		NSLog(@"Nav controller is nil");
	[self.navigationController pushViewController:childController animated:YES];
}

/*
#pragma mark ReverseGeocoderDelegate Methods
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot obtain address."
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	//NSString *street = [placemark.addressDictionary valueForKey:(NSString *)kABPersonAddressStreetKey];
}
*/

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // we have received our current location, so enable the "Get Current Address" button
    //[getAddressButton setEnabled:YES];
}


#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation{
	
	MKCoordinateSpan span;
	span.latitudeDelta=.2;
	span.longitudeDelta=.2;
	
}


@end

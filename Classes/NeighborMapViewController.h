//
//  NeighborMapViewController.h
//  NeighborMe
//
//  Created by Aditya Herlambang on 11/22/10.
//  Copyright 2010 University of Arizona. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "NeighborMapAnnotation.h"
#include "NeighborProfileViewController.h"

@interface NeighborMapViewController:UIViewController <CLLocationManagerDelegate, MKMapViewDelegate/*, MKReverseGeocoderDelegate*/>{
	MKMapView *mapView;
	//MKReverseGeocoder *reverseGeocoder;
	CLLocationManager *locationManager;
	UIScrollView * scrollView;
	NSMutableArray *annotationArray;
	NSMutableArray *imgArray;
	NSMutableData *responseData;
	NSArray *results;
	NeighborProfileViewController * childController;
}

- (void) generateAnnotation;
- (UIImage *) imageWithImage:(UIImage *) image scaledToSize:(CGSize) newSize;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
//@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain) IBOutlet UIScrollView * scrollView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *imgArray;
@property (nonatomic, retain) NSMutableArray *annotationArray;
@property (nonatomic, retain) NeighborProfileViewController * childController;

- (IBAction)toggleAction:(id)sender;

@end

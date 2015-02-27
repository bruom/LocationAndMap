//
//  MapViewController.h
//  LocationAndMap
//
//  Created by Bruno Omella Mainieri on 2/26/15.
//  Copyright (c) 2015 Bruno Omella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapa;
@property (retain) CLLocationManager *locationManager;
@property NSArray *location;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mapTap;
@property CLLocationCoordinate2D coordToque;

- (IBAction)atualizar:(id)sender;

- (IBAction)marcar:(id)sender;

- (void)tocarLocal:(UITapGestureRecognizer *)gestureRecognizer;

@end

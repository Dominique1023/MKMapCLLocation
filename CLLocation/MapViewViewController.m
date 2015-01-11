//
//  MapViewViewController.m
//  CLLocation
//
//  Created by Dominique on 1/11/15.
//  Copyright (c) 2015 dominique vasquez. All rights reserved.
//

#import "MapViewViewController.h"

@interface MapViewViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addCurrentLocation];
    [self addPizzaPins];
    [self zoomIn]; 
}

-(void)addCurrentLocation{
    CLLocationCoordinate2D currentCoordinate = self.currentPlacemark.location.coordinate;
    MKPointAnnotation *currentAnnotation = [MKPointAnnotation new];
    currentAnnotation.coordinate = currentCoordinate;
    currentAnnotation.title = @"You";

    [self.mapView addAnnotation:currentAnnotation];
}

-(void)addPizzaPins{

        //lat and long coordinates to make a pin on a map
        CLLocationCoordinate2D coordinate = self.pizzasMapItem.placemark.location.coordinate;

        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = coordinate;
        annotation.title = [NSString stringWithFormat:@"%@", self.pizzasMapItem.name];

        [self.mapView addAnnotation:annotation];
}

-(void)zoomIn{
    MKMapRect zoomRect = MKMapRectNull;

    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        MKMapPoint pointAnnotation = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(pointAnnotation.x, pointAnnotation.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }

    [self.mapView setVisibleMapRect:zoomRect animated:YES];

}

@end

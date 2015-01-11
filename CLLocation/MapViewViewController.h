//
//  MapViewViewController.h
//  CLLocation
//
//  Created by Dominique on 1/11/15.
//  Copyright (c) 2015 dominique vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewViewController : UIViewController
@property MKMapItem *pizzasMapItem;
@property CLPlacemark *currentPlacemark;
@end

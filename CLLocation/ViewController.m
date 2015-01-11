//
//  ViewController.m
//  CLLocation
//
//  Created by Dominique on 1/10/15.
//  Copyright (c) 2015 dominique vasquez. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MapViewViewController.h"

@interface ViewController ()<CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *pizzas;
@property CLLocationManager *location;
@property NSTimer *timer;
@property CLPlacemark *currentPlacemarker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pizzas = [NSArray new];

    self.location = [CLLocationManager new];
    self.location.delegate = self;

}

#pragma mark CLLocationManager Methods and Delegates
- (IBAction)onFindThePizzaButtonPressed:(id)sender {

    //if the user taps the button again and wants to do a search at a new location
    //brings the textView back and does another location search
    if (self.statusView.hidden == YES) {
        self.statusView.hidden = NO;
        [self gettingLocation];
    }else{
        [self gettingLocation];
    }

}

-(void)gettingLocation{
    //NSLocationAlwaysUsageDescription info.plist
    //request's the users authorization to use location services
    SEL requestSelector = NSSelectorFromString(@"requestAlwaysAuthorization");
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
        [self.location respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.location performSelector:requestSelector withObject:nil afterDelay:00];
        [self.location requestWhenInUseAuthorization];

    } else {
        [self.location startUpdatingLocation];
    }

    [self.location startUpdatingLocation];
    self.statusTextView.text = @"Locating You...";
}

-(void)reverseGeocoding:(CLLocation *)location{
    CLGeocoder *geo = [CLGeocoder new];
    [geo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Reverse geocoding error: %@", error.description);
        }


        self.currentPlacemarker = [placemarks firstObject];

        NSString *string = [NSString stringWithFormat:@"%@ %@  \n%@ %@", self.currentPlacemarker.subThoroughfare, self.currentPlacemarker.thoroughfare, self.currentPlacemarker.locality, self.currentPlacemarker.postalCode];
        self.statusTextView.text = [NSString stringWithFormat:@"Found you: \n%@", string];
        [self findFoodNearMe:self.currentPlacemarker.location];

        //hides the text view and uiview with status
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(finished) userInfo:nil repeats:NO];
    }];

}

-(void)finished{
    self.statusView.hidden = YES;
    [self.tableView reloadData];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    for (CLLocation *location in locations) {
        self.statusTextView.text =  @"Location Found... Begin Reverse Geocoding";
        [self reverseGeocoding:location];
        [self.location stopUpdatingLocation];
        break;
    }
}

#pragma mark Search
-(void)findFoodNearMe:(CLLocation *)location{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"Pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));

    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];

    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error) {
            NSLog(@"MKLocalSearch Error: %@", error.description);
        }

        self.pizzas = response.mapItems;
        MKMapItem *mapItem = [self.pizzas firstObject];

        self.statusTextView.text = [NSString stringWithFormat:@"You should go to \n%@", mapItem.name];
    }];

}

#pragma mark UITableViewDelegate and Datasource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pizzas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];

    MKMapItem *mapItem = [self.pizzas objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", mapItem.name];

    return cell;
}

#pragma mark PrepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MapViewViewController *mvvc = [segue destinationViewController];

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    mvvc.pizzasMapItem = [self.pizzas objectAtIndex:indexPath.row];

    mvvc.currentPlacemark = self.currentPlacemarker;
}

@end

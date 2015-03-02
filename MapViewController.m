//
//  MapViewController.m
//  LocationAndMap
//
//  Created by Bruno Omella Mainieri on 2/26/15.
//  Copyright (c) 2015 Bruno Omella. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize mapa;
@synthesize locationManager;
@synthesize mapTap;
@synthesize coordToque;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //IMPORTANTE
    [mapa setDelegate:self];
    
    _pontosRota = [[NSMutableArray alloc]init];
    
    _inicioData = [NSDate date];
    
    locationManager = [[CLLocationManager alloc]init];
    
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    [locationManager setDelegate:self];
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    mapa.mapType = MKMapTypeSatellite;
    
    mapTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tocarLocal:)];
    [self.mapa addGestureRecognizer:mapTap];
    
    mapa.showsUserLocation = YES;
    [locationManager startUpdatingLocation];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Geo e Mapa

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    _location = locations;
    
    CLLocationCoordinate2D location = [[locations lastObject]coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 500, 500);
    
    [mapa setRegion:region animated:YES];
    [_pontosRota addObject:[_location lastObject]];
    [self drawRoute:_pontosRota];
    
}

-(IBAction)atualizar:(id)sender{
//    CLLocationCoordinate2D location = [[_location lastObject]coordinate];
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 500, 500);
//    [mapa setRegion:region animated:YES];
    
    [self drawRoute:_pontosRota];
}

- (IBAction)marcar:(id)sender {
    //Instanciar o MKPointAnnotation
    MKPointAnnotation *pm = [[MKPointAnnotation alloc]init];
    
    //Determinar a localização do MKPointAnnotation
    pm.coordinate = [[_location lastObject]coordinate];
    
    //Adicionar pm ao mapa
    [mapa addAnnotation:pm];
}


-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Failure updating location.");
}

- (void)tocarLocal:(UITapGestureRecognizer *)gestureRecognizer{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapa];
    CLLocationCoordinate2D toque =
    [self.mapa convertPoint:touchPoint toCoordinateFromView:self.mapa];
    
    coordToque = toque;
    
    NSLog(@"Location found from Map: %f %f",toque.latitude,toque.longitude);
    
    MKPointAnnotation *pm = [[MKPointAnnotation alloc]init];
    
    pm.coordinate = coordToque;
    
    [mapa addAnnotation:pm];
    
}



#pragma mark - Features do App RunRoute

//encerra sessão e calcula meta-dados desta
- (IBAction)fimSessao:(id)sender {
    [locationManager stopUpdatingLocation];
    NSArray *sessao = _pontosRota;
    _fimData = [NSDate date];
    NSTimeInterval aux = [_fimData timeIntervalSinceDate:_inicioData];
    NSLog(@"%i minutos e %i segundos.", (int)aux/60, (int)aux%60) ;
    NSLog(@"Distancia: %f metros.", [self calculaDistancia:sessao]);
}

//calcula distancia total da rota
-(float)calculaDistancia:(NSArray*)pontos{
    if(nil==pontos || pontos.count == 0){
        return 0.0;
    }
    float distancia = 0.0;
    for(int i=1;i<pontos.count-1;i++){
        distancia += (float)[[pontos objectAtIndex:i]  distanceFromLocation:[pontos objectAtIndex:i+1]];
    }
    return distancia;
}


#pragma mark - PolyLine


-(void)drawRoute:(NSMutableArray*)pontos{
    
    
    //para evitar de criar infinitas linhas e sobrecarregar a memoria
    if(nil!=_antigaLinha){
        [mapa removeOverlay:_antigaLinha];
    }
    CLLocationCoordinate2D coordenadas[pontos.count];
    for(int i=0; i< pontos.count; i++){
        CLLocation *local = [pontos objectAtIndex:i];
        CLLocationCoordinate2D coordenada = local.coordinate;
        
        coordenadas[i] = coordenada;
    }
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordenadas count:pontos.count];
    _antigaLinha = polyline;
    [mapa addOverlay:polyline];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        
        
        //É ESSE QUE DEFINE A COR
        renderer.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        renderer.lineWidth   = 5;
        
        return renderer;
    }
    
    return nil;
}




@end

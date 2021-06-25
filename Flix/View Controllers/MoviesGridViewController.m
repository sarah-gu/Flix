//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Sarah Wen Gu on 6/24/21.
//

#import "MoviesGridViewController.h"
#import "SVProgressHUD.h"
#import "MovieCollectionCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesGridViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *filteredData;
@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchMovies];
    });
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing *(postersPerLine - 1) )/ postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    

    // Do any additional setup after loading the view.
}


- (void)fetchMovies{
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"]; //swap in desired endpoint (instead of now_playing)
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               dispatch_async(dispatch_get_main_queue(),^{
                   [SVProgressHUD dismiss];
               });
               
               
               self.movies = dataDictionary[@"results"];
               NSLog(@"%@", self.movies);
               self.filteredData = self.movies;
               [self.collectionView reloadData];
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
           }
       }];
    [task resume];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredData[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
    //NSLog(@"Tapping on a movie!");
    
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    NSDictionary *movie = self.filteredData[indexPath.item];
    NSString *baseURLString_high = @"https://image.tmdb.org/t/p/original";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString_high = [baseURLString_high stringByAppendingString:posterURLString];
    
    NSURL *posterURL_high = [NSURL URLWithString:fullPosterURLString_high];
    NSURLRequest *request_high = [NSURLRequest requestWithURL:posterURL_high];
    
    NSString *baseURLString_low = @"https://image.tmdb.org/t/p/w45";
    NSString *fullPosterURLString_low = [baseURLString_low stringByAppendingString:posterURLString];
    NSURL *posterURL_low = [NSURL URLWithString:fullPosterURLString_low];
    NSURLRequest *request_low = [NSURLRequest requestWithURL:posterURL_low];
    
    cell.posterView.image = nil;
    
    [cell.posterView setImageWithURLRequest:request_low placeholderImage:nil success:^(NSURLRequest *  imageRequest, NSHTTPURLResponse * imageResponse, UIImage * smallImage) {
        if(imageResponse != nil){
            cell.posterView.alpha = 0.0;
            cell.posterView.image = smallImage;
            
            [UIView animateWithDuration:0.3 animations:^{
                cell.posterView.alpha = 1.0;
            } completion:^(BOOL finished){
                [cell.posterView setImageWithURLRequest:request_high
                                       placeholderImage:smallImage
                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *largeImage){
                    cell.posterView.image = largeImage;
                }
                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    NSLog(@"Error in image request");
                }];
            }];
        
        }
        else{
            [cell.posterView setImageWithURLRequest:request_high
                                   placeholderImage:smallImage
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *largeImage){
                cell.posterView.image = largeImage;
            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"Error in image request");
            }];
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"Error in image request");
    }];
    

    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredData.count;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(nonnull NSString *)searchText{
    if(searchText.length != 0){
       // NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings){
         //   return [evaluatedObject containsString:searchText];
        //}];




       // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@)", searchText];
        NSDictionary *genres = @{@"Action": @28, @"Adventure":@12, @"Animation": @16,@"Comedy":@35, @"Crime":@80, @"Documentary":@99, @"Drama": @18,@"Family": @10751, @"Fantasy":@14, @"History":@36,@"Horror": @27,@"Music": @10402,@"Mystery": @9648, @"Romance": @10749, @"Science Fiction": @878, @"TV Movie":@10770, @"Thriller": @53,   @"War": @10752,@"Western" : @37  };

        NSLog(@"%@", searchText);
        if (genres[searchText]){
            NSObject *toSearch = genres[searchText];
            NSLog(@"%@", toSearch);
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings){
                 return [evaluatedObject[@"genre_ids"] containsObject:toSearch];
            }];
            self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];
        }
        else{
            self.filteredData = self.movies; 
        }
        //NSArray *movieGenres = self.movies[@"genre_ids" ];
     //   for (id my_genre in [@"genre_ids"]){

       // }

    //    NSPredicate *predicate = [NSPredicate ]
        
    }
    else{
        self.filteredData = self.movies;
    }
    [self.collectionView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

@end

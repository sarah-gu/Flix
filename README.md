# Project 2 - *Flix*

**Flix** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **24** hours spent in total

## User Stories

The following **required** functionality is complete:

- [X] User sees an app icon on the home screen and a styled launch screen.
- [X] User can view a list of movies currently playing in theaters from The Movie Database.
- [X] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [X] User sees a loading state while waiting for the movies API.
- [X] User can pull to refresh the movie list.
- [X] User sees an error message when there's a networking error.
- [X] User can tap a tab bar button to view a grid layout of Movie Posters using a CollectionView.

The following **optional** features are implemented:

- [X] User can tap a poster in the collection view to see a detail screen of that movie
- [X] User can search for a movie.
- [X] All images fade in as they are loading.
- [ ] User can view the large movie poster by tapping on a cell.
- [X] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [ ] Customize the selection effect of the cell.
- [X] Customize the navigation bar.
- [ ] Customize the UI.
- [ ] User can view the app on various device sizes and orientations.
- [X] Run your app on a real device.

The following **additional** features are implemented:

- [X] Adding genre information under each movie card
- [X] Allowing for a search by genre feature in the movie poster view 
- [X] Adding a rating feature in the DetailViewCard

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Adding a dropdown menu type navigation bar instead of scrolling
2. Having a related movies feature

## Video Walkthrough

Here's a walkthrough of implemented user stories:

![Flix Demo](https://github.com/sarah-gu/Flix/blob/main/Flix.gif)

GIF created with [EZGif](https://ezgif.com).

Image of all movie listings: 
![all movies](https://github.com/sarah-gu/Flix/blob/main/allmovies.PNG)

Image of title search: 
![title search](https://github.com/sarah-gu/Flix/blob/main/titlesearch.PNG)

Image of genre search: 
![genre search](https://github.com/sarah-gu/Flix/blob/main/genresearch.PNG)

Image of Detail View: 
![detail view ](https://github.com/sarah-gu/Flix/blob/main/detailview.PNG)

## Notes

I encountered a challenge with the genre searching portion of the app - I had to learn about the NSPredicate classes and how to implement the Search Bar feature in order to get those queries to come up. I also spent some time trying to add a custom Pod class to have a drop down menu, but was unfortunately unable to get the custom class to work with XCode (potentially an outdated package). 
## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library
- SVProgressHUD - loading icon for network requets
## License

    Copyright [2021] [Sarah Gu]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

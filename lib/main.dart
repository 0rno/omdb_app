import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const OmdbApp());
}

const String apiKey = '93e17977';

Future<Movie> fetchMovie(String search, [String? year]) async {
  StringBuffer sb = StringBuffer()
    ..write('http://www.omdbapi.com/?apikey=$apiKey&plot=full&')
    // If search is a valid IMDB Title ID (i.e. "tt" followed by 7 or more digits),
    // search by ID ('i'), otherwise search by title ('t').
    ..write((RegExp(r'tt\d{7,}').hasMatch(search)) ? 'i' : 't')
    ..write('=$search');
  if (year != null) { sb.write('&y=$year');}
  String url = sb.toString();
  
  final response = await http.get(
    Uri.parse(url),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Movie.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load movie');
  }
}

class Movie {
  final String title;
  final String year;
  final String rated;
  final String released;
  final String runtime;
  final String genre;
  final String director;
  final String writer;
  final String actors;
  final String plot;
  final String language;
  final String country;
  final String awards;
  final String poster;
  final List<dynamic> ratings;
  final String metascore;
  final String imdbRating;
  final String imdbVotes;
  final String imdbID;
  final String type;
  final String dvd;
  final String boxOffice;
  final String production;
  final String website;

  const Movie(
      {
      this.title = 'N/A',
      this.year = 'N/A',
      this.rated = 'N/A',
      this.released = 'N/A',
      this.runtime = 'N/A',
      this.genre = 'N/A',
      this.director = 'N/A',
      this.writer = 'N/A',
      this.actors = 'N/A',
      this.plot = 'N/A',
      this.language = 'N/A',
      this.country = 'N/A',
      this.awards = 'N/A',
      this.poster = 'N/A',
      this.ratings = const [],
      this.metascore = 'N/A',
      this.imdbRating = 'N/A',
      this.imdbVotes = 'N/A',
      this.imdbID = 'N/A',
      this.type = 'N/A',
      this.dvd = 'N/A',
      this.boxOffice = 'N/A',
      this.production = 'N/A',
      this.website = 'N/A',
  });

  factory Movie.fromJson(Map<dynamic, dynamic> json) {
    return Movie(
      title: json['Title'] as String,
      year: json['Year'] as String,
      rated: json['Rated'] as String,
      released: json['Released'] as String,
      runtime: json['Runtime'] as String,
      genre: json['Genre'] as String,
      director: json['Director'] as String,
      writer: json['Writer'] as String,
      actors: json['Actors'] as String,
      ratings: json['Ratings'] as List,
      plot: json['Plot'] as String,
      language: json['Language'] as String,
      country: json['Country'] as String,
      awards: json['Awards'] as String,
      poster: json['Poster'] as String,
      metascore: json['Metascore'] as String,
      imdbRating: json['imdbRating'] as String,
      imdbVotes: json['imdbVotes'] as String,
      imdbID: json['imdbID'] as String,
      type: json['Type'] as String,
      dvd: json['DVD'] as String,
      boxOffice: json['BoxOffice'] as String,
      production: json['Production'] as String,
      website: json['Website'] as String,
    );
  }
}

class OmdbApp extends StatefulWidget {
  const OmdbApp({super.key});

  @override
  State<OmdbApp> createState() {
    return _OmdbAppState();
  }

}

class _OmdbAppState extends State<OmdbApp> {
  final TextEditingController _searchController = TextEditingController();
  int currentYear = DateTime.now().year;
  String? selectedYear;
  Future<Movie>? _futureMovie;
  List<Movie> watchlist = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Data Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: const TabBar(
            tabs: [
              Tab(
                text: "Search",
                icon: Icon(Icons.search)
              ),
              Tab(
                text: "Watchlist",
                icon: Icon(Icons.add_to_queue)
              ),
            ],
          ),
          // ),
          body: TabBarView(
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (String value) {
                              setState(() {
                                  _futureMovie = fetchMovie(value);
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter title or IMDB ID',
                            ),
                          ),
                        ),
                        
                        DropdownMenu(
                          dropdownMenuEntries: List<DropdownMenuEntry<int>>.generate(
                            currentYear - 1899, // An entry for every year since 1900.
                            (int index) => DropdownMenuEntry(
                              value: currentYear - index,
                              label: (currentYear - index).toString(),
                            ), growable: false
                          ),
                          enableFilter: true,
                          hintText: 'Year',
                          menuHeight: 200,
                          onSelected: (int? year) {
                            if (year != null) {
                              setState(() {
                                  selectedYear = year.toString();
                              });
                            }
                          },
                        ),
                        
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                                _futureMovie = fetchMovie(_searchController.text, selectedYear);
                            });
                          },
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                    FutureBuilder<Movie>(
                      future: _futureMovie,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: <Widget>[
                                    
                                    if (snapshot.data!.poster != 'N/A')
                                    Image.network(
                                      snapshot.data!.poster,
                                      width: 300,
                                    ),
                                    
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start, // Stick text on the left
                                        children: <Widget>[
                                          
                                          //print movie data here
                                          
                                          Text('${snapshot.data!.title} (${snapshot.data!.year})'),
                                          Text(
                                            snapshot.data!.plot == 'N/A'
                                            ? "Plot not found."
                                            : snapshot.data!.plot,
                                          ),
                                          OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                  watchlist.contains(snapshot.data!)
                                                  ? watchlist.remove(snapshot.data!)
                                                  : watchlist.add(snapshot.data!);
                                                }
                                              );
                                            },
                                            child: Icon(!watchlist.contains(snapshot.data)
                                              ? Icons.add_to_queue
                                              : Icons.remove_from_queue),
                                            
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Text('No results!');
                          }
                        }
                        return (_futureMovie != null) ?  const CircularProgressIndicator() : const Text('');
                      },
                    ),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: watchlist.length,
                itemBuilder: (BuildContext context, int index) {
                  // Could make this prettier
                  return Text('${watchlist[index].title} (${watchlist[index].year})');
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/match/tournament.dart';
import '../service/tournament_service.dart';

class TournamentMap extends StatefulWidget {
  @override
  _TournamentMapState createState() => _TournamentMapState();
}

class _TournamentMapState extends State<TournamentMap> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  late TournamentService tournamentService;
  List<Tournament> _tournaments = [];

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    addCustomMarker();
    _searchController.addListener(_filterTournaments);
    fetchTournaments();
  }

  void addCustomMarker() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(120, 120)),
      'assets/images/custom-marker.webp',
    );

    setState(() {
      markerIcon = markerIcon;
    });
  }

  Future<void> fetchTournaments() async {
    try {
      List<Tournament> tournaments = await tournamentService.fetchTournaments();
      setState(() {
        _tournaments = tournaments;
        _loadMarkers(tournaments);
      });
    } catch (error) {
      print("Error fetching tournaments: $error");
    }
  }

  void _zoomToCity(String city) {
    var tournament = _tournaments.firstWhere(
          (t) => t.location?.toLowerCase() == city.toLowerCase() || t.name.toLowerCase() == city.toLowerCase(),
      orElse: () => _tournaments.first,
    );
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(tournament.latitude ?? 0.0, tournament.longitude ?? 0.0),
          zoom: 10.0,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    print("Map created");
  }

  void _loadMarkers(List<Tournament> tournaments) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _markers.clear();
        for (var tournament in tournaments) {
          _markers.add(
            Marker(
              markerId: MarkerId(tournament.id.toString()),
              position: LatLng(tournament.latitude ?? 0.0, tournament.longitude ?? 0.0),
              icon: markerIcon,
              infoWindow: InfoWindow(
                title: tournament.name,
                snippet: 'Tournament ID: ${tournament.id}\nClick here for more info',
                onTap: () {
                  _showCustomInfoWindow(context, tournament);
                },
              ),
              onTap: () {
                _showCustomInfoWindow(context, tournament);
              },
            ),
          );
        }
      });
    });
  }

  void _showCustomInfoWindow(BuildContext context, Tournament tournament) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tournament.name,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                CachedNetworkImage(
                  width: 200,
                  height: 200,
                  imageUrl: tournament.media?.fileName != null
                      ? '${dotenv.env['MEDIA_URL']}${tournament.media?.fileName}'
                      : '${dotenv.env['MEDIA_URL']}yugiho.webp',
                ),
                SizedBox(height: 10),
                Text(
                  'Tournament ID: ${tournament.id}\nLocation: ${tournament.location}',
                  style: TextStyle(fontSize: 16.0),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/tournaments');
                  },
                  child: Text("M'inscrire"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _filterTournaments() {
    String search = _searchController.text.toLowerCase();
    _zoomToCity(search);
    setState(() {
      _markers.clear();
      _tournaments
          .where((tournament) => tournament.location!.toLowerCase().contains(search) || tournament.name.toLowerCase().contains(search))
          .forEach((tournament) {
        _markers.add(
          Marker(
            icon: markerIcon,
            markerId: MarkerId(tournament.id.toString()),
            position: LatLng(tournament.latitude ?? 0.0, tournament.longitude ?? 0.0),
            infoWindow: InfoWindow(
              title: tournament.name,
              snippet: 'Click here for more info',
              onTap: () {
                _showCustomInfoWindow(context, tournament);
              },
            ),
            onTap: () {
              _showCustomInfoWindow(context, tournament);
            },
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search a name or a city',
            hintStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0.0, 0.0),
          zoom: 2.0,
        ),
        markers: _markers,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}

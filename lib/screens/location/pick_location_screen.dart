import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng; // GUNAKAN ALIAS

class PickLocationScreen extends StatefulWidget {
  @override
  _PickLocationScreenState createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  latLng.LatLng _selectedLocation = latLng.LatLng(-6.200000, 106.816666); // Default Jakarta

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pilih Lokasi")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _selectedLocation,
          initialZoom: 15.0,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: _selectedLocation,
                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          Navigator.pop(context, _selectedLocation);
        },
      ),
    );
  }
}

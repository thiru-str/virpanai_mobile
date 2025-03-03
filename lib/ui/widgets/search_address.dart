import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:waioz/ui/map_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_config.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/page_route_utils.dart';

import '../../api/api_service.dart';
import '../../model/address_list_response.dart';
import '../../model/register_response.dart';
import '../../utility/location_util.dart';
import 'address_card.dart';
import 'common_header_app_bar.dart';

class SearchAddressPage extends StatefulWidget {

  final Function(Address selectedAddress)? onTapAddress;

  const SearchAddressPage({
    Key? key,
    this.onTapAddress,
  }) : super(key: key);

  @override
  _SearchAddressPageState createState() => _SearchAddressPageState();
}

class _SearchAddressPageState extends State<SearchAddressPage> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  List<dynamic> _predictions = [];
  bool _isSearching = false; // Track search state

  GetAddressListResponse? addressListResponse;
  bool apiLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddressListApi();
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final url = "https://maps.googleapis.com/maps/api/place/autocomplete/json";

    try {
      // Fetch approximate location without forcing GPS
      Position? position = await LocationUtil.getApproximateLocation();

      // Set default values for location
      String? locationParam;
      int radius = 30000; // 50 km default radius

      if (position != null) {
        locationParam = "${position.latitude},${position.longitude}";
      }

      final response = await _dio.get(url, queryParameters: {
        "input": query,
        "key": AppConfig.googleApiKey,
        if (locationParam != null) "location": locationParam, // Only add if available
        if (locationParam != null) "radius": radius, // Bias the search if available
      });

      if (response.statusCode == 200) {
        setState(() {
          _predictions = response.data['predictions'] ?? [];
        });
      } else {
        print("Failed to fetch autocomplete suggestions");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchPlaceDetails(String placeId, String description) async {
    final detailsUrl = "https://maps.googleapis.com/maps/api/place/details/json";

    try {
      final response = await _dio.get(detailsUrl, queryParameters: {
        "place_id": placeId,
        "key": AppConfig.googleApiKey,
      });

      if (response.statusCode == 200) {
        final location = response.data['result']['geometry']['location'];
        double latitude = location['lat'];
        double longitude = location['lng'];

        print("Selected Location: $description");
        print("Latitude: $latitude, Longitude: $longitude");

        if(mounted) {
          final result = await PageRouteUtils.push(context, MapPage(latitude: latitude, longitude: longitude,doublePop: true,));
          if (result == true) {
            getAddressListApi();
          }
        }
      } else {
        print("Failed to fetch place details");
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
  }

  void _onLocationSelected(String placeId, String description) {
    _fetchPlaceDetails(placeId, description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonHeaderAppBar(
        title: 'Your Location',
        onBackTap: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search a new address",
                hintStyle: FontUtils.circularStdStyle(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _predictions = [];
                      _isSearching = false;
                    });
                  },
                )
                    : null,
              ),
              style: FontUtils.circularStdStyle(),
              onChanged: _onSearchChanged,
            ),

            const SizedBox(height: 24.0),

            // Current Location Section (Only Show When Search is Empty)
            if (!_isSearching) ...[
              GestureDetector(
                onTap: () async {
                  if(mounted) {
                    final result = await PageRouteUtils.push(context, MapPage(doublePop: true,));
                    if (result == true) {
                      getAddressListApi();
                    }
                  }
                },
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.my_location, color: Colors.purple),
                        SizedBox(width: 8.0),
                        Text(
                          "Current location",
                          style: FontUtils.circularStdStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 32.0),
                      child: Text(
                        "Using GPS",
                        style: FontUtils.circularStdStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),

            ],

            // Search Results List
            if (_isSearching)
              Expanded(
                child: ListView.builder(
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return ListTile(
                      leading:  Icon(Icons.location_on,color: AppColors.primary,),
                      title: Text(prediction['description'],style: FontUtils.circularStdStyle(),),
                      onTap: () =>
                          _onLocationSelected(prediction['place_id'], prediction['description']),
                    );
                  },
                ),
              ),

            // Saved Location Section (Will be implemented separately)
            if (!_isSearching) ...[
              const SizedBox(height: 16.0),
              Text(
                "Saved Location",
                style: FontUtils.circularStdStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              addressListResponse?.addresses?.isNotEmpty ?? false
                  ? Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 16.0),
                  itemCount: addressListResponse?.addresses?.length ??
                      0, // Dynamic count of AddressCard widgets
                  itemBuilder: (context, index) {
                    Address? address =
                    addressListResponse?.addresses?[index];
                    return GestureDetector(
                      child: AddressCard(
                        isFromEdit: false,
                        title: address?.addressName ??
                            'Others', // If address name is null, show 'Untitled'
                        address:
                        '${address?.address1}, ${address?.city}, ${address?.province}, ${address?.postalCode}',
                        icon: address?.addressName == "Home" ? Icons.home : address?.addressName == "Work" ? Icons.work : Icons.location_pin, // Or choose another icon based on address data
                        onDelete: () {

                        },
                        onEdit: () async {
                        },
                      ),
                      onTap: (){
                        if (widget.onTapAddress != null) {
                                widget.onTapAddress!(address!);
                                Navigator.of(context).pop();
                              }
                            },
                    );
                  },
                ),
              )
               : _SavedLocationsWidget(), // Placeholder for saved locations
            ],
          ],
        ),
      ),
    );
  }

  void getAddressListApi() async {
    try {
      final ApiService apiService = ApiService();
      var response = await apiService.getAddressList(context);
      if (mounted) {
        setState(() {
          addressListResponse = response;
          apiLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiLoading = false;
        });
      }
      print(e);
    }
  }
}

// Empty Saved Locations Widget (To Be Implemented)
class _SavedLocationsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "No saved locations",
      style: FontUtils.circularStdStyle(color: Colors.grey),
    );
  }
}

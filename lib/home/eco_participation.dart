import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// ===============================
/// 1) 홈 화면에 표시되는 파란색 카드 UI
/// ===============================
class EcoParticipationSection extends StatelessWidget {
  const EcoParticipationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapView()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.eco, color: Colors.blue, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "근처 친환경 활동 장소 확인하기",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "지도로 확인하기",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// 2) 지도 페이지(MapView)
/// ===============================
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(37.5665, 126.9780);
  bool _showShopList = false;
  String? _selectedShopName;

  final List<_Shop> _shops = [
    _Shop(
      name: "아름다운가게 압구정점",
      address: "서울 강남구 압구정로 30길 15",
      position: const LatLng(37.5265, 127.0287),
    ),
    _Shop(
      name: "아름다운가게 강동점",
      address: "서울 강동구 천호대로 1095",
      position: const LatLng(37.5384, 127.1407),
    ),
    _Shop(
      name: "굿윌스토어 잠실점",
      address: "서울 송파구 올림픽로 269",
      position: const LatLng(37.5140, 127.1059),
    ),
    _Shop(
      name: "굿윌스토어 강동첨단점",
      address: "서울 강동구 상일동 522",
      position: const LatLng(37.5550, 127.1700),
    ),
    _Shop(
      name: "더피커 성수점",
      address: "서울 성동구 연무장5길 9-16",
      position: const LatLng(37.5444, 127.0565),
    ),
  ];

  final CameraPosition _initialPosition =
  const CameraPosition(target: LatLng(37.5665, 126.9780), zoom: 12);

  Future<void> _determinePosition() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      setState(() {
        _currentPosition = LatLng(p.latitude, p.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 14),
      );
    } catch (_) {}
  }

  double _distance(LatLng a, LatLng b) =>
      Geolocator.distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);

  List<_Shop> _sortedShops() {
    final list = List<_Shop>.from(_shops);
    list.sort(
          (a, b) => _distance(_currentPosition, a.position)
          .compareTo(_distance(_currentPosition, b.position)),
    );
    return list;
  }

  Set<Marker> _createMarkers() {
    return _shops.map((s) {
      final selected = s.name == _selectedShopName;

      return Marker(
        markerId: MarkerId(s.name),
        position: s.position,
        infoWindow: InfoWindow(
          title: s.name,
          snippet: s.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          selected ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      );
    }).toSet();
  }

  Future<void> _onSelect(_Shop s) async {
    setState(() => _selectedShopName = s.name);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(s.position, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedShops();

    return Scaffold(
      appBar: AppBar(
        title: const Text("친환경 참여 공간"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          /// 지도 영역
          SizedBox(
            height: 250,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _createMarkers(),
              onMapCreated: (c) => _mapController = c,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),

          const SizedBox(height: 10),

          /// 메뉴 버튼 2개
          Row(
            children: [
              Expanded(
                child: _menuButton(
                  icon: Icons.my_location,
                  text: "현재 위치",
                  onTap: _determinePosition,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _menuButton(
                  icon: Icons.store,
                  text: "주변 친환경 가게",
                  onTap: () => setState(() => _showShopList = !_showShopList),
                ),
              ),
            ],
          ),

          /// 주변 가게 목록 (가로 스크롤)
          if (_showShopList)
            SizedBox(
              height: 150,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                scrollDirection: Axis.horizontal,
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final shop = sorted[i];
                  final dist = _distance(_currentPosition, shop.position);

                  final distText = dist >= 1000
                      ? "${(dist / 1000).toStringAsFixed(1)}km"
                      : "${dist.toStringAsFixed(0)}m";

                  final selected = shop.name == _selectedShopName;

                  return GestureDetector(
                    onTap: () => _onSelect(shop),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? Colors.green.shade600 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shop.address,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                              color: selected ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            distText,
                            style: TextStyle(
                              fontSize: 12,
                              color: selected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.green, size: 20),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// 3) Shop 데이터 모델
/// ===============================
class _Shop {
  final String name;
  final String address;
  final LatLng position;

  _Shop({required this.name, required this.address, required this.position});
}

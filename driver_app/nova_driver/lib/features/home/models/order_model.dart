class Order {
  final String id;
  final String pickupAddress;
  final String destinationAddress;
  final int price;
  final String distance;
  final String estimatedTime;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;

  const Order({
    required this.id,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.price,
    required this.distance,
    required this.estimatedTime,
    this.pickupLat = 41.3112,
    this.pickupLng = 69.2784,
    this.destinationLat = 41.2995,
    this.destinationLng = 69.2401,
  });

  String get formattedPrice {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} so\'m';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'pickupAddress': pickupAddress,
        'destinationAddress': destinationAddress,
        'price': price,
        'distance': distance,
        'estimatedTime': estimatedTime,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
      };

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id']?.toString() ?? '',
      pickupAddress: map['pickupAddress']?.toString() ?? '',
      destinationAddress: map['destinationAddress']?.toString() ?? '',
      price: (map['price'] is int)
          ? map['price'] as int
          : int.tryParse(map['price']?.toString() ?? '0') ?? 0,
      distance: map['distance']?.toString() ?? '',
      estimatedTime: map['estimatedTime']?.toString() ?? '',
      pickupLat: (map['pickupLat'] as num?)?.toDouble() ?? 41.3112,
      pickupLng: (map['pickupLng'] as num?)?.toDouble() ?? 69.2784,
      destinationLat: (map['destinationLat'] as num?)?.toDouble() ?? 41.2995,
      destinationLng: (map['destinationLng'] as num?)?.toDouble() ?? 69.2401,
    );
  }
}

class EarningRecord {
  final String time;
  final String route;
  final int price;

  const EarningRecord({
    required this.time,
    required this.route,
    required this.price,
  });

  String get formattedPrice {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} so\'m';
  }
}

const List<Order> demoOrders = [
  Order(
    id: '001',
    pickupAddress: 'Amir Temur ko\'chasi, 15',
    destinationAddress: 'Tashkent City, Mall',
    price: 12500,
    distance: '4.2 km',
    estimatedTime: '15 daqiqa',
    pickupLat: 41.3112,
    pickupLng: 69.2784,
    destinationLat: 41.3090,
    destinationLng: 69.2820,
  ),
  Order(
    id: '002',
    pickupAddress: 'Mustaqillik maydoni',
    destinationAddress: 'Olazor bozori',
    price: 8000,
    distance: '2.8 km',
    estimatedTime: '10 daqiqa',
    pickupLat: 41.3145,
    pickupLng: 69.2785,
    destinationLat: 41.3020,
    destinationLng: 69.2650,
  ),
  Order(
    id: '003',
    pickupAddress: 'Chilonzor-9, 45-uy',
    destinationAddress: 'Toshkent xalqaro aeroporti',
    price: 45000,
    distance: '32.5 km',
    estimatedTime: '40 daqiqa',
    pickupLat: 41.2800,
    pickupLng: 69.2200,
    destinationLat: 41.2610,
    destinationLng: 69.2810,
  ),
];

const List<EarningRecord> demoEarnings = [
  EarningRecord(time: '09:15', route: 'Chilonzor → Markaziy bozor', price: 12500),
  EarningRecord(time: '10:30', route: 'Sergeli → Amir Temur ko\'chasi', price: 8000),
  EarningRecord(time: '12:00', route: 'Mirzo Ulug\'bek → Tashkent City', price: 15000),
  EarningRecord(time: '14:15', route: 'Yunusobod → Olmazor', price: 9500),
  EarningRecord(time: '16:45', route: 'Shayxontohur → Chilonzor', price: 11000),
  EarningRecord(time: '18:00', route: 'Beruniy → Aeroport', price: 45000),
];

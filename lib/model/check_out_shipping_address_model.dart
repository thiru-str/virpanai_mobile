class ShippingAddress {
  dynamic firstName;
  dynamic lastName;
  dynamic company;
  dynamic address1;
  dynamic address2;
  dynamic city;
  dynamic postalCode;
  String? countryCode;
  dynamic province;
  dynamic phone;
  String? latitude;
  String? longitude;

  ShippingAddress({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.postalCode,
    this.countryCode,
    this.province,
    this.phone,
    this.latitude,
    this.longitude,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
    firstName: json["first_name"],
    lastName: json["last_name"],
    company: json["company"],
    address1: json["address_1"],
    address2: json["address_2"],
    city: json["city"],
    postalCode: json["postal_code"],
    countryCode: json["country_code"],
    province: json["province"],
    phone: json["phone"],
    latitude: json["metadata"]?["latitude"],
    longitude: json["metadata"]?["longitude"],
  );

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      "first_name": firstName,
      "last_name": lastName,
      "company": company,
      "address_1": address1,
      "address_2": address2,
      "city": city,
      "postal_code": postalCode,
      "country_code": countryCode,
      "province": province,
      "phone": phone,
    };
    if (latitude != null && longitude != null) {
      json["metadata"] = {"latitude": latitude, "longitude": longitude};
    }
    return json;
  }
}
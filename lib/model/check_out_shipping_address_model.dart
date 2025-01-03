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
  );

  Map<String, dynamic> toJson() => {
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
}
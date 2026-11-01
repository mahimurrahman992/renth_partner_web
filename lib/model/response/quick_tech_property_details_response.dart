
class QuicktechPropertyDetailsResponse {
    String? message;
    Property? property;

    QuicktechPropertyDetailsResponse({this.message, this.property});

    QuicktechPropertyDetailsResponse.fromJson(Map<String, dynamic> json) {
        message = json["message"];
        property = json["property"] == null ? null : Property.fromJson(json["property"]);
    }

    static List<QuicktechPropertyDetailsResponse> fromList(List<Map<String, dynamic>> list) {
        return list.map(QuicktechPropertyDetailsResponse.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["message"] = message;
        if(property != null) {
            data["property"] = property?.toJson();
        }
        return data;
    }
}

class Property {
    int? id;
    String? overview;
    String? nearBy;
    String? additionalDetails;
    String? title;
    dynamic aboutProperty;
    String? startingPricePerNight;
    dynamic totalPrice;
    int? bookingStatus;
    int? countryId;
    dynamic divisionId;
    int? districtId;
    dynamic upazillaId;
    dynamic gender;
    dynamic residentType;
    String? address;
    dynamic mapEmbedCode;
    dynamic ownerName;
    dynamic aboutOwner;
    int? userId;
    int? status;
    int? propertyCategoryId;
    String? createdAt;
    String? updatedAt;
    int? reviewsCount;
    dynamic reviewsAvgRating;
    bool? isWishlisted;
    List<UniqueFacilities>? uniqueFacilities;
    PropertyCategory? propertyCategory;
    Country? country;
    District? district;
    List<MultiImages>? multiImages;
    List<PropertyRooms>? propertyRooms;
    Manager? manager;

    Property({this.id, this.overview, this.nearBy, this.additionalDetails, this.title, this.aboutProperty, this.startingPricePerNight, this.totalPrice, this.bookingStatus, this.countryId, this.divisionId, this.districtId, this.upazillaId, this.gender, this.residentType, this.address, this.mapEmbedCode, this.ownerName, this.aboutOwner, this.userId, this.status, this.propertyCategoryId, this.createdAt, this.updatedAt, this.reviewsCount, this.reviewsAvgRating, this.isWishlisted, this.uniqueFacilities, this.propertyCategory, this.country, this.district, this.multiImages, this.propertyRooms, this.manager});

    Property.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        overview = json["overview"];
        nearBy = json["near_by"];
        additionalDetails = json["additional_details"];
        title = json["title"];
        aboutProperty = json["about_property"];
        startingPricePerNight = json["starting_price_per_night"];
        totalPrice = json["total_price"];
        bookingStatus = json["booking_status"];
        countryId = json["country_id"];
        divisionId = json["division_id"];
        districtId = json["district_id"];
        upazillaId = json["upazilla_id"];
        gender = json["gender"];
        residentType = json["resident_type"];
        address = json["address"];
        mapEmbedCode = json["map_embed_code"];
        ownerName = json["owner_name"];
        aboutOwner = json["about_owner"];
        userId = json["user_id"];
        status = json["status"];
        propertyCategoryId = json["property_category_id"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
        reviewsCount = json["reviews_count"];
        reviewsAvgRating = json["reviews_avg_rating"];
        isWishlisted = json["is_wishlisted"];
        uniqueFacilities = json["unique_facilities"] == null ? null : (json["unique_facilities"] as List).map((e) => UniqueFacilities.fromJson(e)).toList();
        propertyCategory = json["property_category"] == null ? null : PropertyCategory.fromJson(json["property_category"]);
        country = json["country"] == null ? null : Country.fromJson(json["country"]);
        district = json["district"] == null ? null : District.fromJson(json["district"]);
        multiImages = json["multi_images"] == null ? null : (json["multi_images"] as List).map((e) => MultiImages.fromJson(e)).toList();
        propertyRooms = json["property_rooms"] == null ? null : (json["property_rooms"] as List).map((e) => PropertyRooms.fromJson(e)).toList();
        manager = json["manager"] == null ? null : Manager.fromJson(json["manager"]);
    }

    static List<Property> fromList(List<Map<String, dynamic>> list) {
        return list.map(Property.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["overview"] = overview;
        data["near_by"] = nearBy;
        data["additional_details"] = additionalDetails;
        data["title"] = title;
        data["about_property"] = aboutProperty;
        data["starting_price_per_night"] = startingPricePerNight;
        data["total_price"] = totalPrice;
        data["booking_status"] = bookingStatus;
        data["country_id"] = countryId;
        data["division_id"] = divisionId;
        data["district_id"] = districtId;
        data["upazilla_id"] = upazillaId;
        data["gender"] = gender;
        data["resident_type"] = residentType;
        data["address"] = address;
        data["map_embed_code"] = mapEmbedCode;
        data["owner_name"] = ownerName;
        data["about_owner"] = aboutOwner;
        data["user_id"] = userId;
        data["status"] = status;
        data["property_category_id"] = propertyCategoryId;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        data["reviews_count"] = reviewsCount;
        data["reviews_avg_rating"] = reviewsAvgRating;
        data["is_wishlisted"] = isWishlisted;
        if(uniqueFacilities != null) {
            data["unique_facilities"] = uniqueFacilities?.map((e) => e.toJson()).toList();
        }
        if(propertyCategory != null) {
            data["property_category"] = propertyCategory?.toJson();
        }
        if(country != null) {
            data["country"] = country?.toJson();
        }
        if(district != null) {
            data["district"] = district?.toJson();
        }
        if(multiImages != null) {
            data["multi_images"] = multiImages?.map((e) => e.toJson()).toList();
        }
        if(propertyRooms != null) {
            data["property_rooms"] = propertyRooms?.map((e) => e.toJson()).toList();
        }
        if(manager != null) {
            data["manager"] = manager?.toJson();
        }
        return data;
    }
}

class Manager {
    int? id;
    String? wallet;
    int? firstRoom;
    dynamic country;
    String? name;
    String? slug;
    dynamic email;
    String? phone;
    dynamic passresetToken;
    String? profilePhoto;
    dynamic birthday;
    dynamic gender;
    dynamic address;
    dynamic emailVerifiedAt;
    dynamic profileFor;
    int? activeStatus;
    String? role;
    String? profileVisibility;
    String? interestRequestAccess;
    int? status;
    dynamic type;
    int? propertyCategoryId;
    String? createdAt;
    String? updatedAt;

    Manager({this.id, this.wallet, this.firstRoom, this.country, this.name, this.slug, this.email, this.phone, this.passresetToken, this.profilePhoto, this.birthday, this.gender, this.address, this.emailVerifiedAt, this.profileFor, this.activeStatus, this.role, this.profileVisibility, this.interestRequestAccess, this.status, this.type, this.propertyCategoryId, this.createdAt, this.updatedAt});

    Manager.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        wallet = json["wallet"];
        firstRoom = json["first_room"];
        country = json["country"];
        name = json["name"];
        slug = json["slug"];
        email = json["email"];
        phone = json["phone"];
        passresetToken = json["passresetToken"];
        profilePhoto = json["profile_photo"];
        birthday = json["birthday"];
        gender = json["gender"];
        address = json["address"];
        emailVerifiedAt = json["email_verified_at"];
        profileFor = json["profile_for"];
        activeStatus = json["active_status"];
        role = json["role"];
        profileVisibility = json["profile_visibility"];
        interestRequestAccess = json["interest_request_access"];
        status = json["status"];
        type = json["type"];
        propertyCategoryId = json["property_category_id"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
    }

    static List<Manager> fromList(List<Map<String, dynamic>> list) {
        return list.map(Manager.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["wallet"] = wallet;
        data["first_room"] = firstRoom;
        data["country"] = country;
        data["name"] = name;
        data["slug"] = slug;
        data["email"] = email;
        data["phone"] = phone;
        data["passresetToken"] = passresetToken;
        data["profile_photo"] = profilePhoto;
        data["birthday"] = birthday;
        data["gender"] = gender;
        data["address"] = address;
        data["email_verified_at"] = emailVerifiedAt;
        data["profile_for"] = profileFor;
        data["active_status"] = activeStatus;
        data["role"] = role;
        data["profile_visibility"] = profileVisibility;
        data["interest_request_access"] = interestRequestAccess;
        data["status"] = status;
        data["type"] = type;
        data["property_category_id"] = propertyCategoryId;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        return data;
    }
}

class PropertyRooms {
    int? id;
    String? discountPricePerNight;
    String? extraMattressPricePerNight;
    String? extraPricePerAdult;
    String? extraPricePerChildBed;
    int? vatPercentage;
    String? serviceCharge;
    int? managerId;
    int? propertyId;
    int? roomTypeId;
    int? bedTypeId;
    String? roomName;
    String? roomPricePerNight;
    int? capacityOfAdults;
    int? capacityOfChildren;
    String? roomSize;
    String? roomDescription;
    int? numberOfRoom;
    String? video;
    int? status;
    dynamic checkOut;
    String? createdAt;
    String? updatedAt;
    List<Facilities>? facilities;
    RoomType? roomType;
    List<RoomImages>? roomImages;

    PropertyRooms({this.id, this.discountPricePerNight, this.extraMattressPricePerNight, this.extraPricePerAdult, this.extraPricePerChildBed, this.vatPercentage, this.serviceCharge, this.managerId, this.propertyId, this.roomTypeId, this.bedTypeId, this.roomName, this.roomPricePerNight, this.capacityOfAdults, this.capacityOfChildren, this.roomSize, this.roomDescription, this.numberOfRoom, this.video, this.status, this.checkOut, this.createdAt, this.updatedAt, this.facilities, this.roomType, this.roomImages});

    PropertyRooms.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        discountPricePerNight = json["discount_price_per_night"];
        extraMattressPricePerNight = json["extra_mattress_price_per_night"];
        extraPricePerAdult = json["extra_price_per_adult"];
        extraPricePerChildBed = json["extra_price_per_child_bed"];
        vatPercentage = json["vat_percentage"];
        serviceCharge = json["service_charge"];
        managerId = json["manager_id"];
        propertyId = json["property_id"];
        roomTypeId = json["room_type_id"];
        bedTypeId = json["bed_type_id"];
        roomName = json["room_name"];
        roomPricePerNight = json["room_price_per_night"];
        capacityOfAdults = json["capacity_of_adults"];
        capacityOfChildren = json["capacity_of_children"];
        roomSize = json["room_size"];
        roomDescription = json["room_description"];
        numberOfRoom = json["number_of_room"];
        video = json["video"];
        status = json["status"];
        checkOut = json["check_out"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
        facilities = json["facilities"] == null ? null : (json["facilities"] as List).map((e) => Facilities.fromJson(e)).toList();
        roomType = json["room_type"] == null ? null : RoomType.fromJson(json["room_type"]);
        roomImages = json["room_images"] == null ? null : (json["room_images"] as List).map((e) => RoomImages.fromJson(e)).toList();
    }

    static List<PropertyRooms> fromList(List<Map<String, dynamic>> list) {
        return list.map(PropertyRooms.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["discount_price_per_night"] = discountPricePerNight;
        data["extra_mattress_price_per_night"] = extraMattressPricePerNight;
        data["extra_price_per_adult"] = extraPricePerAdult;
        data["extra_price_per_child_bed"] = extraPricePerChildBed;
        data["vat_percentage"] = vatPercentage;
        data["service_charge"] = serviceCharge;
        data["manager_id"] = managerId;
        data["property_id"] = propertyId;
        data["room_type_id"] = roomTypeId;
        data["bed_type_id"] = bedTypeId;
        data["room_name"] = roomName;
        data["room_price_per_night"] = roomPricePerNight;
        data["capacity_of_adults"] = capacityOfAdults;
        data["capacity_of_children"] = capacityOfChildren;
        data["room_size"] = roomSize;
        data["room_description"] = roomDescription;
        data["number_of_room"] = numberOfRoom;
        data["video"] = video;
        data["status"] = status;
        data["check_out"] = checkOut;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        if(facilities != null) {
            data["facilities"] = facilities?.map((e) => e.toJson()).toList();
        }
        if(roomType != null) {
            data["room_type"] = roomType?.toJson();
        }
        if(roomImages != null) {
            data["room_images"] = roomImages?.map((e) => e.toJson()).toList();
        }
        return data;
    }
}

class RoomImages {
    int? id;
    int? propertyRoomId;
    String? photoName;
    String? createdAt;
    String? updatedAt;

    RoomImages({this.id, this.propertyRoomId, this.photoName, this.createdAt, this.updatedAt});

    RoomImages.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        propertyRoomId = json["property_room_id"];
        photoName = json["photo_name"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
    }

    static List<RoomImages> fromList(List<Map<String, dynamic>> list) {
        return list.map(RoomImages.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["property_room_id"] = propertyRoomId;
        data["photo_name"] = photoName;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        return data;
    }
}

class RoomType {
    int? id;
    String? name;
    int? totalRoom;
    int? bookedRoom;
    int? availableRoom;
    String? status;
    String? createdAt;
    String? updatedAt;

    RoomType({this.id, this.name, this.totalRoom, this.bookedRoom, this.availableRoom, this.status, this.createdAt, this.updatedAt});

    RoomType.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        name = json["name"];
        totalRoom = json["total_room"];
        bookedRoom = json["booked_room"];
        availableRoom = json["available_room"];
        status = json["status"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
    }

    static List<RoomType> fromList(List<Map<String, dynamic>> list) {
        return list.map(RoomType.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["name"] = name;
        data["total_room"] = totalRoom;
        data["booked_room"] = bookedRoom;
        data["available_room"] = availableRoom;
        data["status"] = status;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        return data;
    }
}

class Facilities {
    int? id;
    String? name;
    String? iconClass;
    String? facilityPhoto;
    String? createdAt;
    String? updatedAt;
    Pivot1? pivot;

    Facilities({this.id, this.name, this.iconClass, this.facilityPhoto, this.createdAt, this.updatedAt, this.pivot});

    Facilities.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        name = json["name"];
        iconClass = json["icon_class"];
        facilityPhoto = json["facility_photo"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
        pivot = json["pivot"] == null ? null : Pivot1.fromJson(json["pivot"]);
    }

    static List<Facilities> fromList(List<Map<String, dynamic>> list) {
        return list.map(Facilities.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["name"] = name;
        data["icon_class"] = iconClass;
        data["facility_photo"] = facilityPhoto;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        if(pivot != null) {
            data["pivot"] = pivot?.toJson();
        }
        return data;
    }
}

class Pivot1 {
    int? propertyRoomId;
    int? facilityId;

    Pivot1({this.propertyRoomId, this.facilityId});

    Pivot1.fromJson(Map<String, dynamic> json) {
        propertyRoomId = json["property_room_id"];
        facilityId = json["facility_id"];
    }

    static List<Pivot1> fromList(List<Map<String, dynamic>> list) {
        return list.map(Pivot1.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["property_room_id"] = propertyRoomId;
        data["facility_id"] = facilityId;
        return data;
    }
}

class MultiImages {
    int? id;
    int? propertyId;
    String? photoName;
    String? createdAt;
    String? updatedAt;

    MultiImages({this.id, this.propertyId, this.photoName, this.createdAt, this.updatedAt});

    MultiImages.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        propertyId = json["property_id"];
        photoName = json["photo_name"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
    }

    static List<MultiImages> fromList(List<Map<String, dynamic>> list) {
        return list.map(MultiImages.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["property_id"] = propertyId;
        data["photo_name"] = photoName;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        return data;
    }
}

class District {
    int? id;
    int? countryId;
    int? divisionId;
    String? name;
    String? bnName;
    String? lat;
    String? lon;
    String? url;

    District({this.id, this.countryId, this.divisionId, this.name, this.bnName, this.lat, this.lon, this.url});

    District.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        countryId = json["country_id"];
        divisionId = json["division_id"];
        name = json["name"];
        bnName = json["bn_name"];
        lat = json["lat"];
        lon = json["lon"];
        url = json["url"];
    }

    static List<District> fromList(List<Map<String, dynamic>> list) {
        return list.map(District.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["country_id"] = countryId;
        data["division_id"] = divisionId;
        data["name"] = name;
        data["bn_name"] = bnName;
        data["lat"] = lat;
        data["lon"] = lon;
        data["url"] = url;
        return data;
    }
}

class Country {
    int? id;
    String? name;
    String? shortName;
    String? code;
    int? status;
    String? createdAt;
    String? updatedAt;

    Country({this.id, this.name, this.shortName, this.code, this.status, this.createdAt, this.updatedAt});

    Country.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        name = json["name"];
        shortName = json["short_name"];
        code = json["code"];
        status = json["status"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
    }

    static List<Country> fromList(List<Map<String, dynamic>> list) {
        return list.map(Country.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["name"] = name;
        data["short_name"] = shortName;
        data["code"] = code;
        data["status"] = status;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        return data;
    }
}

class PropertyCategory {
    int? id;
    String? name;
    String? categoryPhoto;
    int? platformFee;
    String? createdAt;
    String? updatedAt;

    PropertyCategory({this.id, this.name, this.categoryPhoto, this.platformFee, this.createdAt, this.updatedAt});

    PropertyCategory.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        name = json["name"];
        categoryPhoto = json["category_photo"];
        platformFee = json["platform_fee"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
    }

    static List<PropertyCategory> fromList(List<Map<String, dynamic>> list) {
        return list.map(PropertyCategory.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["name"] = name;
        data["category_photo"] = categoryPhoto;
        data["platform_fee"] = platformFee;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        return data;
    }
}

class UniqueFacilities {
    int? id;
    String? name;
    String? iconClass;
    String? facilityPhoto;
    String? createdAt;
    String? updatedAt;
    Pivot? pivot;

    UniqueFacilities({this.id, this.name, this.iconClass, this.facilityPhoto, this.createdAt, this.updatedAt, this.pivot});

    UniqueFacilities.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        name = json["name"];
        iconClass = json["icon_class"];
        facilityPhoto = json["facility_photo"];
        createdAt = json["created_at"];
        updatedAt = json["updated_at"];
        pivot = json["pivot"] == null ? null : Pivot.fromJson(json["pivot"]);
    }

    static List<UniqueFacilities> fromList(List<Map<String, dynamic>> list) {
        return list.map(UniqueFacilities.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["name"] = name;
        data["icon_class"] = iconClass;
        data["facility_photo"] = facilityPhoto;
        data["created_at"] = createdAt;
        data["updated_at"] = updatedAt;
        if(pivot != null) {
            data["pivot"] = pivot?.toJson();
        }
        return data;
    }
}

class Pivot {
    int? propertyRoomId;
    int? facilityId;

    Pivot({this.propertyRoomId, this.facilityId});

    Pivot.fromJson(Map<String, dynamic> json) {
        propertyRoomId = json["property_room_id"];
        facilityId = json["facility_id"];
    }

    static List<Pivot> fromList(List<Map<String, dynamic>> list) {
        return list.map(Pivot.fromJson).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["property_room_id"] = propertyRoomId;
        data["facility_id"] = facilityId;
        return data;
    }
}

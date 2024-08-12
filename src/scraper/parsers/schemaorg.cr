require "json"

module Parsers::SchemaOrg
  class Thing
    include JSON::Serializable

    use_json_discriminator "@type", {Product: Product}

    @[JSON::Field(key: "@context")]
    property context : String?

    @[JSON::Field(key: "@type")]
    property type : String?
  end

  class Graph < Thing
    @[JSON::Field(key: "@graph")]
    property graph : Array(Product)
  end

  class Product < Thing
    include JSON::Serializable

    property name : String?
    property description : String?
    property sku : String | Int64 | Nil
    property mpn : String?
    property brand : Brand? = nil
    property manufacturer : Organization? = nil
    property offers : Array(Offer)? = nil
    property aggregate_rating : AggregateRating? = nil
    property review : Array(Review)? = nil
    property image : (String | Array(String))? = nil
    property url : String?
    property product_id : String?
    property category : Array(String)? = nil
    property release_date : String?
    property color : String?
    property material : String?
    property weight : QuantitativeValue? = nil
    property height : QuantitativeValue? = nil
    property width : QuantitativeValue? = nil
    property depth : QuantitativeValue? = nil
    property gtin8 : String?
    property gtin12 : String?
    property gtin13 : String?
    property gtin14 : String?
    property additional_type : String?
    property alternate_name : String?
    property same_as : String?
    property main_entity_of_page : String?
    property additional_property : Array(PropertyValue)? = nil
  end

  class Brand < Thing
    include JSON::Serializable

    property name : String?
  end

  class Organization < Thing
    include JSON::Serializable

    property name : String?
  end

  class Person < Thing
    include JSON::Serializable

    property name : String?
  end

  class Offer < Thing
    include JSON::Serializable

    property price : String | Float64?
    property price_currency : String?
    property availability : String?
    property url : String?
  end

  class AggregateRating < Thing
    include JSON::Serializable

    property rating_value : Float64?
    property review_count : Int32?
  end

  class Review < Thing
    include JSON::Serializable

    property author : Person | Organization? = nil
    property review_body : String?
    property review_rating : Rating? = nil
  end

  class Rating < Thing
    include JSON::Serializable

    property rating_value : Float64?
  end

  class QuantitativeValue < Thing
    include JSON::Serializable

    property value : Float64?
    property unit_code : String?
  end

  class PropertyValue < Thing
    include JSON::Serializable

    property name : String?
    property value : String?
  end
end

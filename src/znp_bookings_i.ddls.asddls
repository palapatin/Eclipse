@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Naren Bookings entity'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZNP_BOOKINGS_I 
as select from znp_bookings
composition [0..*] of ZNP_SUPPLEMENT_I as _supplement
association to parent ZNP_TRAVEL_I as _Travel 
on $projection.TravelUuid = _Travel.TravelUuid
{ 
    key booking_uuid      as BookingUuid,
    parent_uuid           as TravelUuid,
    booking_id            as BookingId,
    booking_date          as BookingDate,
    customer_id           as CustomerId,
    carrier_id            as CarrierId,
    connection_id         as ConnectionId,
    flight_date           as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    flight_price          as FlightPrice,
    currency_code         as CurrencyCode,
    booking_status        as BookingStatus,
    @Semantics.systemDateTime.localInstanceLastChangedAt
    local_last_changed_at as LocalLastChangedAt,  
    _Travel,
    _supplement
}

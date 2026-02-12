@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bookings consumption'
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity ZNP_BOOKINGS_C as projection on ZNP_BOOKINGS_I
{
    key BookingUuid,
    TravelUuid,
    BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LocalLastChangedAt,
    /* Associations */
     _Travel: redirected to parent ZNP_TRAVEL_C,
    _supplement: redirected to composition child ZNP_SUPPLEMENT_C
   
}
